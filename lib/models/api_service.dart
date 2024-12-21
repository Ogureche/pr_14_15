import 'package:dio/dio.dart';
import 'package:pr_14_15/models/note.dart';

class ApiService {
  final Dio _dio = Dio();

  Future<List<Note>> getProducts() async {
    try {
      final response = await _dio.get('http://192.168.1.73:8080/products');
      if (response.statusCode == 200) {
        List<Note> products = (response.data as List)
            .map((product) => Note.fromJson(product))
            .toList();
        return products;
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      throw Exception('Error fetching products: $e');
    }
  }
}
//'http://192.168.1.73:8080/products'