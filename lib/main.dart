import 'package:flutter/material.dart';
import 'controllers/device_controller.dart';
import 'controllers/setup_controller.dart';
import 'services/api_service.dart';
import 'services/logger_service.dart';
import 'services/storage_service.dart';
import 'views/home_view.dart';
import 'views/landing_page.dart';
import 'views/settings_view.dart';
import 'views/setup_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final logger = LoggerService('Main');
  logger.info('Starting LevelMate application');

  final storageService = await StorageService.init();
  final token = storageService.getToken();
  final apiService = ApiService(token: token);

  runApp(LevelMateApp(
    storageService: storageService,
    apiService: apiService,
  ));
}

class LevelMateApp extends StatelessWidget {
  final StorageService storageService;
  final ApiService apiService;

  const LevelMateApp({
    super.key,
    required this.storageService,
    required this.apiService,
  });

  @override
  Widget build(BuildContext context) {
    final hasToken = storageService.hasToken();
    final logger = LoggerService('LevelMateApp');
    logger.info('Building app with ${hasToken ? "existing" : "no"} token');

    return MaterialApp(
      title: 'LevelMate',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      initialRoute: hasToken ? '/home' : '/',
      routes: {
        '/': (context) => const LandingPage(),
        '/setup': (context) => SetupView(
              controller: SetupController(apiService, storageService),
            ),
        '/home': (context) => HomeView(
              controller: DeviceController(apiService),
              apiService: apiService,
            ),
        '/settings': (context) => SettingsView(
              storageService: storageService,
            ),
      },
    );
  }
}
