import 'package:flutter/material.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      elevation: 16,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.grey.shade50, Colors.grey.shade100],
          ),
        ),
        child: Column(
          children: [
            _buildDrawerHeader(),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  const SizedBox(height: 8),
                  _buildDrawerSection('', [
                    _DrawerItemData(Icons.home_filled, 'Home', () {}),
                    _DrawerItemData(Icons.psychology, 'Learning Chat', () {}),
                    _DrawerItemData(Icons.book_rounded, 'Courses', () {}),
                    _DrawerItemData(Icons.forum_rounded, 'Forum', () {}),
                    _DrawerItemData(Icons.settings_rounded, 'Settings', () {}),
                  ]),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 0.5),
            _buildLogoutButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerHeader() {
    return Container(
      height: 200,
      margin: const EdgeInsets.only(bottom: 8),
      child: DrawerHeader(
        margin: EdgeInsets.zero,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF2E7D32), // Dark green
              const Color(0xFF388E3C), // Medium green
              const Color(0xFF4CAF50), // Light green
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
        child: _buildProfileContainer(),
      ),
    );
  }

  Widget _buildProfileContainer() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Left side - Photo
          _buildProfilePhoto(),
          const SizedBox(width: 16),
          // Right side - User info
          Expanded(child: _buildUserDetails()),
        ],
      ),
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
        radius: 35,
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

  Widget _buildUserDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Name
        const Text(
          'Raj Kumar',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.3,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),

        // Projects with number
        Row(
          children: [
            Icon(
              Icons.agriculture,
              color: Colors.white.withOpacity(0.9),
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              'Projects: 24',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),

        // Account created date
        Row(
          children: [
            Icon(
              Icons.calendar_today,
              color: Colors.white.withOpacity(0.9),
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              'Since: Jan 2024',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ],
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
            ),
          ),
        ...items.map(
          (item) => _buildDrawerItem(
            icon: item.icon,
            title: item.title,
            onTap: () {
              // Navigator.pop(context);
              item.onTap();
            },
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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: const Color(0xFF2E7D32), size: 22),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF2E2E2E),
                      letterSpacing: 0.1,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.grey[400],
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        elevation: 0,
        child: InkWell(
          onTap: () {
            _showLogoutDialog(context);
          },
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
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.logout_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Sign Out',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 0.3,
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
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Sign Out',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          content: const Text('Are you sure you want to sign out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // Perform logout
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Sign Out',
                style: TextStyle(color: Colors.white),
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
