import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import 'theme/app_theme.dart';
import 'providers/countdown_provider.dart';
import 'providers/race_replay_provider.dart';
import 'providers/navigation_provider.dart';
import 'services/openf1_service.dart';
import 'services/circuit_service.dart';
import 'screens/countdown_screen.dart';
import 'screens/race_replay_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final client = http.Client();
  final openF1Service = HttpOpenF1Service(client);
  final circuitService = HttpCircuitService(client);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => CountdownProvider(openF1Service)..loadData(),
        ),
        ChangeNotifierProvider(
          create: (_) => RaceReplayProvider(openF1Service, circuitService)..loadYear(2026),
        ),
        ChangeNotifierProvider(
          create: (_) => NavigationProvider(),
        ),
      ],
      child: const F1CompanionApp(),
    ),
  );
}

class F1CompanionApp extends StatelessWidget {
  const F1CompanionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'F1 Companion',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late final NavigationProvider _navigationProvider;

  @override
  void initState() {
    super.initState();
    _navigationProvider = Provider.of<NavigationProvider>(context, listen: false);
    _navigationProvider.addListener(_onNavigationChanged);
  }

  @override
  void dispose() {
    _navigationProvider.removeListener(_onNavigationChanged);
    super.dispose();
  }

  void _onNavigationChanged() {
    if (!mounted) return;
    final countdownProvider = Provider.of<CountdownProvider>(context, listen: false);
    final replayProvider = Provider.of<RaceReplayProvider>(context, listen: false);

    if (_navigationProvider.currentIndex == 0) {
      countdownProvider.startTimer();
      replayProvider.pause();
    } else {
      countdownProvider.stopTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    final navigationProvider = Provider.of<NavigationProvider>(context);
    final currentIndex = navigationProvider.currentIndex;

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: const [
          CountdownScreen(),
          RaceReplayScreen(),
        ],
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashColor: AppTheme.primary.withValues(alpha: 0.1),
          highlightColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) => navigationProvider.setTab(index),
          backgroundColor: AppTheme.surface,
          selectedItemColor: AppTheme.primary,
          unselectedItemColor: AppTheme.textMuted,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          selectedLabelStyle: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.timer),
              activeIcon: Icon(Icons.timer),
              label: 'Countdown',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.map_outlined),
              activeIcon: Icon(Icons.map),
              label: 'Race Replay',
            ),
          ],
        ),
      ),
    );
  }
}
