import 'package:flutter/material.dart';
import 'package:flutter_application_for_us/screens/homes/Tixio_apps.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/booking_provider.dart';
import 'providers/location_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthState()),
        ChangeNotifierProvider(create: (_) => BookingState()),
        ChangeNotifierProvider(create: (_) => LocationState()),
      ],
      child: const TixioApp(),
    ),
  );
}
