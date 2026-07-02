import 'package:project_uts_apk/providers/auth_provider.dart';
import 'package:project_uts_apk/providers/booking_provider.dart';
import 'package:project_uts_apk/providers/location_provider.dart';
import 'package:project_uts_apk/providers/watchlist_provider.dart';

// Global state singletons — dipakai di seluruh app
final AuthState authState = AuthState();
final BookingState bookingState = BookingState();
final LocationState locationState = LocationState();
final WatchlistState watchlistState = WatchlistState();
