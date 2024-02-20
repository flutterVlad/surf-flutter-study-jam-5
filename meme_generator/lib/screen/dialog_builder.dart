import 'package:flutter/material.dart';

import 'enums.dart';

/// Returns [AlertDialog] for edit meme.
Future<void> dialogBulder({
  required BuildContext context,
  required String title,
  required ContentType type,
  required List<String> savedItems,
  required TextEditingController controller,
  required void Function() onAccept,
  required void Function(String) onTakeSaved,
  void Function()? onTakeFromGallery,
}) async {
  final List<TextButton> items = savedItems
      .map(
        (e) => TextButton(
          onPressed: () {
            onTakeSaved(e);
            Navigator.of(context).pop();
          },
          child: Text(
            e,
            maxLines: 1,
            style: const TextStyle(color: Colors.blue),
          ),
        ),
      )
      .toList();

  return showDialog(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: Text(title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ...items,
          TextField(controller: controller),
        ],
      ),
      actions: <TextButton>[
        if (type == ContentType.image)
          TextButton(
            onPressed: () {
              onTakeFromGallery?.call();
              Navigator.of(context).pop();
            },
            child: const Text(
              'Выбрать из галереи',
              style: TextStyle(color: Colors.green),
            ),
          ),
        TextButton(
          onPressed: () {
            controller.clear();
            Navigator.of(context).pop();
          },
          child: const Text(
            'Назад',
            style: TextStyle(color: Colors.red),
          ),
        ),
        TextButton(
          onPressed: () {
            onAccept();
            controller.clear();
            Navigator.of(context).pop();
          },
          child: const Text(
            'Подвердить',
            style: TextStyle(color: Colors.blue),
          ),
        ),
      ],
    ),
  );
}

/// Updates a [savedList] with [item].
///
/// [savedList] can not have more then 5 elements.
void addInSaved(List<String> savedList, String item) {
  if (item.isNotEmpty) {
    savedList.insert(0, item);
    if (savedList.length > 5) {
      savedList.removeLast();
    }
    savedList.toSet().toList();
  }
}
