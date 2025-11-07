import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:ui' as ui;
import 'package:event_safety_app/core/theme/app_colors.dart';
import 'package:event_safety_app/bloc/hazard/hazard_bloc.dart';
import 'package:event_safety_app/bloc/hazard/hazard_event.dart';
import 'package:event_safety_app/bloc/hazard/hazard_state.dart';
import 'package:event_safety_app/bloc/location/location_bloc.dart';
import 'package:event_safety_app/bloc/location/location_event.dart';
import 'package:event_safety_app/bloc/location/location_state.dart';
import 'package:event_safety_app/bloc/auth/auth_bloc.dart';
import 'package:event_safety_app/bloc/auth/auth_state.dart';

/// Map screen showing hazards and user location using OpenStreetMap
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  LatLng? _currentLocation;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    // Load hazards and start location tracking
    context.read<HazardBloc>().add(const LoadHazards());
    context.read<LocationBloc>().add(StartLocationTracking());
    
    // Get current user ID
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      _currentUserId = authState.user.id;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hazard Map'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Show filter options
            },
          ),
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: () {
              // TODO: Center on user location
            },
          ),
        ],
      ),
      body: BlocListener<LocationBloc, LocationState>(
        listener: (context, state) {
          if (state is LocationLoaded) {
            setState(() {
              _currentLocation = LatLng(
                state.location.latitude,
                state.location.longitude,
              );
            });
            // Center map on user location when first loaded
            if (_currentLocation != null) {
              _mapController.move(_currentLocation!, 15.0);
            }
          }
        },
        child: Stack(
          children: [
            // OpenStreetMap with markers
            BlocBuilder<HazardBloc, HazardState>(
              builder: (context, hazardState) {
                final markers = <Marker>[];
                
                // Add user location marker
                if (_currentLocation != null) {
                  markers.add(
                    Marker(
                      point: _currentLocation!,
                      width: 40,
                      height: 40,
                      child: Icon(
                        Icons.my_location,
                        color: AppColors.primaryBlue,
                        size: 40,
                        shadows: const [
                          Shadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                
                // Add hazard markers
                if (hazardState is HazardLoaded) {
                  for (var hazard in hazardState.hazards) {
                    // Check if hazard was reported by current user
                    final isCurrentUser = hazard.reportedBy == _currentUserId;
                    final markerColor = isCurrentUser 
                        ? AppColors.primaryBlue  // User's own hazards
                        : AppColors.accentOrange; // Other users' hazards
                    
                    markers.add(
                      Marker(
                        point: LatLng(hazard.latitude, hazard.longitude),
                        width: 50,
                        height: 50,
                        child: GestureDetector(
                          onTap: () {
                            _showHazardDetails(hazard);
                          },
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Pin shadow
                              Positioned(
                                bottom: 0,
                                child: Container(
                                  width: 20,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: Colors.black26,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                              // Pin marker
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: markerColor,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 3,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: markerColor.withOpacity(0.4),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      _getHazardIcon(hazard.type),
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                  // Pin point
                                  CustomPaint(
                                    size: const Size(10, 8),
                                    painter: _PinPointerPainter(markerColor),
                                  ),
                                ],
                              ),
                              // Verification badge for verified hazards
                              if (hazard.isVerified)
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: const BoxDecoration(
                                      color: AppColors.secondaryGreen,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 10,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                }
                
                return FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _currentLocation ?? const LatLng(28.6139, 77.2090), // Default to Delhi
                    initialZoom: 15.0,
                    minZoom: 5.0,
                    maxZoom: 18.0,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.all,
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.hazardnet.event_safety_app',
                      tileBuilder: isDark ? _darkModeTileBuilder : null,
                    ),
                    MarkerLayer(markers: markers),
                  ],
                );
              },
            ),

            // Legend overlay (top right)
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: AppColors.primaryBlue,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Your Reports',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.white : AppColors.grey900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: AppColors.accentOrange,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Others\' Reports',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.white : AppColors.grey900,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Hazard list overlay at bottom (keeping existing implementation)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                constraints: const BoxConstraints(maxHeight: 300),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Handle bar
                    Container(
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.grey300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  // Title
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Nearby Hazards',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.white : AppColors.grey900,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            context.read<HazardBloc>().add(RefreshHazards());
                          },
                          child: const Text('Refresh'),
                        ),
                      ],
                    ),
                  ),

                  const Divider(height: 1),

                  // Hazard list
                  Expanded(
                    child: BlocBuilder<HazardBloc, HazardState>(
                      builder: (context, state) {
                        if (state is HazardLoading) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (state is HazardLoaded) {
                          if (state.hazards.isEmpty) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Text(
                                  'No hazards found nearby',
                                  style: TextStyle(
                                    color: isDark ? AppColors.grey400 : AppColors.grey500,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            );
                          }

                          return ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: state.hazards.length,
                            itemBuilder: (context, index) {
                              final hazard = state.hazards[index];
                              return _HazardListItem(hazard: hazard);
                            },
                          );
                        }

                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ],
              ),
            ),
            ),
          ],
        ),
      ),
    );
  }

  // Dark mode tile builder to invert map colors
  Widget _darkModeTileBuilder(BuildContext context, Widget tileWidget, TileImage tile) {
    return ColorFiltered(
      colorFilter: const ColorFilter.matrix([
        -1,  0,  0, 0, 255,
         0, -1,  0, 0, 255,
         0,  0, -1, 0, 255,
         0,  0,  0, 1,   0,
      ]),
      child: tileWidget,
    );
  }

  // Get hazard icon based on type
  IconData _getHazardIcon(String type) {
    switch (type) {
      case 'pothole':
        return Icons.crisis_alert;
      case 'speed_breaker':
      case 'speed_breaker_unmarked':
        return Icons.speed;
      case 'obstacle':
        return Icons.block;
      case 'closed_road':
        return Icons.do_not_disturb_on;
      default:
        return Icons.warning;
    }
  }

  // Show hazard details in bottom sheet
  void _showHazardDetails(dynamic hazard) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                controller: scrollController,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Handle bar
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppColors.grey300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Hazard type with icon
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _getSeverityColor(hazard.severity).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              _getHazardIcon(hazard.type),
                              color: _getSeverityColor(hazard.severity),
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  hazard.typeName,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? AppColors.white : AppColors.grey900,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _getSeverityColor(hazard.severity),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    hazard.severityText.toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Detection image (if available)
                      if (hazard.imageUrl != null) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            hazard.imageUrl!,
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              height: 180,
                              decoration: BoxDecoration(
                                color: _getSeverityColor(hazard.severity).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.image_not_supported,
                                    size: 48,
                                    color: isDark ? AppColors.grey600 : AppColors.grey400,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Image unavailable',
                                    style: TextStyle(
                                      color: isDark ? AppColors.grey400 : AppColors.grey600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                height: 180,
                                decoration: BoxDecoration(
                                  color: _getSeverityColor(hazard.severity).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Hazard details grid
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurface : AppColors.grey100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            _buildDetailRow(
                              Icons.access_time,
                              'Detected',
                              _getTimeAgo(hazard.detectedAt),
                              isDark,
                            ),
                            const SizedBox(height: 12),
                            _buildDetailRow(
                              Icons.location_on,
                              'Coordinates',
                              '${hazard.latitude.toStringAsFixed(5)}, ${hazard.longitude.toStringAsFixed(5)}',
                              isDark,
                            ),
                            const SizedBox(height: 12),
                            _buildDetailRow(
                              Icons.security,
                              'Risk Level',
                              hazard.severityText,
                              isDark,
                              color: _getSeverityColor(hazard.severity),
                            ),
                            const SizedBox(height: 12),
                            _buildDetailRow(
                              Icons.person,
                              'Reported By',
                              hazard.reportedByName ?? 'Anonymous',
                              isDark,
                            ),
                            const SizedBox(height: 12),
                            _buildDetailRow(
                              Icons.people,
                              'Total Reports',
                              '${hazard.verificationCount} ${hazard.verificationCount == 1 ? "person" : "people"}',
                              isDark,
                            ),
                            if (hazard.isVerified) ...[
                              const SizedBox(height: 12),
                              _buildDetailRow(
                                Icons.verified,
                                'Status',
                                'Verified ✓',
                                isDark,
                                color: AppColors.secondaryGreen,
                              ),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Navigate button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // TODO: Integrate with navigation app
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.navigation),
                          label: const Text('Navigate Here'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            backgroundColor: AppColors.primaryBlue,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, bool isDark, {Color? color}) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: color ?? (isDark ? AppColors.grey400 : AppColors.grey600),
        ),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.grey400 : AppColors.grey600,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color ?? (isDark ? AppColors.white : AppColors.grey900),
            ),
          ),
        ),
      ],
    );
  }

  Color _getSeverityColor(String severity) {
    switch (severity) {
      case 'low':
        return AppColors.severityLow;
      case 'medium':
        return AppColors.severityMedium;
      case 'high':
        return AppColors.severityHigh;
      case 'critical':
        return AppColors.severityCritical;
      default:
        return AppColors.grey500;
    }
  }

  String _getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}

