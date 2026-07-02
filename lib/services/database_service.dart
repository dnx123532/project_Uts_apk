import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';
import '../models/movie_models.dart';
import '../models/food_model.dart';
import '../models/booking_model.dart';

class DatabaseService {
  static Database? _database;

  Future<Database?> get database async {
    if (kIsWeb) return null;
    if (_database != null) return _database!;
    _database = await _initDB('tixio.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 5,
      onCreate: (db, version) async {
        await _createTables(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 5) {
          // Hapus cache lama agar data CDN dari Firestore langsung dipakai
          try { await db.execute('DELETE FROM movies'); } catch (_) {}
          try { await db.execute('DELETE FROM food_items'); } catch (_) {}
        }
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS food_items (
              id TEXT PRIMARY KEY,
              name TEXT,
              category TEXT,
              price INTEGER,
              imagePath TEXT,
              description TEXT
            )
          ''');
        }
        if (oldVersion < 3) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS bookings (
              id TEXT PRIMARY KEY,
              uid TEXT NOT NULL,
              movieTitle TEXT,
              movieImagePath TEXT,
              cinemaName TEXT,
              screenType TEXT,
              time TEXT,
              date TEXT,
              seats TEXT,
              ticketPrice INTEGER,
              foodOrder TEXT,
              paymentMethod TEXT,
              grandTotal INTEGER,
              bookedAt TEXT
            )
          ''');
        }
      },
    );
  }

  Future<void> _createTables(Database db) async {
    await db.execute('''
      CREATE TABLE movies (
        title TEXT PRIMARY KEY,
        genre TEXT,
        imagePath TEXT,
        duration TEXT,
        rating REAL,
        trailerPath TEXT,
        synopsis TEXT,
        year TEXT,
        ageRating TEXT,
        cast TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE food_items (
        id TEXT PRIMARY KEY,
        name TEXT,
        category TEXT,
        price INTEGER,
        imagePath TEXT,
        description TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE bookings (
        id TEXT PRIMARY KEY,
        uid TEXT NOT NULL,
        movieTitle TEXT,
        movieImagePath TEXT,
        cinemaName TEXT,
        screenType TEXT,
        time TEXT,
        date TEXT,
        seats TEXT,
        ticketPrice INTEGER,
        foodOrder TEXT,
        paymentMethod TEXT,
        grandTotal INTEGER,
        bookedAt TEXT
      )
    ''');
  }

  // ── MOVIES ──────────────────────────────────────────────────────────────────

  Future<void> cacheMovies(List<MovieModel> movies) async {
    if (kIsWeb) return;
    final db = await database;
    if (db == null) return;

    final batch = db.batch();
    batch.delete('movies');
    for (var movie in movies) {
      batch.insert('movies', movie.toMap());
    }
    await batch.commit();
  }

  Future<List<MovieModel>> getCachedMovies() async {
    if (kIsWeb) return [];
    final db = await database;
    if (db == null) return [];

    final result = await db.query('movies');
    return result.map((map) => MovieModel.fromMap(map)).toList();
  }

  // ── FOOD ITEMS ───────────────────────────────────────────────────────────────

  Future<void> cacheFoodItems(List<FoodItem> items) async {
    if (kIsWeb) return;
    final db = await database;
    if (db == null) return;

    final batch = db.batch();
    batch.delete('food_items');
    for (var item in items) {
      batch.insert('food_items', item.toMap());
    }
    await batch.commit();
  }

  Future<List<FoodItem>> getCachedFoodItems() async {
    if (kIsWeb) return [];
    final db = await database;
    if (db == null) return [];

    final result = await db.query('food_items');
    return result.map((map) => FoodItem.fromMap(map)).toList();
  }

  // ── BOOKINGS (per user, offline cache) ──────────────────────────────────────

  Future<void> saveBooking(String uid, BookingItem item) async {
    if (kIsWeb) return;
    final db = await database;
    if (db == null) return;

    await db.insert(
      'bookings',
      {
        'id': item.id,
        'uid': uid,
        'movieTitle': (item.movie?.title ?? '') as String,
        'movieImagePath': (item.movie?.imagePath ?? '') as String,
        'cinemaName': item.cinemaName,
        'screenType': item.screenType,
        'time': item.time,
        'date': item.date.toIso8601String(),
        'seats': jsonEncode(item.seats),
        'ticketPrice': item.ticketPrice,
        'foodOrder': jsonEncode(item.foodOrder),
        'paymentMethod': item.paymentMethod,
        'grandTotal': item.grandTotal,
        'bookedAt': item.bookedAt.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<BookingItem>> getCachedBookings(String uid) async {
    if (kIsWeb) return [];
    final db = await database;
    if (db == null) return [];

    final rows = await db.query(
      'bookings',
      where: 'uid = ?',
      whereArgs: [uid],
      orderBy: 'bookedAt DESC',
    );

    return rows.map((row) {
      return BookingItem(
        id: row['id'] as String,
        movie: BookingMovie(
          title: row['movieTitle'] as String? ?? '',
          imagePath: row['movieImagePath'] as String? ?? '',
        ),
        cinemaName: row['cinemaName'] as String,
        screenType: row['screenType'] as String,
        time: row['time'] as String,
        date: DateTime.parse(row['date'] as String),
        seats: List<String>.from(jsonDecode(row['seats'] as String)),
        ticketPrice: row['ticketPrice'] as int,
        foodOrder: (jsonDecode(row['foodOrder'] as String) as List)
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList(),
        paymentMethod: row['paymentMethod'] as String,
        grandTotal: row['grandTotal'] as int,
        bookedAt: DateTime.parse(row['bookedAt'] as String),
      );
    }).toList();
  }

  Future<void> clearUserBookings(String uid) async {
    if (kIsWeb) return;
    final db = await database;
    if (db == null) return;
    await db.delete('bookings', where: 'uid = ?', whereArgs: [uid]);
  }
}
