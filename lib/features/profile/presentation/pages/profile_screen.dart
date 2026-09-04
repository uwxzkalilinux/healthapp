import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/cubit/auth_cubit.dart';
import '../../../auth/cubit/auth_state.dart';
import '../../../../features/favorites/presentation/pages/favorites_screen.dart';
import '../../../../features/search/presentation/pages/search_screen.dart';
import '../../../../features/notifications/presentation/pages/notifications_screen.dart';
import '../../../../features/reminders/presentation/pages/reminders_screen.dart';
import '../../../../core/services/data_seeder.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../../features/admin/presentation/pages/admin_dashboard.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.mintBackground,
      appBar: AppBar(
        title: const Text('حسابي', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (state is AuthAuthenticated) {
            final user = state.user;
            final isAdmin = user.isAdmin;
            
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // بطاقة المستخدم
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const CircleAvatar(
                          radius: 40,
                          backgroundImage: NetworkImage('https://cdn-icons-png.flaticon.com/512/3135/3135715.png'),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          user.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.email,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        if (isAdmin) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryTeal.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              '👑 مدير النظام (Admin)',
                              style: TextStyle(
                                color: AppTheme.primaryTeal,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // القائمة
                  _buildMenuSection([
                    _buildMenuItem(Icons.person_outline, 'المعلومات الشخصية', AppTheme.textPrimary, () {
                      _showUserInfoDialog(context, user);
                    }),
                    _buildMenuItem(Icons.favorite_outline, 'المفضلة', AppTheme.textPrimary, () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const FavoritesScreen()));
                    }),
                    _buildMenuItem(Icons.notifications_none_outlined, 'الإشعارات', AppTheme.textPrimary, () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()));
                    }),
                  ]),
                  const SizedBox(height: 16),
                  
                  _buildMenuSection([
                    _buildMenuItem(Icons.alarm, 'تذكير الدواء', AppTheme.textPrimary, () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const RemindersScreen()));
                    }),
                    _buildSwitchItem(
                      icon: Icons.dark_mode_outlined,
                      title: 'الوضع الليلي',
                      value: context.watch<ThemeCubit>().state == ThemeMode.dark,
                      onChanged: (val) {
                        context.read<ThemeCubit>().toggleTheme();
                      },
                    ),
                    _buildMenuItem(Icons.help_outline, 'المساعدة والدعم', AppTheme.textPrimary, () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تواصل معنا عبر البريد: support@healthplus.com')));
                    }),
                  ]),
                  const SizedBox(height: 16),
                  
                  if (isAdmin) ...[
                    _buildMenuSection([
                      _buildMenuItem(Icons.dashboard, 'لوحة تحكم المشرف', AppTheme.primaryTeal, () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminDashboard()));
                      }),
                      _buildMenuItem(Icons.cloud_upload, 'تحميل بيانات تجريبية', const Color(0xFF3498DB), () {
                        _seedData(context);
                      }),
                    ]),
                    const SizedBox(height: 16),
                  ],

                  _buildMenuSection([
                    _buildMenuItem(Icons.logout, 'تسجيل الخروج', AppTheme.alertRed, () {
                      context.read<AuthCubit>().logout();
                    }),
                  ]),
                  const SizedBox(height: 40),
                ],
              ),
            );
          }
          
          return const Center(child: Text('الرجاء تسجيل الدخول'));
        },
      ),
    );
  }

  void _showUserInfoDialog(BuildContext context, dynamic user) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('المعلومات الشخصية'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('الاسم: ${user.name}', style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              Text('البريد: ${user.email}', style: const TextStyle(fontSize: 16)),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('حسناً', style: TextStyle(color: AppTheme.primaryTeal))),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('تغيير اللغة'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('العربية'),
                leading: const Icon(Icons.language, color: AppTheme.primaryTeal),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('اللغة الحالية هي العربية')));
                },
              ),
              ListTile(
                title: const Text('English (Coming Soon)'),
                leading: const Icon(Icons.language, color: Colors.grey),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('سيتم دعم اللغة الإنجليزية قريباً')));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuSection(List<Widget> items) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: items,
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, Color color, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: AppTheme.textSecondary.withOpacity(0.5)),
      onTap: onTap,
    );
  }

  Widget _buildSwitchItem({required IconData icon, required String title, required bool value, required ValueChanged<bool> onChanged}) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.textPrimary),
      title: Text(
        title,
        style: const TextStyle(
          color: AppTheme.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppTheme.primaryTeal,
      ),
    );
  }

  void _seedData(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('تحميل بيانات تجريبية'),
          content: const Text('سيتم إضافة بيانات تجريبية لجميع الأقسام (أدوية، أمراض، تغذية، إسعافات، فحوصات، نصائح، مقالات). هل تريد المتابعة؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('⏳ جاري تحميل البيانات...')));
                try {
                  await DataSeeder().seedAll();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ تم تحميل جميع البيانات التجريبية بنجاح!'), backgroundColor: Color(0xFF27AE60)));
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('❌ خطأ: $e')));
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryTeal),
              child: const Text('تحميل', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
