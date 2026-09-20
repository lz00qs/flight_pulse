import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_providers.dart';
import '../theme/app_colors.dart';
import '../widgets/tracking_card.dart';

class TrackingListView extends ConsumerWidget {
  final bool isMobile;
  final VoidCallback onAddFlightTap;

  const TrackingListView({
    super.key,
    required this.isMobile,
    required this.onAddFlightTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(trackingFilterProvider);
    final activeFlights = ref.watch(activeFlightsProvider);
    final expiredFlights = ref.watch(expiredFlightsProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final displayedFlights = filter == TrackingFilter.active ? activeFlights : expiredFlights;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16.0 : 48.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Flight tracking',
                    style: TextStyle(
                      fontSize: isMobile ? 24 : 28,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'A clear view of every itinerary you watch.',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
              if (!isMobile)
                ElevatedButton.icon(
                  onPressed: onAddFlightTap,
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Add flight'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
            ],
          ),

          const SizedBox(height: 24),

          // Status Filter Tabs
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceSecondaryDark : AppColors.surfaceSecondaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTabPill(
                  label: 'Active',
                  count: activeFlights.length,
                  isSelected: filter == TrackingFilter.active,
                  onTap: () {
                    ref.read(trackingFilterProvider.notifier).state = TrackingFilter.active;
                  },
                  isDark: isDark,
                ),
                _buildTabPill(
                  label: 'Expired',
                  count: expiredFlights.length,
                  isSelected: filter == TrackingFilter.expired,
                  onTap: () {
                    ref.read(trackingFilterProvider.notifier).state = TrackingFilter.expired;
                  },
                  isDark: isDark,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Main Layout: List & Guidance Sidebar
          if (isMobile) ...[
            if (displayedFlights.isEmpty)
              _buildEmptyState(context, isDark)
            else
              ...displayedFlights.map(
                (trip) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: TrackingCardWidget(
                    trip: trip,
                    isMobile: true,
                    onTap: () {
                      ref.read(selectedTripIdProvider.notifier).state = trip.id;
                    },
                  ),
                ),
              ),
            const SizedBox(height: 16),
            _buildGuidanceCard(context, isDark, activeCount: activeFlights.length),
          ] else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: displayedFlights.isEmpty
                      ? _buildEmptyState(context, isDark)
                      : Column(
                          children: displayedFlights
                              .map(
                                (trip) => Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: TrackingCardWidget(
                                    trip: trip,
                                    isMobile: false,
                                    onTap: () {
                                      ref.read(selectedTripIdProvider.notifier).state = trip.id;
                                    },
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  flex: 2,
                  child: _buildGuidanceCard(context, isDark, activeCount: activeFlights.length),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildTabPill({
    required String label,
    required int count,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.primary : Colors.white)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected && !isDark
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? (isDark ? Colors.white : AppColors.primary)
                    : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? (isDark ? Colors.white.withOpacity(0.2) : AppColors.primary.withOpacity(0.1))
                    : (isDark ? AppColors.borderDark : AppColors.borderLight),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isSelected
                      ? (isDark ? Colors.white : AppColors.primary)
                      : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuidanceCard(BuildContext context, bool isDark, {required int activeCount}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tracking status',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Active trips are checked automatically every 10 minutes across supported providers (Ctrip, Trip.com, Amadeus).',
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.check_circle_outline_rounded, size: 18, color: AppColors.success),
              const SizedBox(width: 8),
              Text(
                '$activeCount active watched journeys',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(48),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.flight_outlined,
            size: 48,
            color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
          ),
          const SizedBox(height: 16),
          Text(
            'No flights in this list',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start tracking a flight to watch fares in real-time.',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }
}
