import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubit/auth_cubit.dart';
import '../../cubit/auth_state.dart';
import '../../../home/presentation/pages/test_backend_page.dart';

class TestAuthPage extends StatefulWidget {
  const TestAuthPage({super.key});

  @override
  State<TestAuthPage> createState() => _TestAuthPageState();
}

class _TestAuthPageState extends State<TestAuthPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isLogin = true;

  @override
  void initState() {
    super.initState();
    context.read<AuthCubit>().checkAuthStatus();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();

    if (email.isEmpty || password.isEmpty) return;

    if (_isLogin) {
      context.read<AuthCubit>().login(email, password);
    } else {
      if (name.isEmpty) return;
      context.read<AuthCubit>().register(email, password, name);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('اختبار المصادقة والصلاحيات 🔐')),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage, style: const TextStyle(color: Colors.white)), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          if (state is AuthInitial || state is AuthLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is AuthAuthenticated) {
            final user = state.user;
            return ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const Icon(Icons.account_circle, size: 80, color: Colors.blue),
                const SizedBox(height: 16),
                Text('أهلاً، ${user.name}!', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                Text(user.email, style: const TextStyle(fontSize: 16, color: Colors.grey), textAlign: TextAlign.center),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: user.isAdmin ? Colors.orange.shade100 : Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    user.isAdmin ? '👑 دورك: مشرف (Admin)' : '👤 دورك: مستخدم عادي (User)',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: user.isAdmin ? Colors.orange.shade800 : Colors.blue.shade800,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 32),
                if (user.isAdmin) ...[
                  const Divider(),
                  const Text('لوحة تحكم المشرف 🛠️', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const TestBackendPage()),
                      );
                    },
                    icon: const Icon(Icons.dashboard_customize),
                    label: const Text('اختبار الرفع الكامل (Cloudinary)'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
                ElevatedButton.icon(
                  onPressed: () => context.read<AuthCubit>().logout(),
                  icon: const Icon(Icons.logout),
                  label: const Text('تسجيل الخروج'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade100,
                    foregroundColor: Colors.red.shade900,
                  ),
                )
              ],
            );
          } else {
            // Unauthenticated
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_isLogin ? 'تسجيل الدخول' : 'إنشاء حساب جديد', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  if (!_isLogin)
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'الاسم', border: OutlineInputBorder()),
                    ),
                  if (!_isLogin) const SizedBox(height: 16),
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'البريد الإلكتروني', border: OutlineInputBorder()),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    decoration: const InputDecoration(labelText: 'كلمة المرور', border: OutlineInputBorder()),
                    obscureText: true,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _submit,
                      child: Text(_isLogin ? 'دخول' : 'إنشاء حساب'),
                    ),
                  ),
                  TextButton(
                    onPressed: () => setState(() => _isLogin = !_isLogin),
                    child: Text(_isLogin ? 'ليس لديك حساب؟ إنشاء حساب جديد' : 'لديك حساب؟ تسجيل الدخول'),
                  )
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
