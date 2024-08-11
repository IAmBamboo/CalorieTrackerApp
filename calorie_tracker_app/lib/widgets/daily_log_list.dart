import 'package:calorie_tracker_app/app_state.dart';
import 'package:calorie_tracker_app/pages/log_entry_view.dart';
import 'package:flutter/material.dart';
import 'package:calorie_tracker_app/models/log.dart';

/// Builds an animated widget list of Log entries.
/// A sectioned list of various eatTime's which will group the log entries under the appropriate section
/// The list is expandable to display additional information of each log entry.
///
/// Arguments:
/// - logsList: The list of Logs to build a list of
/// - onTileTap: An integer used to find which tile is tapped
/// - expandedTile: An integer used to find which tile is expanded
/// - appState: The appState to be passed
class DailyLogList extends StatelessWidget {
  final List<Log> logsList;
  final ValueChanged<int> onTileTap;
  final int? expandedTile;
  final AppState appState;

  const DailyLogList({
    super.key,
    required this.logsList,
    required this.onTileTap,
    required this.expandedTile,
    required this.appState,
  });

  @override
  Widget build(BuildContext context) {
    // Group the logs by eatTime
    Map<String, List<Log>> groupedLogs = {
      'Breakfast': [],
      'Lunch': [],
      'Dinner': [],
      'Snacks': [],
    };

    for (var log in logsList) {
      if (groupedLogs.containsKey(log.eatTime)) {
        groupedLogs[log.eatTime]!.add(log);
      }
    }

    // Build the list view
    return ListView(
      children: groupedLogs.entries.expand<Widget>((entry) {
        // Create a section for each eatTime
        String eatTime = entry.key;
        List<Log> logs = entry.value;

        if (logs.isEmpty) return [];

        return [
          Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 16.0, bottom: 8.0),
            child: Text(
              eatTime,
              style: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 255, 228, 141),
              ),
            ),
          ),
          const Divider(),
          ...logs.map<Widget>((log) {
            final bool isExpanded = expandedTile == logsList.indexOf(log);
            return GestureDetector(
              onTap: () => onTileTap(logsList.indexOf(log)),
              child: AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutQuint,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: isExpanded
                            ? const Color.fromARGB(255, 255, 228, 141)
                            : Colors.grey,
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
                        subtitle: Text(
                          '${log.calories.toString()} cal from ${log.servingMeasured.toString()}${log.servingUnit}\nOpenFoodFacts BarCode ID:${log.foodId}',
                          maxLines: isExpanded ? null : 1,
                          overflow: isExpanded
                              ? TextOverflow.visible
                              : TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color.fromARGB(255, 190, 190, 190),
                          ),
                        ),
                        leading: isExpanded
                          ? const Icon(
                              Icons.keyboard_arrow_up_rounded,
                              color: Color.fromARGB(255, 255, 196, 0),
                              shadows: <Shadow>[
                                Shadow(
                                  blurRadius: 5,
                                  color: Color.fromARGB(255, 255, 196, 0),
                                ),
                              ],
                            )
                          : const Icon(
                              Icons.keyboard_arrow_down_rounded,
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
                                  MaterialPageRoute(
                                    builder: (context) => LogEntryView(log: log, appState: appState),
                                  ),
                                );
                              break;
                              case 'delete':
                                appState.deleteLog(
                                  log: log,
                                  onSuccess: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Log was successfully deleted.')),
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
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ];
      }).toList(),
    );
  }
}