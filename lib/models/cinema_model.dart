class CinemaSchedule {
  final String cinemaName;
  final String screenType;
  final int price;
  final List<String> times;

  const CinemaSchedule({
    required this.cinemaName,
    required this.screenType,
    required this.price,
    required this.times,
  });

  factory CinemaSchedule.fromMap(Map<String, dynamic> map) {
    return CinemaSchedule(
      cinemaName: map['cinemaName'] ?? '',
      screenType: map['screenType'] ?? '',
      price: (map['price'] as num?)?.toInt() ?? 0,
      times: List<String>.from(map['times'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'cinemaName': cinemaName,
      'screenType': screenType,
      'price': price,
      'times': times,
    };
  }
}
