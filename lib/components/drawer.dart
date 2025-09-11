import 'package:flutter/material.dart';
import 'package:krishi_sakhi/l10n/app_localizations.dart';
import 'package:krishi_sakhi/screens/chatbot_screen.dart';
import 'package:krishi_sakhi/screens/courses_screen.dart';
import 'package:krishi_sakhi/screens/forum_screen.dart';
import 'package:krishi_sakhi/screens/home_screen.dart';
import 'package:krishi_sakhi/screens/settings_screen.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!; // make non-null
    return Drawer(
      elevation: 16,
      child: Column(
        children: [
          _buildDrawerHeader(context),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.grey.shade50, Colors.grey.shade100],
                ),
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    _buildDrawerSection('', [
                      _DrawerItemData(Icons.home_filled, l10n.drawerHome, () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => HomeScreen()),
                        );
                      }),
                      _DrawerItemData(
                        Icons.psychology,
                        l10n.drawerLearningChat,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatbotScreen(),
                            ),
                          );
                        },
                      ),
                      _DrawerItemData(
                        Icons.book_rounded,
                        l10n.drawerCourses,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CoursesScreen(),
                            ),
                          );
                        },
                      ),
                      _DrawerItemData(
                        Icons.forum_rounded,
                        l10n.drawerForum,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ForumScreen(),
                            ),
                          );
                        },
                      ),
                      _DrawerItemData(
                        Icons.settings_rounded,
                        l10n.drawerSettings,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SettingsScreen(),
                            ),
                          );
                        },
                      ),
                    ]),
                    // Language switcher section
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
          const Divider(height: 1, thickness: 0.5),
          _buildLogoutButton(context),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: 200, maxHeight: 240),
      margin: EdgeInsets.zero,
      padding: EdgeInsets.fromLTRB(
        16,
        MediaQuery.of(context).padding.top + 16,
        16,
        16,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF2E7D32),
            const Color(0xFF388E3C),
            const Color(0xFF4CAF50),
          ],
          stops: const [0.0, 0.6, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: _buildProfileContainer(context),
    );
  }

  Widget _buildProfileContainer(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      padding: const EdgeInsets.all(12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Use different layouts based on available space
          if (constraints.maxWidth < 200) {
            return _buildCompactProfile(context);
          } else {
            return _buildStandardProfile(context);
          }
        },
      ),
    );
  }

  Widget _buildCompactProfile(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildProfilePhoto(),
        const SizedBox(height: 8),
        Flexible(child: _buildUserDetails(context)),
      ],
    );
  }

  Widget _buildStandardProfile(BuildContext context) {
    return Row(
      children: [
        // Left side - Photo
        _buildProfilePhoto(),
        const SizedBox(width: 12),
        // Right side - User info
        Expanded(child: _buildUserDetails(context)),
      ],
    );
  }

  Widget _buildProfilePhoto() {
    return Container(
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
        radius: 30, // Reduced from 35 to save space
        backgroundImage: const NetworkImage(
          'https://static.vecteezy.com/system/resources/previews/022/395/514/non_2x/a-beautiful-smiling-young-male-farmer-in-front-of-a-farm-background-ai-generated-photo.jpeg',
        ),
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
    );
  }

  Widget _buildUserDetails(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Flexible(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Name
          Flexible(
            child: Text(
              l10n.userName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16, // Reduced from 18
                fontWeight: FontWeight.bold,
                letterSpacing: 0.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 6), // Reduced spacing
          // Projects with number
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.agriculture,
                  color: Colors.white.withOpacity(0.9),
                  size: 14, // Reduced from 16
                ),
                const SizedBox(width: 4), // Reduced spacing
                Flexible(
                  child: Text(
                    l10n.projectsCount('24'),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12, // Reduced from 14
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 2),

          // Account created date
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.calendar_today,
                  color: Colors.white.withOpacity(0.9),
                  size: 14, // Reduced from 16
                ),
                const SizedBox(width: 4), // Reduced spacing
                Flexible(
                  child: Text(
                    l10n.sinceDate,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 11, // Reduced from 12
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerSection(String title, List<_DrawerItemData> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
                letterSpacing: 1.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ...items.map(
          (item) => _buildDrawerItem(
            icon: item.icon,
            title: item.title,
            onTap: item.onTap,
          ),
        ),
      ],
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 14,
            ), // Reduced vertical padding
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6), // Reduced from 8
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: const Color(0xFF2E7D32),
                    size: 20,
                  ), // Reduced from 22
                ),
                const SizedBox(width: 12), // Reduced from 16
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15, // Reduced from 16
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF2E2E2E),
                      letterSpacing: 0.1,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.grey[400],
                  size: 18, // Reduced from 20
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        elevation: 0,
        child: InkWell(
          onTap: () => _showLogoutDialog(context),
          borderRadius: BorderRadius.circular(12),
          child: Ink(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.red.shade500.withOpacity(0.9),
                  Colors.red.shade600,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.shade200.withOpacity(0.5),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 12,
              ), // Reduced from 14
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.logout_rounded,
                    color: Colors.white,
                    size: 20, // Reduced from 22
                  ),
                  const SizedBox(width: 8), // Reduced from 12
                  Flexible(
                    child: Text(
                      l10n.signOut,
                      style: const TextStyle(
                        fontSize: 15, // Reduced from 16
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            l10n.signOut,
            style: const TextStyle(fontWeight: FontWeight.w600),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          content: SingleChildScrollView(
            child: Text(
              l10n.signOutQuestion,
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                l10n.cancel,
                style: TextStyle(color: Colors.grey[600]),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // TODO: Perform logout
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                l10n.signOut,
                style: const TextStyle(color: Colors.white),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _DrawerItemData {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  _DrawerItemData(this.icon, this.title, this.onTap);
}
