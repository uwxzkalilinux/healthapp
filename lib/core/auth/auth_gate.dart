import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/auth/cubit/auth_cubit.dart';
import '../../features/auth/cubit/auth_state.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/main_layout/presentation/pages/main_layout_screen.dart';
import '../../features/favorites/cubit/favorites_cubit.dart';

/// بوابة المصادقة: تتحقق من حالة المستخدم وتوجّهه للمكان الصحيح
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();
    context.read<AuthCubit>().checkAuthStatus();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          context.read<FavoritesCubit>().init(state.user.uid);
        }
      },
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
        if (state is AuthInitial || state is AuthLoading) {
          // شاشة التحميل أثناء التحقق
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFF168B75)),
                  SizedBox(height: 16),
                  Text('جاري التحقق...', style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
          );
        } else if (state is AuthAuthenticated) {
          // المستخدم مسجل دخوله → الشاشة الرئيسية
          return const MainLayoutScreen();
        } else {
          // غير مسجل دخوله أو حصل خطأ → صفحة تسجيل الدخول
          return const LoginPage();
        }
      },
    ),
    );
  }
}
