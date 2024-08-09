import 'package:calorie_tracker_app/app_state.dart';
import 'package:calorie_tracker_app/pages/log_entry_view.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DayLogView extends StatelessWidget {
  final AppState appState;
  final List logsList;
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
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.miniCenterFloat,
        floatingActionButton: FloatingActionButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => LogEntryView(appState: appState),
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
          "${appState.user?.email?.split('@').first ?? 'User'}'s Calorie Log - ${DateFormat('M-d-yyyy').format(appState.date!)}",
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
            onPressed: () async {
              //Change the date to current time for debug
              print('Console Print: Attempt to change date');
              DateTime? pickDate = await showDatePicker(
                context: context,
                initialDate: appState.date,
                firstDate: DateTime(2000),
                lastDate: DateTime(2101),
              );
              if (pickDate != null) {
                appState.date = pickDate;
                appState.fetchLogs(pickDate);
                if (appState.date != null) {
                  print('Console Print: Updated AppState Date is ${DateFormat('M-d-yyyy').format(appState.date!)}');
                } else {
                  print('Console Print: ERROR appState.date returned as NULL');
                }
              }
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(30.0),
          child: Container(
            color: Colors.red,
            height: 30.0,
            width: double.infinity,
            alignment: Alignment.center,
            child: const Text(
              "Calories Consumed: 0",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
      body: logsList.isEmpty
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
          : ListView.builder(
              itemCount: logsList.length,
              itemBuilder: (context, index) {
                final log = logsList[index];
                final bool isExpanded = expandedTile == index;

                return GestureDetector(
                  onTap: () => onTileTap(index),
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
                              'Calories: ${log.calories.toString()}',
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
              },
            ),
    );
  }
}