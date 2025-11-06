import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:event_safety_app/core/theme/app_colors.dart';
import 'package:event_safety_app/bloc/hazard/hazard_bloc.dart';
import 'package:event_safety_app/bloc/hazard/hazard_event.dart';
import 'package:event_safety_app/bloc/hazard/hazard_state.dart';
import 'package:event_safety_app/bloc/location/location_bloc.dart';
import 'package:event_safety_app/bloc/location/location_event.dart';
import 'package:event_safety_app/bloc/location/location_state.dart';

/// Map screen showing hazards and user location
/// TODO: Integrate Google Maps when ready
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  @override
  void initState() {
    super.initState();
    // Load hazards and start location tracking
    context.read<HazardBloc>().add(const LoadHazards());
    context.read<LocationBloc>().add(StartLocationTracking());
  }

  @override
  Widget build(BuildContext context) {
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
      body: Stack(
        children: [
          // TODO: Replace with GoogleMap widget
          Container(
            color: AppColors.grey100,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.map_outlined,
                    size: 80,
                    color: AppColors.grey400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Map View',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.grey700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Google Maps integration will be added here',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.grey500,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Hazard list overlay at bottom
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              constraints: const BoxConstraints(maxHeight: 300),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
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
                        const Text(
                          'Nearby Hazards',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
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
                                    color: AppColors.grey500,
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
    );
  }
}

/// Hazard list item widget
class _HazardListItem extends StatelessWidget {
  final dynamic hazard;

  const _HazardListItem({required this.hazard});

  @override
  Widget build(BuildContext context) {
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
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
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
