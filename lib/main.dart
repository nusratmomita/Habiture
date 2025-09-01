import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/habit_provider.dart';
import 'providers/quote_provider.dart';
import 'screens/login_screen.dart';
import 'screens/registration_screen.dart';
import 'screens/home_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/habit/add_edit_habit.dart';
import 'screens/quotes/categories.dart'; // ✅ Import CategoriesScreen
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer2<ThemeProvider, AuthProvider>(
        builder: (context, themeProvider, authProvider, _) {
          final userId = authProvider.currentUser?.uid ?? "test_user";

          return MultiProvider(
            providers: [
              ChangeNotifierProvider(
                create: (_) => HabitProvider(userId: userId),
              ),
              ChangeNotifierProvider(
                create: (_) => QuotesProvider(userId: userId),
              ),
            ],
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Habit Tracker',
              theme: ThemeData.light(),
              darkTheme: ThemeData.dark(),
              themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
              initialRoute: '/splash',
              routes: {
                '/splash': (context) => const SplashScreen(),
                '/login': (context) => const LoginScreen(),
                '/register': (context) => const RegisterScreen(),
                '/home': (context) => const HomeScreen(),
                '/add_edit_habit': (context) => const AddEditHabitScreen(),
                '/categories': (context) => const CategoriesScreen(), // ✅ Test route
              },
            ),
          );
        },
      ),
    );
  }
}
