import 'package:flutter/material.dart';
import '../models/flight_trip.dart';
import '../theme/app_colors.dart';

class TrackingCardWidget extends StatelessWidget {
  final FlightTrip trip;
  final VoidCallback? onTap;
  final bool isMobile;

  const TrackingCardWidget({
    super.key,
    required this.trip,
    this.onTap,
    this.isMobile = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final isPriceDown = trip.percentChange <= 0;
    final changeColor = isPriceDown ? AppColors.priceDown : AppColors.priceUp;
    final changeText = '${isPriceDown ? "↓" : "↑"} ${trip.percentChange.abs()}%';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: EdgeInsets.all(isMobile ? 18.0 : 24.0),
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
              // Header Row: Route & Status Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          trip.routeCode,
                          style: TextStyle(
                            fontSize: isMobile ? 20 : 22,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${trip.origin} → ${trip.destination} · ${trip.datesText}',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  _buildStatusTag(context, trip.status),
                ],
              ),

              const SizedBox(height: 16),

              // Price & Sparkline Trend Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CURRENT PRICE',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 8,
                          children: [
                            Text(
                              '${trip.currency}${trip.currentPrice.round()}',
                              style: TextStyle(
                                fontSize: isMobile ? 22 : 26,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                              ),
                            ),
                            Text(
                              changeText,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: changeColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Mini Sparkline Curve
                  SizedBox(
                    width: isMobile ? 80 : 100,
                    height: 36,
                    child: CustomPaint(
                      painter: _SparklinePainter(
                        isPriceDown: isPriceDown,
                        color: changeColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusTag(BuildContext context, TripStatus status) {
    Color tagColor;
    String label;

    switch (status) {
      case TripStatus.active:
        tagColor = AppColors.success;
        label = 'Active';
        break;
      case TripStatus.paused:
        tagColor = AppColors.priceUp;
        label = 'Paused';
        break;
      case TripStatus.expired:
        tagColor = AppColors.textTertiaryLight;
        label = 'Expired';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: tagColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: tagColor,
        ),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final bool isPriceDown;
  final Color color;

  _SparklinePainter({required this.isPriceDown, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    if (isPriceDown) {
      path.moveTo(0, size.height * 0.2);
      path.cubicTo(
        size.width * 0.3,
        size.height * 0.1,
        size.width * 0.6,
        size.height * 0.7,
        size.width,
        size.height * 0.8,
      );
    } else {
      path.moveTo(0, size.height * 0.8);
      path.cubicTo(
        size.width * 0.3,
        size.height * 0.7,
        size.width * 0.6,
        size.height * 0.2,
        size.width,
        size.height * 0.1,
      );
    }

    canvas.drawPath(path, paint);

    // End dot
    final endPoint = isPriceDown
        ? Offset(size.width, size.height * 0.8)
        : Offset(size.width, size.height * 0.1);
    canvas.drawCircle(endPoint, 4, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
