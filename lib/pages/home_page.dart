import 'package:flutter/material.dart';
import 'package:pr_14_15/models/api_service.dart';
import 'package:pr_14_15/components/item.dart';
import 'package:pr_14_15/components/note_card.dart';
import 'package:pr_14_15/models/note.dart';
import 'package:pr_14_15/models/cart.dart';
import 'fav_page.dart';
import 'prof_page.dart';
import 'create_note_page.dart';
import 'basket.dart';
import 'edit_page.dart';
import 'note_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  List<Note> notes = [];
  List<Note> filteredNotes = [];
  List<Note> favorites = [];
  List<CartItem> cart = [];
  final ApiService apiService = ApiService();
  TextEditingController _searchController = TextEditingController();
  TextEditingController _minPriceController = TextEditingController(); // Контроллер для минимальной цены
  TextEditingController _maxPriceController = TextEditingController(); // Контроллер для максимальной цены

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      List<Note> products = await apiService.getProducts();
      setState(() {
        notes = products;
        filteredNotes = products; // Изначально отображаем все товары
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка загрузки товаров: $e')),
      );
    }
  }

  // Фильтрация товаров по названию
  void _filterNotes(String query) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final filtered = notes.where((note) {
        return note.title.toLowerCase().contains(query.toLowerCase());
      }).toList();
      setState(() {
        filteredNotes = filtered;
      });
    });
  }

  // Фильтрация товаров по цене
  void _filterByPrice() {
    double? minPrice = double.tryParse(_minPriceController.text);
    double? maxPrice = double.tryParse(_maxPriceController.text);

    if (minPrice != null && maxPrice != null) {
      setState(() {
        filteredNotes = notes.where((note) {
          return note.price >= minPrice && note.price <= maxPrice;
        }).toList();
      });
    } else {
      // Если цена введена неверно, показываем все товары
      setState(() {
        filteredNotes = notes;
      });
    }
  }

  // Сортировка товаров
  void _sortNotes(String sortType) {
    setState(() {
      if (sortType == 'A-Z') {
        filteredNotes.sort((a, b) => a.title.compareTo(b.title)); // От А до Я
      } else if (sortType == 'Z-A') {
        filteredNotes.sort((a, b) => b.title.compareTo(a.title)); // От Я до А
      } else if (sortType == 'Price Low-High') {
        filteredNotes.sort((a, b) => a.price.compareTo(b.price)); // По возрастанию цены
      } else if (sortType == 'Price High-Low') {
        filteredNotes.sort((a, b) => b.price.compareTo(a.price)); // По убыванию цены
      }
    });
  }

  // Добавление товара в список
  void _addNote(Note note) {
    setState(() {
      notes.add(note);
      filteredNotes.add(note); // Добавляем в отфильтрованный список тоже
    });
  }

  // Открытие карточки товара
  void _openNote(Note note) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NotePage(
          note: note,
          onUpdate: (updatedNote) {
            setState(() {
              int index = notes.indexWhere((n) => n.id == updatedNote.id);
              if (index != -1) {
                notes[index] = updatedNote;
                filteredNotes[index] = updatedNote;
              }
            });
          },
        ),
      ),
    );
  }

  // Удаление товара из списка
  void _deleteNote(int id) {
    setState(() {
      notes.removeWhere((note) => note.id == id);
      filteredNotes.removeWhere((note) => note.id == id);
    });
  }

  // Переключение состояния избранного товара
  void _toggleFavorite(Note note) {
    setState(() {
      if (favorites.contains(note)) {
        favorites.remove(note);
        note.isFav = false;
      } else {
        favorites.add(note);
        note.isFav = true;
      }
    });
  }

  // Удаление из избранных
  void _removeFromFavorites(Note note) {
    setState(() {
      favorites.remove(note);
      note.isFav = false;
    });
  }

  // Добавление товара в корзину
  void _addToCart(Note note) {
    setState(() {
      cart.add(CartItem(note: note));
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${note.title} добавлен в корзину')),
    );
  }

  // Обработка выбранного элемента в нижней панели
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget _getCurrentPage() {
      switch (_selectedIndex) {
        case 0:
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _minPriceController,
                        decoration: InputDecoration(
                          labelText: 'Минимальная цена',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _maxPriceController,
                        decoration: InputDecoration(
                          labelText: 'Максимальная цена',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.filter_list),
                      onPressed: _filterByPrice,
                    ),
                  ],
                ),
              ),
              Expanded(child: _buildNoteList()),
            ],
          );
        case 1:
          return FavPage(
            favorites: favorites,
            onOpenNote: _openNote,
            onRemoveFromFavorites: _removeFromFavorites,
            onAddToCart: _addToCart,
          );
        case 2:
          return ProfPage();
        default:
          return _buildNoteList();
      }
    }

    return Container(
      decoration: const BoxDecoration(
        color: Color.fromARGB(211, 255, 195, 175), // Цвет фона
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('CakeTime'),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => CreateNotePage(onCreate: _addNote),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.shopping_cart), // Иконка корзины
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        CartPage(cartItems: cart), // Передаем корзину
                  ),
                );
              },
            ),

            if (_selectedIndex == 0)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    showSearch(
                      context: context,
                      delegate: NoteSearchDelegate(_filterNotes),
                    );
                  },
                ),
              ),
            if (_selectedIndex == 0)
              PopupMenuButton<String>(
                onSelected: _sortNotes,
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'A-Z', child: Text('От А до Я')),
                  const PopupMenuItem(value: 'Z-A', child: Text('От Я до А')),
                  const PopupMenuItem(value: 'Price Low-High', child: Text('По возрастанию цены')),
                  const PopupMenuItem(value: 'Price High-Low', child: Text('По убыванию цены')),
                ],
              ),
          ],
        ),
        body: _getCurrentPage(),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Главная',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite),
              label: 'Избранные',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Профиль',
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: const Color.fromARGB(211, 255, 153, 115),
          unselectedItemColor: const Color.fromARGB(211, 193, 193, 193),
        ),
      ),
    );
  }

  Widget _buildNoteList() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.62,
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
      ),
      itemCount: filteredNotes.length,
      itemBuilder: (context, index) {
        final note = filteredNotes[index];
        return NoteCard(
          note: note,
          onTap: (note) => _openNote(note),
          onToggleFavorite: (note) {
            _toggleFavorite(note);
          },
          onAddToCart: (note) => _addToCart(note),
        );
      },
    );
  }
}

class NoteSearchDelegate extends SearchDelegate {
  final Function(String) onSearch;

  NoteSearchDelegate(this.onSearch);

  @override
  String? get searchFieldLabel => 'Поиск по названию';

  @override
  TextInputAction get textInputAction => TextInputAction.search;

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
          onSearch(query);
        },
      ),
    ];
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container();
  }

  @override
  Widget buildResults(BuildContext context) {
    onSearch(query);
    return Container();
  }
}