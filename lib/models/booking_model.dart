class BookingMovie {
  final String title;
  final String imagePath;
  const BookingMovie({required this.title, required this.imagePath});
}

class BookingItem {
  final String id;
  final dynamic movie;
  final String cinemaName;
  final String screenType;
  final String time;
  final DateTime date;
  final List<String> seats;
  final int ticketPrice;
  final List<Map<String, dynamic>> foodOrder;
  final String paymentMethod;
  final int grandTotal;
  final DateTime bookedAt;

  BookingItem({
    required this.id,
    required this.movie,
    required this.cinemaName,
    required this.screenType,
    required this.time,
    required this.date,
    required this.seats,
    required this.ticketPrice,
    required this.foodOrder,
    required this.paymentMethod,
    required this.grandTotal,
    required this.bookedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'movieTitle': (movie?.title ?? '') as String,
      'movieImagePath': (movie?.imagePath ?? '') as String,
      'cinemaName': cinemaName,
      'screenType': screenType,
      'time': time,
      'date': date.toIso8601String(),
      'seats': seats,
      'ticketPrice': ticketPrice,
      'foodOrder': foodOrder,
      'paymentMethod': paymentMethod,
      'grandTotal': grandTotal,
      'bookedAt': bookedAt.toIso8601String(),
    };
  }

  factory BookingItem.fromMap(Map<String, dynamic> map) {
    return BookingItem(
      id: map['id'] as String,
      movie: BookingMovie(
        title: map['movieTitle'] as String? ?? '',
        imagePath: map['movieImagePath'] as String? ?? '',
      ),
      cinemaName: map['cinemaName'] as String,
      screenType: map['screenType'] as String,
      time: map['time'] as String,
      date: DateTime.parse(map['date'] as String),
      seats: List<String>.from(map['seats'] as List),
      ticketPrice: map['ticketPrice'] as int,
      foodOrder: (map['foodOrder'] as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList(),
      paymentMethod: map['paymentMethod'] as String,
      grandTotal: map['grandTotal'] as int,
      bookedAt: DateTime.parse(map['bookedAt'] as String),
    );
  }
}
