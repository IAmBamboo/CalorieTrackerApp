import "package:calorie_tracker_app/firebase_options.dart";
import "package:calorie_tracker_app/models/log.dart";
import "package:flutter/material.dart";
import "package:firebase_core/firebase_core.dart";
import "package:firebase_auth/firebase_auth.dart" hide EmailAuthProvider;
import "package:firebase_ui_auth/firebase_ui_auth.dart";
import "package:cloud_firestore/cloud_firestore.dart";

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

  String? _date; // The date for which logs are fetched and managed
  String? get date => _date;
  set date(String? date) {
    _date = date;
    notifyListeners();
  }

  List<Log>? _logs;
  List<Log>? get logs {
    if (user == null || date == null) {
      print('Cannot get logs when user or date is null'); // If the User or Date is null, do not throw an error as the app will redirect the user to sign-in
      return null;
    }
    return _logs;
  }

  set logs(List<Log>? logs) {
    if (user == null || date == null) {
      throw StateError('Cannot set logs when the user or date is null');
    }
    if (logs == null) {
      throw ArgumentError('Cannot set logs to null');
    }
    _logs = logs;
    notifyListeners();
  }

  void _fetchLogs() {
    if (user == null || date == null) {
      throw StateError('Cannot fetch logs when user or date is null');
    }

    FirebaseFirestore.instance
        .collection('/savedDays/${user!.uid}/savedDays/${date!}/foods')
        .get()
        .then((snapshot) {
      logs = snapshot.docs.map((doc) => Log.fromFirestore(doc)).toList();
    });
  }

  void updateLog({
    required Log log, //Require a Log to be passed so we know what we're dealing with
    required VoidCallback onSuccess //A Callback to let us know when it finishes
    }) {

    if (user == null) {
      throw StateError('Cannot update a log when user is null');
    }

    FirebaseFirestore.instance
      .collection('/savedDays/${user!.uid}/savedDays/${date!}/foods')
      .doc(log.id) //this needs to be changed (make sure we are setting a proper ID in logs model)
      .update(log.toMap())
      .then((_) {
        notifyListeners();
        _fetchLogs(); //Update the locally stored logs
        onSuccess(); //A Callback to let us know when it finishes
      }
    );
  }

  void deleteLog({
    required Log log, //Require a Log to be passed so we know what we're dealing with
    required VoidCallback onSuccess //A Callback to let us know when it finishes
    }) {
    if (user == null) {
      throw StateError('Cannot delete a log when user is null');
    }

    FirebaseFirestore.instance
      .collection('/savedDays/${user!.uid}/savedDays/${date!}/foods')
      .doc(log.id)
      .delete()
      .then((_) {
        logs!.remove(log);
        notifyListeners();
        _fetchLogs(); //Update the locally stored logs
        onSuccess(); //A Callback to let us know when it finishes
      }
    );
  }

  void addLog({
    required String foodId, // The unique ID of the food item to be saved
    required String name, // The name of the food to be saved
    required int calories, // Number of calories
    required String eatTime, // Time when the food was eaten (e.g., breakfast, lunch, dinner, snack)
    required Function(String) onSuccess, //A Callback to let us know when it finishes
  }) {
    if (user == null) {
      throw StateError('Cannot add a log when user is null');
    }

    final log = Log(
      foodId: foodId,
      name: name,
      calories: calories,
      eatTime: eatTime,
    );

    FirebaseFirestore.instance
      .collection('/savedDays/${user!.uid}/savedDays/${date!}/foods')
      .add(log.toMap())
      .then((DocumentReference doc) {
        log.id = doc.id;
        logs!.add(log);
        notifyListeners();
        _fetchLogs(); //Update the locally stored logs
        onSuccess(doc.id); //A Callback to let us know when it finishes, pass through the newly created doc.id
      }).catchError((error) {
      print('Failed to add log: $error');
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
        _fetchLogs();
      } else {
        _loggedIn = false;
        _logs = [];
        print('Console Print: No user is signed in!');
      }

      notifyListeners();
    });
  }
}