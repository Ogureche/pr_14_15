import 'package:flutter/material.dart';
import 'package:pr_14_15/models/note.dart';
import 'edit_page.dart';

class NotePage extends StatelessWidget {
  final Note note;
  final Function(Note) onUpdate;

  const NotePage({Key? key, required this.note, required this.onUpdate}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(note.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditPage(
                    note: note,
                    onUpdate: onUpdate,
                  ),
                ),
              ).then((updatedNote) {
                if (updatedNote != null) {
                  onUpdate(updatedNote); // Обновляем заметку
                }
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Отображение изображения заметки
            if (note.imagePath.isNotEmpty) // Проверяем, что поле не пустое
              Image.network(note.imagePath), // Используйте Image.network для загрузки изображения
            const SizedBox(height: 10),
            Text(
              note.description,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text(
              'Цена: ${note.price}₽',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}