import 'package:calorie_tracker_app/app_state.dart';
import 'package:calorie_tracker_app/models/log.dart';
import 'package:calorie_tracker_app/pages/log_entry_view.dart';
import 'package:calorie_tracker_app/widgets/calorie_header.dart';
import 'package:calorie_tracker_app/widgets/log_list_view.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DayLogView extends StatelessWidget {
  final AppState appState;
  final List<Log> logsList;
  final int? expandedTile;
  final void Function(int) onTileTap;
  final void Function(int, String) onLogAction;

  const DayLogView({
    required this.appState,
    required this.logsList,
    required this.expandedTile,
    required this.onTileTap,
    required this.onLogAction,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int totalCalories = logsList.fold(0, (sum, log) => sum + log.calories); //Calculating the total consumed calories from the list of Logs
    
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.miniCenterFloat,
        floatingActionButton: FloatingActionButton( // This is the big yellow button with the +
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => LogEntryView(appState: appState), //nav to add new log entry page
            ),
          ),
          backgroundColor: const Color.fromARGB(255, 255, 196, 0),
          foregroundColor: Colors.black,
          tooltip: 'Create New',
          child: const Icon(Icons.add),
        ),
      backgroundColor: const Color.fromARGB(255, 17, 17, 17),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 39, 39, 39),
        title: Text(
          "Daily Log - ${DateFormat('MMMM d, y').format(appState.date!)}", //Format the appState's date
          style: const TextStyle(
            color: Color.fromARGB(255, 255, 228, 141),
            shadows: <Shadow>[
              Shadow(
                blurRadius: 2,
                color: Color.fromARGB(255, 255, 228, 141),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.calendar_today_rounded,
              color: Color.fromARGB(255, 255, 228, 141),
              shadows: <Shadow>[
                Shadow(
                  blurRadius: 5,
                  color: Color.fromARGB(255, 255, 228, 141),
                ),
              ],
            ),
            onPressed: () async { //Show a DateTime picker so the user can set the appState's date to fetch specific logs
              DateTime? pickDate = await showDatePicker(
                context: context,
                initialDate: appState.date,
                firstDate: DateTime(2000),
                lastDate: DateTime(2101),
              );
              if (pickDate != null) {
                appState.date = pickDate;
                appState.fetchLogs(pickDate);
              }
            },
          ),
        ],
        bottom: CalorieHeader( //This is the little bar that calculates calorie related trackers
          totalCalories: totalCalories, 
          caloriesLimit: appState.userSettings!.caloriesLimit
        )
      ),
      body: logsList.isEmpty //If there are no logs, show some text
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
              ),
            )
          : LogListView( //Build a list from the list of Logs
            logsList: logsList, 
            onTileTap: onTileTap, 
            expandedTile: expandedTile, 
            appState: appState)
    );
  }
}