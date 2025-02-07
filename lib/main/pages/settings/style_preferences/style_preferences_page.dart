import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:lookapp/enums/item_enums.dart';
import 'package:lookapp/providers/discover_provider.dart';
import 'package:lookapp/providers/item_provider.dart';
import 'package:lookapp/providers/user_preferences_provider.dart';

class StylePreferencesPage extends ConsumerWidget {
  const StylePreferencesPage({super.key});

  void _showNumberPicker(BuildContext context, WidgetRef ref, String title,
      {required int minValue,
      required int maxValue,
      required int currentValue,
      required Function(int) onChanged}) {
    int tempValue = currentValue;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: StatefulBuilder(
          builder: (context, setState) => NumberPicker(
            value: tempValue,
            minValue: minValue,
            maxValue: maxValue,
            onChanged: (value) {
              setState(() => tempValue = value);
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              onChanged(tempValue);
              Navigator.of(context).pop();
            },
            child: const Text(
              'Done',
              style: TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userPrefs = ref.watch(userPreferencesProvider);
    final theme = Theme.of(context);

    Widget buildSizeSelector(String title, String value, VoidCallback onTap) {
      return InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: theme.colorScheme.onPrimary,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onPrimary,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                value.isEmpty ? '—' : value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: value.isEmpty
                      ? theme.colorScheme.onPrimary.withOpacity(0.5)
                      : theme.colorScheme.secondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 42,
        leadingWidth: 120,
        leading: Row(
          children: [
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: Navigator.of(context).pop,
              icon: const Icon(Ionicons.chevron_back),
            ),
            Transform.translate(
              offset: const Offset(-12, 0),
              child: TextButton(
                onPressed: Navigator.of(context).pop,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Settings',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
        title: const Text(
          'Style',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text(
              'Save',
              style: TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Shop For',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: Sex.values.map((gender) {
                if (gender == Sex.unisex) {
                  return const SizedBox.shrink();
                } else {
                  return FilterChip(
                    label: Text(gender.displayName),
                    selected: userPrefs.sex == gender,
                    showCheckmark: false,
                    labelStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    selectedColor: Theme.of(context).colorScheme.secondary,
                    labelPadding: EdgeInsets.zero,
                    side: BorderSide(
                      color: userPrefs.sex == gender
                          ? Theme.of(context).colorScheme.secondary
                          : Theme.of(context).colorScheme.onPrimary,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        ref
                            .read(userPreferencesProvider.notifier)
                            .updateSex(gender);
                        ref.read(discoverProvider.notifier).updateState(
                          currentIndex: 0,
                          currentImageIndex: 0,
                          previousIndices: [],
                        );
                        ref.invalidate(itemsProvider);
                      }
                    },
                  );
                }
              }).toList(),
            ),
            const SizedBox(height: 16),
            Text(
              'Preferred Sizes',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            // Tops sizes (multi-select)
            Text(
              'Tops',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ['XS', 'S', 'M', 'L', 'XL'].map((size) {
                final isSelected = userPrefs.topSizes.contains(size);
                return FilterChip(
                  label: Text(size),
                  selected: isSelected,
                  showCheckmark: false,
                  labelStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  selectedColor: Theme.of(context).colorScheme.secondary,
                  labelPadding: EdgeInsets.zero,
                  side: BorderSide(
                    color: isSelected
                        ? Theme.of(context).colorScheme.secondary
                        : Theme.of(context).colorScheme.onPrimary,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  onSelected: (selected) {
                    ref.read(userPreferencesProvider.notifier).updateTopSizes(
                          selected
                              ? [...userPrefs.topSizes, size]
                              : userPrefs.topSizes
                                  .where((s) => s != size)
                                  .toList(),
                        );
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            // Bottoms sizes (number picker)
            Text(
              'Bottoms',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                buildSizeSelector(
                  'Waist',
                  userPrefs.bottomSizes['waist'] ?? '',
                  () => _showNumberPicker(
                    context,
                    ref,
                    'Select Waist Size',
                    minValue: 28,
                    maxValue: 36,
                    currentValue:
                        int.tryParse(userPrefs.bottomSizes['waist'] ?? '') ??
                            28,
                    onChanged: (value) {
                      ref
                          .read(userPreferencesProvider.notifier)
                          .updateBottomSize('waist', value.toString());
                    },
                  ),
                ),
                buildSizeSelector(
                  'Length',
                  userPrefs.bottomSizes['length'] ?? '',
                  () => _showNumberPicker(
                    context,
                    ref,
                    'Select Length',
                    minValue: 30,
                    maxValue: 36,
                    currentValue:
                        int.tryParse(userPrefs.bottomSizes['length'] ?? '') ??
                            30,
                    onChanged: (value) {
                      ref
                          .read(userPreferencesProvider.notifier)
                          .updateBottomSize('length', value.toString());
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Shoe size (number picker)
            Text(
              'Shoes',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 4),
            buildSizeSelector(
              'Size',
              userPrefs.shoeSize ?? '',
              () => _showNumberPicker(
                context,
                ref,
                'Select Shoe Size',
                minValue: 7,
                maxValue: 12,
                currentValue: int.tryParse(userPrefs.shoeSize ?? '') ?? 7,
                onChanged: (value) {
                  ref
                      .read(userPreferencesProvider.notifier)
                      .updateShoeSize(value.toString());
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
