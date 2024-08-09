import "package:calorie_tracker_app/firebase_options.dart";
import "package:calorie_tracker_app/models/log.dart";
import "package:flutter/material.dart";
import "package:firebase_core/firebase_core.dart";
import "package:firebase_auth/firebase_auth.dart" hide EmailAuthProvider;
import "package:firebase_ui_auth/firebase_ui_auth.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import 'package:intl/intl.dart';

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

  DateTime? _date; // The date for which logs are fetched and managed
  DateTime? get date => _date;
  set date(DateTime? date) {
    _date = date;
    notifyListeners();
  }

  List<Log>? _logs;
  List<Log>? get logs {
    if (user == null) {
      print('Console Print: Cannot get logs when user or date is null'); // If the User or Date is null, do not throw an error as the app will redirect the user to sign-in
      return null;
    }
    return _logs;
  }

  set logs(List<Log>? logs) {
    if (user == null) {
      throw StateError('Cannot set logs when the user or date is null');
    }
    if (logs == null) {
      throw ArgumentError('Cannot set logs to null');
    }
    _logs = logs;
    notifyListeners();
  }

  void fetchLogs(DateTime date) {
    String dateString = DateFormat('M-d-yyyy').format(date);
    if (user == null) {
      //throw StateError('Cannot fetch logs when user or date is null');
      print('Console Print: Cannot fetch logs when user is null');
      return;
    }

    FirebaseFirestore.instance
        .collection('/savedDays/${user!.uid}/savedDays/$dateString/foods')
        .get()
        .then((snapshot) {
          print('Console Print: Query completed with ${snapshot.docs.length} documents found');
          if (snapshot.docs.isEmpty) {
            print('Console Print: No logs found for date $dateString');
          }
          logs = snapshot.docs.map((doc) => Log.fromFirestore(doc)).toList();
          print('Console Print: Logs fetched and updated');
        }).catchError((error) {
      print('Console Print: Error fetching logs: $error');
    });
  }

  void updateLog({
    required Log log, //Require a Log to be passed so we know what we're dealing with
    required VoidCallback onSuccess //A Callback to let us know when it finishes
    }) {
    String dateString = DateFormat('M-d-yyyy').format(date!);
    if (user == null) {
      throw StateError('Cannot update a log when user is null');
    }

    FirebaseFirestore.instance
      .collection('/savedDays/${user!.uid}/savedDays/$dateString/foods')
      .doc(log.id) //this needs to be changed (make sure we are setting a proper ID in logs model)
      .update(log.toMap())
      .then((_) {
        notifyListeners();
        fetchLogs(_date!); //Update the locally stored logs
        onSuccess(); //A Callback to let us know when it finishes
      }
    );
  }

  void deleteLog({
    required Log log, //Require a Log to be passed so we know what we're dealing with
    required VoidCallback onSuccess //A Callback to let us know when it finishes
    }) {
    String dateString = DateFormat('M-d-yyyy').format(date!);
    if (user == null) {
      throw StateError('Cannot delete a log when user is null');
    }

    FirebaseFirestore.instance
      .collection('/savedDays/${user!.uid}/savedDays/$dateString/foods')
      .doc(log.id)
      .delete()
      .then((_) {
        logs!.remove(log);
        notifyListeners();
        fetchLogs(_date!); //Update the locally stored logs
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
    String dateString = DateFormat('M-d-yyyy').format(date!);
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
      .collection('/savedDays/${user!.uid}/savedDays/$dateString/foods')
      .add(log.toMap())
      .then((DocumentReference doc) {
        log.id = doc.id;
        logs!.add(log);
        notifyListeners();
        fetchLogs(_date!); //Update the locally stored logs
        onSuccess(doc.id); //A Callback to let us know when it finishes, pass through the newly created doc.id
      }).catchError((error) {
      print('Console Print: Failed to add log: $error');
    }
  );
}

  Future<void> init() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Console Print: Firebase initialized successfully');

    FirebaseUIAuth.configureProviders([
      EmailAuthProvider(),
    ]);

    // Set date to show today
    _date = DateTime.now();
    print('Console Print: Date set to $_date');
    notifyListeners();

    FirebaseAuth.instance.userChanges().listen((user) {
      print('Console Print: User change detected');
      if (user != null) {
        print('Console Print: User is not null, user is ${user.email}');
        _loggedIn = true;
        this.user = user;
        if (_date != null) {
          print('Console Print: Fetching logs with $_date');
          fetchLogs(_date!);
          print('Console Print: Fetched logs');
        } else {
          print('Console Print: Date is null at login');
        }
      } else {
        _loggedIn = false;
        _logs = [];
        print('Console Print: No user is signed in!');
      }
      notifyListeners();
      print('Console Print: notifyListeners() called');
    });
  } catch (e) {
    print('Console Print: Error initializing Firebase: $e');
  }
}
}