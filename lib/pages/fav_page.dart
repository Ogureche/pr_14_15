import 'package:flutter/material.dart';
import 'package:pr_14_15/models/note.dart';
import 'package:pr_14_15/components/note_card.dart';

class FavPage extends StatelessWidget {
  final List<Note> favorites;
  final Function(Note) onOpenNote;
  final Function(Note) onRemoveFromFavorites;
  final Function(Note) onAddToCart; // Добавляем новый параметр
  final Color backgroundColor;

  const FavPage({
    Key? key,
    required this.favorites,
    required this.onOpenNote,
    required this.onRemoveFromFavorites,
    required this.onAddToCart, // Добавляем новый параметр
    this.backgroundColor = const Color.fromARGB(211, 255, 195, 175),
  }) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: favorites.isEmpty
          ? const Center(child: Text('Нет избранных товаров'))
          : Padding(
        padding: const EdgeInsets.all(0.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.62,
            crossAxisSpacing: 10.0,
            mainAxisSpacing: 10.0,
          ),

          itemCount: favorites.length,
          itemBuilder: (context, index) {
            final note = favorites[index];
            return NoteCard(
              note: note,
              onTap: (note) => onOpenNote(note),
              onToggleFavorite: (note) {
                onRemoveFromFavorites(note);
              },
              onAddToCart: (note) => onAddToCart(note),
            );
          },
        ),
      ),
    );
  }
}