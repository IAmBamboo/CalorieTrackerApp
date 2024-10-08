import "package:calorie_tracker_app/app_state.dart";
import "package:calorie_tracker_app/models/food_product.dart";
import "package:calorie_tracker_app/models/log.dart";
import "package:calorie_tracker_app/widgets/food_search_results.dart";
import "package:calorie_tracker_app/widgets/product_log_view.dart";
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
  late String? _foodId; //Barcode ID of the food item
  late FoodProduct? singleProduct; //Used for Barcode entries, transfer the search result into a single object to use

  // Search state variables
  String _searchQuery = ''; //Query to search
  List<FoodProduct> _searchResults = []; //List of results as FoodProducts
  String _searchMessage = ''; //Used as feedback for the user
  bool _isLoading = false; //Used for feedback for the ui

  String? selectedEatTime; //Used by the dropdown menu to store the selected value of the add popup

  @override
  void initState() {
    super.initState();
    _isLoggedIn = widget.appState.loggedIn; //Checks to see if the User is signed in, update Bool as so
    //Check to see if a Log was provided when navigating to this page
    if (widget.log != null) { 
      //A Log was provided so copy the contents of the Log to this page
      _isNewLog = false; //Update the Bool used to identify if a Log was passed
      _foodId = widget.log!.foodId; //Transfer the barcode Id
      _searchFood(_foodId!, true); //Search by barcode
    } else {
      //A Log was not provided, can add more handling here in the future
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoggedIn) { //If there is a user signed in, show the log page
      return Scaffold(
        backgroundColor: const Color.fromARGB(255, 17, 17, 17),
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 17, 17, 17),
          leading: IconButton( //This is the back button
            icon: const Icon(Icons.arrow_back, size: 30, color: Color.fromARGB(255, 255, 196, 0)),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          //This is the Title of the page
          title: _isNewLog //Check if a log was provided
            ? const Text("Add new log entry", //No log
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
            : Text('Viewing ${widget.log!.name}', //A log was provided, use the log data
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
        //This is the body of the page
        body: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              if (_isNewLog) ...[ //Check to see if a log was provided, adjust body depending on so
                //This is a new log, let the user search the OpenFoodFact's database for food
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: TextField( //This is the search field to search for food
                        autofocus: false,
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
                    IconButton( //Search button
                      icon: const Icon(Icons.search, color: Color.fromARGB(255, 255, 228, 141)),
                      onPressed: () {
                        _searchFood(_searchQuery, false);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 40), //Padding
                if (_isLoading) 
                  const CircularProgressIndicator(
                    color: Color.fromARGB(255, 255, 196, 0),
                  ) 
                else 
                  Expanded(
                    child: _searchResults.isEmpty
                      ? const Center(child: Text('No results found', style: TextStyle(color: Colors.white)))
                      : FoodSearchResultsList(appState: widget.appState, products: _searchResults,),
                  ),
              ] else ...[
              //This is an existing log, show the product data and log data
                if (_isLoading)
                  const CircularProgressIndicator(
                    color: Color.fromARGB(255, 255, 196, 0),
                  )
                else
                  Expanded(
                    child: ProductLogView(
                      singleProduct: singleProduct,
                      log: widget.log,
                    ),
                  ),
                  const SizedBox(height: 10), //Padding
              ],
              if (_isNewLog) // Search Message Handling
                if (!_isLoading) ... [
                  const SizedBox(height: 10), //Padding
                  Text(_searchMessage, style: const TextStyle(color: Colors.white)),
                ],
              //Bottom disclaimer text
              const SizedBox(height: 10), //Padding
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

  /// Searches using the query and provided info to find product(s) matching the given information
  /// from the OpenFoodFact's database. Updates the local list of searchResults with FoodProducts 
  /// that match the given query. If a Barcode was provided, it will return a singular FoodProduct in the list
  /// Arguments:
  /// - query: A string to search through the OpenFoodFact;s database with
  /// - isBarCode: A boolean about whether or not the search is using a Barcode (Used for existing logs)
  Future<void> _searchFood(String query, bool isBarCode) async {
    // API documentation: https://openfoodfacts.github.io/openfoodfacts-server/api/
    //                    https://openfoodfacts.github.io/openfoodfacts-server/api/tutorial-off-api/
    setState(() {
      _isLoading = true;
    });
    late http.Response response;

    //Check for barcode as the search link differs
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
        // Extracting nutritional information
        final double? totalFat = nutriments.containsKey('fat') ? (nutriments['fat'] as num).toDouble() : null;
        final double? saturatedFat = nutriments.containsKey('saturated-fat') ? (nutriments['saturated-fat'] as num).toDouble() : null;
        final double? transFat = nutriments.containsKey('trans-fat') ? (nutriments['trans-fat'] as num).toDouble() : null;
        final int? cholesterol = nutriments.containsKey('cholesterol') ? (nutriments['cholesterol'] as num).toInt() : null;
        final int? sodium = nutriments.containsKey('sodium') ? (nutriments['sodium'] as num).toInt() : null;
        final double? totalCarbohydrates = nutriments.containsKey('carbohydrates') ? (nutriments['carbohydrates'] as num).toDouble() : null;
        final double? dietaryFiber = nutriments.containsKey('fiber') ? (nutriments['fiber'] as num).toDouble() : null;
        final double? sugars = nutriments.containsKey('sugars') ? (nutriments['sugars'] as num).toDouble() : null;
        final double? proteins = nutriments.containsKey('proteins') ? (nutriments['proteins'] as num).toDouble() : null;

        int? calories;
        String? servingSize = originalServingSize;

        //Adjusting calories and serving size info based off available information
        if (nutriments.containsKey('energy-kcal_serving')) {
          //A specific serving size was found, use it
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
          totalFat: totalFat,
          saturatedFat: saturatedFat,
          transFat: transFat,
          cholesterol: cholesterol,
          sodium: sodium,
          totalCarbohydrates: totalCarbohydrates,
          dietaryFiber: dietaryFiber,
          sugars: sugars,
          proteins: proteins,
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
}