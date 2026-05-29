import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/app_providers.dart';
import 'core/app_theme.dart';
import 'core/app_routes.dart';
import 'core/app_constants.dart';
import 'core/pocketbase_client.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('Error loading .env or initializing: $e');
    // Lanjutkan aplikasi meskipun .env gagal dimuat (fallback akan digunakan)
  }
  
  await PocketBaseClient.init();
  
  runApp(const CookSnapApp());
}

class CookSnapApp extends StatelessWidget {
  const CookSnapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: AppProviders.build(),
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        builder: (context, child) => GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: child,
        ),
        initialRoute: AppRoutes.splash,
        routes: AppRoutes.routes,
      ),
    );
  }
}
