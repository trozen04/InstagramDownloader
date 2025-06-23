import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'Screens/APIBloc/insta_downloader_bloc.dart';
import 'Screens/Dashboard/home_screen.dart';
import 'Screens/Download/download_history.dart';
import 'Screens/Download/download_screen.dart';
import 'Screens/Static/about_screen.dart';
import 'Screens/Static/contact_me_screen.dart';
import 'Utils/flutter_color_themes.dart';
import 'Widgets/custom_navigator.dart';
import 'screens/splash_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer' as developer;

final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();
String? sharedText;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  developer.log('Main: Starting app initialization', name: 'MainApp');
  FlutterError.onError = (details) {
    developer.log('FlutterError: ${details.exceptionAsString()}, stack: ${details.stack}', name: 'MainApp');
  };
  try {
    const MethodChannel _channel = MethodChannel('app.channel.shared.data');
    developer.log('Main: Setting up MethodChannel', name: 'MainApp');
    _channel.setMethodCallHandler((call) async {
      developer.log('Main: MethodChannel called: method=${call.method}, args=${call.arguments}', name: 'MainApp');
      if (call.method == 'getSharedText') {
        sharedText = call.arguments as String?;
        developer.log('Main: Received shared text: $sharedText', name: 'MainApp');
      }
    });
    MobileAds.instance.initialize().then((_) {
      developer.log('Main: MobileAds initialized successfully', name: 'MainApp');
    }).catchError((e) {
      developer.log('Main: Error initializing MobileAds: $e', name: 'MainApp');
    });
    developer.log('Main: Running app', name: 'MainApp');
    runApp(const MyApp());
  } catch (e) {
    developer.log('Main: Error during app initialization: $e', name: 'MainApp');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    developer.log('MyApp: Building widget tree', name: 'MainApp');
    return MultiBlocProvider(
      providers: [
        BlocProvider<InstaDownloaderBloc>(create: (context) => InstaDownloaderBloc()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        navigatorObservers: [routeObserver],
        title: 'Instagram Downloader',
        theme: ThemeData(
          textTheme: GoogleFonts.outfitTextTheme(),
          primaryColor: AppColors.buttoncolor,
          scaffoldBackgroundColor: AppColors.my_profile_bg_color,
        ),
        initialRoute: '/',
        onGenerateRoute: (settings) {
          developer.log('MyApp: Generating route: ${settings.name}', name: 'MainApp');
          Widget page;
          switch (settings.name) {
            case '/':
              page = const SplashScreen();
              break;
            case '/home':
              page = HomeScreen(sharedText: sharedText);
              break;
            case '/download':
              final args = settings.arguments as Map<String, String>?;
              final url = args?['url'] ?? '';
              final type = args?['type'] ?? 'instagram';
              page = DownloadScreen(url: url, type: type);
              break;
            case '/history':
              page = const HistoryScreen();
              break;
            case '/contact':
              page = const ContactMeScreen();
              break;
            case '/about':
              page = const AboutScreen();
              break;
            default:
              page = const SplashScreen();
          }
          return NavigationUtils.slideTransition(page);
        },
      ),
    );
  }
}