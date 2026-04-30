import 'package:project_uts_apk/models/movie_models.dart';
import 'package:project_uts_apk/providers/auth_provider.dart';
import 'package:project_uts_apk/providers/location_provider.dart';

final AuthState authState = AuthState();

final LocationState locationState = LocationState();

// EDIT FILM NOW SHOWING DI SINI
final List<MovieModel> nowShowingMovies = [
  MovieModel(
    title: 'Avengers: Endgame',
    genre: 'Action, Adventure, Sci-Fi',
    imagePath: 'assets/images/avengerendgame.webp',
    duration: '181 min',
    rating: 8.4,
  ),
  MovieModel(
    title: 'chainsaw man',
    genre: 'Action, Anime, Supernatural',
    imagePath: 'assets/images/chainsawman.jpeg',
    duration: '97 min',
    rating: 8.5,
  ),
  MovieModel(
    title: 'the dark knight',
    genre: 'Action, Crime, Drama',
    imagePath: 'assets/images/thedarkknight.jpeg',
    duration: '152 min',
    rating: 9.0,
  ),
  MovieModel(
    title: 'Look back',
    genre: 'Drama, Slice of Life, Anime',
    imagePath: 'assets/images/lookback.jpeg',
    duration: '58 min',
    rating: 8.3,
  ),
  MovieModel(
    title: 'merah putih: one for all',
    genre: 'Action, War, Drama',
    imagePath: 'assets/images/oneforall.jpeg',
    duration: '110 min',
    rating: 7.2,
  ),
  MovieModel(
    title: 'jujutsu kaisen 0',
    genre: 'Action, Fantasy, Anime',
    imagePath: 'assets/images/jujutsukaisen.jpeg',
    duration: '105 min',
    rating: 7.8,
  ),
  MovieModel(
    title: 'now you see me',
    genre: 'Crime, Thriller, Mystery',
    imagePath: 'assets/images/nowyouseeme.jpeg',
    duration: '115 min',
    rating: 7.3,
  ),
  MovieModel(
    title: 'The Conjuring',
    genre: 'Horror, Mystery, Thrille',
    imagePath: 'assets/images/theconjuring.webp',
    duration: '112 min',
    rating: 7.5,
  ),
  MovieModel(
    title: 'toy story 4',
    genre: 'Animation, Adventure, Comedy',
    imagePath: 'assets/images/toystory4.jpeg',
    duration: '100 min',
    rating: 7.7,
  ),
  MovieModel(
    title: 'avengers: infinity war',
    genre: 'Action, Adventure, Sci-Fi',
    imagePath: 'assets/images/avengersinfinitywar.jpeg',
    duration: '149 min',
    rating: 8.4,
  ),
];

// EDIT FILM UPCOMING DI SINI
final List<MovieModel> upcomingMovies = [
  MovieModel(
    title: 'Upcoming 1',
    genre: 'Genre',
    imagePath: 'assets/images/upcoming1.jpg',
    duration: 'Coming Soon',
    rating: 0,
  ),
  MovieModel(
    title: 'Upcoming 2',
    genre: 'Genre',
    imagePath: 'assets/images/upcoming2.jpg',
    duration: 'Coming Soon',
    rating: 0,
  ),
];
