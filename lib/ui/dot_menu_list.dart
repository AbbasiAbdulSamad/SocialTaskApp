import 'package:flutter/material.dart';

/// Model class (if needed directly)
class PopupMenuItemModel {
  final String value;
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  PopupMenuItemModel({required this.value, required this.label, required this.icon, required this.onTap,});
}

/// Reusable Dot Menu Widget
class DotMenuList extends StatelessWidget {
  final List<PopupMenuItemModel> items;
  final TextTheme textTheme;

  const DotMenuList({Key? key, required this.items, required this.textTheme,}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30,
      child: PopupMenuButton<String>(
        onSelected: (value) {
          final selected = items.firstWhere((item) => item.value == value);
          selected.onTap();
        },
        itemBuilder: (BuildContext context) => items.map((item) {
          return PopupMenuItem<String>(
            value: item.value,
            child: Row(
              children: [
                Icon(item.icon, size: 18),
                const SizedBox(width: 5),
                Text(item.label, style: textTheme.displaySmall),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// ✅ This is your simple function: just pass a list of maps
Widget getDefaultDotMenu(
    BuildContext context,
    List<Map<String, dynamic>> menuData,
    ) {
  final textTheme = Theme.of(context).textTheme;

  final List<PopupMenuItemModel> items = menuData.map((data) {
    return PopupMenuItemModel(
      value: data['value'] ?? '',
      label: data['label'] ?? '',
      icon: data['icon'] ?? Icons.help_outline,
      onTap: data['onTap'] ?? () {},
    );
  }).toList();

  return DotMenuList(
    items: items,
    textTheme: textTheme,
  );
}
