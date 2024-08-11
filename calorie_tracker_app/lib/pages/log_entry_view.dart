import "package:calorie_tracker_app/app_state.dart";
import "package:calorie_tracker_app/models/food_product.dart";
import "package:calorie_tracker_app/models/log.dart";
import "package:flutter/material.dart";
import 'package:http/http.dart' as http;
import 'dart:convert';

class LogEntryView extends StatefulWidget {
  const LogEntryView({required this.appState, this.log, super.key});

  final Log? log;
  final AppState appState;
  @override
  State<LogEntryView> createState() => _LogEntryViewState();
}


class _LogEntryViewState extends State<LogEntryView> {
  bool _isNewLog = true; //Used to identify if this instance is for a new Log or an existing one
  late bool _isLoggedIn; //Used to identify if a user is signed in
  late String? _foodId; //Barcode ID
  late FoodProduct? singleProduct;

  // Search state variables
  String _searchQuery = '';
  List<FoodProduct> _searchResults = [];
  String _searchMessage = '';
  bool _isLoading = false;
  int? _expandedTile; //Used to control which ListTile is expanded

  String? selectedEatTime;

  @override
  void initState() {
    super.initState();
    _isLoggedIn = widget.appState.loggedIn; //Checks to see if the User is signed in, update Bool as so
    //Check to see if a Log was provided when navigating to this page
    if (widget.log != null) { 
      //A Log was provided so copy the contents of the Log to this page
      _isNewLog = false; //Update the Bool used to identify if a Log was passed
      _foodId = widget.log!.foodId; //Transfer the barcode Id
      print('Console Print: Existing log entry');
      _searchFood(_foodId!, true); //Search by barcode
    } else {
      //A Log was not provided so set everything to defaults
      //Can add more handling in the future
    }
  }

