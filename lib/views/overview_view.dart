import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_providers.dart';
import '../theme/app_colors.dart';
import '../widgets/tracking_card.dart';

class OverviewView extends ConsumerWidget {
  final bool isMobile;
  final VoidCallback onAddFlightTap;

  const OverviewView({
    super.key,
    required this.isMobile,
    required this.onAddFlightTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeFlights = ref.watch(activeFlightsProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16.0 : 48.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero Heading & Action
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Good morning, Alex',
                      style: TextStyle(
                        fontSize: isMobile ? 24 : 28,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Your tracked flights at a glance.',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
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

          // Summary Metric Cards
          _buildSummaryMetrics(context, isDark),

          const SizedBox(height: 32),

          // Section Title: Watching Now
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'Watching now',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
              TextButton(
                onPressed: () {
                  ref.read(currentNavProvider.notifier).state = NavigationTab.tracking;
                },
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'View all tracking',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward_rounded, size: 16, color: AppColors.primary),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Grid or Column of Active Flight Cards & Insight Notice
          if (isMobile) ...[
            ...activeFlights.take(2).map(
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
            _buildPriceInsightCard(context, isDark, isMobile: true, ref: ref),
          ] else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    children: activeFlights
                        .take(2)
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
                const SizedBox(width: 20),
                Expanded(
                  flex: 2,
                  child: _buildPriceInsightCard(context, isDark, isMobile: false, ref: ref),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildSummaryMetrics(BuildContext context, bool isDark) {
    final metrics = [
      _MetricData('Tracked trips', '4', '2 departures ahead'),
      _MetricData('Price drops', '2', 'In the last 7 days'),
      _MetricData('Lowest fare', 'HK\$1,426', 'Shenzhen → Osaka'),
      _MetricData('Next trip', 'Oct 22', 'Hong Kong → Tokyo'),
    ];

    if (isMobile) {
      return GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.6,
        children: metrics.map((m) => _buildMetricCard(m, isDark)).toList(),
      );
    }

    return Row(
      children: metrics.map((m) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 16),
            child: _buildMetricCard(m, isDark),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMetricCard(_MetricData data, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            data.title,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            data.value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            data.subtitle,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildPriceInsightCard(BuildContext context, bool isDark, {required bool isMobile, required WidgetRef ref}) {
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Worth a look',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Shenzhen → Osaka just hit a new low.',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '¥1,426 is 12.4% below its 30-day average. Last checked 10 minutes ago.',
            style: TextStyle(
              fontSize: 14,
              height: 1.4,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 20),
          OutlinedButton(
            onPressed: () {
              ref.read(selectedTripIdProvider.notifier).state = '2';
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              side: BorderSide(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('View price history'),
          ),
        ],
      ),
    );
  }
}

class _MetricData {
  final String title;
  final String value;
  final String subtitle;

  _MetricData(this.title, this.value, this.subtitle);
}
