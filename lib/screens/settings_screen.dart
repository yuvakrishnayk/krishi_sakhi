import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:krishi_sakhi/components/drawer.dart';
import 'package:krishi_sakhi/l10n/app_localizations.dart';
import 'package:krishi_sakhi/main.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  List<bool> _faqExpanded = [false, false, false, false];

  String _userName = 'Your Name';
  File? _profileImageFile;
  String _profilePicUrl = 'https://static.vecteezy.com/system/resources/previews/022/395/514/non_2x/a-beautiful-smiling-young-male-farmer-in-front-of-a-farm-background-ai-generated-photo.jpeg';

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      drawer: const CustomDrawer(),
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        title: Text(
          loc.settings,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
            tooltip: 'Open navigation menu',
          ),
        ),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.grey.shade50, Colors.grey.shade100],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          children: [
            // Profile Section with Edit
            Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Stack(
                children: [
                  _buildProfileContainer(context),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      icon: const Icon(Icons.edit, color: Colors.white),
                      tooltip: 'Edit Profile',
                      onPressed: () => _showEditProfileDialog(context),
                    ),
                  ),
                ],
              ),
            ),
            // Notification Toggle
            _buildSettingCard(
              context,
              icon: Icons.notifications_active_rounded,
              title: 'Notifications',
              subtitle: _notificationsEnabled ? 'On' : 'Off',
              trailing: Switch(
                value: _notificationsEnabled,
                activeColor: const Color(0xFF2E7D32),
                onChanged: (val) {
                  setState(() => _notificationsEnabled = val);
                },
              ),
              onTap: () => setState(() => _notificationsEnabled = !_notificationsEnabled),
            ),
            // Language Option
            _buildSettingCard(
              context,
              icon: Icons.language,
              title: loc.language,
              subtitle: _getCurrentLanguage(context),
              onTap: () => _showLanguageDialog(context),
            ),
            // FAQ Section
            Padding(
              padding: const EdgeInsets.only(top: 18),
              child: Text(
                'FAQ',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[900],
                ),
              ),
            ),
            _buildFaqDropdown(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileContainer(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2E7D32),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Left side - Photo
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              radius: 35,
              backgroundImage: _profileImageFile != null
                  ? FileImage(_profileImageFile!)
                  : NetworkImage(_profilePicUrl) as ImageProvider,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF4CAF50).withOpacity(0.3),
                    width: 1,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Right side - User info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _userName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.agriculture, color: Colors.white.withOpacity(0.9), size: 16),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        '24 Projects',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.calendar_today, color: Colors.white.withOpacity(0.9), size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'Since Jan 2024',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context) async {
    final nameController = TextEditingController(text: _userName);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () async {
                final picker = ImagePicker();
                final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                if (pickedFile != null) {
                  setState(() {
                    _profileImageFile = File(pickedFile.path);
                  });
                  Navigator.of(context).pop();
                  _showEditProfileDialog(context); // reopen dialog to show new image
                }
              },
              child: CircleAvatar(
                radius: 35,
                backgroundImage: _profileImageFile != null
                    ? FileImage(_profileImageFile!)
                    : NetworkImage(_profilePicUrl) as ImageProvider,
                child: Container(
                  alignment: Alignment.bottomRight,
                  child: const Icon(Icons.camera_alt, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _userName = nameController.text;
              });
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Ink(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.shade100.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: const Color(0xFF2E7D32), size: 28),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2E2E2E),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (trailing != null) trailing,
                  if (trailing == null)
                    Icon(Icons.chevron_right_rounded, color: Colors.grey[400], size: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFaqDropdown() {
    final faqList = [
      {
        'question': 'How do I change the app language?',
        'answer': 'Tap on the Language option in Settings. Select English or Malayalam. The app will update to your chosen language instantly.',
      },
      {
        'question': 'How do I enable notifications?',
        'answer': 'Go to Settings and use the Notifications switch to turn notifications on or off. You will receive updates based on your preference.',
      },
      {
        'question': 'How do I contact support?',
        'answer': 'You can contact support by visiting the Forum section for community help or using the Chatbot for instant assistance.',
      },
      {
        'question': 'How do I edit my profile?',
        'answer': 'Go to Settings and tap the edit icon on your profile. You can change your name and profile picture.',
      },
    ];

    // Ensure _faqExpanded matches faqList length
    if (_faqExpanded.length != faqList.length) {
      _faqExpanded = List<bool>.filled(faqList.length, false);
    }

    return ExpansionPanelList(
      expansionCallback: (int index, bool isExpanded) {
        setState(() {
          _faqExpanded[index] = !isExpanded;
        });
      },
      children: faqList.asMap().entries.map((entry) {
        int idx = entry.key;
        var faq = entry.value;
        return ExpansionPanel(
          headerBuilder: (context, isExpanded) {
            return ListTile(
              title: Text(
                faq['question']!,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            );
          },
          body: ListTile(
            title: Text(faq['answer']!),
          ),
          isExpanded: _faqExpanded[idx],
        );
      }).toList(),
      elevation: 1,
      dividerColor: Colors.grey[300],
      expandedHeaderPadding: const EdgeInsets.symmetric(vertical: 4),
    );
  }

  String _getCurrentLanguage(BuildContext context) {
    final locale = Localizations.localeOf(context);
    switch (locale.languageCode) {
      case 'ml':
        return 'മലയാളം';
      case 'en':
      default:
        return 'English';
    }
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          AppLocalizations.of(context)!.chooseLanguage,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<Locale>(
              value: const Locale('en'),
              groupValue: Localizations.localeOf(context),
              title: const Text('English'),
              activeColor: const Color(0xFF388E3C),
              onChanged: (locale) {
                MyApp.of(context)?.changeLocale(locale!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<Locale>(
              value: const Locale('ml'),
              groupValue: Localizations.localeOf(context),
              title: const Text('മലയാളം'),
              activeColor: const Color(0xFF388E3C),
              onChanged: (locale) {
                MyApp.of(context)?.changeLocale(locale!);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}