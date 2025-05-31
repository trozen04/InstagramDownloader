import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'Screens/APIBloc/insta_downloader_bloc.dart';
import 'Screens/Dashboard/home_screen.dart';
import 'Screens/Download/download_history.dart';
import 'Screens/Download/download_screen.dart';
import 'Utils/flutter_color_themes.dart';
import 'Widgets/custom_navigator.dart';
import 'screens/splash_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
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
              page = const HomeScreen();
              break;
            case '/download':
              final args = settings.arguments as Map<String, String>;
              final url = args['url']!;
              final type = args['type']!;
              page = DownloadScreen(url: url, type: type);
              break;
            case '/history':
              page = const HistoryScreen();
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