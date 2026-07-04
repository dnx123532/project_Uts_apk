import 'package:flutter/material.dart';
import 'package:project_uts_apk/data/data_film.dart';
import 'package:project_uts_apk/providers/chat_provider.dart';
import 'package:project_uts_apk/screens/bookings/booking_page.dart';
import 'package:project_uts_apk/screens/chat/chat_screen.dart';
import 'package:project_uts_apk/screens/food_and_beverages/fnb_page.dart';
import 'package:project_uts_apk/screens/login/login_screen.dart';
import 'package:project_uts_apk/screens/movie/cinema_page.dart';
import 'package:provider/provider.dart';

import 'home_content.dart';

// HOME SCREEN
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeContent(
        onSeeAllTap: () {
          setState(() => _currentIndex = 2);
        },
      ),
      const BookingPage(),
      const MoviePage(),
      const CinemaPage(),
      const FnBPage(),
    ];

    return AnimatedBuilder(
      animation: authState,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(child: pages[_currentIndex]),
          floatingActionButton: FloatingActionButton(
            backgroundColor: const Color(0xFF1A237E),
            foregroundColor: Colors.white,
            tooltip: 'Chat dengan Tixi',
            child: const Icon(Icons.smart_toy_rounded),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => ChangeNotifierProvider.value(
                  value: context.read<ChatProvider>(),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.82,
                    child: const ChatScreen(),
                  ),
                ),
              );
            },
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            // Cari di dalam class _HomeScreenState bagian onTap:
            // Cari di dalam class _HomeScreenState bagian onTap:
            onTap: (i) {
              // Wajib login untuk tab Booking(1), Cinema(3), dan F&B(4)
              if ((i == 1 || i == 3 || i == 4) && !authState.isLoggedIn) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Login dulu yuk buat akses fitur ini!"),
                    backgroundColor: Color(0xFF1A237E),
                  ),
                );
              } else {
                setState(() => _currentIndex = i);
              }
            },
            type: BottomNavigationBarType.fixed,
            selectedItemColor: const Color(0xFF1A237E),
            unselectedItemColor: Colors.grey,
            selectedFontSize: 11,
            unselectedFontSize: 11,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.confirmation_number_outlined),
                label: 'My Booking',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.movie_filter_outlined),
                label: 'Movie',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.theaters_outlined),
                label: 'Cinema',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.local_dining_outlined),
                label: 'F&B',
              ),
            ],
          ),
        );
      },
    );
  }
}
