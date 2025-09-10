import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class FormScreens extends StatefulWidget {
  const FormScreens({super.key});

  @override
  _FormScreensState createState() => _FormScreensState();
}

class _FormScreensState extends State<FormScreens>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _farmNameController = TextEditingController(text: 'Green Acres');
  final _locationController = TextEditingController(text: 'California, USA');
  final _landSizeController = TextEditingController();
  final _varietyController = TextEditingController();

  // Form state
  String? selectedCropType;
  String? selectedSoilType;
  bool seasonalPlanning = false;
  bool irrigationFacilities = true;
  double farmingExperience = 3.0;

  // Animation controllers
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _farmNameController.dispose();
    _locationController.dispose();
    _landSizeController.dispose();
    _varietyController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  String _getExperienceLabel(double value, AppLocalizations loc) {
    if (value <= 1) return loc.beginner;
    if (value <= 2) return loc.novice;
    if (value <= 3) return loc.intermediate;
    if (value <= 4) return loc.advanced;
    return loc.expert;
  }

  List<String> _getCropTypes(AppLocalizations loc) {
    return [
      loc.wheat,
      loc.rice,
      loc.corn,
      loc.soybeans,
      loc.cotton,
      loc.sugarcane,
      loc.barley,
      loc.oats,
    ];
  }

  List<String> _getSoilTypes(AppLocalizations loc) {
    return [
      loc.clay,
      loc.sandy,
      loc.loamy,
      loc.silty,
      loc.peaty,
      loc.chalky,
      loc.saline,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Color(0xFFF8FAF8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        title: Text(
          loc.newProject,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
          tooltip: loc.cancel,
        ),
        elevation: 4,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Progress indicator
                _buildProgressIndicator(),
                SizedBox(height: 24),

                // Farm Details Section
                _buildSection(
                  title: 'Farm Details',
                  icon: Icons.agriculture_outlined,
                  children: [
                    _buildTextFormField(
                      controller: _farmNameController,
                      label: loc.farmName,
                      icon: Icons.eco_outlined,
                      validator:
                          (value) =>
                              value?.isEmpty == true ? 'Required field' : null,
                    ),
                    SizedBox(height: 16),
                    _buildTextFormField(
                      controller: _landSizeController,
                      label: loc.landSize,
                      icon: Icons.crop_landscape_outlined,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value?.isEmpty == true) return 'Required field';
                        if (double.tryParse(value!) == null) {
                          return 'Enter valid number';
                        }
                        return null;
                      },
                    ),
                  ],
                ),

                SizedBox(height: 28),

                // Crop Information Section
                _buildSection(
                  title: 'Crop Information',
                  icon: Icons.grass_outlined,
                  children: [
                    _buildEnhancedDropdownField(
                      label: loc.cropType,
                      value: selectedCropType,
                      items: _getCropTypes(loc),
                      onChanged:
                          (value) => setState(() => selectedCropType = value),
                      icon: Icons.agriculture,
                    ),
                  ],
                ),

                SizedBox(height: 28),

                _buildSection(
                  title: 'Soil & Environment',
                  icon: Icons.terrain_outlined,
                  children: [
                    _buildEnhancedDropdownField(
                      label: loc.soilType,
                      value: selectedSoilType,
                      items: _getSoilTypes(loc),
                      onChanged:
                          (value) => setState(() => selectedSoilType = value),
                      icon: Icons.layers,
                    ),
                    SizedBox(height: 16),
                    _buildEnhancedToggleField(
                      label: 'Irrigation Facilities',
                      subtitle: 'Modern irrigation system available',
                      value: irrigationFacilities,
                      onChanged:
                          (value) =>
                              setState(() => irrigationFacilities = value),
                      icon: Icons.water_drop_outlined,
                    ),
                  ],
                ),

                SizedBox(height: 28),

                // Additional Info Section
                _buildEnhancedSliderField(
                  label: loc.experience,
                  value: farmingExperience,
                  min: 0,
                  max: 5,
                  divisions: 5,
                  onChanged:
                      (value) => setState(() => farmingExperience = value),
                  loc: loc,
                ),

                SizedBox(height: 40),

                // Enhanced Bottom Buttons
                _buildActionButtons(loc),

                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.timeline, color: Color(0xFF4CAF50)),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Project Setup Progress',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                SizedBox(height: 4),
                LinearProgressIndicator(
                  value: 0.7,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
                ),
              ],
            ),
          ),
          Text(
            '70%',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF4CAF50),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Color(0xFF4CAF50), size: 20),
            SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Color(0xFF4CAF50)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          labelStyle: TextStyle(color: Colors.grey[600]),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Color(0xFF4CAF50), width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    required IconData icon,
    String? hint,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        child: DropdownButtonFormField<String>(
          initialValue: value,
          decoration: InputDecoration(
            labelText: label,
            hintText: hint ?? 'Select an option',
            prefixIcon: Container(
              margin: EdgeInsets.only(left: 12, right: 8),
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Color(0xFF4CAF50).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Color(0xFF4CAF50), size: 20),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Color(0xFF4CAF50), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.redAccent, width: 1),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            labelStyle: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            floatingLabelBehavior: FloatingLabelBehavior.auto,
          ),
          icon: Container(
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Color(0xFF4CAF50).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Color(0xFF4CAF50),
              size: 22,
            ),
          ),
          menuMaxHeight: 300,
          itemHeight: 56,
          style: TextStyle(
            fontSize: 15,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
          items:
              items.map((item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        margin: EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                              value == item
                                  ? Color(0xFF4CAF50)
                                  : Colors.transparent,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          item,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.black87,
                            fontWeight:
                                value == item
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
          onChanged: onChanged,
          validator:
              validator ??
              (value) => value == null ? 'Please select an option' : null,
          isExpanded: true,
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(12),
          elevation: 8,
          hint:
              hint != null
                  ? Text(
                    hint,
                    style: TextStyle(color: Colors.grey[400], fontSize: 15),
                  )
                  : null,
        ),
      ),
    );
  }

  Widget _buildEnhancedToggleField({
    required String label,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
    required IconData icon,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Color(0xFF4CAF50).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Color(0xFF4CAF50), size: 20),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: Color(0xFF4CAF50),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedSliderField({
    required String label,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required Function(double) onChanged,
    required AppLocalizations loc,
  }) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Color(0xFF4CAF50).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getExperienceLabel(value, loc),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4CAF50),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: Color(0xFF4CAF50),
              inactiveTrackColor: Color(0xFF4CAF50).withOpacity(0.2),
              thumbColor: Color(0xFF4CAF50),
              overlayColor: Color(0xFF4CAF50).withOpacity(0.2),
              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 10),
              overlayShape: RoundSliderOverlayShape(overlayRadius: 20),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Beginner',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              Text(
                'Expert',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(AppLocalizations loc) {
    return Row(
      children: [
        SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                // Handle form submission
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Project created successfully!'),
                    backgroundColor: Color(0xFF4CAF50),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF4CAF50),
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_circle_outline, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  loc.submit,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
