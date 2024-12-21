import 'package:flutter/material.dart';
import 'package:pr_14_15/models/note.dart';

class EditPage extends StatefulWidget {
  final Note note;
  final Function(Note) onUpdate;

  const EditPage({
    Key? key,
    required this.note,
    required this.onUpdate,
  }) : super(key: key);

  @override
  _EditPageState createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _photoController;
  late String _selectedCategory; // Добавлено: для хранения выбранной категории

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note.title);
    _descriptionController = TextEditingController(text: widget.note.description);
    _priceController = TextEditingController(text: widget.note.price.toString());
    _photoController = TextEditingController(text: widget.note.imagePath);
    _selectedCategory = widget.note.category; // Инициализация категории
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _photoController.dispose();
    super.dispose();
  }

  void _saveNote() {
    final updatedNote = Note(
      id: widget.note.id,
      title: _titleController.text,
      description: _descriptionController.text,
      imagePath: _photoController.text,
      price: double.tryParse(_priceController.text) ?? 0.0,
      category: _selectedCategory, // Передаем выбранную категорию
      isFav: widget.note.isFav,
    );

    widget.onUpdate(updatedNote);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Редактировать товар'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveNote,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Название'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Описание'),
            ),
            TextField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: 'Цена'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _photoController,
              decoration: const InputDecoration(labelText: 'URL изображения'),
            ),
            const SizedBox(height: 16.0),
            DropdownButton<String>(
              value: _selectedCategory,
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                });
              },
              items: ['Торты', 'Пирожные', 'Десерты'].map((category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
            ),
            if (_photoController.text.isNotEmpty)
              Image.network(
                _photoController.text,
                height: 150,
                fit: BoxFit.cover,
              ),
          ],
        ),
      ),
    );
  }
}
