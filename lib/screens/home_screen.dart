import 'package:flutter/material.dart';
import '../routes/app_routes.dart';
 
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
 
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}
 
class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
 
  // Animation controller for the pulsing icon
  late AnimationController _controller;
  late Animation<double>   _scaleAnimation;
 
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true); // ping-pong forever
 
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }
 
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end:   Alignment.bottomCenter,
            colors: [Color(0xFF1565C0), Color(0xFF42A5F5), Color(0xFFE3F2FD)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
 
                // Animated Icon
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    width: 120, height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.school, size: 70, color: Colors.white),
                  ),
                ),
 
                const SizedBox(height: 32),
 
                // Title
                const Text(
                  'Grade Calculator',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
 
                const SizedBox(height: 8),
 
                const Text(
                  'PRO',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w300,
                    color: Colors.white70,
                    letterSpacing: 8,
                  ),
                ),
 
                const SizedBox(height: 16),
 
                const Text(
                  'Manage students, track grades\nand analyze performance',
                  style: TextStyle(fontSize: 15, color: Colors.white70, height: 1.6),
                  textAlign: TextAlign.center,
                ),
 
                const SizedBox(height: 60),
 
                // Feature Cards Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: const [
                    _FeatureCard(emoji: '📥', label: 'Import\nData'),
                    _FeatureCard(emoji: '📊', label: 'Track\nGrades'),
                    _FeatureCard(emoji: '📤', label: 'Export\nResults'),
                  ],
                ),
 
                const SizedBox(height: 60),
 
                // Get Started Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.login),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF1565C0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 8,
                    ),
                    child: const Text(
                      'Get Started',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
 
                const SizedBox(height: 16),
 
                const Text(
                  'Sign in to access your dashboard',
                  style: TextStyle(fontSize: 13, color: Colors.white60),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
 
class _FeatureCard extends StatelessWidget {
  final String emoji;
  final String label;
  const _FeatureCard({required this.emoji, required this.label});
 
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90, height: 90,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Colors.white, height: 1.3),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
 