import 'trip.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<Trip> retrieveTrip(
    double fromLong, double fromLat, double toLong, double toLat) async {
  String url =
      'https://api.mapbox.com/optimized-trips/v1/mapbox/driving/$fromLong,$fromLat;$toLong,$toLat?roundtrip=false&source=first&destination=last&access_token=pk.eyJ1IjoidGJvcmxlZSIsImEiOiJjazRvNGI4ZXAycTBtM2txd2Z3eHk3Ymh1In0.12yn8XMdhqdoPByYti4g5g';
  var response = await http.get(url);
  var decoded = json.decode(response.body);
  if(decoded['trips'] != null && decoded['trips'].length > 0) {
    return Trip(distance: decoded['trips'][0]['distance'].toDouble(),
        duration: decoded['trips'][0]['duration'].toDouble());
  } else {
    return null;
  }
}
