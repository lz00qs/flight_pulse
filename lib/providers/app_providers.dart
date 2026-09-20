import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/flight_trip.dart';

enum NavigationTab { overview, tracking, settings }
enum TrackingFilter { active, expired }

// Current Navigation Tab
final currentNavProvider = StateProvider<NavigationTab>((ref) => NavigationTab.overview);

// Selected Trip ID for Detail View (null = show list)
final selectedTripIdProvider = StateProvider<String?>((ref) => null);

// Tracking Filter (Active vs Expired)
final trackingFilterProvider = StateProvider<TrackingFilter>((ref) => TrackingFilter.active);

// Theme Mode Provider (Light, Dark, System)
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.light);

// App Language Provider
final languageProvider = StateProvider<String>((ref) => 'EN');

// Notification Settings State
class NotificationSettings {
  final bool telegramEnabled;
  final String telegramBotToken;
  final String telegramChatId;
  final bool emailEnabled;
  final String emailAddress;

  const NotificationSettings({
    this.telegramEnabled = true,
    this.telegramBotToken = '••••••••••••••••',
    this.telegramChatId = '123456789',
    this.emailEnabled = true,
    this.emailAddress = 'alex@example.com',
  });

  NotificationSettings copyWith({
    bool? telegramEnabled,
    String? telegramBotToken,
    String? telegramChatId,
    bool? emailEnabled,
    String? emailAddress,
  }) {
    return NotificationSettings(
      telegramEnabled: telegramEnabled ?? this.telegramEnabled,
      telegramBotToken: telegramBotToken ?? this.telegramBotToken,
      telegramChatId: telegramChatId ?? this.telegramChatId,
      emailEnabled: emailEnabled ?? this.emailEnabled,
      emailAddress: emailAddress ?? this.emailAddress,
    );
  }
}

final notificationSettingsProvider = StateProvider<NotificationSettings>((ref) => const NotificationSettings());

