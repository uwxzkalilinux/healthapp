import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../categories/presentation/pages/medicines_list_screen.dart';
import '../../../categories/presentation/pages/diseases_list_screen.dart';
import '../../../categories/presentation/pages/nutrition_list_screen.dart';
import '../../../categories/presentation/pages/first_aid_list_screen.dart';
import '../../../categories/presentation/pages/medical_tests_list_screen.dart';
import '../../../categories/presentation/pages/health_tips_list_screen.dart';
import '../../../articles/presentation/pages/articles_list_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, int> _counts = {
    'users': 0,
    'medicines': 0,
    'diseases': 0,
    'articles': 0,
  };
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    setState(() => _isLoading = true);
    try {
      final futures = await Future.wait([
        _firestore.collection('users').count().get(),
        _firestore.collection('medicines').count().get(),
        _firestore.collection('diseases').count().get(),
        _firestore.collection('articles').count().get(),
      ]);
      
      setState(() {
        _counts = {
          'users': futures[0].count ?? 0,
          'medicines': futures[1].count ?? 0,
          'diseases': futures[2].count ?? 0,
          'articles': futures[3].count ?? 0,
        };
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppTheme.mintBackground,
        appBar: AppBar(
          title: const Text('لوحة تحكم المشرف'),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _fetchStats,
            ),
          ],
        ),
        body: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryTeal))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('الإحصائيات العامة', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryTeal)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _buildStatCard('المستخدمين', _counts['users'].toString(), Icons.people, Colors.blue)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildStatCard('الأدوية', _counts['medicines'].toString(), Icons.medication, Colors.green)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildStatCard('الأمراض', _counts['diseases'].toString(), Icons.coronavirus, Colors.orange)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildStatCard('المقالات', _counts['articles'].toString(), Icons.article, Colors.purple)),
                    ],
                  ),
                  const SizedBox(height: 32),
                  
                  const Text('إدارة الأقسام', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryTeal)),
                  const SizedBox(height: 16),
                  _buildAdminMenu(context),
                ],
              ),
            ),
      ),
    );
  }

  Widget _buildStatCard(String title, String count, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5)),
        ],
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, size: 40, color: color),
          const SizedBox(height: 12),
          Text(count, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildAdminMenu(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [
          _buildMenuItem(context, 'إدارة الأدوية', Icons.medication, const MedicinesListScreen()),
          const Divider(height: 1),
          _buildMenuItem(context, 'إدارة الأمراض', Icons.coronavirus, const DiseasesListScreen()),
          const Divider(height: 1),
          _buildMenuItem(context, 'إدارة التغذية', Icons.apple, const NutritionListScreen()),
          const Divider(height: 1),
          _buildMenuItem(context, 'إدارة الإسعافات', Icons.healing, const FirstAidListScreen()),
          const Divider(height: 1),
          _buildMenuItem(context, 'إدارة الفحوصات', Icons.science, const MedicalTestsListScreen()),
          const Divider(height: 1),
          _buildMenuItem(context, 'إدارة النصائح', Icons.eco, const HealthTipsListScreen()),
          const Divider(height: 1),
          _buildMenuItem(context, 'إدارة المقالات', Icons.article, const ArticlesListScreen()),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, String title, IconData icon, Widget page) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryTeal),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => page));
      },
    );
  }
}
