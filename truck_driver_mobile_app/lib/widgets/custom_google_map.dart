import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:truck_driver_mobile_app/models/BinStop.dart';
import 'package:truck_driver_mobile_app/services/map_service.dart';

class CustomGoogleMap extends StatefulWidget {
  final List<BinStop> binStops;
  final LocationData? liveLocation;
  final Function(String stopId)? onMarkerTap;

  const CustomGoogleMap({
    Key? key,
    required this.binStops,
    this.liveLocation,
    this.onMarkerTap,
  }) : super(key: key);

  @override
  State<CustomGoogleMap> createState() => _CustomGoogleMapState();
}

class _CustomGoogleMapState extends State<CustomGoogleMap> {
  final Completer<GoogleMapController> _controller = Completer();
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  // Default to Colombo if no location
  static const LatLng _defaultLocation = LatLng(6.9271, 79.8612);

  @override
  void initState() {
    super.initState();
    _updateMapElements();
  }

  @override
  void didUpdateWidget(covariant CustomGoogleMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.liveLocation != oldWidget.liveLocation ||
        widget.binStops != oldWidget.binStops) {
      _updateMapElements();
    }
  }

  void _updateMapElements() {
    _createMarkers();
    _fetchRoute();
  }

  void _createMarkers() {
    final markers = <Marker>{};

    // 1. Truck Marker
    if (widget.liveLocation != null) {
      markers.add(
        Marker(
          markerId: const MarkerId("truck"),
          position: LatLng(widget.liveLocation!.latitude!, widget.liveLocation!.longitude!),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          infoWindow: const InfoWindow(title: "My Truck"),
          zIndex: 10,
        ),
      );
    }

    // 2. Bin Markers
    for (int i = 0; i < widget.binStops.length; i++) {
      final bin = widget.binStops[i];

      // Skip invalid coordinates
      if (bin.latitude == 0 || bin.longitude == 0) continue;

      markers.add(
        Marker(
          markerId: MarkerId("bin-${bin.binId}"),
          position: LatLng(bin.latitude, bin.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: InfoWindow(title: "Stop ${i + 1}: ${bin.binId}"),
          onTap: () {
            if (widget.onMarkerTap != null) widget.onMarkerTap!(bin.id);
          },
        ),
      );
    }

    if (mounted) setState(() => _markers = markers);
  }

  Future<void> _fetchRoute() async {
    // Need at least current loc + 1 bin, OR 2 bins to draw a line
    if (widget.binStops.isEmpty) return;

    LatLng origin;
    if (widget.liveLocation != null) {
      origin = LatLng(widget.liveLocation!.latitude!, widget.liveLocation!.longitude!);
    } else if (widget.binStops.isNotEmpty) {
      // If no GPS, start from first bin
      origin = LatLng(widget.binStops.first.latitude, widget.binStops.first.longitude);
    } else {
      return;
    }

    List<LatLng> destinations = widget.binStops
        .where((b) => b.latitude != 0 && b.longitude != 0)
        .map((b) => LatLng(b.latitude, b.longitude))
        .toList();

    if (destinations.isEmpty) return;

    try {
      List<LatLng> points = await MapService().getRouteCoordinates(
        origin: origin,
        destinations: destinations,
      );

      if (points.isNotEmpty && mounted) {
        setState(() {
          _polylines = {
            Polyline(
              polylineId: const PolylineId("route"),
              color: Colors.blue,
              width: 5,
              points: points,
            )
          };
        });
        _fitBounds([origin, ...destinations]);
      }
    } catch (e) {
      print("Error drawing route: $e");
    }
  }

  Future<void> _fitBounds(List<LatLng> points) async {
    final GoogleMapController controller = await _controller.future;
    if (points.isEmpty) return;

    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (var p in points) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }

    controller.animateCamera(CameraUpdate.newLatLngBounds(
      LatLngBounds(
        southwest: LatLng(minLat, minLng),
        northeast: LatLng(maxLat, maxLng),
      ),
      60.0,
    ));
  }

  @override
  Widget build(BuildContext context) {
    // Determine initial camera center
    LatLng center = _defaultLocation;
    if (widget.liveLocation != null) {
      center = LatLng(widget.liveLocation!.latitude!, widget.liveLocation!.longitude!);
    } else if (widget.binStops.isNotEmpty && widget.binStops.first.latitude != 0) {
      center = LatLng(widget.binStops.first.latitude, widget.binStops.first.longitude);
    }

    return GoogleMap(
      initialCameraPosition: CameraPosition(target: center, zoom: 14),
      onMapCreated: (controller) {
        if (!_controller.isCompleted) {
          _controller.complete(controller);
          // Trigger fit bounds after map loads
          if (widget.binStops.isNotEmpty) _fetchRoute();
        }
      },
      markers: _markers,
      polylines: _polylines,
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
    );
  }
}