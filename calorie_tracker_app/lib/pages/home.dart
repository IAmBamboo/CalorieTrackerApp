import 'package:calorie_tracker_app/models/log.dart';
import 'package:calorie_tracker_app/pages/day_log_view.dart';
import 'package:calorie_tracker_app/pages/settings.dart';
import 'package:flutter/material.dart';
import 'package:calorie_tracker_app/app_state.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({required this.appState, super.key});

  final AppState appState;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  List<Log> _logsList = []; //Stored list of Logs (Logged food/drink entries)
  late bool _isLoggedIn; //Used to identify if a user is signed in
  int? _expandedTile; //Used to control which ListTile is expanded
  late AnimationController _controller; //Animation Controller
  int _selectedIndex = 0; //Selected index of the bottom navbar

  @override
  void initState() {
    super.initState();
    _isLoggedIn = widget.appState.loggedIn; //Checks to see if the User is signed in, update Bool as so
    _logsList = widget.appState.logs ?? []; //Update local entry logs from the User's Logs stored online
    widget.appState.addListener(_updateState);
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
  }

  //Disposes the listener and AnimationController
  @override
  void dispose() {
    widget.appState.removeListener(_updateState);
    _controller.dispose();
    super.dispose();
  }

  //Check to see if User is logged in and update Logs, reset _expandedTile
  void _updateState() {
    setState(() {
      _isLoggedIn = widget.appState.loggedIn;
      _logsList = widget.appState.logs ?? [];
      _expandedTile = null;
      print('Console Print: User is ${widget.appState.user?.email ?? 'unknown'}');
      print('Console Print: Login status is $_isLoggedIn');
    });
  }

  void _onNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoggedIn) { //If there is a user signed in, show their Food Logs
      print('Console Print: Login status is $_isLoggedIn');
      if (widget.appState.date != null) {
        print('Console Print: Updated AppState Date is ${DateFormat('M-d-yyyy').format(widget.appState.date!)}');
      } else {
        print('Console Print: ERROR widget.appState.date returned as NULL');
      }

      return Scaffold(
        backgroundColor: const Color.fromARGB(255, 17, 17, 17),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
          currentIndex: _selectedIndex,
          unselectedItemColor: Colors.white,
          selectedItemColor: const Color.fromARGB(255, 255, 242, 199),
          selectedIconTheme: const IconThemeData(
            color: Color.fromARGB(255, 255, 228, 141),
            shadows: <Shadow>[
              Shadow(
                blurRadius: 10,
                color: Color.fromARGB(255, 255, 228, 141),
              ),
            ],
          ),
          unselectedIconTheme: const IconThemeData(
            color: Colors.white,
          ),
          backgroundColor: const Color.fromARGB(255, 39, 39, 39),
          onTap: _onNavItemTapped,
        ),
        //END OF BOTTOM NAV BAR
        // BODY OF PAGE
        body: _isLoggedIn ? _getBody() :
        ListView(
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
    } else { //If there is no user signed in, show a Page asking the user to Sign in
      return Scaffold(
        appBar: AppBar(
          title: const Text('Food Calorie Tracker App'),
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

   Widget _getBody() {
    switch (_selectedIndex) {
      case 0:
        return DayLogView(
          appState: widget.appState,
          logsList: _logsList,
          expandedTile: _expandedTile,
          onTileTap: (index) {
            setState(() {
              _expandedTile = _expandedTile == index ? null : index;
            });
          },
          onLogAction: (index, action) {
            if (action == 'open') {
              // Handle log open action
            } else if (action == 'delete') {
              // Handle log delete action
            }
          },
        );
      case 1:
        return SettingsPage(
          appState: widget.appState,
        );
      default:
        return const Center(
          child: Text(
            'Index 0: Home',
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
        );
    }
  }
}