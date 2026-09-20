enum TripType { oneWay, roundTrip, multiCity }

enum TripStatus { active, expired, paused }

class PricePoint {
  final DateTime date;
  final double price;
  final String provider;

  const PricePoint({
    required this.date,
    required this.price,
    required this.provider,
  });
}

class ProviderPrice {
  final String name;
  final double price;
  final String currency;

  const ProviderPrice({
    required this.name,
    required this.price,
    this.currency = 'HK\$',
  });
}

class FlightSegment {
  final String originCode;
  final String originCity;
  final String destinationCode;
  final String destinationCity;
  final DateTime departureDate;

  const FlightSegment({
    required this.originCode,
    required this.originCity,
    required this.destinationCode,
    required this.destinationCity,
    required this.departureDate,
  });
}

class FlightTrip {
  final String id;
  final String routeCode; // e.g. "HKG → NRT"
  final String origin; // e.g. "Hong Kong"
  final String destination; // e.g. "Tokyo"
  final String datesText; // e.g. "Oct 22 – Oct 28"
  final TripType tripType;
  final TripStatus status;
  final double currentPrice;
  final double initialPrice;
  final String currency;
  final double percentChange;
  final String primaryProvider;
  final DateTime lastChecked;
  final double lowest30Days;
  final double average30Days;
  final double highest30Days;
  final double targetPrice;
  final bool alertOnNewLow;
  final List<PricePoint> priceHistory;
  final List<ProviderPrice> providerPrices;
  final List<FlightSegment> segments;

  const FlightTrip({
    required this.id,
    required this.routeCode,
    required this.origin,
    required this.destination,
    required this.datesText,
    required this.tripType,
    required this.status,
    required this.currentPrice,
    required this.initialPrice,
    this.currency = 'HK\$',
    required this.percentChange,
    required this.primaryProvider,
    required this.lastChecked,
    required this.lowest30Days,
    required this.average30Days,
    required this.highest30Days,
    this.targetPrice = 1700,
    this.alertOnNewLow = true,
    this.priceHistory = const [],
    this.providerPrices = const [],
    this.segments = const [],
  });

  FlightTrip copyWith({
    String? id,
    String? routeCode,
    String? origin,
    String? destination,
    String? datesText,
    TripType? tripType,
    TripStatus? status,
    double? currentPrice,
    double? initialPrice,
    String? currency,
    double? percentChange,
    String? primaryProvider,
    DateTime? lastChecked,
    double? lowest30Days,
    double? average30Days,
    double? highest30Days,
    double? targetPrice,
    bool? alertOnNewLow,
    List<PricePoint>? priceHistory,
    List<ProviderPrice>? providerPrices,
    List<FlightSegment>? segments,
  }) {
    return FlightTrip(
      id: id ?? this.id,
      routeCode: routeCode ?? this.routeCode,
      origin: origin ?? this.origin,
      destination: destination ?? this.destination,
      datesText: datesText ?? this.datesText,
      tripType: tripType ?? this.tripType,
      status: status ?? this.status,
      currentPrice: currentPrice ?? this.currentPrice,
      initialPrice: initialPrice ?? this.initialPrice,
      currency: currency ?? this.currency,
      percentChange: percentChange ?? this.percentChange,
      primaryProvider: primaryProvider ?? this.primaryProvider,
      lastChecked: lastChecked ?? this.lastChecked,
      lowest30Days: lowest30Days ?? this.lowest30Days,
      average30Days: average30Days ?? this.average30Days,
      highest30Days: highest30Days ?? this.highest30Days,
      targetPrice: targetPrice ?? this.targetPrice,
      alertOnNewLow: alertOnNewLow ?? this.alertOnNewLow,
      priceHistory: priceHistory ?? this.priceHistory,
      providerPrices: providerPrices ?? this.providerPrices,
      segments: segments ?? this.segments,
    );
  }
}
