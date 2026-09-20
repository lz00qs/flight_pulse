import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/flight_trip.dart';
import '../providers/app_providers.dart';
import '../theme/app_colors.dart';
import '../widgets/price_chart.dart';

class TrackingDetailView extends ConsumerWidget {
  final FlightTrip trip;
  final bool isMobile;
  final VoidCallback onEditTap;

  const TrackingDetailView({
    super.key,
    required this.trip,
    required this.isMobile,
    required this.onEditTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16.0 : 48.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Breadcrumb Back Button
          InkWell(
            onTap: () {
              ref.read(selectedTripIdProvider.notifier).state = null;
            },
            borderRadius: BorderRadius.circular(8),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 4, horizontal: 2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.arrow_back_rounded, size: 16, color: AppColors.primary),
                  SizedBox(width: 6),
                  Text(
                    'Tracking',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Detail Heading & Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${trip.origin} → ${trip.destination}',
                      style: TextStyle(
                        fontSize: isMobile ? 28 : 36,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${trip.routeCode}   ·   ${trip.datesText}   ·   ${_tripTypeLabel(trip.tripType)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isMobile)
                Row(
                  children: [
                    OutlinedButton(
                      onPressed: onEditTap,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        side: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Edit tracking'),
                    ),
                    const SizedBox(width: 10),
                    TextButton(
                      onPressed: () {
                        ref.read(flightListProvider.notifier).toggleStatus(trip.id);
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                      child: Text(trip.status == TripStatus.paused ? 'Resume' : 'Pause'),
                    ),
                  ],
                ),
            ],
          ),

          const SizedBox(height: 24),

          // Current Price Hero & Stats Card
          _buildPriceHeroCard(context, isDark),

          const SizedBox(height: 24),

          // Price History Chart Container
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
            ),
            child: PriceHistoryChart(
              priceHistory: trip.priceHistory,
              currency: trip.currency,
            ),
          ),

          const SizedBox(height: 24),

          // Sources & Alert Rules Row
          if (isMobile) ...[
            _buildSourcesCard(context, isDark),
            const SizedBox(height: 16),
            _buildAlertRulesCard(context, isDark),
            const SizedBox(height: 16),
            _buildDeleteButton(context, isDark, ref),
          ] else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildSourcesCard(context, isDark)),
                const SizedBox(width: 20),
                Expanded(child: _buildAlertRulesCard(context, isDark)),
              ],
            ),

          if (!isMobile) ...[
            const SizedBox(height: 24),
            _buildDeleteButton(context, isDark, ref),
          ],
        ],
      ),
    );
  }

  Widget _buildPriceHeroCard(BuildContext context, bool isDark) {
    final isPriceDown = trip.percentChange <= 0;

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CURRENT BEST PRICE',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${trip.currency}${trip.currentPrice.round()}',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${isPriceDown ? "↓" : "↑"} ${trip.percentChange.abs()}% since tracking began',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isPriceDown ? AppColors.priceDown : AppColors.priceUp,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${trip.primaryProvider} · checked 10 minutes ago',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem('Lowest', '${trip.currency}${trip.lowest30Days.round()}', isDark),
                    _buildStatItem('Average', '${trip.currency}${trip.average30Days.round()}', isDark),
                    _buildStatItem('Highest', '${trip.currency}${trip.highest30Days.round()}', isDark),
                  ],
                ),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CURRENT BEST PRICE',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${trip.currency}${trip.currentPrice.round()}',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${isPriceDown ? "↓" : "↑"} ${trip.percentChange.abs()}% since tracking began',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: isPriceDown ? AppColors.priceDown : AppColors.priceUp,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${trip.primaryProvider} · checked 10 minutes ago',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    _buildStatCard('Lowest', '${trip.currency}${trip.lowest30Days.round()}', 'Last 30 days', isDark),
                    const SizedBox(width: 12),
                    _buildStatCard('Average', '${trip.currency}${trip.average30Days.round()}', 'Last 30 days', isDark),
                    const SizedBox(width: 12),
                    _buildStatCard('Highest', '${trip.currency}${trip.highest30Days.round()}', 'Last 30 days', isDark),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _buildStatCard(String label, String value, String subtitle, bool isDark) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, bool isDark) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
      ],
    );
  }

  Widget _buildSourcesCard(BuildContext context, bool isDark) {
    final providers = trip.providerPrices.isEmpty
        ? [
            ProviderPrice(name: 'Ctrip', price: trip.currentPrice, currency: trip.currency),
            ProviderPrice(name: 'Trip.com', price: trip.currentPrice + 28, currency: trip.currency),
            ProviderPrice(name: 'Amadeus', price: trip.currentPrice + 68, currency: trip.currency),
          ]
        : trip.providerPrices;

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
            'Prices by source',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'The lowest available fare appears above.',
            style: TextStyle(
              fontSize: 13,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 20),
          ...providers.map(
            (p) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    p.name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                  ),
                  Text(
                    '${p.currency}${p.price.round()}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
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

  Widget _buildAlertRulesCard(BuildContext context, bool isDark) {
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
            'Price alerts',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Notify when the price drops',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Target price: ${trip.currency}${trip.targetPrice.round()}',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'New historical low: ${trip.alertOnNewLow ? "On" : "Off"}',
            style: TextStyle(
              fontSize: 13,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 20),
          OutlinedButton(
            onPressed: onEditTap,
            style: OutlinedButton.styleFrom(
              foregroundColor: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              side: BorderSide(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Edit alerts'),
          ),
        ],
      ),
    );
  }

  Widget _buildDeleteButton(BuildContext context, bool isDark, WidgetRef ref) {
    return OutlinedButton.icon(
      onPressed: () {
        _showDeleteDialog(context, isDark, ref);
      },
      icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error),
      label: const Text('Delete tracking', style: TextStyle(color: AppColors.error)),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: AppColors.error),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, bool isDark, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Delete this tracking?'),
        content: const Text('This will remove its price history and alerts. You can add it back anytime.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(flightListProvider.notifier).removeFlight(trip.id);
              ref.read(selectedTripIdProvider.notifier).state = null;
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _tripTypeLabel(TripType type) {
    switch (type) {
      case TripType.oneWay:
        return 'One-way';
      case TripType.roundTrip:
        return 'Round-trip';
      case TripType.multiCity:
        return 'Multi-city';
    }
  }
}
