import 'package:dio/dio.dart';
import '../models/movie_models.dart';
import '../models/food_model.dart';
import '../models/cinema_model.dart';

class ApiService {
  final Dio _dio = Dio();

  final String _movieUrl  = 'https://api.npoint.io/b1540683fe1da1c6f09c';
  final String _foodUrl   = 'https://api.npoint.io/8f6c8c907aad37f15214';
  final String _cinemaUrl = 'https://api.npoint.io/e649bf8653754fd7c1bb';

  Future<List<MovieModel>> fetchMovies() async {
    final response = await _dio.get(_movieUrl);
    final List data = response.data['data'] ?? response.data;
    return data.map((json) => MovieModel.fromJson(json)).toList();
  }

  Future<List<FoodItem>> fetchFoodItems() async {
    final response = await _dio.get(_foodUrl);
    final List data = response.data['data'] ?? response.data;
    return data
        .map((json) => FoodItem.fromMap(Map<String, dynamic>.from(json)))
        .toList();
  }

  Future<Map<String, List<CinemaSchedule>>> fetchCinemas() async {
    final response = await _dio.get(_cinemaUrl);
    final List data = response.data['data'] ?? response.data;

    final Map<String, List<CinemaSchedule>> result = {};
    for (var item in data) {
      final city = item['city'] as String;
      result.putIfAbsent(city, () => []);
      result[city]!.add(CinemaSchedule.fromMap(Map<String, dynamic>.from(item)));
    }
    return result;
  }
}
