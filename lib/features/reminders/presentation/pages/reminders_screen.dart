import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/models/medicine_reminder.dart';
import '../../../../core/services/reminder_service.dart';
import 'add_reminder_page.dart';

class RemindersScreen extends StatelessWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppTheme.mintBackground,
        appBar: AppBar(
          title: const Text('تذكير الدواء', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: AppTheme.mintBackground,
          elevation: 0,
        ),
        body: StreamBuilder<List<MedicineReminder>>(
          stream: ReminderService().getUserRemindersStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: AppTheme.primaryTeal));
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 60, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text('حدث خطأ: ${snapshot.error}', style: const TextStyle(color: Colors.grey, fontSize: 14)),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        // force rebuild
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const RemindersScreen()));
                      },
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      label: const Text('إعادة المحاولة', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryTeal),
                    ),
                  ],
                ),
              );
            }

            final reminders = snapshot.data ?? [];

            if (reminders.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryTeal.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.alarm_off, size: 60, color: Colors.grey.shade400),
                    ),
                    const SizedBox(height: 20),
                    const Text('لا توجد تذكيرات مسجلة', style: TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    const Text('اضغط على + لإضافة تذكير جديد', style: TextStyle(fontSize: 14, color: Colors.grey)),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: reminders.length,
              itemBuilder: (context, index) {
                final reminder = reminders[index];
                return _buildReminderCard(context, reminder);
              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: AppTheme.primaryTeal,
          icon: const Icon(Icons.add_alarm, color: Colors.white),
          label: const Text('إضافة تذكير', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const AddReminderPage()));
          },
        ),
      ),
    );
  }

  Widget _buildReminderCard(BuildContext context, MedicineReminder reminder) {
    final isActive = reminder.isActive;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isActive ? AppTheme.primaryTeal.withOpacity(0.2) : Colors.grey.withOpacity(0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isActive ? AppTheme.primaryTeal.withOpacity(0.08) : Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Time circle
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: isActive
                    ? const LinearGradient(colors: [Color(0xFF2AAA8A), Color(0xFF38C9A7)])
                    : LinearGradient(colors: [Colors.grey.shade300, Colors.grey.shade400]),
                shape: BoxShape.circle,
                boxShadow: isActive
                    ? [BoxShadow(color: AppTheme.primaryTeal.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))]
                    : [],
              ),
              child: Center(
                child: Text(
                  reminder.time.format(context),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reminder.medicineName,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: isActive ? AppTheme.textPrimary : Colors.grey,
                    ),
                  ),
                  if (reminder.notes.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      reminder.notes,
                      style: TextStyle(fontSize: 12, color: isActive ? AppTheme.textSecondary : Colors.grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isActive ? const Color(0xFF27AE60).withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isActive ? 'مفعّل' : 'متوقف',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isActive ? const Color(0xFF27AE60) : Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Controls
            Column(
              children: [
                Switch(
                  value: isActive,
                  activeColor: AppTheme.primaryTeal,
                  onChanged: (value) {
                    ReminderService().toggleReminder(reminder.id, value);
                  },
                ),
                InkWell(
                  onTap: () => _confirmDelete(context, reminder),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppTheme.alertRed.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.delete_outline, color: AppTheme.alertRed, size: 18),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, MedicineReminder reminder) {
    showDialog(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('حذف التذكير'),
          content: Text('هل تريد حذف تذكير دواء ${reminder.medicineName}؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('إلغاء', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                await ReminderService().deleteReminder(reminder.id);
              },
              child: const Text('حذف', style: TextStyle(color: AppTheme.alertRed)),
            ),
          ],
        ),
      ),
    );
  }
}
