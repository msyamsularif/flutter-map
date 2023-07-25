# Flutter Maps App

This project contains the results of learning research in implementing Google Maps on Flutter.
Here is a demo of the flutter maps application

<img src="https://github.com/msyamsularif/flutter-map/blob/main/assets/doc/Doc%20Flutter%20Map.gif" width="320" height="640"/>

## Features

- Set limits on the reachable area
- Creates directions for navigating shipments that fall within the specified area
- Get current location (or realtime current location)

## Tech

Flutter maps use several open source packages found in [pub.dev](https://pub.dev/), including :

- [google_maps_flutter](https://pub.dev/packages/google_maps_flutter) - this is used to display the map with the Google Maps SDK
- [geocoding](https://pub.dev/packages/geocoding) - to translate latitude and longitude coordinates into an address 
- [geolocator](https://pub.dev/packages/geolocator) - provides easy access to platform specific location services
- [flutter_polyline_points](https://pub.dev/packages/flutter_polyline_points) - that decodes encoded google polyline string into list of geo-coordinates suitable for showing route/polyline on maps

## Installation

To use this project, it is required to setup the Google Maps SDK first, You can access the following guide [Google Maps Platform](https://developers.google.com/maps/gmp-get-started?hl=id) or [CodeLabs FLutter Maps](https://codelabs.developers.google.com/codelabs/google-maps-in-flutter?hl=id#0)

After successfully setting up the Google Maps SDK, you can replace the API Key into the following file :
- _android\app\src\main\AndroidManifest.xml_
    - ![](https://github.com/msyamsularif/flutter-map/blob/main/assets/doc/AndroidManifest.png)

- _lib\helper\maps_helper.dart_
    - ![](https://github.com/msyamsularif/flutter-map/blob/main/assets/doc/maps_helper.png)

and you can immediately run the flutter application with the following command
```sh
flutter pub get
flutter run lib/main.dart
```

>To simulate the location , you need to do some modifications.

#### For Android:
If you are on Windows or using the Android simulator, click on the bottom three dots and make sure you are in the location. Let's say the source location is Google Plex, change the **source location** to these coordinates and the destination location is your current location, please custom the area in the `_listAreaLatLng` variable according to your location. Now click on the “route” tab, and look for the current location and Google plex as a starting point. Save route, set loop route press playback speed. The current location is moving which is what we want.