// Mock Initial Flights
final _initialFlights = <FlightTrip>[
  FlightTrip(
    id: '1',
    routeCode: 'HKG → NRT',
    origin: 'Hong Kong',
    destination: 'Tokyo',
    datesText: 'Oct 22 – Oct 28',
    tripType: TripType.roundTrip,
    status: TripStatus.active,
    currentPrice: 1842,
    initialPrice: 2007,
    currency: 'HK\$',
    percentChange: -8.2,
    primaryProvider: 'Ctrip',
    lastChecked: DateTime.now().subtract(const Duration(minutes: 10)),
    lowest30Days: 1720,
    average30Days: 2040,
    highest30Days: 2320,
    targetPrice: 1700,
    alertOnNewLow: true,
    providerPrices: const [
      ProviderPrice(name: 'Ctrip', price: 1842),
      ProviderPrice(name: 'Trip.com', price: 1870),
      ProviderPrice(name: 'Amadeus', price: 1910),
    ],
    priceHistory: [
      PricePoint(date: DateTime.now().subtract(const Duration(days: 30)), price: 2150, provider: 'Ctrip'),
      PricePoint(date: DateTime.now().subtract(const Duration(days: 23)), price: 2180, provider: 'Trip.com'),
      PricePoint(date: DateTime.now().subtract(const Duration(days: 16)), price: 2040, provider: 'Ctrip'),
      PricePoint(date: DateTime.now().subtract(const Duration(days: 9)), price: 1980, provider: 'Amadeus'),
      PricePoint(date: DateTime.now().subtract(const Duration(days: 2)), price: 1720, provider: 'Ctrip'),
      PricePoint(date: DateTime.now(), price: 1842, provider: 'Ctrip'),
    ],
    segments: [
      FlightSegment(
        originCode: 'HKG',
        originCity: 'Hong Kong',
        destinationCode: 'NRT',
        destinationCity: 'Tokyo Narita',
        departureDate: DateTime.now().add(const Duration(days: 14)),
      ),
      FlightSegment(
        originCode: 'NRT',
        originCity: 'Tokyo Narita',
        destinationCode: 'HKG',
        destinationCity: 'Hong Kong',
        departureDate: DateTime.now().add(const Duration(days: 20)),
      ),
    ],
  ),
  FlightTrip(
    id: '2',
    routeCode: 'SZX → KIX',
    origin: 'Shenzhen',
    destination: 'Osaka',
    datesText: 'Nov 12 – Nov 18',
    tripType: TripType.roundTrip,
    status: TripStatus.active,
    currentPrice: 1426,
    initialPrice: 1628,
    currency: '¥',
    percentChange: -12.4,
    primaryProvider: 'Trip.com',
    lastChecked: DateTime.now().subtract(const Duration(minutes: 10)),
    lowest30Days: 1426,
    average30Days: 1628,
    highest30Days: 1890,
    targetPrice: 1400,
    alertOnNewLow: true,
    providerPrices: const [
      ProviderPrice(name: 'Trip.com', price: 1426, currency: '¥'),
      ProviderPrice(name: 'Ctrip', price: 1450, currency: '¥'),
      ProviderPrice(name: 'Fliggy', price: 1490, currency: '¥'),
    ],
    priceHistory: [
      PricePoint(date: DateTime.now().subtract(const Duration(days: 30)), price: 1890, provider: 'Trip.com'),
      PricePoint(date: DateTime.now().subtract(const Duration(days: 20)), price: 1750, provider: 'Ctrip'),
      PricePoint(date: DateTime.now().subtract(const Duration(days: 10)), price: 1628, provider: 'Trip.com'),
      PricePoint(date: DateTime.now(), price: 1426, provider: 'Trip.com'),
    ],
  ),
  FlightTrip(
    id: '3',
    routeCode: 'PEK → LHR',
    origin: 'Beijing',
    destination: 'London',
    datesText: 'Dec 01 – Dec 15',
    tripType: TripType.roundTrip,
    status: TripStatus.active,
    currentPrice: 4200,
    initialPrice: 4200,
    currency: '¥',
    percentChange: 0.0,
    primaryProvider: 'Air China',
    lastChecked: DateTime.now().subtract(const Duration(hours: 1)),
    lowest30Days: 4100,
    average30Days: 4350,
    highest30Days: 4800,
  ),
  FlightTrip(
    id: '4',
    routeCode: 'PVG → SIN',
    origin: 'Shanghai',
    destination: 'Singapore',
    datesText: 'Aug 01 – Aug 08',
    tripType: TripType.roundTrip,
    status: TripStatus.expired,
    currentPrice: 2100,
    initialPrice: 2300,
    currency: '¥',
    percentChange: -8.7,
    primaryProvider: 'Singapore Airlines',
    lastChecked: DateTime.now().subtract(const Duration(days: 60)),
    lowest30Days: 2100,
    average30Days: 2250,
    highest30Days: 2500,
  ),
  FlightTrip(
    id: '5',
    routeCode: 'HND → SYD',
    origin: 'Tokyo',
    destination: 'Sydney',
    datesText: 'Jul 10 – Jul 20',
    tripType: TripType.roundTrip,
    status: TripStatus.expired,
    currentPrice: 85000,
    initialPrice: 92000,
    currency: '¥',
    percentChange: -7.6,
    primaryProvider: 'ANA',
    lastChecked: DateTime.now().subtract(const Duration(days: 90)),
    lowest30Days: 85000,
    average30Days: 91000,
    highest30Days: 98000,
  ),
];

// Flight List Notifier
class FlightListNotifier extends StateNotifier<List<FlightTrip>> {
  FlightListNotifier() : super(_initialFlights);

  void addFlight(FlightTrip flight) {
    state = [flight, ...state];
  }

  void removeFlight(String id) {
    state = state.where((f) => f.id != id).toList();
  }

  void toggleStatus(String id) {
    state = state.map((f) {
      if (f.id == id) {
        final newStatus = f.status == TripStatus.active ? TripStatus.paused : TripStatus.active;
        return f.copyWith(status: newStatus);
      }
      return f;
    }).toList();
  }

  void updateFlight(FlightTrip updated) {
    state = state.map((f) => f.id == updated.id ? updated : f).toList();
  }
}

final flightListProvider = StateNotifierProvider<FlightListNotifier, List<FlightTrip>>((ref) {
  return FlightListNotifier();
});

// Derived Providers
final activeFlightsProvider = Provider<List<FlightTrip>>((ref) {
  final flights = ref.watch(flightListProvider);
  return flights.where((f) => f.status != TripStatus.expired).toList();
});

final expiredFlightsProvider = Provider<List<FlightTrip>>((ref) {
  final flights = ref.watch(flightListProvider);
  return flights.where((f) => f.status == TripStatus.expired).toList();
});

final selectedTripProvider = Provider<FlightTrip?>((ref) {
  final selectedId = ref.watch(selectedTripIdProvider);
  if (selectedId == null) return null;
  final flights = ref.watch(flightListProvider);
  return flights.firstWhere((f) => f.id == selectedId, orElse: () => flights.first);
});
