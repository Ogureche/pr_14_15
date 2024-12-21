import 'package:flutter/material.dart';
import 'package:pr_14_15/models/cart.dart';
import 'package:pr_14_15/components/item.dart';
import 'package:pr_14_15/components/cart_card.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CartPage extends StatefulWidget {
  final List<CartItem> cartItems;

  const CartPage({Key? key, required this.cartItems}) : super(key: key);

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  void _removeItem(int index) {
    setState(() {
      widget.cartItems.removeAt(index);
    });
  }

  void _incrementItem(int index, bool add) {
    setState(() {
      if (add) {
        widget.cartItems[index].quantity++;
      } else {
        widget.cartItems[index].quantity--;
      }

      if (widget.cartItems[index].quantity <= 0) {
        widget.cartItems.removeAt(index);
      }
    });
  }

  Future<void> _checkout() async {
    if (widget.cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Корзина пуста!')),
      );
      return;
    }

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        throw Exception('Пользователь не авторизован.');
      }

      final totalPrice = widget.cartItems.fold(
        0.0,
            (sum, item) => sum + (item.note.price * item.quantity),
      );

      // Сохраняем заказ в таблицу "orders"
      await Supabase.instance.client.from('orders').insert({
        'user_id': user.id,
        'total_price': totalPrice,
        'items': widget.cartItems.map((item) => {
          'product_name': item.note.title,
          'quantity': item.quantity,
          'price': item.note.price,
        }).toList(),
        'created_at': DateTime.now().toIso8601String(),
      });

      // Очищаем корзину
      setState(() {
        widget.cartItems.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Заказ успешно оформлен!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка оформления заказа: $e')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Корзина'),
      ),
      body: widget.cartItems.isEmpty
          ? const Center(
        child: Text(
          "Попробуйте добавить товар в корзину",
          style: TextStyle(fontSize: 15),
          textAlign: TextAlign.center,
        ),
      )
          : Stack(
        children: [
          ListView.builder(
            itemCount: widget.cartItems.length,
            itemBuilder: (BuildContext context, int index) {
              return CartCard(
                cartItem: widget.cartItems[index],
                itemIndex: index,
                removeItem: _removeItem,
                incrementItem: _incrementItem,
              );
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    borderRadius:
                    const BorderRadius.all(Radius.circular(20)),
                    color: Theme.of(context).disabledColor,
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Суммарная стоимость корзины: ${widget.cartItems.fold(0.0, (sum, item) => sum + (item.note.price * item.quantity))} ₽',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: _checkout,
                  child: const Text('Оформить заказ'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
