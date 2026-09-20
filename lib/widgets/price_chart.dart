import 'package:flutter/material.dart';
import '../models/flight_trip.dart';
import '../theme/app_colors.dart';

class PriceHistoryChart extends StatefulWidget {
  final List<PricePoint> priceHistory;
  final String currency;

  const PriceHistoryChart({
    super.key,
    required this.priceHistory,
    this.currency = 'HK\$',
  });

  @override
  State<PriceHistoryChart> createState() => _PriceHistoryChartState();
}

class _PriceHistoryChartState extends State<PriceHistoryChart> {
  String _selectedRange = '30D';
  int? _hoveredIndex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final points = widget.priceHistory.isEmpty
        ? [
            PricePoint(date: DateTime.now().subtract(const Duration(days: 30)), price: 2150, provider: 'Ctrip'),
            PricePoint(date: DateTime.now().subtract(const Duration(days: 22)), price: 2080, provider: 'Trip.com'),
            PricePoint(date: DateTime.now().subtract(const Duration(days: 15)), price: 1980, provider: 'Ctrip'),
            PricePoint(date: DateTime.now().subtract(const Duration(days: 8)), price: 1890, provider: 'Amadeus'),
            PricePoint(date: DateTime.now(), price: 1842, provider: 'Ctrip'),
          ]
        : widget.priceHistory;

