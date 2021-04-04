import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:location/location.dart' as Loc;
import 'package:uber_clone_task/src/ui/home/ride_confirm_dialog.dart';
import 'package:uber_clone_task/utils/colors.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<MarkerId, Marker> markers = {};
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();

  final homeScaffoldKey = GlobalKey<ScaffoldState>();
  GoogleMapsPlaces _places =
      GoogleMapsPlaces(apiKey: 'AIzaSyCQXC6t3acK5xh_do3RNEfz0fhHnlSoU9g');
  Completer<GoogleMapController> _controller = Completer();
  static const LatLng _center = const LatLng(31.4544247, 74.2766182);
  List<Map<dynamic, dynamic>> list = [];
  Map address = {};
  String pickUpLocationAddress;
  String dropLocationAddress;
  Set<Marker> marker = new Set();
  LatLng lastMapPosition = _center;

  double pickUpLat;
  double pickUpLong;
  double dropLat;
  double dropLong;

  var location = Loc.Location();

  TextEditingController pickUpController = TextEditingController();
  TextEditingController dropController = TextEditingController();

  @override
  void initState() {
    // _addMarker(LatLng(pickUpLat, pickUpLong), "origin", BitmapDescriptor.defaultMarker);
    //
    // /// destination marker
    // _addMarker(LatLng(dropLat, dropLong), "destination",
    //     BitmapDescriptor.defaultMarkerWithHue(90));
    // _getPolyline();
    super.initState();
    _checkGps().then((value) {
      movetocurrent();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        key: homeScaffoldKey,
        backgroundColor: screenBgColor,
        appBar: AppBar(
          centerTitle: true,
          automaticallyImplyLeading: false,
          backgroundColor: themeColor,
          title: Text(
            'Uber Clone',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomRight: Radius.circular(40),
            ),
          ),
        ),
        body: Container(
          width: Get.width,
          height: Get.height,
          child: Stack(
            children: [
              selectmap(),
              Positioned(
                top: Get.height * .02,
                right: Get.width * .03,
                left: Get.width * .03,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _formField(0, 'pick up location'),
                    _formField(1, 'Drop location'),
                  ],
                ),
              ),
              Positioned(
                bottom: Get.height * .02,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        await Geolocator()
                            .getCurrentPosition()
                            .whenComplete(() {})
                            .then((position) {
                          setState(() {
                            print('m position $position');
                            moveToLocation(
                                LatLng(position.latitude, position.longitude));
                          });
                        });
                      },
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          height: 60,
                          width: 60,
                          margin: EdgeInsets.only(right: 20),
                          child: Icon(Icons.my_location, color: themeColor),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (pickUpController.text != '' &&
                            dropController.text != '') {
                          Get.bottomSheet(RideConfirmDialog());
                        } else {
                          Get.snackbar(
                            'Location',
                            'Please select your pickup and drop location',
                            colorText: Colors.white,
                            backgroundColor: Colors.black,
                          );
                        }
                      },
                      child: Container(
                        width: Get.width,
                        height: Get.height * .066,
                        margin: EdgeInsets.symmetric(
                          vertical: Get.height * .02,
                          horizontal: Get.width * .1,
                        ),
                        decoration: BoxDecoration(
                          color: themeColor,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Book Now',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _formField(int index, String hint) {
    return Container(
      height: 50.0,
      width: Get.width,
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3.0),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.grey,
              offset: Offset(1.0, 5.0),
              blurRadius: 10,
              spreadRadius: 3)
        ],
      ),
      child: TextField(
        readOnly: true,
        onTap: () {
          _handlePressButton(index);
        },
        cursorColor: Colors.black,
        controller: index == 0 ? pickUpController : dropController,
        decoration: InputDecoration(
          icon: Container(
            margin: EdgeInsets.only(left: 20, top: 5),
            width: 10,
            height: 10,
            child: Icon(
              index == 0 ? Icons.location_on : Icons.local_taxi,
              color: Colors.black,
            ),
          ),
          hintText: hint,
          border: InputBorder.none,
          contentPadding: EdgeInsets.only(left: 15.0, top: 16.0),
        ),
      ),
    );
  }

  Widget selectmap() {
    return GoogleMap(
      myLocationButtonEnabled: false,
      myLocationEnabled: true,
      zoomControlsEnabled: false,
      initialCameraPosition: CameraPosition(
          target: LatLng(pickUpLat ?? 0.0, pickUpLong ?? 0.0), zoom: 14.0),
      onTap: (latLong) {
        moveToLocation(latLong);
      },
      mapType: MapType.normal,
      onMapCreated: _onMapCreated,
      onCameraMove: _onCameraMove,
      markers: marker,
      //
      //
      //

      tiltGesturesEnabled: true,
      compassEnabled: true,
      scrollGesturesEnabled: true,
      zoomGesturesEnabled: true,
      // markers: Set<Marker>.of(markers.values),
      polylines: Set<Polyline>.of(polylines.values),
    );
  }

  void _onCameraMove(CameraPosition position) {
    lastMapPosition = position.target;
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  void moveToLocation(LatLng latLng) {
    setState(() {
      _controller.future.then((controller) {
        controller.animateCamera(
          CameraUpdate.newCameraPosition(
              CameraPosition(target: latLng, zoom: 15.0)),
        );
      });

      setMarker(latLng);
    });
  }

  void setMarker(LatLng latLng) {
    setState(() {
      marker.clear();
      marker.add(
          Marker(markerId: MarkerId("selected-location"), position: latLng));
      _getLocation(latLng);
    });
  }

  _getLocation(LatLng latlng) async {
    print("in location picker \n\n\n\n\n");
    final coordinates = new Coordinates(latlng.latitude, latlng.longitude);
    var addresses =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    var mapValues = addresses.first;
    setState(() {
      pickUpLocationAddress = mapValues.addressLine;
      pickUpController.text = pickUpLocationAddress;
      pickUpLong = coordinates.longitude;
      pickUpLat = coordinates.latitude;
      setState(() {});
    });
    print('i am back setter:::$pickUpLocationAddress');
    print('lat:::${latlng.latitude}' + 'long:::${latlng.longitude}');
    print("${mapValues.featureName} : ${mapValues.addressLine}");
  }

  movetocurrent() async {
    await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .whenComplete(() {})
        .then((position) {
      setState(() {
        print('m position $position');
        _controller.future.then((controller) {
          controller.animateCamera(
            CameraUpdate.newCameraPosition(CameraPosition(
                target: LatLng(position.latitude, position.longitude),
                zoom: 15.0)),
          );
        });
      });
    });
  }

  Future _checkGps() async {
    if (!await location.serviceEnabled()) {
      location.requestService();
    }
  }

  Future _handlePressButton(int index) async {
    try {
      print('outside method');
      Prediction p = await PlacesAutocomplete.show(
        context: context,
        apiKey: 'AIzaSyCQXC6t3acK5xh_do3RNEfz0fhHnlSoU9g',
        onError: onError,
        mode: Mode.overlay,
        language: "en",
        // components: [Component(Component.country, "pk")],
      );
      print('in method');
      p = await displayPrediction(p, homeScaffoldKey.currentState, index);
    } catch (e) {
      print('this is error $e');
      return;
    }
  }

  Future<Prediction> displayPrediction(
      Prediction p, ScaffoldState scaffold, int index) async {
    if (p != null) {
      PlacesDetailsResponse detail =
          await _places.getDetailsByPlaceId(p.placeId);
      final lat = detail.result.geometry.location.lat;
      final lng = detail.result.geometry.location.lng;
      print('===========================${detail.result.adrAddress}\n\n\n\n\n');
      if (index == 0) {
        setMarker(LatLng(lat, lng));
        _controller.future.then((value) {
          value.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: LatLng(lat, lng),
                zoom: 15.0,
              ),
            ),
          );
          setState(() {});
        });
      } else {
        final coordinates = new Coordinates(lat, lng);
        var addresses =
            await Geocoder.local.findAddressesFromCoordinates(coordinates);
        var mapValues = addresses.first;

        pickUpLocationAddress = mapValues.addressLine;
        dropController.text = pickUpLocationAddress;
        dropLong = coordinates.longitude;
        dropLat = coordinates.latitude;
        print('======\n\n\n\n\n\n\n\n\n\n\n');
        _addMarker(LatLng(pickUpLat, pickUpLong), "origin",
            BitmapDescriptor.defaultMarker);
        _addMarker(LatLng(dropLat, dropLong), "destination",
            BitmapDescriptor.defaultMarkerWithHue(90));
        _getPolyline();
        setState(() {});
      }
    }
    return p;
  }

  void onError(PlacesAutocompleteResponse response) {
    homeScaffoldKey.currentState.showSnackBar(
      SnackBar(content: Text(response.errorMessage)),
    );
  }

  _addMarker(LatLng position, String id, BitmapDescriptor descriptor) {
    MarkerId markerId = MarkerId(id);
    Marker marker =
        Marker(markerId: markerId, icon: descriptor, position: position);
    markers[markerId] = marker;
  }

  _getPolyline() async {
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      'AIzaSyCQXC6t3acK5xh_do3RNEfz0fhHnlSoU9g',
      PointLatLng(pickUpLat, pickUpLong),
      PointLatLng(dropLat, dropLong),
      // travelMode: TravelMode.driving,
      // wayPoints: [PolylineWayPoint(location: 'Lahore Pakistn')]
    );
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }
    _addPolyLine();
  }

  _addPolyLine() {
    PolylineId id = PolylineId("poly");
    Polyline polyline = Polyline(
        polylineId: id, color: themeColor, points: polylineCoordinates);
    polylines[id] = polyline;
    setState(() {});
  }
}
