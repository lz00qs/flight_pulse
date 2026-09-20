import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'models/flight_trip.dart';
import 'providers/app_providers.dart';
import 'theme/app_colors.dart';
import 'views/add_edit_flight_view.dart';
import 'views/overview_view.dart';
import 'views/settings_view.dart';
import 'views/tracking_detail_view.dart';
import 'views/tracking_list_view.dart';
import 'widgets/bottom_nav.dart';
import 'widgets/sidebar.dart';

void main() {
  runApp(const ProviderScope(child: FlightPulseApp()));
}

class FlightPulseApp extends ConsumerWidget {
  const FlightPulseApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'FlightPulse',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: themeMode,
      home: const MainResponsiveShell(),
    );
  }
}

class MainResponsiveShell extends ConsumerStatefulWidget {
  const MainResponsiveShell({super.key});

  @override
  ConsumerState<MainResponsiveShell> createState() => _MainResponsiveShellState();
}

class _MainResponsiveShellState extends ConsumerState<MainResponsiveShell> {
  bool _isAddingOrEditingFlight = false;
  FlightTrip? _editingFlight;

  void _openAddFlight() {
    setState(() {
      _isAddingOrEditingFlight = true;
      _editingFlight = null;
    });
  }

  void _openEditFlight(FlightTrip flight) {
    setState(() {
      _isAddingOrEditingFlight = true;
      _editingFlight = flight;
    });
  }

  void _closeAddOrEdit() {
    setState(() {
      _isAddingOrEditingFlight = false;
      _editingFlight = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentTab = ref.watch(currentNavProvider);
    final selectedTrip = ref.watch(selectedTripProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 800;

    Widget bodyWidget;

    if (_isAddingOrEditingFlight) {
      bodyWidget = AddEditFlightView(
        initialTrip: _editingFlight,
        isMobile: isMobile,
        onSaved: () => _closeAddOrEdit(),
        onCancel: () => _closeAddOrEdit(),
      );
    } else if (selectedTrip != null) {
      bodyWidget = TrackingDetailView(
        trip: selectedTrip,
        isMobile: isMobile,
        onEditTap: () => _openEditFlight(selectedTrip),
      );
    } else {
      switch (currentTab) {
        case NavigationTab.overview:
          bodyWidget = OverviewView(
            isMobile: isMobile,
            onAddFlightTap: _openAddFlight,
          );
          break;
        case NavigationTab.tracking:
          bodyWidget = TrackingListView(
            isMobile: isMobile,
            onAddFlightTap: _openAddFlight,
          );
          break;
        case NavigationTab.settings:
          bodyWidget = SettingsView(isMobile: isMobile);
          break;
      }
    }

    if (isMobile) {
      return Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              MobileHeader(onAddTap: _openAddFlight),
              Expanded(child: bodyWidget),
              const MobileBottomNavBar(),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: Row(
        children: [
          const DesktopSidebar(),
          Expanded(child: bodyWidget),
        ],
      ),
    );
  }
}
