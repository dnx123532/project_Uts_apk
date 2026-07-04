class MovieModel {
  final String title;
  final String genre;
  final String imagePath;
  final String duration;
  final double rating;
  final String? trailerPath;
  final String synopsis;
  final String year;
  final String ageRating;
  final String cast;

  const MovieModel({
    required this.title,
    required this.genre,
    required this.imagePath,
    this.duration = '120 min',
    this.rating = 8.0,
    this.trailerPath,
    this.synopsis = '',
    this.year = '',
    this.ageRating = '',
    this.cast = '',
  });

  factory MovieModel.fromJson(Map<String, dynamic> json) {
    return MovieModel(
      title: json['title'] ?? 'Unknown',
      genre: json['genre'] ?? 'Unknown',
      imagePath: json['poster_url'] ?? '',
      duration: json['duration'] ?? '120 min',
      rating: (json['rating'] ?? 8.0).toDouble(),
      trailerPath: json['trailer_path'],
      synopsis: json['synopsis'] ?? '',
      year: json['year'] ?? '',
      ageRating: json['age_rating'] ?? '',
      cast: json['cast'] ?? '',
    );
  }

  factory MovieModel.fromMap(Map<String, dynamic> map) {
    return MovieModel(
      title: map['title'] ?? '',
      genre: map['genre'] ?? '',
      imagePath: map['imagePath'] ?? '',
      duration: map['duration'] ?? '120 min',
      rating: (map['rating'] ?? 8.0).toDouble(),
      trailerPath: map['trailerPath'],
      synopsis: map['synopsis'] ?? '',
      year: map['year'] ?? '',
      ageRating: map['ageRating'] ?? '',
      cast: map['cast'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'genre': genre,
      'imagePath': imagePath,
      'duration': duration,
      'rating': rating,
      'trailerPath': trailerPath,
      'synopsis': synopsis,
      'year': year,
      'ageRating': ageRating,
      'cast': cast,
    };
  }
}
