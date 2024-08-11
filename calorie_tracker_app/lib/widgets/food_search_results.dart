import 'package:calorie_tracker_app/app_state.dart';
import 'package:calorie_tracker_app/models/food_product.dart';
import 'package:calorie_tracker_app/widgets/add_log_popup.dart';
import 'package:calorie_tracker_app/widgets/search_result_popup.dart';
import 'package:flutter/material.dart';

/// Builds a list of Log widgets.
/// Each list item is a GestureDetector that when tapped, expands the object to show the full food entry Log description.
/// An AnimatedSize widget is used to animate the expansion and contraction of the list items.
/// Each list item includes a ListTile displaying the food log entry's name and calories, an icon
/// indicating its expansion state, and a PopupMenuButton with options to edit or delete the log.
///
/// Arguments:
/// - logs: A List<Log> containing the logs to be displayed.
class FoodSearchResultsList extends StatefulWidget {
  final List<FoodProduct> products;
  final AppState appState;

  const FoodSearchResultsList({
    Key? key,
    required this.products,
    required this.appState,
  }) : super(key: key);

  @override
  _FoodProductListState createState() => _FoodProductListState();
}

class _FoodProductListState extends State<FoodSearchResultsList> {
  int? _expandedTile;

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      thumbVisibility: true,
      child: ListView.builder(
        itemCount: widget.products.length,
        itemBuilder: (context, index) {
          final FoodProduct product = widget.products[index];
          final bool isExpanded = _expandedTile == index;

          return GestureDetector(
            onTap: () {
              setState(() {
                _expandedTile = isExpanded ? null : index; // Toggle expansion state
                Feedback.forTap(context);
                // Handle tap feedback
              });
            },
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
                      title: Text(
                        '${product.name} ${product.quantity!.isNotEmpty ? '- ${product.quantity}' : ''}', 
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
                        '${product.calories?.toString() ?? 'Unknown'} cals per ${product.servingSize ?? 'Unknown'}. Product ID ${product.foodId}', 
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
                        color: const Color.fromARGB(255, 39, 39, 39),
                        iconColor: const Color.fromARGB(255, 255, 196, 0),
                        onSelected: (value) {
                          switch (value) {
                            case 'add':
                              _showAddFoodLogPopup(context, product, widget.appState);
                              break;
                              case 'open':
                              searchResultPopup(context, product); // Show product info
                              break;
                          }
                        },
                        itemBuilder: (BuildContext bc) {
                          return const [
                            PopupMenuItem(
                              value: 'add',
                              child: Text("Add to Log",
                                style: TextStyle(
                                    color: Color.fromARGB(255, 190, 190, 190),
                                    fontSize: 14,
                                  ),
                              ),
                            ),
                            PopupMenuItem(
                              value: 'open',
                              child: Text("View Product",
                                style: TextStyle(
                                    color: Color.fromARGB(255, 190, 190, 190),
                                    fontSize: 14,
                                  ),
                              ),
                            ),
                          ];
                        },
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  //handler method to allow the popup to show
  void _showAddFoodLogPopup(BuildContext context, FoodProduct product, AppState appState) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AddFoodLogPopup(
        product: product,
        appState: appState,
      );
    },
  );
}
}