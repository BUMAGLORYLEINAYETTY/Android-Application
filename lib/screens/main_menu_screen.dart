import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../routes/app_routes.dart';
 
class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});
 
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
 
    // Menu item data
    final menuItems = [
      _MenuItem(
        icon:     Icons.person_add,
        title:    'Enroll Student',
        subtitle: 'Add a new student to the system',
        color:    const Color(0xFF1565C0),
        route:    AppRoutes.enrollment,
      ),
      _MenuItem(
        icon:     Icons.people,
        title:    'Student List',
        subtitle: '${provider.students.length} enrolled students',
        color:    const Color(0xFF2E7D32),
        route:    AppRoutes.studentList,
      ),
      _MenuItem(
        icon:     Icons.bar_chart,
        title:    'Grade Statistics',
        subtitle: 'Class average: ${provider.averageScore.toStringAsFixed(1)}%',
        color:    const Color(0xFFE65100),
        route:    AppRoutes.studentList,
      ),
      _MenuItem(
        icon:     Icons.download,
        title:    'Export Results',
        subtitle: 'Download grades as Excel file',
        color:    const Color(0xFF6A1B9A),
        route:    AppRoutes.studentList,
      ),
    ];
 
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
            onPressed: () => _showLogoutDialog(context, provider),
          ),
        ],
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
 
          // Welcome Card
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 4,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
                ),
              ),
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 56, height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.school, color: Colors.white, size: 32),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Welcome back! 🎓',
                          style: TextStyle(color: Colors.white, fontSize: 18,
                              fontWeight: FontWeight.bold)),
                      Text(provider.loggedInUser,
                          style: const TextStyle(color: Colors.white70,
                              fontSize: 13)),
                    ],
                  ),
                ],
              ),
            ),
          ),
 
          const SizedBox(height: 16),
 
          // Stats Row
          Row(
            children: [
              _StatCard(
                label: 'Students',
                value: '${provider.students.length}',
                icon:  Icons.people,
                color: const Color(0xFF1565C0),
              ),
              const SizedBox(width: 12),
              _StatCard(
                label: 'Average',
                value: provider.averageScore.toStringAsFixed(1),
                icon:  Icons.calculate,
                color: const Color(0xFF2E7D32),
              ),
              const SizedBox(width: 12),
              _StatCard(
                label: 'Highest',
                value: '${provider.highestScore}',
                icon:  Icons.trending_up,
                color: const Color(0xFFE65100),
              ),
            ],
          ),
 
          const SizedBox(height: 20),
 
          const Text('Quick Actions',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
                  color: Color(0xFF424242))),
 
          const SizedBox(height: 12),
 
          // Menu Items
          ...menuItems.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _MenuCard(item: item),
          )),
        ],
      ),
    );
  }
 
  void _showLogoutDialog(BuildContext context, AppProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.logout, size: 32),
        title: const Text('Sign Out?'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              provider.logout();
              Navigator.pushNamedAndRemoveUntil(
                context, AppRoutes.home, (route) => false);
            },
            child: const Text('Sign Out',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
 
// ── Supporting Widgets ───────────────────────────────────────
 
class _MenuItem {
  final IconData icon;
  final String   title;
  final String   subtitle;
  final Color    color;
  final String   route;
  const _MenuItem({
    required this.icon, required this.title, required this.subtitle,
    required this.color, required this.route,
  });
}
 
class _StatCard extends StatelessWidget {
  final String   label;
  final String   value;
  final IconData icon;
  final Color    color;
  const _StatCard({required this.label, required this.value,
      required this.icon, required this.color});
 
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 4),
              Text(value,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,
                      color: color)),
              Text(label,
                  style: const TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}
 
class _MenuCard extends StatelessWidget {
  final _MenuItem item;
  const _MenuCard({required this.item});
 
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.pushNamed(context, item.route),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 52, height: 52,
                decoration: BoxDecoration(
                  color: item.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(item.icon, color: item.color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.title,
                        style: const TextStyle(fontWeight: FontWeight.w600,
                            fontSize: 15)),
                    Text(item.subtitle,
                        style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
 