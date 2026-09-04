import 'package:flutter/material.dart';
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

import '../../../categories/presentation/pages/medicine_details_screen.dart';
import '../../../categories/presentation/pages/disease_details_screen.dart';
import '../../../categories/presentation/pages/nutrition_details_screen.dart';
import '../../../categories/presentation/pages/first_aid_details_screen.dart';
import '../../../categories/presentation/pages/medical_test_details_screen.dart';
import '../../../categories/presentation/pages/health_tip_details_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final MedicineService _medicineService = MedicineService();
  final DiseaseService _diseaseService = DiseaseService();
  final NutritionService _nutritionService = NutritionService();
  final FirstAidService _firstAidService = FirstAidService();
  final MedicalTestService _medicalTestService = MedicalTestService();
  final HealthTipService _healthTipService = HealthTipService();

  List<Medicine> _allMedicines = [];
  List<Disease> _allDiseases = [];
  List<Nutrition> _allNutritions = [];
  List<FirstAid> _allFirstAids = [];
  List<MedicalTest> _allMedicalTests = [];
  List<HealthTip> _allHealthTips = [];
  
  List<Medicine> _filteredMedicines = [];
  List<Disease> _filteredDiseases = [];
  List<Nutrition> _filteredNutritions = [];
  List<FirstAid> _filteredFirstAids = [];
  List<MedicalTest> _filteredMedicalTests = [];
  List<HealthTip> _filteredHealthTips = [];
  
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedFilter = 'all';

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
        _allMedicines = futures[0] as List<Medicine>;
        _allDiseases = futures[1] as List<Disease>;
        _allNutritions = futures[2] as List<Nutrition>;
        _allFirstAids = futures[3] as List<FirstAid>;
        _allMedicalTests = futures[4] as List<MedicalTest>;
        _allHealthTips = futures[5] as List<HealthTip>;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.trim().toLowerCase();
      if (_searchQuery.isEmpty) {
        _filteredMedicines = [];
        _filteredDiseases = [];
        _filteredNutritions = [];
        _filteredFirstAids = [];
        _filteredMedicalTests = [];
        _filteredHealthTips = [];
      } else {
        _filteredMedicines = _allMedicines.where((m) {
          return m.name.toLowerCase().contains(_searchQuery) ||
                 m.scientificName.toLowerCase().contains(_searchQuery) ||
                 m.uses.any((u) => u.toLowerCase().contains(_searchQuery));
        }).toList();

        _filteredDiseases = _allDiseases.where((d) {
          return d.name.toLowerCase().contains(_searchQuery) ||
                 d.scientificName.toLowerCase().contains(_searchQuery) ||
                 d.symptoms.any((s) => s.toLowerCase().contains(_searchQuery));
        }).toList();
        
        _filteredNutritions = _allNutritions.where((n) {
          return n.title.toLowerCase().contains(_searchQuery) || n.description.toLowerCase().contains(_searchQuery);
        }).toList();
        
        _filteredFirstAids = _allFirstAids.where((f) {
          return f.title.toLowerCase().contains(_searchQuery) || f.description.toLowerCase().contains(_searchQuery);
        }).toList();
        
        _filteredMedicalTests = _allMedicalTests.where((t) {
          return t.testName.toLowerCase().contains(_searchQuery) || t.purpose.toLowerCase().contains(_searchQuery);
        }).toList();
        
        _filteredHealthTips = _allHealthTips.where((h) {
          return h.title.toLowerCase().contains(_searchQuery) || h.category.toLowerCase().contains(_searchQuery);
        }).toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppTheme.mintBackground,
        body: SafeArea(
          child: Column(
            children: [
              _buildSearchBar(),
              _buildFilters(),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryTeal))
                    : _buildSearchResults(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: 'ابحث عن مرض، دواء، أو عرض...',
          prefixIcon: const Icon(Icons.search, color: AppTheme.primaryTeal),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: () {
                    _searchController.clear();
                    _onSearchChanged('');
                  },
                )
              : null,
          filled: true,
          fillColor: AppTheme.mintBackground,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    final filters = [
      {'id': 'all', 'label': 'الكل'},
      {'id': 'medicines', 'label': 'أدوية'},
      {'id': 'diseases', 'label': 'أمراض'},
      {'id': 'nutrition', 'label': 'تغذية'},
      {'id': 'first_aid', 'label': 'إسعافات'},
      {'id': 'medical_tests', 'label': 'فحوصات'},
      {'id': 'health_tips', 'label': 'نصائح'},
    ];

    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _selectedFilter == filter['id'];
          return Padding(
            padding: const EdgeInsets.only(left: 8),
            child: FilterChip(
              label: Text(
                filter['label']!,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppTheme.textPrimary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedFilter = filter['id']!;
                });
              },
              backgroundColor: Colors.white,
              selectedColor: AppTheme.primaryTeal,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? AppTheme.primaryTeal : Colors.grey.shade300,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_searchQuery.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text('اكتب شيئاً للبحث...', style: TextStyle(fontSize: 18, color: Colors.grey)),
          ],
        ),
      );
    }

    if (_filteredMedicines.isEmpty && _filteredDiseases.isEmpty && _filteredNutritions.isEmpty && _filteredFirstAids.isEmpty && _filteredMedicalTests.isEmpty && _filteredHealthTips.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sentiment_dissatisfied, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text('لم يتم العثور على نتائج', style: TextStyle(fontSize: 18, color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if ((_selectedFilter == 'all' || _selectedFilter == 'medicines') && _filteredMedicines.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text('الأدوية المشابهة', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryTeal)),
          ),
          ..._filteredMedicines.map((m) => _buildMedicineCard(m)),
          const SizedBox(height: 24),
        ],
        if ((_selectedFilter == 'all' || _selectedFilter == 'diseases') && _filteredDiseases.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text('الأمراض والمواضيع المشابهة', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryTeal)),
          ),
          ..._filteredDiseases.map((d) => _buildDiseaseCard(d)),
          const SizedBox(height: 24),
        ],
        if ((_selectedFilter == 'all' || _selectedFilter == 'nutrition') && _filteredNutritions.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text('التغذية', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryTeal)),
          ),
          ..._filteredNutritions.map((n) => _buildGenericCard(title: n.title, subtitle: n.calories, imageUrl: n.imageUrl, icon: Icons.apple, iconColor: AppTheme.primaryTeal, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => NutritionDetailsScreen(nutrition: n))))),
          const SizedBox(height: 24),
        ],
        if ((_selectedFilter == 'all' || _selectedFilter == 'first_aid') && _filteredFirstAids.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text('الإسعافات الأولية', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.alertRed)),
          ),
          ..._filteredFirstAids.map((f) => _buildGenericCard(title: f.title, subtitle: f.description, imageUrl: f.imageUrl, icon: Icons.healing, iconColor: AppTheme.alertRed, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => FirstAidDetailsScreen(firstAid: f))))),
          const SizedBox(height: 24),
        ],
        if ((_selectedFilter == 'all' || _selectedFilter == 'medical_tests') && _filteredMedicalTests.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text('المختبر والفحوصات', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.indigo)),
          ),
          ..._filteredMedicalTests.map((t) => _buildGenericCard(title: t.testName, subtitle: t.purpose, imageUrl: t.imageUrl, icon: Icons.biotech, iconColor: Colors.indigo, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MedicalTestDetailsScreen(medicalTest: t))))),
          const SizedBox(height: 24),
        ],
        if ((_selectedFilter == 'all' || _selectedFilter == 'health_tips') && _filteredHealthTips.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text('النصائح الصحية', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
          ),
          ..._filteredHealthTips.map((h) => _buildGenericCard(title: h.title, subtitle: h.category, imageUrl: h.imageUrl, icon: Icons.eco, iconColor: Colors.green, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => HealthTipDetailsScreen(healthTip: h))))),
        ],
      ],
    );
  }

  Widget _buildMedicineCard(Medicine medicine) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: _buildImage(medicine.imageUrl, Icons.medication, AppTheme.primaryTeal),
        title: Text(medicine.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(medicine.scientificName, style: const TextStyle(color: Colors.grey)),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => MedicineDetailsScreen(medicine: medicine)));
        },
      ),
    );
  }

  Widget _buildDiseaseCard(Disease disease) {
    return _buildGenericCard(
      title: disease.name,
      subtitle: disease.scientificName,
      imageUrl: disease.imageUrl,
      icon: Icons.coronavirus_outlined,
      iconColor: AppTheme.primaryTeal,
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DiseaseDetailsScreen(disease: disease))),
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
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis),
        onTap: onTap,
      ),
    );
  }

  Widget _buildImage(String url, IconData fallbackIcon, Color color) {
    return Container(
      width: 50,
      height: 50,
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
                errorBuilder: (context, error, stackTrace) => Icon(fallbackIcon, color: color),
              )
            : Icon(fallbackIcon, color: color),
      ),
    );
  }
}
