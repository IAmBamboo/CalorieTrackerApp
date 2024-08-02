import "package:calorie_tracker_app/app_state.dart";
import "package:calorie_tracker_app/models/note.dart";
import "package:flutter/material.dart";

class LogEntryView extends StatefulWidget {
  const LogEntryView({required this.appState, this.note, super.key});

  final Note? note;
  final AppState appState;
  @override
  State<LogEntryView> createState() => _LogEntryViewState();
}


class _LogEntryViewState extends State<LogEntryView> {
  late TextEditingController _noteTitle; //Title of the Note
  late TextEditingController _noteContent; //Description/Content of the Note
  bool _isNewNote = true; //Used to identify if this instance is for a new Note or an existing one
  late bool _isLoggedIn; //Used to identify if a user is signed in
  late String? _docId; //Local DocId/Note Id

  @override
  void initState() {
    super.initState();
    _isLoggedIn = widget.appState.loggedIn; //Checks to see if the User is signed in, update Bool as so
    //Check to see if a Note was provided when navigating to this page
    if (widget.note != null) { 
      //A Note was provided so copy the contents of the Note to this page
      _noteTitle = TextEditingController(text:widget.note!.title);
      _noteContent = TextEditingController(text:widget.note!.description);
      _isNewNote = false; //Update the Bool used to identify if a Note was passed
      _docId = widget.note!.id; //Transfer the docId to the local one
    } else {
      //A Note was not provided so set everything to blank
      _noteTitle = TextEditingController(text:'');
      _noteContent = TextEditingController(text:'');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoggedIn) { //If there is a user signed in, show their Notes
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
          //This is the TextField for the Title of the Note document
          title: TextField(
            style: const TextStyle(
              color: Colors.white
            ),
            cursorColor: Colors.white,
            controller: _noteTitle,
            decoration: const InputDecoration(
              hintText: 'Search here',
              hintStyle: TextStyle(
                color: Colors.grey
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color.fromARGB(255, 255, 228, 141), width: 2.0), // Customize color and width here
              ),
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: 
            <Widget>[
              TextField(
                style: const TextStyle(
                  color: Colors.white
                ),
                cursorColor: Colors.white,
                controller: _noteTitle,
                decoration: const InputDecoration(
                  hintText: 'Search here',
                  hintStyle: TextStyle(
                    color: Colors.grey
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color.fromARGB(255, 255, 228, 141), width: 2.0), // Customize color and width here
                  ),
                ),
              ),
              const Expanded(
                child: SingleChildScrollView(
                  //This is the TextField for the Description/Content of the Note document
                  child: Text('List')
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