    final prices = points.map((p) => p.price).toList();
    final minPrice = (prices.reduce((a, b) => a < b ? a : b) * 0.95).floorToDouble();
    final maxPrice = (prices.reduce((a, b) => a > b ? a : b) * 1.05).ceilToDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Chart Heading & Range selector
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Price history',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Lowest ${widget.currency}1,720  ·  Average ${widget.currency}2,040',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
            // Range pills
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceSecondaryDark : AppColors.surfaceSecondaryLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: ['7D', '30D', '90D', 'ALL'].map((range) {
                  final isSelected = _selectedRange == range;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedRange = range;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (isDark ? AppColors.primary : Colors.white)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: isSelected && !isDark
                            ? [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                )
                              ]
                            : null,
                      ),
                      child: Text(
                        range,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? (isDark ? Colors.white : AppColors.primary)
                              : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Line Chart Canvas
        SizedBox(
          height: 220,
          width: double.infinity,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return MouseRegion(
                onHover: (event) {
                  final width = constraints.maxWidth;
                  final step = width / (points.length - 1);
                  final idx = (event.localPosition.dx / step).round().clamp(0, points.length - 1);
                  setState(() {
                    _hoveredIndex = idx;
                  });
                },
                onExit: (_) {
                  setState(() {
                    _hoveredIndex = null;
                  });
                },
                child: CustomPaint(
                  size: Size(constraints.maxWidth, 220),
                  painter: _LineChartPainter(
                    points: points,
                    minPrice: minPrice,
                    maxPrice: maxPrice,
                    currency: widget.currency,
                    hoveredIndex: _hoveredIndex ?? points.length - 1,
                    isDark: isDark,
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 12),

        // Time Axis Labels
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: points.map((p) {
            final month = _monthName(p.date.month);
            final day = p.date.day.toString().padLeft(2, '0');
            return Text(
              '$month $day',
              style: TextStyle(
                fontSize: 11,
                color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  String _monthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[(month - 1) % 12];
  }
}

class _LineChartPainter extends CustomPainter {
  final List<PricePoint> points;
  final double minPrice;
  final double maxPrice;
  final String currency;
  final int hoveredIndex;
  final bool isDark;

  _LineChartPainter({
    required this.points,
    required this.minPrice,
    required this.maxPrice,
    required this.currency,
    required this.hoveredIndex,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final gridPaint = Paint()
      ..color = (isDark ? AppColors.borderDark : AppColors.borderLight).withOpacity(0.5)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final textStyle = TextStyle(
      fontSize: 10,
      color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
    );

    // Draw horizontal grid lines (3 levels)
    final priceRange = maxPrice - minPrice;
    final hGridCount = 3;
    for (int i = 0; i < hGridCount; i++) {
      final y = size.height * (i / (hGridCount - 1));
      final priceVal = maxPrice - (priceRange * (i / (hGridCount - 1)));

      // Dash line
      double dx = 50;
      while (dx < size.width) {
        canvas.drawLine(Offset(dx, y), Offset(dx + 4, y), gridPaint);
        dx += 8;
      }

      // Price label on left
      final textSpan = TextSpan(text: '$currency${priceVal.round()}', style: textStyle);
      final textPainter = TextPainter(text: textSpan, textDirection: TextDirection.ltr);
      textPainter.layout();
      textPainter.paint(canvas, Offset(0, y - textPainter.height / 2));
    }

    const paddingLeft = 50.0;
    final chartWidth = size.width - paddingLeft;
    final stepX = chartWidth / (points.length - 1);

    List<Offset> offsets = [];
    for (int i = 0; i < points.length; i++) {
      final x = paddingLeft + i * stepX;
      final normalizedY = (points[i].price - minPrice) / (maxPrice - minPrice);
      final y = size.height - (normalizedY * (size.height - 20)) - 10;
      offsets.add(Offset(x, y));
    }

    // Smooth spline path
    final path = Path();
    path.moveTo(offsets[0].dx, offsets[0].dy);

    for (int i = 0; i < offsets.length - 1; i++) {
      final p0 = offsets[i];
      final p1 = offsets[i + 1];
      final controlPoint1 = Offset(p0.dx + (p1.dx - p0.dx) / 2, p0.dy);
      final controlPoint2 = Offset(p0.dx + (p1.dx - p0.dx) / 2, p1.dy);
      path.cubicTo(controlPoint1.dx, controlPoint1.dy, controlPoint2.dx, controlPoint2.dy, p1.dx, p1.dy);
    }

    // Draw area gradient
    final fillPath = Path.from(path);
    fillPath.lineTo(offsets.last.dx, size.height);
    fillPath.lineTo(offsets.first.dx, size.height);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.primary.withOpacity(0.2),
          AppColors.primary.withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(fillPath, fillPaint);

    // Draw main line
    final linePaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, linePaint);

    // Draw selected hover dot and tooltip
    if (hoveredIndex >= 0 && hoveredIndex < offsets.length) {
      final activePoint = offsets[hoveredIndex];
      final pointData = points[hoveredIndex];

      // Vertical guideline
      final guidePaint = Paint()
        ..color = AppColors.primary.withOpacity(0.3)
        ..strokeWidth = 1;
      canvas.drawLine(Offset(activePoint.dx, 0), Offset(activePoint.dx, size.height), guidePaint);

      // Active circle
      canvas.drawCircle(activePoint, 6, Paint()..color = AppColors.primary);
      canvas.drawCircle(activePoint, 3, Paint()..color = Colors.white);

      // Tooltip Card
      final span = TextSpan(
        children: [
          TextSpan(
            text: '${pointData.provider}\n',
            style: TextStyle(
              fontSize: 11,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
          TextSpan(
            text: '$currency${pointData.price.round()}',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
        ],
      );

      final tp = TextPainter(text: span, textDirection: TextDirection.ltr);
      tp.layout();

      const tooltipPadding = 8.0;
      final tooltipWidth = tp.width + tooltipPadding * 2;
      final tooltipHeight = tp.height + tooltipPadding * 2;

      double tooltipX = activePoint.dx - tooltipWidth / 2;
      if (tooltipX < paddingLeft) tooltipX = paddingLeft;
      if (tooltipX + tooltipWidth > size.width) tooltipX = size.width - tooltipWidth;

      double tooltipY = activePoint.dy - tooltipHeight - 12;
      if (tooltipY < 0) tooltipY = activePoint.dy + 12;

      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(tooltipX, tooltipY, tooltipWidth, tooltipHeight),
        const Radius.circular(8),
      );

      // Tooltip background
      canvas.drawRRect(
        rect,
        Paint()..color = isDark ? AppColors.surfaceSecondaryDark : Colors.white,
      );

      canvas.drawRRect(
        rect,
        Paint()
          ..color = isDark ? AppColors.borderDark : AppColors.borderLight
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );

      tp.paint(canvas, Offset(tooltipX + tooltipPadding, tooltipY + tooltipPadding));
    }
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) {
    return oldDelegate.hoveredIndex != hoveredIndex || oldDelegate.isDark != isDark;
  }
}
