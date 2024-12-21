import 'package:flutter/material.dart';
import 'package:pr_14_15/models/note.dart';

class NoteCard extends StatelessWidget {
  final Note note;
  final Function(Note) onTap;
  final Function(Note) onToggleFavorite;
  final Function(Note) onAddToCart;

  const NoteCard({
    Key? key,
    required this.note,
    required this.onTap,
    required this.onToggleFavorite,
    required this.onAddToCart,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(note),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Ограничиваем размер колонки
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Отображаем изображение товара
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(15)), // Закругляем изображение
              child: Image.network(
                note.imagePath,
                fit: BoxFit.cover,
                height: 135, // Установите нужную высоту для изображения
                width: double.infinity,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                note.title,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                '${note.price} ₽',
                style: TextStyle(fontSize: 14, color: Colors.green),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: Icon(note.isFav ? Icons.favorite : Icons.favorite_border),
                  onPressed: () => onToggleFavorite(note),
                ),
                IconButton(
                  icon: Icon(Icons.add_shopping_cart),
                  onPressed: () => onAddToCart(note),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
