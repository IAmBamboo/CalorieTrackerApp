import "package:calorie_tracker_app/app_state.dart";
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
  late String _foodName; //Name of the log entry
  late int _foodCal; // Calories of the log entry
  bool _isNewLog = true; //Used to identify if this instance is for a new Log or an existing one
  late bool _isLoggedIn; //Used to identify if a user is signed in
  late String? _docId; //Local DocId/Log Id

  // Search state variables
  String _searchQuery = '';
  List<dynamic> _searchResults = [];
  String _searchMessage = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isLoggedIn = widget.appState.loggedIn; //Checks to see if the User is signed in, update Bool as so
    //Check to see if a Log was provided when navigating to this page
    if (widget.log != null) { 
      //A Log was provided so copy the contents of the Log to this page
      _foodName = widget.log!.name;
      _foodCal = widget.log!.calories;
      _isNewLog = false; //Update the Bool used to identify if a Log was passed
      _docId = widget.log!.id; //Transfer the docId to the local one
    } else {
      //A Log was not provided so set everything to defaults
      _foodName = '';
      _foodCal = 0;
    }
  }

  Future<void> _searchFood(String query) async {
    //API documentation: https://openfoodfacts.github.io/openfoodfacts-server/api/
    //                   https://openfoodfacts.github.io/openfoodfacts-server/api/tutorial-off-api/
    setState(() {
      _isLoading = true;
    });

    final response = await http.get(
      Uri.parse('https://world.openfoodfacts.org/cgi/search.pl?search_terms=$query&search_simple=1&action=process&json=1'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _searchResults = data['products'] ?? [];
        _searchMessage = 'Search found ${_searchResults.length} products';
        _isLoading = false;
      });
    } else {
      setState(() {
        _searchMessage = 'Error fetching search results';
        _isLoading = false;
      });
      // Handle
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
            : const Text('Old log',
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
                      icon: const Icon(Icons.search, color: Color.fromARGB(255, 255, 228, 141)), // Use a search icon
                      onPressed: () {
                        _searchFood(_searchQuery);
                      },
                    ),
                  ],
                ),
              const SizedBox(height: 40), //Padding
              if (_isNewLog) 
                if (_isLoading)
                  const CircularProgressIndicator()
                else
                  Text(_searchMessage, style: const TextStyle(color: Colors.white)),
                  // Expanded(
                  //   child: SingleChildScrollView(
                  //     //This is the TextField for the Description/Content of the Note document
                  //     child: Text('List')
                  //   ),
                  // ),
              if (!_isNewLog) 
              // THIS IS A NOT NEW LOG, SHOW CONTENT OF THE LOG ITEM
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Food Name: $_foodName", style: const TextStyle(color: Colors.white)),
                  Text("Food Cal: ${_foodCal.toString()}", style: const TextStyle(color: Colors.white)),
                ],
              ),
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
}