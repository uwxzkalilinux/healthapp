import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/models/medicine.dart';
import '../../../../core/models/disease.dart';
import '../../../../core/models/nutrition.dart';
import '../../../../core/models/first_aid.dart';
import '../../../../core/models/medical_test.dart';
import '../../../../core/models/health_tip.dart';

import '../../../../core/services/medicine_service.dart';
import '../../../../core/services/disease_service.dart';
import '../../../../core/services/nutrition_service.dart';
import '../../../../core/services/first_aid_service.dart';
import '../../../../core/services/medical_test_service.dart';
import '../../../../core/services/health_tip_service.dart';

import '../../cubit/favorites_cubit.dart';
import '../../../categories/presentation/pages/medicine_details_screen.dart';
import '../../../categories/presentation/pages/disease_details_screen.dart';
import '../../../categories/presentation/pages/nutrition_details_screen.dart';
import '../../../categories/presentation/pages/first_aid_details_screen.dart';
import '../../../categories/presentation/pages/medical_test_details_screen.dart';
import '../../../categories/presentation/pages/health_tip_details_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final MedicineService _medicineService = MedicineService();
  final DiseaseService _diseaseService = DiseaseService();
  final NutritionService _nutritionService = NutritionService();
  final FirstAidService _firstAidService = FirstAidService();
  final MedicalTestService _medicalTestService = MedicalTestService();
  final HealthTipService _healthTipService = HealthTipService();

  List<Medicine> _medicines = [];
  List<Disease> _diseases = [];
  List<Nutrition> _nutritions = [];
  List<FirstAid> _firstAids = [];
  List<MedicalTest> _medicalTests = [];
  List<HealthTip> _healthTips = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final futures = await Future.wait<dynamic>([
        _medicineService.getMedicines(),
        _diseaseService.getDiseases(),
        _nutritionService.getNutrition(),
        _firstAidService.getFirstAids(),
        _medicalTestService.getMedicalTests(),
        _healthTipService.getHealthTips(),
      ]);
      setState(() {
        _medicines = futures[0] as List<Medicine>;
        _diseases = futures[1] as List<Disease>;
        _nutritions = futures[2] as List<Nutrition>;
        _firstAids = futures[3] as List<FirstAid>;
        _medicalTests = futures[4] as List<MedicalTest>;
        _healthTips = futures[5] as List<HealthTip>;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل جلب البيانات: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppTheme.mintBackground,
        appBar: AppBar(
          title: const Text('المفضلة', style: TextStyle(fontWeight: FontWeight.bold)),
          elevation: 0,
          backgroundColor: AppTheme.mintBackground,
          foregroundColor: AppTheme.textPrimary,
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryTeal))
            : BlocBuilder<FavoritesCubit, List<String>>(
                builder: (context, favorites) {
                  if (favorites.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.favorite_border, size: 80, color: Colors.grey.shade300),
                          const SizedBox(height: 16),
                          const Text('قائمة المفضلة فارغة', style: TextStyle(fontSize: 18, color: Colors.grey)),
                        ],
                      ),
                    );
                  }

                  final favMedicines = _medicines.where((m) => favorites.contains(m.id)).toList();
                  final favDiseases = _diseases.where((d) => favorites.contains(d.id)).toList();
                  final favNutritions = _nutritions.where((n) => favorites.contains(n.id)).toList();
                  final favFirstAids = _firstAids.where((f) => favorites.contains(f.id)).toList();
                  final favMedicalTests = _medicalTests.where((t) => favorites.contains(t.id)).toList();
                  final favHealthTips = _healthTips.where((h) => favorites.contains(h.id)).toList();

                  return ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      if (favMedicines.isNotEmpty) ...[
                        const Padding(
                          padding: EdgeInsets.only(bottom: 12),
                          child: Text('الأدوية', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryTeal)),
                        ),
                        ...favMedicines.map((medicine) => _buildMedicineCard(medicine)),
                        const SizedBox(height: 24),
                      ],
                      if (favDiseases.isNotEmpty) ...[
                        const Padding(
                          padding: EdgeInsets.only(bottom: 12),
                          child: Text('الأمراض', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryTeal)),
                        ),
                        ...favDiseases.map((disease) => _buildDiseaseCard(disease)),
                        const SizedBox(height: 24),
                      ],
                      if (favNutritions.isNotEmpty) ...[
                        const Padding(
                          padding: EdgeInsets.only(bottom: 12),
                          child: Text('التغذية', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryTeal)),
                        ),
                        ...favNutritions.map((n) => _buildNutritionCard(n)),
                        const SizedBox(height: 24),
                      ],
                      if (favFirstAids.isNotEmpty) ...[
                        const Padding(
                          padding: EdgeInsets.only(bottom: 12),
                          child: Text('الإسعافات الأولية', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.alertRed)),
                        ),
                        ...favFirstAids.map((f) => _buildFirstAidCard(f)),
                        const SizedBox(height: 24),
                      ],
                      if (favMedicalTests.isNotEmpty) ...[
                        const Padding(
                          padding: EdgeInsets.only(bottom: 12),
                          child: Text('المختبر والفحوصات', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.indigo)),
                        ),
                        ...favMedicalTests.map((t) => _buildMedicalTestCard(t)),
                        const SizedBox(height: 24),
                      ],
                      if (favHealthTips.isNotEmpty) ...[
                        const Padding(
                          padding: EdgeInsets.only(bottom: 12),
                          child: Text('النصائح الصحية', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
                        ),
                        ...favHealthTips.map((h) => _buildHealthTipCard(h)),
                      ],
                    ],
                  );
                },
              ),
      ),
    );
  }

  Widget _buildMedicineCard(Medicine medicine) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: _buildImage(medicine.imageUrl, Icons.medication, AppTheme.primaryTeal),
        title: Text(medicine.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        subtitle: Text(medicine.scientificName, style: const TextStyle(color: Colors.grey)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => MedicineDetailsScreen(medicine: medicine)));
        },
      ),
    );
  }

  Widget _buildDiseaseCard(Disease disease) {
    return _buildGenericCard(
      title: disease.name,
      subtitle: disease.description,
      imageUrl: disease.imageUrl,
      icon: Icons.coronavirus_outlined,
      iconColor: AppTheme.primaryTeal,
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DiseaseDetailsScreen(disease: disease))),
    );
  }

  Widget _buildNutritionCard(Nutrition item) {
    return _buildGenericCard(
      title: item.title,
      subtitle: item.calories,
      imageUrl: item.imageUrl,
      icon: Icons.apple,
      iconColor: AppTheme.primaryTeal,
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => NutritionDetailsScreen(nutrition: item))),
    );
  }

  Widget _buildFirstAidCard(FirstAid item) {
    return _buildGenericCard(
      title: item.title,
      subtitle: item.description,
      imageUrl: item.imageUrl,
      icon: Icons.healing,
      iconColor: AppTheme.alertRed,
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => FirstAidDetailsScreen(firstAid: item))),
    );
  }

  Widget _buildMedicalTestCard(MedicalTest item) {
    return _buildGenericCard(
      title: item.testName,
      subtitle: item.purpose,
      imageUrl: item.imageUrl,
      icon: Icons.biotech,
      iconColor: Colors.indigo,
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MedicalTestDetailsScreen(medicalTest: item))),
    );
  }

  Widget _buildHealthTipCard(HealthTip item) {
    return _buildGenericCard(
      title: item.title,
      subtitle: item.category,
      imageUrl: item.imageUrl,
      icon: Icons.eco,
      iconColor: Colors.green,
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => HealthTipDetailsScreen(healthTip: item))),
    );
  }

  Widget _buildGenericCard({
    required String title,
    required String subtitle,
    required String imageUrl,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: _buildImage(imageUrl, icon, iconColor),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: Colors.grey),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  Widget _buildImage(String url, IconData fallbackIcon, Color color) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: url.isNotEmpty
            ? Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Icon(fallbackIcon, size: 30, color: color),
              )
            : Icon(fallbackIcon, size: 30, color: color),
      ),
    );
  }
}
