import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late MapController mapController;
  late AnimationController _animationController;
  int _selectedIndex = 0;
  bool _isExpanded = true;
  int? _tappedMarkerIndex;

  @override
  void initState() {
    super.initState();
    mapController = MapController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  final List<Map<String, dynamic>> locations = [
    {
      'name': dotenv.env['LOCATION_1_NAME'] ?? 'Location 1',
      'lat': double.parse(dotenv.env['LOCATION_1_LAT'] ?? '0'),
      'lng': double.parse(dotenv.env['LOCATION_1_LNG'] ?? '0'),
      'category': dotenv.env['LOCATION_1_CATEGORY'] ?? 'Place',
      'gradient': [Colors.pink.shade600, Colors.amberAccent],
      'icon': Icons.hotel,
      'color': Colors.pink.shade600,
    },
    {
      'name': dotenv.env['LOCATION_2_NAME'] ?? 'Location 2',
      'lat': double.parse(dotenv.env['LOCATION_2_LAT'] ?? '0'),
      'lng': double.parse(dotenv.env['LOCATION_2_LNG'] ?? '0'),
      'category': dotenv.env['LOCATION_2_CATEGORY'] ?? 'Place',
      'gradient': [Colors.indigo, Colors.purpleAccent],
      'icon': Icons.flight,
      'color': Colors.indigo,
    },
    {
      'name': dotenv.env['LOCATION_3_NAME'] ?? 'Location 3',
      'lat': double.parse(dotenv.env['LOCATION_3_LAT'] ?? '0'),
      'lng': double.parse(dotenv.env['LOCATION_3_LNG'] ?? '0'),
      'category': dotenv.env['LOCATION_3_CATEGORY'] ?? 'Place',
      'gradient': [Colors.blue.shade600, Colors.cyanAccent],
      'icon': Icons.shopping_bag,
      'color': Colors.blue.shade600,
    },
    {
      'name': dotenv.env['LOCATION_4_NAME'] ?? 'Location 4',
      'lat': double.parse(dotenv.env['LOCATION_4_LAT'] ?? '0'),
      'lng': double.parse(dotenv.env['LOCATION_4_LNG'] ?? '0'),
      'category': dotenv.env['LOCATION_4_CATEGORY'] ?? 'Place',
      'gradient': [Colors.teal.shade600, Colors.lightGreenAccent],
      'icon': Icons.explore,
      'color': Colors.teal.shade600,
    },
    {
      'name': dotenv.env['LOCATION_5_NAME'] ?? 'Location 5',
      'lat': double.parse(dotenv.env['LOCATION_5_LAT'] ?? '0'),
      'lng': double.parse(dotenv.env['LOCATION_5_LNG'] ?? '0'),
      'category': dotenv.env['LOCATION_5_CATEGORY'] ?? 'Place',
      'gradient': [Colors.green.shade600, Colors.yellowAccent],
      'icon': Icons.coffee,
      'color': Colors.green.shade600,
    },
    {
      'name': dotenv.env['LOCATION_6_NAME'] ?? 'Location 6',
      'lat': double.parse(dotenv.env['LOCATION_6_LAT'] ?? '0'),
      'lng': double.parse(dotenv.env['LOCATION_6_LNG'] ?? '0'),
      'category': dotenv.env['LOCATION_6_CATEGORY'] ?? 'Place',
      'gradient': [Colors.amber, Colors.redAccent],
      'icon': Icons.restaurant,
      'color': Colors.amber,
    },
    {
      'name': dotenv.env['LOCATION_7_NAME'] ?? 'Location 7',
      'lat': double.parse(dotenv.env['LOCATION_7_LAT'] ?? '0'),
      'lng': double.parse(dotenv.env['LOCATION_7_LNG'] ?? '0'),
      'category': dotenv.env['LOCATION_7_CATEGORY'] ?? 'Place',
      'gradient': [Colors.blueGrey.shade900, Colors.blueGrey.shade300],
      'icon': Icons.museum,
      'color': Colors.blueGrey,
    },
  ];

  List<Marker> _createMarkers() {
    final location = locations[_selectedIndex];

    return [
      Marker(
        point: LatLng(location['lat'], location['lng']),
        width: 50,
        height: 50,
        child: GestureDetector(
          onTap: () {
            setState(() {
              if (_tappedMarkerIndex == _selectedIndex) {
                _tappedMarkerIndex = null;
              } else {
                _tappedMarkerIndex = _selectedIndex;
              }
            });
          },
          child: Icon(
            Icons.location_on,
            color: location['color'],
            size: 50,
            shadows: [
              Shadow(
                color: location['color'].withOpacity(0.5),
                blurRadius: 10,
              )
            ],
          ),
        ),
      ),
    ];
  }

  void _navigateToLocation(int index) {
    setState(() {
      _selectedIndex = index;
      _tappedMarkerIndex = null;
    });

    final location = locations[index];
    mapController.move(
      LatLng(location['lat'], location['lng']),
      15,
    );
  }

  void _togglePanel() {
    setState(() {
      _isExpanded = !_isExpanded;
    });

    if (_isExpanded) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  void _closePopup() {
    if (_tappedMarkerIndex != null) {
      setState(() {
        _tappedMarkerIndex = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentLocation = locations[_selectedIndex];

    return Scaffold(
      body: GestureDetector(
        onTap: _closePopup,
        child: Stack(
          children: [
            FlutterMap(
              mapController: mapController,
              options: MapOptions(
                initialCenter: LatLng(currentLocation['lat'], currentLocation['lng']),
                initialZoom: 12,
                minZoom: 3,
                maxZoom: 18,
                onTap: (_, __) => _closePopup(),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.maps_flutter',
                ),
                MarkerLayer(
                  markers: _createMarkers(),
                ),
              ],
            ),
            // Coordinates Popup (no arrow)
            if (_tappedMarkerIndex != null)
              Positioned(
                top: MediaQuery.of(context).size.height * 0.35,
                left: 20,
                right: 20,
                child: Center(
                  child: GestureDetector(
                    onTap: () {},
                    child: TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 300),
                      tween: Tween(begin: 0.0, end: 1.0),
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: Opacity(
                            opacity: value,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: locations[_tappedMarkerIndex!]['gradient'],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: [
                                  BoxShadow(
                                    color: locations[_tappedMarkerIndex!]['gradient'][0]
                                        .withOpacity(0.4),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Icon(
                                          locations[_tappedMarkerIndex!]['icon'],
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Flexible(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              locations[_tappedMarkerIndex!]['category']
                                                  .toUpperCase(),
                                              style: TextStyle(
                                                color: Colors.white.withOpacity(0.9),
                                                fontSize: 10,
                                                fontWeight: FontWeight.w700,
                                                letterSpacing: 1.2,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              locations[_tappedMarkerIndex!]['name'],
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.25),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.my_location,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 10),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Lat: ${locations[_tappedMarkerIndex!]['lat'].toStringAsFixed(4)}',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              'Lng: ${locations[_tappedMarkerIndex!]['lng'].toStringAsFixed(4)}',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: GestureDetector(
                onTap: _closePopup,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.9),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 16,
                    bottom: 24,
                    left: 20,
                    right: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '🗽 Guía de Nueva York',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ),
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: _isExpanded ? 220 : 80,
                  child: GestureDetector(
                    onVerticalDragUpdate: (details) {
                      if (details.primaryDelta! < -5) {
                        if (!_isExpanded) _togglePanel();
                      } else if (details.primaryDelta! > 5) {
                        if (_isExpanded) _togglePanel();
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, -5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: _togglePanel,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Column(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  if (!_isExpanded) ...[
                                    const SizedBox(height: 12),
                                    Text(
                                      'Tap to explore destinations',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                          if (_isExpanded)
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  left: 16,
                                  right: 16,
                                  bottom: 20,
                                ),
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: locations.length,
                                  itemBuilder: (context, index) {
                                    final location = locations[index];
                                    final isSelected = _selectedIndex == index;

                                    return GestureDetector(
                                      onTap: () => _navigateToLocation(index),
                                      child: Container(
                                        width: 130,
                                        margin: const EdgeInsets.only(right: 12),
                                        padding: const EdgeInsets.all(14),
                                        decoration: BoxDecoration(
                                          gradient: isSelected
                                              ? LinearGradient(
                                                  colors: location['gradient'],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                )
                                              : null,
                                          color: isSelected ? null : Colors.grey[100],
                                          borderRadius: BorderRadius.circular(20),
                                          boxShadow: isSelected
                                              ? [
                                                  BoxShadow(
                                                    color: location['gradient'][0]
                                                        .withOpacity(0.4),
                                                    blurRadius: 12,
                                                    offset: const Offset(0, 6),
                                                  ),
                                                ]
                                              : null,
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Icon(
                                              location['icon'],
                                              color: isSelected
                                                  ? Colors.white
                                                  : Colors.grey[600],
                                              size: 28,
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              location['category'],
                                              style: TextStyle(
                                                color: isSelected
                                                    ? Colors.white.withOpacity(0.9)
                                                    : Colors.grey[500],
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              location['name'],
                                              style: TextStyle(
                                                color: isSelected
                                                    ? Colors.white
                                                    : Colors.grey[800],
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const Spacer(),
                                            Text(
                                              '${location['lat'].toStringAsFixed(2)}, ${location['lng'].toStringAsFixed(2)}',
                                              style: TextStyle(
                                                color: isSelected
                                                    ? Colors.white.withOpacity(0.8)
                                                    : Colors.grey[500],
                                                fontSize: 9,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}