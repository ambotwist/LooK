import 'package:flutter/material.dart';

class FilterDropdown extends StatelessWidget {
  final String label;
  final List<PopupMenuItem<String>> items;
  final Function(String) onSelected;
  final double height;
  final EdgeInsetsGeometry? padding;
  final Set<String>? selectedValues;

  const FilterDropdown({
    super.key,
    required this.label,
    required this.items,
    required this.onSelected,
    this.height = 32,
    this.padding,
    this.selectedValues,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(
          color: theme.colorScheme.tertiary,
        ),
        borderRadius: BorderRadius.circular(40),
      ),
      child: PopupMenuButton<String>(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        position: PopupMenuPosition.under,
        color: theme.colorScheme.primary,
        itemBuilder: (context) => [
          // Reset option
          PopupMenuItem(
            value: '',
            child: Row(
              children: [
                Icon(
                  Icons.refresh,
                  color: theme.colorScheme.onPrimary,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'Reset $label',
                  style: TextStyle(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // Divider
          PopupMenuItem(
            enabled: false,
            height: 1,
            child: Divider(
              color: theme.colorScheme.onPrimary.withOpacity(0.2),
              height: 1,
            ),
          ),
          // Regular items with checkmarks
          ...items.map((item) => PopupMenuItem(
                value: item.value,
                child: Row(
                  children: [
                    if (selectedValues?.contains(item.value) ?? false)
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Icon(
                          Icons.check,
                          color: theme.colorScheme.onPrimary,
                          size: 18,
                        ),
                      ),
                    if (!(selectedValues?.contains(item.value) ?? false))
                      const SizedBox(width: 26),
                    DefaultTextStyle(
                      style: TextStyle(
                        color: theme.colorScheme.onPrimary,
                      ),
                      child: item.child!,
                    ),
                  ],
                ),
              )),
        ],
        onSelected: onSelected,
        child: Padding(
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 12.0),
          child: Row(
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.arrow_drop_down,
                color: theme.colorScheme.tertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