  Future<void> _searchFood(String query, bool isBarCode) async {
    // API documentation: https://openfoodfacts.github.io/openfoodfacts-server/api/
    //                   https://openfoodfacts.github.io/openfoodfacts-server/api/tutorial-off-api/
    setState(() {
      _isLoading = true;
    });
    print('Console Print: Searching with query $query, Barcode: $isBarCode');
    late http.Response response;

    if (isBarCode == false) {
      response = await http.get(
        Uri.parse('https://world.openfoodfacts.org/cgi/search.pl?search_terms=$query&search_simple=1&action=process&json=1&sort_by=unique_scans_n'),
      );
    } else if (isBarCode == true) {
      response = await http.get(
        Uri.parse('https://world.openfoodfacts.org/api/v0/product/$query.json'),
      );
    }

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      
      final List<dynamic> products;
      if (isBarCode) {
        //Barcode search should only return a single product, use that product
        products = [data['product']];
      } else {
        //Is not Barcode search, will have a list
        products = data['products'] ?? [];
      }

      final List<FoodProduct> searchResults = products.map<FoodProduct>((product) {
        final nutriments = product['nutriments'] ?? {};
        final String? originalServingSize = product['serving_size'];
        final String productName = product['product_name'] ?? 'Unknown product';
        final String? quantity = product['quantity'] ?? '';
        final String? barCodeId = product['code'] ?? 'Unknown barcode';
        final String imageUrl = product.containsKey('image_url') && product['image_url'].isNotEmpty
          ? product['image_url']
          : '';

        int? calories;
        String? servingSize = originalServingSize;

        if (nutriments.containsKey('energy-kcal_serving')) {
          calories = nutriments['energy-kcal_serving'].toInt();
        } else if (nutriments.containsKey('energy-kcal_100g')) {
          //Resort to 100g/100ml stats if no cal per serving is found
          calories = nutriments['energy-kcal_100g'].toInt();
          servingSize = '100g/100ml';
        } else {
          calories = null;
        }

        return FoodProduct(
          name: productName,
          calories: calories,
          servingSize: servingSize,
          quantity: quantity,
          foodId: barCodeId,
          imageUrl: imageUrl
        );
      }).toList();

      setState(() {
        _searchResults = searchResults;
        _searchMessage = 'Search found ${_searchResults.length} product(s)';
        _isLoading = false;
        if (isBarCode == true) {
          singleProduct = _searchResults.isNotEmpty ? _searchResults.first : null;
        }
        print('Console Print: Product search success ${_searchResults.length} result(s) found. Barcode: $isBarCode');
      });
    } else if (response.statusCode == 500 || response.statusCode == 502 || response.statusCode == 503) {
      setState(() {
        _searchMessage = 'Error code: ${response.statusCode}, OpenFoodFacts server is down. Please wait a while';
        print('Console Print: Product search error ${response.statusCode}, OpenFoodFacts server is down.');
        _isLoading = false;
      });
    } else {
      setState(() {
        _searchMessage = 'Error fetching search results, code: ${response.statusCode}';
        print('Console Print: Product search error ${response.statusCode}');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoggedIn) { //If there is a user signed in, show the log page
      return Scaffold(
        backgroundColor: const Color.fromARGB(255, 17, 17, 17),
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, size: 30, color: Color.fromARGB(255, 255, 196, 0)),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          backgroundColor: const Color.fromARGB(255, 17, 17, 17),
          //This is the Title of the page
          title: _isNewLog
            ? const Text("Add new log entry", 
                style: TextStyle(
                  color: Color.fromARGB(255, 255, 228, 141),
                  shadows: <Shadow>[
                    Shadow(
                      blurRadius: 2,
                      color: Color.fromARGB(255, 255, 228, 141),
                    ),
                  ]
                ),
              )
            : Text('Viewing ${widget.log!.name}',
              style: const TextStyle(
                color: Color.fromARGB(255, 255, 228, 141),
                shadows: <Shadow>[
                  Shadow(
                    blurRadius: 2,
                    color: Color.fromARGB(255, 255, 228, 141),
                  ),
                ]
              ),
            )
        ),

        body: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              if (_isNewLog) 
                // THIS IS A NEW LOG, SHOW A SEARCH TO THE OPENFOODFACT'S DATABASE
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: TextField(
                        style: const TextStyle(color: Colors.white),
                        cursorColor: Colors.white,
                        decoration: const InputDecoration(
                          hintText: 'Search here',
                          hintStyle: TextStyle(color: Colors.grey),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color.fromARGB(255, 255, 228, 141), width: 2.0),
                          ),
                        ),
                        onChanged: (query) {
                          setState(() {
                            _searchQuery = query;
                          });
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.search, color: Color.fromARGB(255, 255, 228, 141)),
                      onPressed: () {
                        _searchFood(_searchQuery, false);
                      },
                    ),
                  ],
                ),
              const SizedBox(height: 40), //Padding
              if (_isNewLog) 
                if (_isLoading)
                  const CircularProgressIndicator()
                else
                  Expanded(
                    child: _searchResults.isEmpty 
                      ? const Center(child: Text('No results found', style: TextStyle(color: Colors.white))) 
                      // BUILDING A LIST TO DISPLAY SEARCH RESULTS
                      : _buildList(_searchResults)
                    ),
              if (!_isNewLog) 
              // THIS IS A NOT NEW LOG, SHOW CONTENT OF THE LOG ITEM
                if (_isLoading)
                  const CircularProgressIndicator()
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (singleProduct!.imageUrl!.isNotEmpty)
                      SizedBox(
                        width: 400, // Set the desired width
                        height: 400, // Set the desired height
                        child: Image.network(
                          singleProduct?.imageUrl ?? '',
                          fit: BoxFit.contain, // Scales the image to cover the box
                        ),
                      ),
                      if (singleProduct!.imageUrl!.isNotEmpty)
                        const SizedBox(height: 40), //Padding
                      Text('Serving Size: ${singleProduct?.calories.toString() ?? 'Unknown'} cals per ${singleProduct?.servingSize ?? 'Unknown'}.', 
                        style: const TextStyle(color: Colors.white)
                      ),
                      Text("You logged: ${widget.log!.calories.toString()} calories from ${widget.log!.servingMeasured.toString()}${widget.log!.servingUnit}", style: const TextStyle(color: Colors.white)),
                      Text("Barcode ID: $_foodId", style: const TextStyle(color: Colors.white)),
                      
                    ],
                  ),
              //CLEAN THIS UP
              if (_isNewLog) 
                if (!_isLoading)
                const SizedBox(height: 20), //Padding
              if (_isNewLog) 
                if (!_isLoading)
                  Text(_searchMessage, style: const TextStyle(color: Colors.white)),
              const SizedBox(height: 60), //Padding
              const Text('Data provided by (c) Open Food Facts contributors',
                style: TextStyle(
                    color: Colors.white
                  ),
                ),
              const Text('https://world.openfoodfacts.org/',
                style: TextStyle(
                    color: Colors.white
                  ),
                ),
            ]
          ),
        ),
      );
    } else { //If there is no user signed in, show a Page asking the user to Sign in
      return Scaffold(
        appBar: AppBar(
          title: const Text('Calorie Tracker App'),
        ),
        body: ListView(
          children: [
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/sign-in');
              },
              child: const Text('Sign In'),
            ),
          ],
        ),
      );
    }
  }

  /// Builds a list of Log widgets.
  /// Each list item is a GestureDetector that when tapped, expands the object to show the full food entry Log description.
  /// An AnimatedSize widget is used to animate the expansion and contraction of the list items.
  /// Each list item includes a ListTile displaying the food log entry's name and calories, an icon
  /// indicating its expansion state, and a PopupMenuButton with options to edit or delete the log.
  ///
  /// Arguments:
  /// - logs: A List<Log> containing the logs to be displayed.
  Widget _buildList(List<FoodProduct> query) {
    return ListView.builder(
      itemCount: query.length,
      itemBuilder: (context, index) {
        final FoodProduct product = query[index];
        final bool isExpanded = _expandedTile == index;

        return GestureDetector(
          onTap: () {
            setState(() {
              _expandedTile = isExpanded ? null : index; //Toggle expansion state
              Feedback.forTap(context);
              //Handle
            });
          },
          child: AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutQuint,
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isExpanded ? const Color.fromARGB(255, 255, 228, 141) : Colors.grey,
                    width: 2.0,
                  ),
                ),
              ),
              child: Column(
                children: [
                  ListTile(
                    title: Text(
                      '${product.name} ${product.quantity!.isNotEmpty ? '- ${product.quantity}' : ''}', 
                      style: const TextStyle(
                        color: Color.fromARGB(255, 255, 242, 199),
                        shadows: <Shadow>[
                          Shadow(
                            blurRadius: 2,
                            color: Color.fromARGB(255, 255, 228, 141),
                          ),
                        ],
                      ),
                    ),
                    subtitle: Text('${product.calories?.toString() ?? 'Unknown'} cals per ${product.servingSize ?? 'Unknown'}. Product ID ${product.foodId}', 
                      maxLines: isExpanded ? null : 1, 
                      overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color.fromARGB(255, 190, 190, 190),
                      ),
                    ),
                    leading: isExpanded ? 
                    const Icon(Icons.keyboard_arrow_up_rounded, 
                      color: Color.fromARGB(255, 255, 196, 0),
                      shadows: <Shadow>[
                        Shadow(
                          blurRadius: 5,
                          color: Color.fromARGB(255, 255, 196, 0),
                        ),
                      ],
                    )
                    : const Icon(Icons.keyboard_arrow_down_rounded, 
                      color: Color.fromARGB(255, 255, 196, 0),
                      shadows: <Shadow>[
                        Shadow(
                          blurRadius: 5,
                          color: Color.fromARGB(255, 255, 196, 0),
                        ),
                      ],
                    ),
                    trailing: PopupMenuButton(
                      iconColor: const Color.fromARGB(255, 255, 196, 0),
                      onSelected: (value) {
                        switch (value) {
                          case 'add':
                            print('Console Print: Add to log');
                            _showAddPopup(context, product); // Show dialog to get additional input
                            break;
                            case 'open':
                            print('Console Print: Open search result');
                            break;
                        }
                      },
                      itemBuilder: (BuildContext bc) {
                        return const [
                          PopupMenuItem(
                            value: 'add',
                            child: Text("Add to Log"),
                          ),
                          PopupMenuItem(
                            value: 'open',
                            child: Text("View Product"),
                          ),
                        ];
                      },
                    ),
                  )
                ],
              ),
            )
          )
        );
      },
    );
  }



  Future<void> _showAddPopup(BuildContext context, FoodProduct product) async {
    final List<String> eatTimeOptions = ['Breakfast', 'Lunch', 'Dinner', 'Snacks'];
    final TextEditingController servingController = TextEditingController();
    String? errorMessage;
    String? servingSizeText;
    double? servingSize;

    if (product.servingSize == '100g/100ml') {
      servingSizeText = 'g/ml';
      servingSize = 100;
    } else {
      servingSizeText = product.servingSize?.replaceAll(RegExp(r'[0-9]'), '') ?? '';
      servingSize = double.tryParse(
      product.servingSize!
        .replaceAll(RegExp(r'[^\d.]'), '')
        .replaceAll(RegExp(r'\.(?=.*\.)'), '')
      );
    }

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              backgroundColor: const Color.fromARGB(255, 31, 31, 31),
              title: Text(
                '${product.name} ${product.quantity?.isNotEmpty == true ? '- ${product.quantity}' : ''}\n${product.calories?.toString() ?? 'Unknown'} cals per ${product.servingSize ?? 'Unknown'}',
                maxLines: 3,
                overflow: TextOverflow.visible,
                style: const TextStyle(
                  color: Color.fromARGB(255, 255, 242, 199),
                  fontSize: 20,
                  shadows: <Shadow>[
                    Shadow(
                      blurRadius: 2,
                      color: Color.fromARGB(255, 255, 228, 141),
                    ),
                  ],
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    children: [
                      const Text('I ate this at ',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButton<String>(
                          dropdownColor: const Color.fromARGB(255, 25, 25, 25),
                          style: const TextStyle(
                            color: Color.fromARGB(255, 190, 190, 190),
                            fontSize: 14,
                          ),
                          hint: const Text("Select a time",
                            style: TextStyle(
                              color: Color.fromARGB(255, 190, 190, 190),
                              fontSize: 14,
                            ),
                          ),
                          value: selectedEatTime,
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedEatTime = newValue;
                            });
                          },
                          items: eatTimeOptions.map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextField(
                              controller: servingController,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(
                                color: Color.fromARGB(255, 190, 190, 190),
                              ),
                              decoration: const InputDecoration(
                                hintText: 'Enter how much you ate',
                                hintStyle: TextStyle(
                                  color: Color.fromARGB(255, 190, 190, 190),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            if (errorMessage != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                errorMessage!,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        )
                      ),
                      const SizedBox(width: 8),
                      Text(servingSizeText!,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    selectedEatTime = null;
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('Add'),
                  onPressed: () {
                    if (selectedEatTime != null) {
                      int? userEnteredAmount = int.tryParse(servingController.text);
                      if (userEnteredAmount != null && servingSize != null) {
                        double calcCalories = (userEnteredAmount / servingSize) * (product.calories ?? 0);
                        int totalCalories = calcCalories.toInt();
                        print('Console Print: $userEnteredAmount / $servingSize * ${product.calories}');
                        print('Console Print: Calculated calories to $totalCalories');
                        print('Console Print: set servingUnit to $servingSizeText');
                        widget.appState.addLog(
                          foodId: product.foodId ?? 'default_food_id',
                          name: product.name,
                          calories: totalCalories,
                          eatTime: selectedEatTime!,
                          servingUnit: servingSizeText!,
                          servingMeasured: userEnteredAmount,
                          onSuccess: (logId) {
                            print('Console Print: Log added successfully with ID: $logId');
                          },
                        );
                        Navigator.of(context).pop();
                      } else {
                        setState(() {
                          errorMessage = 'Please enter a valid amount!';
                        });
                      }
                    } else {
                      setState(() {
                        errorMessage = 'Please select the time of consumption!';
                      });
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}