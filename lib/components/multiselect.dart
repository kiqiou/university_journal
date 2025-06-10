import 'package:flutter/material.dart';

class MultiSelectDialog<T> extends StatefulWidget {
  final List<T> items;
  final List<T> initiallySelected;
  final String Function(T) itemLabel;

  const MultiSelectDialog({
    super.key,
    required this.items,
    required this.initiallySelected,
    required this.itemLabel,
  });

  @override
  State<MultiSelectDialog<T>> createState() => _MultiSelectDialogState<T>();
}

class _MultiSelectDialogState<T> extends State<MultiSelectDialog<T>> {
  late List<T> selected;

  @override
  void initState() {
    super.initState();
    selected = [...widget.initiallySelected];
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Выберите элементы'),
      content: SingleChildScrollView(
        child: ListBody(
          children: widget.items.map((item) {
            final isSelected = selected.contains(item);
            return CheckboxListTile(
              value: isSelected,
              title: Text(widget.itemLabel(item)),
              onChanged: (bool? value) {
                setState(() {
                  if (value == true) {
                    selected.add(item);
                  } else {
                    selected.remove(item);
                  }
                });
              },
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          child: const Text('Отмена'),
          onPressed: () => Navigator.pop(context),
        ),
        ElevatedButton(
          child: const Text('Готово'),
          onPressed: () => Navigator.pop(context, selected),
        ),
      ],
    );
  }
}
