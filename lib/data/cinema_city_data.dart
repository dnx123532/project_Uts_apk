// Data bioskop Medan - edit jadwal & harga sesuai kebutuhan
// ─── DATA BIOSKOP 10 KOTA ──────────────────────────────────────────────────
import 'package:flutter_application_for_us/models/cinema_model.dart';

final Map<String, List<CinemaSchedule>> cityCinemas = {
  'Jakarta': [
    const CinemaSchedule(
      cinemaName: 'Grand Indonesia',
      screenType: 'REGULAR 2D',
      price: 60000,
      times: ['12:00', '14:30', '17:00', '19:30'],
    ),
    const CinemaSchedule(
      cinemaName: 'Senayan City',
      screenType: 'IMAX 2D',
      price: 85000,
      times: ['13:00', '16:00', '19:00'],
    ),
    const CinemaSchedule(
      cinemaName: 'Kelapa Gading',
      screenType: 'VIP 2D',
      price: 120000,
      times: ['14:00', '18:00', '20:30'],
    ),
  ],
  'Bandung': [
    const CinemaSchedule(
      cinemaName: 'Ciwalk',
      screenType: 'REGULAR 2D',
      price: 45000,
      times: ['12:30', '15:00', '18:00', '20:30'],
    ),
    const CinemaSchedule(
      cinemaName: 'Paris Van Java',
      screenType: 'REGULAR 2D',
      price: 50000,
      times: ['13:15', '16:15', '19:15'],
    ),
    const CinemaSchedule(
      cinemaName: 'Trans Studio Mall',
      screenType: 'MACRO XE',
      price: 65000,
      times: ['14:00', '17:30'],
    ),
  ],
  'Bali': [
    const CinemaSchedule(
      cinemaName: 'Beachwalk',
      screenType: 'REGULAR 2D',
      price: 60000,
      times: ['13:00', '16:00', '19:00'],
    ),
    const CinemaSchedule(
      cinemaName: 'Level 21',
      screenType: 'REGULAR 2D',
      price: 55000,
      times: ['12:30', '15:30', '18:30'],
    ),
  ],
  'Balikpapan': [
    const CinemaSchedule(
      cinemaName: 'Pentacity',
      screenType: 'REGULAR 2D',
      price: 50000,
      times: ['12:00', '14:30', '17:00'],
    ),
    const CinemaSchedule(
      cinemaName: 'E-Walk',
      screenType: 'REGULAR 2D',
      price: 45000,
      times: ['13:00', '15:30', '18:00'],
    ),
  ],
  'Batam': [
    const CinemaSchedule(
      cinemaName: 'Mega Mall',
      screenType: 'REGULAR 2D',
      price: 40000,
      times: ['12:15', '15:15', '18:15'],
    ),
    const CinemaSchedule(
      cinemaName: 'Grand Batam Mall',
      screenType: 'REGULAR 2D',
      price: 45000,
      times: ['13:30', '16:30', '19:30'],
    ),
  ],
  'Bekasi': [
    const CinemaSchedule(
      cinemaName: 'Summarecon Mall',
      screenType: 'IMAX 2D',
      price: 65000,
      times: ['12:00', '15:00', '18:00'],
    ),
    const CinemaSchedule(
      cinemaName: 'Mega Bekasi',
      screenType: 'REGULAR 2D',
      price: 40000,
      times: ['13:00', '15:30', '18:30'],
    ),
  ],
  'Bogor': [
    const CinemaSchedule(
      cinemaName: 'Botani Square',
      screenType: 'REGULAR 2D',
      price: 45000,
      times: ['12:45', '15:45', '18:45'],
    ),
    const CinemaSchedule(
      cinemaName: 'Cibinong City',
      screenType: 'REGULAR 2D',
      price: 40000,
      times: ['13:15', '16:15', '19:15'],
    ),
  ],
  'Makassar': [
    const CinemaSchedule(
      cinemaName: 'Trans Studio Mall',
      screenType: 'REGULAR 2D',
      price: 50000,
      times: ['12:00', '14:30', '17:00'],
    ),
    const CinemaSchedule(
      cinemaName: 'Panakkukang',
      screenType: 'REGULAR 2D',
      price: 45000,
      times: ['13:00', '15:30', '18:00'],
    ),
  ],
  'Palembang': [
    const CinemaSchedule(
      cinemaName: 'Palembang Icon',
      screenType: 'REGULAR 2D',
      price: 45000,
      times: ['12:30', '15:00', '17:30'],
    ),
    const CinemaSchedule(
      cinemaName: 'Palembang Square',
      screenType: 'REGULAR 2D',
      price: 40000,
      times: ['13:00', '15:30', '18:00'],
    ),
  ],
  'Medan': [
    const CinemaSchedule(
      cinemaName: 'Plaza Medan Fair',
      screenType: 'REGULAR 2D',
      price: 44000,
      times: ['12:00', '13:25', '14:25', '16:50', '19:15', '21:40'],
    ),
    const CinemaSchedule(
      cinemaName: 'Lippo Plaza Medan',
      screenType: 'REGULAR 2D',
      price: 37000,
      times: ['12:00', '14:20', '16:40', '19:00'],
    ),
    const CinemaSchedule(
      cinemaName: 'Sun Plaza',
      screenType: 'IMAX 2D',
      price: 65000,
      times: ['13:00', '16:00', '20:00'],
    ),
    const CinemaSchedule(
      cinemaName: 'Hermes Place',
      screenType: 'REGULAR 2D',
      price: 35000,
      times: ['13:30', '16:00', '18:30'],
    ),
  ],
};
