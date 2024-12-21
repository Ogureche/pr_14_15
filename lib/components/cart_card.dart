import 'package:flutter/material.dart';
import 'package:pr_14_15/models/cart.dart';

class CartCard extends StatelessWidget {
  final CartItem cartItem;
  final int itemIndex;
  final Function(int) removeItem;
  final Function(int, bool) incrementItem;

  const CartCard({
    Key? key,
    required this.cartItem,
    required this.itemIndex,
    required this.removeItem,
    required this.incrementItem,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Image.network(
          cartItem.note.imagePath,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
        ),
        title: Text(cartItem.note.title),
        subtitle: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${cartItem.note.price} ₽'),
            Text('Количество: ${cartItem.quantity}'),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () => removeItem(itemIndex), // Удаление товара из корзины
        ),
      ),
    );
  }
}