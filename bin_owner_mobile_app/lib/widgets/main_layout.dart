import 'package:flutter/material.dart';
import 'package:bin_owner_mobile_app/screens/bin_level_screen.dart';
import 'package:bin_owner_mobile_app/screens/notification.dart';
import 'package:bin_owner_mobile_app/screens/calendar.dart';
import 'package:bin_owner_mobile_app/screens/problem_report_screen.dart';
import 'package:bin_owner_mobile_app/screens/settings.dart';

// Constants for better maintainability
class AppConstants {
  static const Color primaryColor = Colors.green;
  static const Color inactiveColor = Colors.grey;
  static const Color backgroundColor = Color(0xFF121212);
  static const Color surfaceColor = Color(0xFF1E1E1E);
  static const Color borderColor = Color(0xFF2C2C2C);
  static const Color textColor = Colors.white;
  static const Color textSecondaryColor = Color(0xFFB0B0B0);

  static const Duration animationDuration = Duration(milliseconds: 250);
  static const Duration refreshDelay = Duration(milliseconds: 800);

  static const double iconSize = 24.0;
  static const double fontSize = 12.0;
  static const double padding = 8.0;
  static const double borderWidth = 1.0;
}

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isRefreshing = false;

  // Moved to getter to avoid keeping in memory
  List<ScreenConfig> get _screenConfigs => [
    ScreenConfig(
      screen: const BinLevelScreen(),
      title: 'Bin Status',
      icon: Icons.delete_outline,
    ),
    ScreenConfig(
      screen: const NotificationScreen(),
      title: 'Notifications',
      icon: Icons.notifications,
    ),
    ScreenConfig(
      screen: const CollectionCalendarScreen(),
      title: 'Calendar',
      icon: Icons.calendar_today,
    ),
    ScreenConfig(
      screen: const ProblemReportScreen(),
      title: 'Report',
      icon: Icons.report_problem,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: AppConstants.animationDuration,
    );

    // Use scale animation instead of fade for better UX
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _navigateTo(int index) {
    if (index == _currentIndex || _isRefreshing) return;

    setState(() => _currentIndex = index);

    // Simple animation restart instead of complex reverse/forward
    _animationController.reset();
    _animationController.forward();
  }

  Future<void> _refreshData() async {
    if (_isRefreshing) return;

    setState(() => _isRefreshing = true);

    try {
      // Simulate refresh operation
      await Future.delayed(AppConstants.refreshDelay);

      if (mounted) {
        _showSuccessMessage('Data refreshed successfully');
      }
    } catch (e) {
      if (mounted) {
        _showErrorMessage('Refresh failed: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isRefreshing = false);
      }
    }
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppConstants.primaryColor,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _openSettings() async {
    try {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const SettingsScreen(),
          settings: const RouteSettings(name: '/settings'),
        ),
      );
    } catch (e) {
      if (mounted) {
        _showErrorMessage('Could not open settings');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: _buildAppBar(),
      body: Column(
        children: [Expanded(child: _buildBody()), _buildBottomNavigation()],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        _screenConfigs[_currentIndex].title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: AppConstants.textColor,
        ),
      ),
      centerTitle: true,
      elevation: 0,
      backgroundColor: const Color.from(
        alpha: 1,
        red: 0.118,
        green: 0.118,
        blue: 0.118,
      ),
      actions: [
        // Compact action row with both icons
        Container(
          margin: const EdgeInsets.only(right: 12.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Refresh button
              Container(
                decoration: BoxDecoration(
                  color: AppConstants.borderColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  constraints: const BoxConstraints(
                    minWidth: 40,
                    minHeight: 40,
                  ),
                  icon:
                      _isRefreshing
                          ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppConstants.primaryColor,
                              ),
                            ),
                          )
                          : const Icon(
                            Icons.refresh_outlined,
                            size: 20,
                            color: AppConstants.textColor,
                          ),
                  tooltip: 'Refresh',
                  onPressed: _isRefreshing ? null : _refreshData,
                ),
              ),
              const SizedBox(width: 8),
              // Settings button
              Container(
                decoration: BoxDecoration(
                  color: AppConstants.borderColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  constraints: const BoxConstraints(
                    minWidth: 40,
                    minHeight: 40,
                  ),
                  icon: const Icon(
                    Icons.settings_outlined,
                    size: 20,
                    color: AppConstants.textColor,
                  ),
                  tooltip: 'Settings',
                  onPressed: _openSettings,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      decoration: BoxDecoration(
        color: AppConstants.surfaceColor,
        border: Border(
          top: BorderSide(
            color: AppConstants.borderColor,
            width: AppConstants.borderWidth,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: AppConstants.padding,
            horizontal: 16.0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              _screenConfigs.length,
              (index) => _buildNavItem(index),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index) {
    final config = _screenConfigs[index];
    final isSelected = _currentIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () => _navigateTo(index),
        borderRadius: BorderRadius.circular(12),
        splashColor: AppConstants.primaryColor.withOpacity(0.1),
        highlightColor: AppConstants.primaryColor.withOpacity(0.05),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: AppConstants.animationDuration,
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? AppConstants.primaryColor.withOpacity(0.15)
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  config.icon,
                  size: AppConstants.iconSize,
                  color:
                      isSelected
                          ? AppConstants.primaryColor
                          : AppConstants.inactiveColor.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 4),
              AnimatedDefaultTextStyle(
                duration: AppConstants.animationDuration,
                style: TextStyle(
                  fontSize: AppConstants.fontSize,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color:
                      isSelected
                          ? AppConstants.primaryColor
                          : AppConstants.textSecondaryColor,
                ),
                child: Text(config.title),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: IndexedStack(
        index: _currentIndex,
        children: _screenConfigs.map((config) => config.screen).toList(),
      ),
    );
  }
}

class ScreenConfig {
  final Widget screen;
  final String title;
  final IconData icon;

  const ScreenConfig({
    required this.screen,
    required this.title,
    required this.icon,
  });
}

// Optional: Custom page route for smoother transitions
class FadePageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;

  FadePageRoute({required this.child})
    : super(
        pageBuilder: (context, animation, secondaryAnimation) => child,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: AppConstants.animationDuration,
      );
}
