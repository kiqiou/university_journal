import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../colors/colors.dart';

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
  late List<T> filteredItems;
  late List<T> selectedItems;
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredItems = widget.items;
    selectedItems = List.from(widget.initiallySelected);

    searchController.addListener(() {
      final query = searchController.text.toLowerCase();
      setState(() {
        filteredItems = widget.items.where((item) {
          return widget.itemLabel(item).toLowerCase().contains(query);
        }).toList();
      });
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Выберите', style: TextStyle(color: Colors.grey.shade700)),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200, width: 1.5),
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width / 2,
        height: 400,
        child: Column(
          children: [
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Поиск',
                prefixIcon: Icon(Icons.search, color: Colors.grey.shade700,),
              ),
            ),
            SizedBox(height: 12),
            Expanded(
              child: filteredItems.isEmpty
                  ? Center(child: Text('Не найдено'))
                  : ListView.builder(
                itemCount: filteredItems.length,
                itemBuilder: (_, index) {
                  final item = filteredItems[index];
                  final isSelected = selectedItems.contains(item);
                  return CheckboxListTile(
                    value: isSelected,
                    side: BorderSide(color: Colors.grey.shade700),
                    activeColor: MyColors.blueJournal,
                    title: Text(widget.itemLabel(item)),
                    onChanged: (checked) {
                      setState(() {
                        if (checked == true) {
                          selectedItems.add(item);
                        } else {
                          selectedItems.remove(item);
                        }
                      });
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: Text('Отмена', style: TextStyle(fontSize: 16, color: MyColors.blueJournal),),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(selectedItems),
          child: Text('Выбрать', style: TextStyle(fontSize: 16, color: MyColors.blueJournal)),
        ),
      ],
    );
  }
}