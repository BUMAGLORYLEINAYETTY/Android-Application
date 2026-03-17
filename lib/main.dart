import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
 
import 'providers/app_provider.dart';
import 'routes/app_routes.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/main_menu_screen.dart';
import 'screens/enrollment_screen.dart';
import 'screens/student_list_screen.dart';
 
void main() {
  runApp(
    // ChangeNotifierProvider makes AppProvider available to ALL screens
    ChangeNotifierProvider(
      create: (_) => AppProvider(),
      child: const GradeCalculatorApp(),
    ),
  );
}
 
class GradeCalculatorApp extends StatelessWidget {
  const GradeCalculatorApp({super.key});
 
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Grade Calculator Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1565C0)),
        useMaterial3: true,
      ),
 
      // Starting screen
      initialRoute: AppRoutes.home,
 
      // All named routes
      routes: {
        AppRoutes.home:        (_) => const HomeScreen(),
        AppRoutes.login:       (_) => const LoginScreen(),
        AppRoutes.mainMenu:    (_) => const MainMenuScreen(),
        AppRoutes.enrollment:  (_) => const EnrollmentScreen(),
        AppRoutes.studentList: (_) => const StudentListScreen(),
      },
    );
  }
}
 