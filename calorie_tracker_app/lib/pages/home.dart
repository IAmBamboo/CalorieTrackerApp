import 'package:calorie_tracker_app/models/log.dart';
import 'package:calorie_tracker_app/pages/log_entry_view.dart';
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

  @override
  Widget build(BuildContext context) {
    if (_isLoggedIn) { //If there is a user signed in, show their Food Logs
      print('Console Print: Login status is $_isLoggedIn');
      print('Console Print: The AppState Date is ${widget.appState.date}');

      return Scaffold(
        backgroundColor: const Color.fromARGB(255, 17, 17, 17),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        //BOTTOM NAV BAR
        bottomNavigationBar: BottomAppBar(
          color: const Color.fromARGB(255, 44, 44, 44),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              IconButton(
                icon: const Icon(Icons.calendar_today_rounded,
                  color: Color.fromARGB(255, 255, 228, 141),
                  shadows: <Shadow>[
                    Shadow(
                      blurRadius: 5,
                      color: Color.fromARGB(255, 255, 228, 141),
                    ),
                  ],
                ),
                onPressed: () async {
                  //Change the date to current time for debug
                  print('Attempt to change date');
                  DateTime? pickDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (pickDate != null) {
                    String newDate = DateFormat('M-d-yyyy').format(pickDate);
                    setState(() {
                      widget.appState.date = newDate;
                      widget.appState.fetchLogs(newDate);
                      print('Updated AppState Date is ${widget.appState.date}');
                  });
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.settings,
                  color: Color.fromARGB(255, 255, 228, 141),
                  shadows: <Shadow>[
                    Shadow(
                      blurRadius: 5,
                      color: Color.fromARGB(255, 255, 228, 141),
                    ),
                  ],
                ),
                onPressed: () {
                  //Settings
                  print('settings');
                },
              ),
            ],
          ),
        ),
        //END OF BOTTOM NAV BAR
        floatingActionButton: FloatingActionButton(
          onPressed: () => Navigator.of(context).push(
            SlidePageRoute(
              page: LogEntryView(appState: widget.appState),
            ),
          ),
          backgroundColor: const Color.fromARGB(255, 255, 196, 0),
          foregroundColor: Colors.black,
          tooltip: 'Create New',
          child: const Icon(Icons.add),
        ),
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 17, 17, 17),
          title: Text("${widget.appState.user?.email!.split('@').first}'s Calorie Log - ${widget.appState.date}", //Use the User's DisplayName
            style: const TextStyle(
              color: Color.fromARGB(255, 255, 228, 141),
              shadows: <Shadow>[
                Shadow(
                  blurRadius: 2,
                  color: Color.fromARGB(255, 255, 228, 141),
                ),
              ]
            ),
          ),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.account_circle,
                color: Color.fromARGB(255, 255, 228, 141),
                shadows: <Shadow>[
                  Shadow(
                    blurRadius: 5,
                    color: Color.fromARGB(255, 255, 228, 141),
                  ),
                ],
              ),
              onPressed: () {
                Navigator.of(context).pushNamed('/profile');
              },
            ),
          ],
        ),
        body: _logsList.isEmpty
          ? const Center(
            child: Text(
              "No logs available.",
              style: TextStyle(
                  color: Color.fromARGB(255, 255, 242, 199),
                  shadows: <Shadow>[
                    Shadow(
                      blurRadius: 2,
                      color: Color.fromARGB(255, 255, 228, 141),
                    ),
                  ],
                ),
            )
          )
          : _buildList(_logsList),
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

  /// Builds a list of Log widgets.
  /// Each list item is a GestureDetector that when tapped, expands the object to show the full food entry Log description.
  /// An AnimatedSize widget is used to animate the expansion and contraction of the list items.
  /// Each list item includes a ListTile displaying the food log entry's name and calories, an icon
  /// indicating its expansion state, and a PopupMenuButton with options to edit or delete the log.
  ///
  /// Arguments:
  /// - logs: A List<Log> containing the logs to be displayed.
  Widget _buildList(List<Log> logs) {
    return ListView.builder(
      itemCount: logs.length,
      itemBuilder: (context, index) {
        final log = logs[index];
        final bool isExpanded = _expandedTile == index;

        return GestureDetector(
          onTap: () {
            setState(() {
              _expandedTile = isExpanded ? null : index; //Toggle expansion state
              Feedback.forTap(context);
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
                    key: UniqueKey(),
                    title: Text(
                      log.name, 
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
                    subtitle: Text('Calories: ${log.calories.toString()}', 
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
                          case 'open':
                            Navigator.of(context).push(
                              SlidePageRoute(
                                page: LogEntryView(log: log, appState: widget.appState),
                              ),
                            );
                            break;
                          case 'delete':
                            widget.appState.deleteLog(
                              log: log,
                              onSuccess: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Food entry was successfully deleted.')),
                                );
                              }
                            );
                            break;
                        }
                      },
                      itemBuilder: (BuildContext bc) {
                        return const [
                          PopupMenuItem(
                            value: 'open',
                            child: Text("View Log"),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Text("Delete"),
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
}

/// A custom PageRouteBuilder that creates a slide transition from left to right when navigating.
/// 
/// Properties:
/// - page: The widget representing the new page to navigate to.
class SlidePageRoute extends PageRouteBuilder {
  final Widget page;

  SlidePageRoute({required this.page})
    : super(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var tween = Tween(
            begin: const Offset(-1.0, 0.0), 
            end: Offset.zero
          )
          .chain(CurveTween(curve: Curves.easeOutQuint));
          return SlideTransition(position: animation.drive(tween), child: child);
        },
      );
}