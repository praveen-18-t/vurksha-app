import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/custom_icon_widget.dart';
import '../models/lat_lng.dart';

class LocationPickerWidget extends StatefulWidget {
  final LatLng? initialLocation;
  final Function(double, double) onLocationSelected;
  final VoidCallback onBack;

  const LocationPickerWidget({
    super.key,
    this.initialLocation,
    required this.onLocationSelected,
    required this.onBack,
  });

  @override
  State<LocationPickerWidget> createState() => _LocationPickerWidgetState();
}

class _LocationPickerWidgetState extends State<LocationPickerWidget> {
  LatLng? _selectedLocation;
  bool _isLoading = false;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialLocation;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_searchController.text.isNotEmpty) {
      setState(() => _isSearching = true);
      // Simulate search delay
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) setState(() => _isSearching = false);
      });
    } else {
      setState(() => _isSearching = false);
    }
  }

  void _onMapTap(LatLng location) {
    setState(() => _selectedLocation = location);
  }

  void _onConfirmLocation() {
    if (_selectedLocation != null) {
      widget.onLocationSelected(
        _selectedLocation!.latitude,
        _selectedLocation!.longitude,
      );
    }
  }

  void _onUseCurrentLocation() async {
    setState(() => _isLoading = true);
    
    // Simulate getting current location
    await Future.delayed(const Duration(seconds: 2));
    
    setState(() {
      _selectedLocation = const LatLng(18.5333, 73.8567); // Pune coordinates
      _isLoading = false;
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Current location detected')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        variant: AppBarVariant.standard,
        title: const Text('Select Location'),
        showBackButton: true,
        actions: [
          IconButton(
            onPressed: _onUseCurrentLocation,
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.my_location),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Interactive map view (in real app, use Google Maps or similar)
          _buildMapPlaceholder(theme),

          // Search bar
          Positioned(
            top: 2.h,
            left: 4.w,
            right: 4.w,
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search for a location',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _isSearching
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 4.w,
                    vertical: 1.5.h,
                  ),
                ),
              ),
            ),
          ),

          // Location suggestions (when searching)
          if (_searchController.text.isNotEmpty && _isSearching == false)
            Positioned(
              top: 10.h,
              left: 4.w,
              right: 4.w,
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _getMockSuggestions().length,
                  itemBuilder: (context, index) {
                    final suggestion = _getMockSuggestions()[index];
                    return ListTile(
                      leading: CustomIconWidget(
                        iconName: 'location_on',
                        color: theme.colorScheme.primary,
                        size: 4.w,
                      ),
                      title: Text(suggestion['name'] as String),
                      subtitle: Text(suggestion['address'] as String),
                      onTap: () {
                        final lat = suggestion['lat'] as double;
                        final lng = suggestion['lng'] as double;
                        setState(() {
                          _selectedLocation = LatLng(lat, lng);
                          _searchController.text = suggestion['name'] as String;
                        });
                      },
                    );
                  },
                ),
              ),
            ),

          // Map marker
          if (_selectedLocation != null)
            Positioned(
              top: 50.h - 30,
              left: 50.w - 15,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.colorScheme.surface,
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.location_on,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),

          // Bottom panel with location info and confirm button
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Location info
                  if (_selectedLocation != null) ...[
                    Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'location_on',
                          color: theme.colorScheme.primary,
                          size: 4.w,
                        ),
                        SizedBox(width: 2.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Selected Location',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                ),
                              ),
                              Text(
                                '${_selectedLocation!.latitude.toStringAsFixed(6)}, ${_selectedLocation!.longitude.toStringAsFixed(6)}',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 2.h),
                  ],

                  // Confirm button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _selectedLocation != null ? _onConfirmLocation : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        padding: EdgeInsets.symmetric(vertical: 2.h),
                      ),
                      child: Text(
                        'Confirm Location',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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

  Widget _buildMapPlaceholder(ThemeData theme) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: theme.colorScheme.surfaceContainerHighest,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.map,
            size: 64,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'Interactive Map View',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap to select your location on the map',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.5),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          // Tap gesture detector
          GestureDetector(
            onTap: () {
              // Simulate map tap - in real app, get actual coordinates
              _onMapTap(const LatLng(18.5333, 73.8567));
            },
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.transparent,
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getMockSuggestions() {
    return [
      {
        'name': 'Koregaon Park',
        'address': 'Pune, Maharashtra',
        'lat': 18.5333,
        'lng': 73.8567,
      },
      {
        'name': 'Hinjewadi',
        'address': 'Pune, Maharashtra',
        'lat': 18.5975,
        'lng': 73.7355,
      },
      {
        'name': 'Kalyani Nagar',
        'address': 'Pune, Maharashtra',
        'lat': 18.5415,
        'lng': 73.9035,
      },
      {
        'name': 'Magarpatta',
        'address': 'Pune, Maharashtra',
        'lat': 18.5115,
        'lng': 73.9255,
      },
    ];
  }
}

class MapGridPainter extends CustomPainter {
  final ThemeData theme;

  MapGridPainter(this.theme);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = theme.dividerColor.withValues(alpha: 0.3)
      ..strokeWidth = 0.5;

    // Draw vertical lines
    for (double x = 0; x < size.width; x += 50) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Draw horizontal lines
    for (double y = 0; y < size.height; y += 50) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
