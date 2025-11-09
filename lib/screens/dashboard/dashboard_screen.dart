import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:event_safety_app/core/theme/app_colors.dart';
import 'package:event_safety_app/core/constants/app_constants.dart';
import 'package:event_safety_app/bloc/auth/auth_bloc.dart';
import 'package:event_safety_app/bloc/auth/auth_state.dart';
import 'package:event_safety_app/bloc/camera/camera_bloc.dart';
import 'package:event_safety_app/bloc/camera/camera_event.dart';
import 'package:event_safety_app/bloc/alerts/alerts_bloc.dart';
import 'package:event_safety_app/bloc/alerts/alerts_event.dart';
import 'package:event_safety_app/bloc/alerts/alerts_state.dart';
import 'package:event_safety_app/screens/camera/camera_screen.dart';
import 'package:event_safety_app/screens/map/map_screen.dart';
import 'package:event_safety_app/screens/alerts/alerts_screen.dart';
import 'package:event_safety_app/screens/profile/profile_screen.dart';

/// Main dashboard with navigation and quick access features
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  late final CameraBloc _cameraBloc;

  @override
  void initState() {
    super.initState();
    _cameraBloc = context.read<CameraBloc>();
  }

  final List<Widget> _screens = [
    const DashboardHomeScreen(),
    const MapScreen(),
    const CameraScreen(),
    const AlertsScreen(),
    const ProfileScreen(),
  ];

  void _onNavigationTap(int index) {
    // Dispose camera when navigating away from camera screen
    if (_selectedIndex == 2 && index != 2) {
      _cameraBloc.add(DisposeCameraEvent());
    }
    
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildNavItem(int index, IconData activeIcon, IconData inactiveIcon, String label) {
    final isSelected = _selectedIndex == index;
    
    return GestureDetector(
      onTap: () => _onNavigationTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.primaryGradient : null,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryBlue.withValues(alpha:0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSelected ? activeIcon : inactiveIcon,
                color: isSelected ? Colors.white : AppColors.grey500,
                size: isSelected ? 26 : 24,
              ),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: isSelected ? 12 : 11,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? Colors.white : AppColors.grey600,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.darkSurface
              : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha:0.08),
              blurRadius: 30,
              offset: const Offset(0, -10),
              spreadRadius: 0,
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: _buildNavItem(0, Icons.home_rounded, Icons.home_outlined, 'Home'),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildNavItem(1, Icons.explore_rounded, Icons.explore_outlined, 'Explore'),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildNavItem(2, Icons.qr_code_scanner_rounded, Icons.qr_code_scanner_outlined, 'Scan'),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildNavItem(3, Icons.notifications_rounded, Icons.notifications_outlined, 'Alerts'),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildNavItem(4, Icons.person_rounded, Icons.person_outline_rounded, 'Profile'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Dashboard home screen with quick actions and stats
class DashboardHomeScreen extends StatelessWidget {
  const DashboardHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.grey50,
      body: CustomScrollView(
        slivers: [
          // Premium App Bar with Glassmorphism
          SliverAppBar(
            expandedHeight: 180,
            floating: false,
            pinned: true,
            stretch: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [
                StretchMode.zoomBackground,
                StretchMode.blurBackground,
              ],
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Gradient Background
                  Container(
                    decoration: const BoxDecoration(
                      gradient: AppColors.heroGradient,
                    ),
                  ),
                  // Animated Circles Background
                  Positioned(
                    top: -50,
                    right: -50,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha:0.1),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -30,
                    left: -30,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha:0.05),
                      ),
                    ),
                  ),
                  // Content
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
                      child: BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          String userName = 'Driver';
                          if (state is Authenticated) {
                            userName = state.user.displayName ?? 'Driver';
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              // Time-based greeting with icon
                              Row(
                                children: [
                                  Icon(
                                    _getGreetingIcon(),
                                    color: Colors.white.withValues(alpha:0.9),
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _getGreeting(),
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white.withValues(alpha:0.9),
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                userName,
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Stay safe on the road',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withValues(alpha:0.8),
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content with premium spacing
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Premium Stats Card
                _buildPremiumStatsCard(context)
                    .animate()
                    .fadeIn(duration: 600.ms, curve: Curves.easeOut)
                    .slideY(begin: 0.3, end: 0, curve: Curves.easeOut),

                const SizedBox(height: 28),

                // Section Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Quick Access',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.white : AppColors.grey900,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Your most used features',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? AppColors.grey400 : AppColors.grey600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ).animate().fadeIn(delay: 200.ms),

                const SizedBox(height: 16),

                // Premium Actions Grid
                _buildPremiumActionsGrid(context)
                    .animate()
                    .fadeIn(delay: 300.ms, duration: 600.ms)
                    .slideY(begin: 0.2, end: 0),

                const SizedBox(height: 28),

                // Vehicle Health Section
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    if (state is Authenticated) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Vehicle Status',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: isDark ? AppColors.white : AppColors.grey900,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildPremiumVehicleCard(
                            damageScore: state.user.cumulativeDamageScore,
                            needsMaintenance: state.user.needsMaintenanceCheck,
                            context: context,
                          ),
                        ],
                      ).animate().fadeIn(delay: 400.ms);
                    }
                    return const SizedBox.shrink();
                  },
                ),

                const SizedBox(height: 28),

                // Recent Alerts Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Recent Alerts',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.white : AppColors.grey900,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Latest notifications',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? AppColors.grey400 : AppColors.grey600,
                          ),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () {
                        // Navigate to alerts tab
                      },
                      child: Row(
                        children: [
                          Text(
                            'View All',
                            style: TextStyle(
                              color: AppColors.primaryBlue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 16,
                            color: AppColors.primaryBlue,
                          ),
                        ],
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 500.ms),

                const SizedBox(height: 16),

                BlocBuilder<AlertsBloc, AlertsState>(
                  builder: (context, state) {
                    if (state is AlertsLoaded) {
                      final recentAlerts = state.alerts.take(3).toList();
                      if (recentAlerts.isEmpty) {
                        return _buildEmptyAlertsState(context);
                      }

                      return Column(
                        children: recentAlerts
                            .asMap()
                            .entries
                            .map(
                              (entry) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _buildPremiumAlertCard(entry.value, context)
                                    .animate()
                                    .fadeIn(
                                      delay: (600 + entry.key * 100).ms,
                                      duration: 500.ms,
                                    )
                                    .slideX(begin: 0.2, end: 0),
                              ),
                            )
                            .toList(),
                      );
                    }
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(AppColors.primaryBlue),
                        ),
                      ),
                    );
                  },
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumStatsCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.primaryBlue.withValues(alpha:0.1),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withValues(alpha:0.08),
            blurRadius: 30,
            offset: const Offset(0, 10),
            spreadRadius: -5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryBlue.withValues(alpha:0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.trending_up_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TODAY\'S JOURNEY',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? AppColors.grey400 : AppColors.grey600,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '2.5',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: isDark ? AppColors.white : const Color(0xFF1A202C),
                            letterSpacing: -1,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'km driven',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.grey400 : AppColors.grey500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Simple Divider
          Container(
            height: 1,
            color: isDark ? AppColors.grey700 : AppColors.grey200,
          ),
          const SizedBox(height: 20),
          // Enhanced Stats Grid
          Row(
            children: [
              Expanded(
                child: _buildPremiumStatItem(
                  icon: Icons.warning_amber_rounded,
                  label: 'Hazards',
                  value: '12',
                  color: AppColors.accentOrange,
                  context: context,
                ),
              ),
              Container(
                width: 1.5,
                height: 55,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      AppColors.grey200,
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              Expanded(
                child: _buildPremiumStatItem(
                  icon: Icons.verified_rounded,
                  label: 'Verified',
                  value: '8',
                  color: AppColors.secondaryGreen,
                  context: context,
                ),
              ),
              Container(
                width: 1.5,
                height: 55,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      AppColors.grey200,
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              Expanded(
                child: _buildPremiumStatItem(
                  icon: Icons.star_rounded,
                  label: 'Points',
                  value: '245',
                  color: AppColors.accentPurple,
                  context: context,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    BuildContext? context,
  }) {
    final isDark = context != null && Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha:0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.white : const Color(0xFF1A202C),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? AppColors.grey400 : AppColors.grey600,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildPremiumActionsGrid(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 14,
      crossAxisSpacing: 14,
      childAspectRatio: 1.25,
      children: [
        _buildPremiumActionCard(
          title: 'Start Scan',
          subtitle: 'Detect hazards',
          icon: Icons.qr_code_scanner_rounded,
          gradient: AppColors.primaryGradient,
          onTap: () {},
        ),
        _buildPremiumActionCard(
          title: 'View Map',
          subtitle: 'Explore nearby',
          icon: Icons.explore_rounded,
          gradient: AppColors.safetyGradient,
          onTap: () {},
        ),
        _buildPremiumActionCard(
          title: 'Alerts',
          subtitle: '3 new',
          icon: Icons.notifications_active_rounded,
          gradient: AppColors.warningGradient,
          onTap: () {},
        ),
        _buildPremiumActionCard(
          title: 'Profile',
          subtitle: 'View stats',
          icon: Icons.person_rounded,
          gradient: LinearGradient(
            colors: [AppColors.accentPurple, AppColors.accentPurple.withValues(alpha:0.7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildPremiumActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: gradient.colors.first.withValues(alpha:0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
                spreadRadius: -4,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha:0.25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withValues(alpha:0.9),
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumVehicleCard({
    required int damageScore,
    required bool needsMaintenance,
    required BuildContext context,
  }) {
    final progress = (damageScore / 1000).clamp(0.0, 1.0);
    Color progressColor = AppColors.secondaryGreen;
    String statusText = 'Excellent';
    IconData statusIcon = Icons.check_circle_rounded;
    String statusEmoji = '✨';

    if (damageScore >= 850) {
      progressColor = AppColors.error;
      statusText = 'Critical';
      statusIcon = Icons.error_rounded;
      statusEmoji = '⚠️';
    } else if (damageScore >= 600) {
      progressColor = AppColors.accentOrange;
      statusText = 'Needs Attention';
      statusIcon = Icons.warning_rounded;
      statusEmoji = '⚡';
    } else if (damageScore >= 400) {
      progressColor = AppColors.warning;
      statusText = 'Fair';
      statusIcon = Icons.info_rounded;
      statusEmoji = '👍';
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: progressColor.withValues(alpha:0.15),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: progressColor.withValues(alpha:0.1),
            blurRadius: 30,
            offset: const Offset(0, 10),
            spreadRadius: -5,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [progressColor, progressColor.withValues(alpha:0.7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: progressColor.withValues(alpha:0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.directions_car_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'HEALTH SCORE',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? AppColors.grey400 : AppColors.grey600,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '$damageScore',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              color: progressColor,
                              letterSpacing: -1.5,
                              height: 1,
                            ),
                          ),
                          Text(
                            ' / 1000',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.grey400,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: progressColor.withValues(alpha:0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: progressColor.withValues(alpha:0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        statusEmoji,
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 12,
                          color: progressColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Premium Progress Bar
            Stack(
              children: [
                Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: AppColors.grey200,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: FractionallySizedBox(
                    widthFactor: progress,
                    child: Container(
                      height: 10,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [progressColor, progressColor.withValues(alpha:0.8)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: progressColor.withValues(alpha:0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (needsMaintenance) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha:0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.error.withValues(alpha:0.2),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.error,
                            AppColors.error.withValues(alpha:0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.build_circle_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Maintenance Required',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.error,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Schedule a check-up soon',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.grey700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: AppColors.error,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumAlertCard(dynamic alert, BuildContext context) {
    IconData icon = Icons.notifications_active_rounded;
    Color color = AppColors.accentOrange;
    String emoji = '🔔';

    if (alert.type == 'pothole' || alert.type == 'hazard_proximity') {
      icon = Icons.report_problem_rounded;
      color = AppColors.error;
      emoji = '⚠️';
    } else if (alert.type == 'speed_breaker') {
      icon = Icons.speed_rounded;
      color = AppColors.warning;
      emoji = '⚡';
    } else if (alert.type == 'maintenance_due') {
      icon = Icons.build_circle_rounded;
      color = AppColors.accentOrange;
      emoji = '🔧';
    }

    // Format timestamp
    final now = DateTime.now();
    final difference = now.difference(alert.timestamp);
    String timeAgo;
    if (difference.inDays > 0) {
      timeAgo = '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      timeAgo = '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      timeAgo = '${difference.inMinutes}m ago';
    } else {
      timeAgo = 'Just now';
    }

    final isHighSeverity = alert.severity?.toLowerCase() == 'high' || 
                          alert.type == 'pothole' || 
                          alert.type == 'hazard_proximity';

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha:0.15),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha:0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
            spreadRadius: -4,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [color, color.withValues(alpha:0.7)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: color.withValues(alpha:0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(icon, color: Colors.white, size: 24),
                    ),
                    if (isHighSeverity)
                      Positioned(
                        top: -4,
                        right: -4,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.error.withValues(alpha:0.4),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.priority_high_rounded,
                            color: Colors.white,
                            size: 10,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            emoji,
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              alert.title,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: isDark ? AppColors.white : AppColors.grey900,
                                letterSpacing: -0.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 13,
                            color: AppColors.grey500,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            timeAgo,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? AppColors.grey400 : AppColors.grey600,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha:0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyAlertsState(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.grey200,
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryBlue.withValues(alpha:0.1),
                  AppColors.accentPurple.withValues(alpha:0.1),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_none_rounded,
              size: 48,
              color: AppColors.primaryBlue,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'All Clear!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.white : const Color(0xFF1A202C),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No alerts at the moment',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppColors.grey400 : AppColors.grey600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getGreetingIcon() {
    final hour = DateTime.now().hour;
    if (hour < 12) return Icons.wb_sunny_rounded;
    if (hour < 17) return Icons.wb_sunny_outlined;
    return Icons.nightlight_round;
  }

  Widget _buildModernAlertCard(dynamic alert, BuildContext context) {
    return _buildPremiumAlertCard(alert, context);
  }

  Widget _buildEmptyState(BuildContext context) {
    return _buildEmptyAlertsState(context);
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }
}
