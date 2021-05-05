import 'package:flutter/material.dart';
import 'package:different/widgets/StatGridDrive.dart';
import 'package:location/location.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sensors/sensors.dart';

class DataStorage {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/locationData.csv');
  }

  Future<File> writeData(String data) async {
    final file = await _localFile;

    // Write the file
    return file.writeAsString(data, mode: FileMode.append);
  }
  Future<int> deleteFile() async {
    try {
      final file = await _localFile;

      await file.delete();
    } catch (e) {
      return 0;
    }
  }
}

class DriveScreen extends StatefulWidget {
  final DataStorage data;
  DriveScreen({Key key, @required this.data}) : super(key: key);

  @override
  _DriveScreenState createState() => _DriveScreenState();
}

class _DriveScreenState extends State<DriveScreen> {
  double _speed;
  Timer _timer;
  String _accelerometerValues;
  String _gyroscopeValues;
  List<StreamSubscription<dynamic>> _streamSubscriptions =
  <StreamSubscription<dynamic>>[];

  @override
  void initState() {
    super.initState();
    _listenLocation();
    _streamSubscriptions
        .add(accelerometerEvents.listen((AccelerometerEvent event) {
      setState(() {
        _accelerometerValues = event.x.toString() +
            "," +
            event.y.toString() +
            "," +
            event.z.toString();
      });
    }));
    _streamSubscriptions.add(gyroscopeEvents.listen((GyroscopeEvent event) {
      setState(() {
        _gyroscopeValues = event.x.toString() +
            "," +
            event.y.toString() +
            "," +
            event.z.toString();
      });
    }));
  }

  //location data
  final Location location = Location();

  LocationData _location;
  StreamSubscription<LocationData> _locationSubscription;
  String _error;

  Future<void> _listenLocation() async {
    location.requestPermission();
    _locationSubscription =
        location.onLocationChanged.handleError((dynamic err) {
          setState(() {
            _error = err.code;
          });
          _locationSubscription.cancel();
        }).listen((LocationData currentLocation) {
          setState(() {
            _error = null;
            _location = currentLocation;
            _speed = _location.speed;
          });
        });
  }

  Future<void> _stopListen() async {
    _locationSubscription.cancel();
  }

  Future<void> newData() async {
    // Write the variable as a string to the file.
    if (_location != null && _error == null) {
      widget.data.writeData(
          '${_location.longitude.toString() + "," + _location.latitude.toString() + "," + _accelerometerValues.toString() + "," + _gyroscopeValues.toString()} \n');
    }
  }

  Future<void> timer() async {
    _timer =
    new Timer.periodic(Duration(milliseconds: 750), (Timer t) => newData());
  }

  @override
  void dispose() {
    // _timer.cancel();
    for (StreamSubscription<dynamic> subscription in _streamSubscriptions) {
      subscription.cancel();
    }
    _locationSubscription.cancel();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          appBar: AppBar(
              leading: GestureDetector(
                onTap: () {
                  _timer.cancel();
                  _stopListen();
                  Navigator.pop(context);
                },
                child: Icon(
                  Icons.baby_changing_station,
                ),
              ),
              title: Text('LyftOff'),
              backgroundColor: Color(0xFF282828)),
          backgroundColor: Color(0xFF333333),
          body: SizedBox(
            height: 325,
            child: StatsGrid(
                distance: 15,
                speed: (_speed?.round() ?? 0),
                time: DateTime.now().toString()),
          ),
          floatingActionButton: SizedBox(
            height: 60.0,
            width: 185.0,
            child: FloatingActionButton.extended(
              onPressed: () {
                widget.data.deleteFile();
                timer();
              },
              backgroundColor: Colors.green,
              label: Text(
                'התחל נסיעה',
                style: TextStyle(
                  fontSize: 20.0,
                ),
              ),
              icon: Icon(
                Icons.car_rental,
                size: 30.0,
              ),
              splashColor: Colors.greenAccent,
            ),
          ),
        ));
  }
}