// Custom painter for pin pointer
class _PinPointerPainter extends CustomPainter {
  final Color color;

  _PinPointerPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = ui.Path()
      ..moveTo(size.width / 2, size.height)
      ..lineTo(0, 0)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Hazard list item widget
class _HazardListItem extends StatelessWidget {
  final dynamic hazard;

  const _HazardListItem({required this.hazard});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getSeverityColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getSeverityColor().withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _getSeverityColor(),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getHazardIcon(),
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
                  hazard.typeName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.white : AppColors.grey900,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: AppColors.grey500,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _getTimeAgo(hazard.detectedAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.grey500,
                      ),
                    ),
                    const SizedBox(width: 16),
                    if (hazard.isVerified) ...[
                      Icon(
                        Icons.verified,
                        size: 14,
                        color: AppColors.secondaryGreen,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Verified',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.secondaryGreen,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: _getSeverityColor(),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              hazard.severityText,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getSeverityColor() {
    switch (hazard.severity) {
      case 'low':
        return AppColors.severityLow;
      case 'medium':
        return AppColors.severityMedium;
      case 'high':
        return AppColors.severityHigh;
      case 'critical':
        return AppColors.severityCritical;
      default:
        return AppColors.grey500;
    }
  }

  IconData _getHazardIcon() {
    switch (hazard.type) {
      case 'pothole':
        return Icons.crisis_alert;
      case 'speed_breaker':
      case 'speed_breaker_unmarked':
        return Icons.speed;
      case 'obstacle':
        return Icons.block;
      case 'closed_road':
        return Icons.do_not_disturb_on;
      default:
        return Icons.warning;
    }
  }

  String _getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
