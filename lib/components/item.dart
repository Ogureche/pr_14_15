import 'package:flutter/material.dart';
import 'package:pr_14_15/models/note.dart';

class Item extends StatelessWidget {
  final Note note;
  final Function(int) onDelete;

  const Item({
    Key? key,
    required this.note,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(note.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red), // Иконка мусорного ведра
            onPressed: () {
              _showDeleteConfirmationDialog(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (note.imagePath.isNotEmpty)
              Image.network(note.imagePath),
            const SizedBox(height: 16),
            Text(note.title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(note.description),
            const SizedBox(height: 8),
            Text('${note.price} ₽', style: TextStyle(color: Colors.green)),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Подтверждение'),
          content: const Text('Вы уверены, что хотите удалить этот товар?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Закрыть диалог
              },
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () {
                onDelete(note.id); // Вызов функции удаления
                Navigator.of(context).pop(); // Закрыть диалог
                Navigator.of(context).pop(); // Вернуться на предыдущий экран
              },
              child: const Text('Удалить'),
            ),
          ],
        );
      },
    );
  }
}