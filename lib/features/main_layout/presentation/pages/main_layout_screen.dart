import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../features/home/presentation/pages/home_screen.dart';
import '../../../../features/profile/presentation/pages/profile_screen.dart';
import '../../../../features/favorites/presentation/pages/favorites_screen.dart';
import '../../../../features/search/presentation/pages/search_screen.dart';
import '../../../../features/notifications/presentation/pages/notifications_screen.dart';
import '../../../../features/categories/presentation/pages/medicines_list_screen.dart';
import '../../../../features/categories/presentation/pages/diseases_list_screen.dart';
import '../../../../features/categories/presentation/pages/nutrition_list_screen.dart';
import '../../../../features/categories/presentation/pages/first_aid_list_screen.dart';
import '../../../../features/categories/presentation/pages/medical_tests_list_screen.dart';
import '../../../../features/categories/presentation/pages/health_tips_list_screen.dart';

class MainLayoutScreen extends StatefulWidget {
  const MainLayoutScreen({super.key});

  @override
  State<MainLayoutScreen> createState() => _MainLayoutScreenState();
}

class _MainLayoutScreenState extends State<MainLayoutScreen> {
  int _currentIndex = 2; // الصفحة الرئيسية هي الديفولت (المنتصف)
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // صفحات التطبيق الأساسية
  final List<Widget> _pages = [
    const ProfileScreen(),
    const NotificationsScreen(),
    const HomeScreen(),
    const SearchScreen(),
    const FavoritesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    // استخدم Directionality لدعم اللغة العربية RTL
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        drawer: _buildDrawer(),
        body: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          children: _pages,
        ),
        bottomNavigationBar: _buildBottomNavBar(),
      ),
    );
  }

  // 1. القائمة الجانبية (Drawer)
  Widget _buildDrawer() {
    return Drawer(
      child: Container(
        color: AppTheme.mintBackground,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: AppTheme.mintBackgroundDarker,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.health_and_safety, size: 60, color: AppTheme.primaryTeal),
                  const SizedBox(height: 10),
                  const Text(
                    'صحة +',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryTeal,
                    ),
                  ),
                ],
              ),
            ),
            _buildDrawerItem(context, Icons.home_outlined, 'الرئيسية', true, () => Navigator.pop(context)),
            _buildDrawerItem(context, Icons.medication_outlined, 'الأدوية', false, () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const MedicinesListScreen())); }),
            _buildDrawerItem(context, Icons.coronavirus_outlined, 'الأمراض', false, () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const DiseasesListScreen())); }),
            _buildDrawerItem(context, Icons.apple_outlined, 'التغذية', false, () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const NutritionListScreen())); }),
            _buildDrawerItem(context, Icons.medical_services_outlined, 'الإسعافات الأولية', false, () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const FirstAidListScreen())); }),
            _buildDrawerItem(context, Icons.science_outlined, 'المختبر والفحوصات', false, () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const MedicalTestsListScreen())); }),
            _buildDrawerItem(context, Icons.eco_outlined, 'النصائح الصحية', false, () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const HealthTipsListScreen())); }),
            const Divider(),
            _buildDrawerItem(context, Icons.favorite_outline, 'المفضلة', false, () { Navigator.pop(context); setState(() => _currentIndex = 4); }),
            _buildDrawerItem(context, Icons.notifications_none_outlined, 'الإشعارات', false, () { Navigator.pop(context); setState(() => _currentIndex = 1); }),
            _buildDrawerItem(context, Icons.settings_outlined, 'الإعدادات', false, () { Navigator.pop(context); }),
            _buildDrawerItem(context, Icons.help_outline, 'المساعدة والدعم', false, () { Navigator.pop(context); }),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, IconData icon, String title, bool isSelected, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: isSelected ? AppTheme.primaryTeal : AppTheme.textSecondary),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? AppTheme.primaryTeal : AppTheme.textPrimary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      onTap: onTap,
    );
  }

  // 2. شريط التنقل السفلي (Bottom Navigation Bar)
  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            _pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'حسابي',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_none_outlined),
            activeIcon: Icon(Icons.notifications),
            label: 'الإشعارات',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'الرئيسية',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            activeIcon: Icon(Icons.search),
            label: 'بحث',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_outline),
            activeIcon: Icon(Icons.favorite),
            label: 'المفضلة',
          ),
        ],
      ),
    );
  }
}
