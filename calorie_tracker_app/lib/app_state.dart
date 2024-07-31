import "package:calorie_tracker_app/firebase_options.dart";
import "package:flutter/material.dart";
import "package:firebase_core/firebase_core.dart";
import "package:firebase_auth/firebase_auth.dart" hide EmailAuthProvider;
import "package:firebase_ui_auth/firebase_ui_auth.dart";
import "package:cloud_firestore/cloud_firestore.dart";

import "models/note.dart";

class AppState extends ChangeNotifier {
  AppState() {
    init();
  }

  bool _loggedIn = false;
  bool get loggedIn => _loggedIn;

  User? _user;
  User? get user => _user;
  set user(User? user) {
    if (user == null) {
      throw ArgumentError('Cannot set the user to null');
    }
    _user = user;
  }

  List<Note>? _notes;
  List<Note>? get notes {
    if (user == null) {
      print('Cannot get notes when user is null'); //If the User is null, do not throw an error as the app will redirect the user to sign-in
      return null;
    }
    return _notes;
  }

  set notes(List<Note>? notes) {
    if (user == null) {
      throw StateError('Cannot set notes when the user is null');
    }
    if (notes == null) {
      throw ArgumentError('Cannot set notes to null');
    }
    _notes = notes;
    notifyListeners();
  }

  void _fetchNotes() {
    if (user == null) {
      throw StateError('Cannot fetch notes when user is null');
    }

    FirebaseFirestore.instance
        .collection('/notes/${user!.uid}/notes')
        .get()
        .then((snapshot) {
      notes = snapshot.docs.map((doc) => Note.fromFirestore(doc)).toList();
    });
  }

  void updateNote({
    required Note note, //Require a Note to be passed so we know what we're dealing with
    required VoidCallback onSuccess //A Callback to let us know when it finishes
    }) {

    if (user == null) {
      throw StateError('Cannot update a note when user is null');
    }

    FirebaseFirestore.instance
      .collection('/notes/${user!.uid}/notes')
      .doc(note.id)
      .update(note.toMap())
      .then((_) {
        notifyListeners();
        _fetchNotes(); //Update the locally stored notes
        onSuccess(); //A Callback to let us know when it finishes
      }
    );
  }

  void deleteNote({
    required Note note, //Require a Note to be passed so we know what we're dealing with
    required VoidCallback onSuccess //A Callback to let us know when it finishes
    }) {
    if (user == null) {
      throw StateError('Cannot delete a note when user is null');
    }

    FirebaseFirestore.instance
      .collection('/notes/${user!.uid}/notes')
      .doc(note.id)
      .delete()
      .then((_) {
        notes!.remove(note);
        notifyListeners();
        _fetchNotes(); //Update the locally stored notes
        onSuccess(); //A Callback to let us know when it finishes
      }
    );
  }

  void addNote({
    required String description, //The description/contents to be saved
    required String title, //The title to be saved
    required Function(String) onSuccess, //A Callback to let us know when it finishes
  }) {
    if (user == null) {
      throw StateError('Cannot add a note when user is null');
    }

    final note = Note(
      description: description,
      title: title,
    );

    FirebaseFirestore.instance
      .collection('/notes/${user!.uid}/notes')
      .add(note.toMap())
      .then((DocumentReference doc) {
        note.id = doc.id;
        notes!.add(note);
        notifyListeners();
        _fetchNotes(); //Update the locally stored notes
        onSuccess(doc.id); //A Callback to let us know when it finishes, pass through the newly created doc.id
      }).catchError((error) {
      print('Failed to add note: $error');
    }
  );
}

  Future<void> init() async {
    // Initial app state

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FirebaseUIAuth.configureProviders(
      [
        EmailAuthProvider(),
      ],
    );

    FirebaseAuth.instance.userChanges().listen((user) {
      if (user != null) {
        _loggedIn = true;
        this.user = user;
        _fetchNotes();
      } else {
        _loggedIn = false;
        _notes = [];
        print('Console Print: No user is signed in!');
      }

      notifyListeners();
    });
  }
}