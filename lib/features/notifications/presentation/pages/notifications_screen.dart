import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // قائمة إشعارات وهمية للتوضيح
    // في التطبيق الحقيقي سيتم جلبها من Firebase أو حفظها في قاعدة بيانات محلية (SQLite/Hive)
    final notifications = [
      {
        'title': 'تذكير بدواء', 
        'body': 'حان موعد تناول دواء بنادول إكسترا (حبتين).', 
        'time': 'الآن', 
        'icon': Icons.medication, 
        'color': Colors.blue
      },
      {
        'title': 'تنبيه صحي', 
        'body': 'احرص على شرب كمية كافية من الماء اليوم للحفاظ على صحتك.', 
        'time': 'قبل ساعتين', 
        'icon': Icons.water_drop, 
        'color': Colors.lightBlue
      },
      {
        'title': 'تحديث جديد', 
        'body': 'تمت إضافة أمراض وأدوية جديدة لقاعدة البيانات، تصفحها الآن!', 
        'time': 'أمس', 
        'icon': Icons.update, 
        'color': AppTheme.primaryTeal
      },
      {
        'title': 'مرحباً بك!', 
        'body': 'أهلاً بك في تطبيق صحة+، دليلك الشامل للمعلومات الطبية.', 
        'time': 'منذ يومين', 
        'icon': Icons.celebration, 
        'color': Colors.orange
      },
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppTheme.mintBackground,
        appBar: AppBar(
          title: const Text('الإشعارات', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: AppTheme.mintBackground,
          foregroundColor: AppTheme.textPrimary,
          elevation: 0,
        ),
        body: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            final notif = notifications[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (notif['color'] as Color).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(notif['icon'] as IconData, color: notif['color'] as Color),
                ),
                title: Text(notif['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(notif['body'] as String, style: const TextStyle(color: Colors.black87, height: 1.4)),
                      const SizedBox(height: 8),
                      Text(notif['time'] as String, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
                onTap: () {
                  // يمكن إضافة حركة عند النقر على الإشعار
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
