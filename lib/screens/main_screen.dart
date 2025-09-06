import 'package:flutter/material.dart';
import '../components/drawer.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late AnimationController _animationController;

  // Sample data for dashboard (in a real app, this would come from an API)

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleDrawer() {
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      _scaffoldKey.currentState?.closeDrawer();
      _animationController.reverse();
    } else {
      _scaffoldKey.currentState?.openDrawer();
      _animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: CustomDrawerButton(
          animationController: _animationController,
          onPressed: _toggleDrawer,
        ),
        title: Text(
          'Krishi Sakhi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green[700],
        elevation: 2,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              // Handle notification action
            },
          ),
        ],
      ),
      drawer: CustomDrawer(),
      onDrawerChanged: (isOpened) {
        // Sync animation with drawer state
        if (isOpened) {
          _animationController.forward();
        } else {
          _animationController.reverse();
        }
      },
    );
  }
}

class CustomDrawerButton extends StatelessWidget {
  final AnimationController animationController;
  final VoidCallback onPressed;

  const CustomDrawerButton({
    required this.animationController,
    required this.onPressed,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12.0),
      child: Container(
        margin: EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 2.0,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: AnimatedBuilder(
          animation: animationController,
          builder: (context, child) {
            return Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Top line
                  Transform.translate(
                    offset: Offset(0, -6 + 6 * animationController.value),
                    child: Transform.rotate(
                      angle: animationController.value * 0.8, // ~45 degrees
                      child: Container(
                        height: 2.5,
                        width: 18,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                  // Middle line
                  Opacity(
                    opacity: 1 - animationController.value,
                    child: Container(
                      height: 2.5,
                      width: 18,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  // Bottom line
                  Transform.translate(
                    offset: Offset(0, 6 - 6 * animationController.value),
                    child: Transform.rotate(
                      angle: -animationController.value * 0.8, // ~-45 degrees
                      child: Container(
                        height: 2.5,
                        width: 18,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
