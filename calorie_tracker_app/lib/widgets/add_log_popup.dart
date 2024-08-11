import 'package:calorie_tracker_app/app_state.dart';
import 'package:calorie_tracker_app/models/food_product.dart';
import 'package:flutter/material.dart';

/// Builds a pop up window that allows the user to add a FoodProduct to their Log list
/// It will calculate the calories by using the given FoodProduct's information and extract
/// other necessary information to transfer everything required into a Log object to save
/// Arguments:
/// - appState: The AppState to be passed
/// - product: The FoodProduct to be used and converted into a Log object to save
class AddFoodLogPopup extends StatefulWidget {
  final FoodProduct product;
  final AppState appState;

  const AddFoodLogPopup({
    Key? key,
    required this.product,
    required this.appState,
  }) : super(key: key);

  @override
  _AddFoodLogPopupState createState() => _AddFoodLogPopupState();
}

class _AddFoodLogPopupState extends State<AddFoodLogPopup> {
  final List<String> eatTimeOptions = ['Breakfast', 'Lunch', 'Dinner', 'Snacks'];
  final TextEditingController servingController = TextEditingController();
  String? errorMessage; //Error message for user feedback
  String? servingSizeText; //The unit of measurement from the serving size
  double? servingSize; //The measurement of the serving size
  String? selectedEatTime; //Selected eat time

  @override
  void initState() {
    super.initState();

    if (widget.product.servingSize == '100g/100ml') {
      //This is a default measurement commonly found
      servingSizeText = 'g/ml';
      servingSize = 100;
    } else {
      //Good chance we are not using the default measurement, if so then we need to extract the info
      servingSizeText = widget.product.servingSize?.replaceAll(RegExp(r'[0-9]'), '') ?? ''; //Remove numbers from the serving size text
      servingSize = _parseServingSize(widget.product.servingSize); //Parse the string and use the first whole number found
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color.fromARGB(255, 31, 31, 31),
      title: Text(
        '${widget.product.name} ${widget.product.quantity?.isNotEmpty == true ? '- ${widget.product.quantity}' : ''}\n${widget.product.calories?.toString() ?? 'Unknown'} cals per ${widget.product.servingSize ?? 'Unknown'}',
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
          Row( //Dropdown menu row
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
          Row( //Calorie textfield row
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      autofocus: false,
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
      actions: <Widget>[ //Buttons at bottom
        TextButton(
          child: const Text('Cancel', style: TextStyle(color: Color.fromARGB(255, 255, 196, 0),),),
          onPressed: () {
            selectedEatTime = null; //reset this
            Navigator.of(context).pop(); //Pop the popup window
          },
        ),
        TextButton(
          child: const Text('Add', style: TextStyle(color: Color.fromARGB(255, 255, 196, 0),),),
          onPressed: () {
            if (selectedEatTime != null) { //make sure they selected an eatTime
              double? userEnteredAmount = double.tryParse(servingController.text); //get user input

              if (userEnteredAmount != null && servingSize != null) {
                double calcCalories = (userEnteredAmount / servingSize!) * (widget.product.calories ?? 0); //Calc new calories from input and servingsize
                int totalCalories = calcCalories.toInt(); //Convert to int
                widget.appState.addLog( //Add log
                  foodId: widget.product.foodId ?? 'no_bar_code',
                  name: widget.product.name,
                  calories: totalCalories,
                  eatTime: selectedEatTime!,
                  servingUnit: servingSizeText!,
                  servingMeasured: userEnteredAmount,
                  onSuccess: (logId) {
                    Navigator.of(context).pop(); //Close window after add
                  },
                );
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
  }

  /// Parses a string to find the first whole number. Returns that number
  /// Arguments:
  /// - servingSizeText: The string to be parsed
  double? _parseServingSize(String? servingSizeText) {
    if (servingSizeText == null || servingSizeText.isEmpty) {
      return 0; //Return 0 incase we can't find anything
    }
    final match = RegExp(r'\b(\d+(\.\d+)?)\b').allMatches(servingSizeText);
    if (match.isNotEmpty) {
      final numbers = match.map((m) => m.group(0)).toList();
      if (numbers.isNotEmpty) {
        return double.tryParse(numbers.first!);
      }
    }
    return 0; //Return 0 incase we can't find anything
  }
}