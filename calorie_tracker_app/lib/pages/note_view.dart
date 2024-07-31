import "package:calorie_tracker_app/app_state.dart";
import "package:calorie_tracker_app/models/note.dart";
import "package:flutter/material.dart";

class NoteView extends StatefulWidget {
  const NoteView({required this.appState, this.note, super.key});

  final Note? note;
  final AppState appState;
  @override
  State<NoteView> createState() => _NoteViewState();
}


class _NoteViewState extends State<NoteView> {
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
              hintText: 'Enter your title here',
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
            children: <Widget>[
              Expanded(
                child: SingleChildScrollView(
                  //This is the TextField for the Description/Content of the Note document
                  child: TextField(
                    style: const TextStyle(
                      color: Colors.white
                    ),
                    cursorColor: Colors.white,
                    controller: _noteContent,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Start typing!',
                      hintStyle: TextStyle(
                        color: Colors.grey
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color.fromARGB(255, 255, 228, 141), width: 2.0), // Customize color and width here
                      ),
                    ),
                    minLines: 8,
                    maxLines: null,
                  ),
                ),
              ),
              const SizedBox(height: 20), //Padding
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      //This is the Save Button which changes depending on if a Note was passed through when navigating to this page
                      IconButton(
                        onPressed: () {
                          //Check if this instance is a new Note or if it's an already existing one
                          if (_isNewNote) {
                            //It's a new Note, so save it as a new Note to the user's database
                            widget.appState.addNote(
                              description: _noteContent.text, 
                              title: _noteTitle.text,
                              onSuccess: (docId) { //Get the DocId of the new Note
                                setState(() {
                                  _isNewNote = false; //Set it so this is now an existing Note
                                  _docId = docId; //Transfer the DocId to the locally stored one
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Note was successfully created!', style: TextStyle(color: Colors.white))),
                                );
                              },
                            );
                          } else {
                            //It's an already existing Note, so update it online
                            widget.appState.updateNote(
                              note: Note(
                                id: widget.note!.id,
                                title: _noteTitle.text,
                                description: _noteContent.text,
                              ),
                              onSuccess: () { 
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Note was successfully updated!', style: TextStyle(color: Colors.white))),
                                );
                              }
                            );
                          }
                        },
                        icon: const Icon(Icons.save,
                          color: Color.fromARGB(255, 255, 196, 0),
                          shadows: <Shadow>[
                            Shadow(
                              blurRadius: 5,
                              color: Color.fromARGB(255, 255, 196, 0),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        _isNewNote ? 'Save New' : 'Save', //Change the text depending on if it's an entirely new Note or not
                        style: const TextStyle(
                          color: Colors.white
                        ),
                      ),
                    ]
                  ),
                  if (!_isNewNote)
                  Column(
                    children: <Widget>[
                      //This is the Delete Button which appears depending on if a Note was passed through when navigating to this page
                      IconButton(
                        onPressed: () {
                          //Delete the Note
                          widget.appState.deleteNote(
                            note: Note(
                                id: widget.note != null ? //If a Note was passed through, use its Id, if we just created it then use the locally stored Id
                                widget.note!.id : _docId,
                                title: _noteTitle.text,
                                description: _noteContent.text,
                              ),
                            onSuccess: () {
                              Navigator.of(context).pop(); //Return the User to the HomePage
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Note was successfully deleted.', style: TextStyle(color: Colors.white),)),
                              );
                            }
                          );
                        },
                        icon: const Icon(Icons.delete,
                          color: Color.fromARGB(255, 255, 196, 0),
                          shadows: <Shadow>[
                            Shadow(
                              blurRadius: 5,
                              color: Color.fromARGB(255, 255, 196, 0),
                            ),
                          ],
                        ),
                      ),
                      const Text('Delete',
                        style: TextStyle(
                          color: Colors.white
                        ),
                      ),
                    ]
                  ),
                ],
              ),
            ]
          ),
        ),
      );
    } else { //If there is no user signed in, show a Page asking the user to Sign in
      return Scaffold(
        appBar: AppBar(
          title: const Text('Notes App'),
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