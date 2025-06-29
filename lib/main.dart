import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
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
import 'package:flutter/services.dart';
import 'package:sentry_flutter/sentry_flutter.dart';


const MethodChannel _logChannel = MethodChannel('app.channel.log');
final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();
String? sharedText;

void main() {
  runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized(); // 🔁 Moved here
    await SentryFlutter.init(
          (options) {
        options.dsn = 'https://f88cdd9c8bac9383b053b7d860dc75a8@o4509580511084544.ingest.us.sentry.io/4509580514426880';
        options.sendDefaultPii = true;
      },
    );
    const MethodChannel _channel = MethodChannel('app.channel.shared.data');
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'getSharedText') {
        sharedText = call.arguments as String?;
      }
    });

    runApp(const MyApp());
  }, (Object error, StackTrace stack) {
    _logError(error, stack);
  });
}

void _logError(Object error, StackTrace? stack) {
  final msg = '❌ Error: $error\n📍 Stack: $stack';
  _logChannel.invokeMethod('log', {'message': msg});
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

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