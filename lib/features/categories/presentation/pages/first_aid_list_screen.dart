import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/first_aid_service.dart';
import '../../../../core/models/first_aid.dart';
import '../../../auth/cubit/auth_cubit.dart';
import '../../../auth/cubit/auth_state.dart';
import '../../../admin/presentation/pages/add_first_aid_page.dart';
import 'first_aid_details_screen.dart';

class FirstAidListScreen extends StatefulWidget {
  const FirstAidListScreen({super.key});

  @override
  State<FirstAidListScreen> createState() => _FirstAidListScreenState();
}

class _FirstAidListScreenState extends State<FirstAidListScreen> {
  final _firstAidService = FirstAidService();
  late Future<List<FirstAid>> _firstAidFuture;

  // Multi-select state
  bool _isMultiSelectMode = false;
  final Set<String> _selectedItems = {};

  @override
  void initState() {
    super.initState();
    _refreshFirstAid();
  }

  void _refreshFirstAid() {
    setState(() {
      _firstAidFuture = _firstAidService.getFirstAids();
      _isMultiSelectMode = false;
      _selectedItems.clear();
    });
  }

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedItems.contains(id)) {
        _selectedItems.remove(id);
        if (_selectedItems.isEmpty) {
          _isMultiSelectMode = false;
        }
      } else {
        _selectedItems.add(id);
      }
    });
  }

  void _toggleMultiSelectMode(String id) {
    setState(() {
      _isMultiSelectMode = true;
      _selectedItems.add(id);
    });
  }

  Future<void> _deleteSelectedItems() async {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('حذف العناصر'),
          content: Text('هل أنت متأكد من حذف ${_selectedItems.length} عنصر؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('⏳ جاري الحذف...')));
                
                try {
                  for (final id in _selectedItems) {
                    await _firstAidService.deleteFirstAid(id);
                  }
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('✅ تم الحذف بنجاح'), backgroundColor: AppTheme.primaryTeal),
                    );
                    _refreshFirstAid();
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('❌ خطأ: $e')));
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.alertRed),
              child: const Text('حذف', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = context.select((AuthCubit cubit) => (cubit.state is AuthAuthenticated) ? (cubit.state as AuthAuthenticated).user.isAdmin : false);

    return Scaffold(
      backgroundColor: AppTheme.mintBackground,
      appBar: AppBar(
        title: _isMultiSelectMode 
          ? Text('${_selectedItems.length} محدد', style: const TextStyle(fontWeight: FontWeight.bold))
          : const Text('الإسعافات الأولية'),
        centerTitle: true,
        leading: _isMultiSelectMode
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    _isMultiSelectMode = false;
                    _selectedItems.clear();
                  });
                },
              )
            : null,
        actions: [
          if (_isMultiSelectMode && isAdmin)
            IconButton(
              icon: const Icon(Icons.delete, color: AppTheme.alertRed),
              onPressed: _deleteSelectedItems,
            ),
        ],
      ),
      body: FutureBuilder<List<FirstAid>>(
        future: _firstAidFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('حدث خطأ: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('لا توجد إسعافات مضافة حالياً.'));
          }

          final firstAidItems = snapshot.data!;
          return RefreshIndicator(
            onRefresh: () async => _refreshFirstAid(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: firstAidItems.length,
              itemBuilder: (context, index) {
                final firstAid = firstAidItems[index];
                final isSelected = _selectedItems.contains(firstAid.id);

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: isSelected ? AppTheme.primaryTeal : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: firstAid.imageUrl.isNotEmpty
                            ? Image.network(
                                firstAid.imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => const Icon(Icons.medical_services, size: 30, color: Colors.red),
                              )
                            : const Icon(Icons.medical_services, size: 30, color: Colors.red),
                      ),
                    ),
                    title: Text(firstAid.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    subtitle: Text(
                      firstAid.description,
                      style: const TextStyle(color: Colors.grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: _isMultiSelectMode && isAdmin
                        ? Checkbox(
                            value: isSelected,
                            onChanged: (value) => _toggleSelection(firstAid.id),
                            activeColor: AppTheme.primaryTeal,
                          )
                        : const Icon(Icons.arrow_forward_ios, size: 16),
                    onLongPress: isAdmin && !_isMultiSelectMode
                        ? () => _toggleMultiSelectMode(firstAid.id)
                        : null,
                    onTap: () async {
                      if (_isMultiSelectMode && isAdmin) {
                        _toggleSelection(firstAid.id);
                        return;
                      }

                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => FirstAidDetailsScreen(firstAid: firstAid)),
                      );
                      if (result == true) {
                        _refreshFirstAid();
                      }
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: isAdmin && !_isMultiSelectMode
          ? FloatingActionButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddFirstAidPage()),
                );
                _refreshFirstAid();
              },
              backgroundColor: AppTheme.primaryTeal,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }
}
