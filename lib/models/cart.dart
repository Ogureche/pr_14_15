import 'note.dart';

class CartItem {
  final Note note;
  int quantity;

  CartItem({required this.note, this.quantity = 1});
}