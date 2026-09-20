import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/flight_trip.dart';
import '../providers/app_providers.dart';
import '../theme/app_colors.dart';

class AddEditFlightView extends ConsumerStatefulWidget {
  final FlightTrip? initialTrip;
  final bool isMobile;
  final VoidCallback onSaved;
  final VoidCallback onCancel;

  const AddEditFlightView({
    super.key,
    this.initialTrip,
    required this.isMobile,
    required this.onSaved,
    required this.onCancel,
  });

  @override
  ConsumerState<AddEditFlightView> createState() => _AddEditFlightViewState();
}

class _AddEditFlightViewState extends ConsumerState<AddEditFlightView> {
  late TripType _tripType;
  late TextEditingController _originController;
  late TextEditingController _destinationController;
  late TextEditingController _targetPriceController;
  late DateTime _departureDate;
  late DateTime _returnDate;
  String _cabinClass = 'Economy';
  int _passengers = 1;

  @override
  void initState() {
    super.initState();
    final t = widget.initialTrip;
    _tripType = t?.tripType ?? TripType.roundTrip;
    _originController = TextEditingController(text: t != null ? '${t.origin} (${t.routeCode.split("→").first.trim()})' : 'Hong Kong (HKG)');
    _destinationController = TextEditingController(text: t != null ? '${t.destination} (${t.routeCode.split("→").last.trim()})' : 'Tokyo (NRT)');
    _targetPriceController = TextEditingController(text: t != null ? '${t.targetPrice.round()}' : '1700');
    _departureDate = DateTime.now().add(const Duration(days: 14));
    _returnDate = DateTime.now().add(const Duration(days: 20));
  }

  @override
  void dispose() {
    _originController.dispose();
    _destinationController.dispose();
    _targetPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isEditing = widget.initialTrip != null;

    return SingleChildScrollView(
      padding: EdgeInsets.all(widget.isMobile ? 16.0 : 48.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Intro
          Row(
            children: [
              IconButton(
                onPressed: widget.onCancel,
                icon: const Icon(Icons.arrow_back_rounded),
                tooltip: 'Back',
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isEditing ? 'Edit tracking' : 'Add flight tracking',
                    style: TextStyle(
                      fontSize: widget.isMobile ? 22 : 28,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isEditing
                        ? '${widget.initialTrip!.origin} → ${widget.initialTrip!.destination}'
                        : 'Set an itinerary once. FlightPulse will watch prices.',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Main Layout
          if (widget.isMobile) ...[
            _buildFormCard(context, isDark, isEditing),
            const SizedBox(height: 16),
            _buildGuidanceCard(context, isDark),
          ] else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: _buildFormCard(context, isDark, isEditing),
                ),
                const SizedBox(width: 24),
                Expanded(
                  flex: 2,
                  child: _buildGuidanceCard(context, isDark),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildFormCard(BuildContext context, bool isDark, bool isEditing) {
    return Container(
      padding: const EdgeInsets.all(28),
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
          // Trip Type Segmented Control
          Text(
            'Trip type',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceSecondaryDark : AppColors.surfaceSecondaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: TripType.values.map((type) {
                final isSelected = _tripType == type;
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _tripType = type;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      alignment: Alignment.center,
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
                      child: Text(
                        _tripTypeLabel(type),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? (isDark ? Colors.white : AppColors.primary)
                              : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 24),

          // Route Inputs
          Text(
            'Route',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _originController,
                  label: 'Origin airport',
                  icon: Icons.flight_takeoff_rounded,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: _destinationController,
                  label: 'Destination airport',
                  icon: Icons.flight_land_rounded,
                  isDark: isDark,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Dates & Details
          Text(
            'Travel details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildDateField(
                  label: 'Departure date',
                  date: _departureDate,
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _departureDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setState(() => _departureDate = picked);
                    }
                  },
                  isDark: isDark,
                ),
              ),
              if (_tripType == TripType.roundTrip) ...[
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDateField(
                    label: 'Return date',
                    date: _returnDate,
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _returnDate,
                        firstDate: _departureDate,
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        setState(() => _returnDate = picked);
                      }
                    },
                    isDark: isDark,
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildDropdownField(
                  label: 'Cabin class',
                  value: _cabinClass,
                  items: const ['Economy', 'Premium Economy', 'Business', 'First'],
                  onChanged: (val) {
                    if (val != null) setState(() => _cabinClass = val);
                  },
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDropdownField(
                  label: 'Passengers',
                  value: '$_passengers adult',
                  items: const ['1 adult', '2 adults', '3 adults', '4 adults'],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _passengers = int.parse(val.split(' ').first));
                    }
                  },
                  isDark: isDark,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Alerts
          Text(
            'Alerts',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _targetPriceController,
            label: 'Target price (HK\$)',
            icon: Icons.notifications_active_outlined,
            isDark: isDark,
            keyboardType: TextInputType.number,
          ),

          const SizedBox(height: 32),

          // Actions
          Row(
            children: [
              ElevatedButton(
                onPressed: _handleSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: Text(isEditing ? 'Save changes' : 'Start tracking'),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: widget.onCancel,
                style: OutlinedButton.styleFrom(
                  foregroundColor: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  side: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDark,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: TextStyle(
            fontSize: 14,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 18, color: AppColors.primary),
            filled: true,
            fillColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime date,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    final text = '${_monthName(date.month)} ${date.day}, ${date.year}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_rounded, size: 18, color: AppColors.primary),
                const SizedBox(width: 12),
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
              items: items.map((item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGuidanceCard(BuildContext context, bool isDark) {
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
            'A simple price watch',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'We compare available providers (Ctrip, Trip.com, Amadeus) and send notifications when prices drop below your target price.',
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'You can edit dates, pause alerts, or remove this flight tracking at any time from your tracking details page.',
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  void _handleSave() {
    final targetPrice = double.tryParse(_targetPriceController.text) ?? 1700;
    final originCode = _originController.text.contains('(')
        ? _originController.text.split('(').last.replaceAll(')', '').trim()
        : 'HKG';
    final destCode = _destinationController.text.contains('(')
        ? _destinationController.text.split('(').last.replaceAll(')', '').trim()
        : 'NRT';

    if (widget.initialTrip != null) {
      final updated = widget.initialTrip!.copyWith(
        targetPrice: targetPrice,
        routeCode: '$originCode → $destCode',
      );
      ref.read(flightListProvider.notifier).updateFlight(updated);
    } else {
      final newFlight = FlightTrip(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        routeCode: '$originCode → $destCode',
        origin: _originController.text.split('(').first.trim(),
        destination: _destinationController.text.split('(').first.trim(),
        datesText: '${_monthName(_departureDate.month)} ${_departureDate.day} – ${_monthName(_returnDate.month)} ${_returnDate.day}',
        tripType: _tripType,
        status: TripStatus.active,
        currentPrice: targetPrice + 120,
        initialPrice: targetPrice + 200,
        currency: 'HK\$',
        percentChange: -4.5,
        primaryProvider: 'Ctrip',
        lastChecked: DateTime.now(),
        lowest30Days: targetPrice - 50,
        average30Days: targetPrice + 150,
        highest30Days: targetPrice + 400,
        targetPrice: targetPrice,
      );
      ref.read(flightListProvider.notifier).addFlight(newFlight);
    }

    widget.onSaved();
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

  String _monthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[(month - 1) % 12];
  }
}
