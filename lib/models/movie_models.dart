// import 'package:flutter/material.dart';

// DATA FILM
class MovieModel {
  final String title;
  final String genre;
  final String imagePath;
  final String duration;
  final double rating;
  final String? trailerPath; // ← tambah ini
  final String synopsis;
  const MovieModel({
    required this.title,
    required this.genre,
    required this.imagePath,
    this.duration = '120 min',
    this.rating = 8.0,
    this.trailerPath, // ← tambah ini
    this.synopsis = '',
  });
}
