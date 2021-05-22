import 'package:different/db/db.dart';
import 'package:different/db/drive_db.dart';
import 'package:flutter/material.dart';
import 'package:different/widgets/StatGridDrive.dart';
import 'package:location/location.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sensors/sensors.dart';
import 'package:flutter_mailer/flutter_mailer.dart';
import 'package:url_launcher/url_launcher.dart';
const _url = 'https://www.youtube.com/watch?v=e2QKlmMT8II';

class DataStorage {
  Future<String> get _localPath async {
    final directory = await getExternalStorageDirectory();
    return directory.path;
  }

  //getApplicationDocumentsDirectory()

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

String formatTime(int milliseconds) {
  var secs = milliseconds ~/ 1000;
  var hours = (secs ~/ 3600).toString().padLeft(2, '0');
  var minutes = ((secs % 3600) ~/ 60).toString().padLeft(2, '0');
  var seconds = (secs % 60).toString().padLeft(2, '0');
  return "$hours:$minutes:$seconds";
}

void _launchURL() async =>
    await canLaunch(_url) ? await launch(_url) : throw 'Could not launch $_url';

class DriveScreen extends StatefulWidget {
  final DataStorage data;
  DriveScreen({Key key, @required this.data}) : super(key: key);

  @override
  _DriveScreenState createState() => _DriveScreenState();
}

class _DriveScreenState extends State<DriveScreen> {
  List<Drive> drives;
  int count = 0;
  int distance_old = 0;
  double _speed;
  Timer _timer;
  Timer _timer2;
  int how_many;
  List list;
  double _distance = 0;
  Stopwatch _stopwatch;
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
    widget.data.deleteFile();
    timer();
    _stopwatch = Stopwatch();
    _stopwatch.start();
    data();
  }

  //location data
  final Location location = Location();

  LocationData _location;
  StreamSubscription<LocationData> _locationSubscription;
  String _error;

  Future<void> _listenLocation() async {
    location.requestPermission();
    location.changeSettings(accuracy: LocationAccuracy.high, interval: 1000);
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
        _speed = _location.speed * 3.6;
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
          '${_location.latitude.toString() + "," + _location.longitude.toString() + "," + _accelerometerValues.toString() + "," + _gyroscopeValues.toString() + "," + "" + "," + ""}  \n');
    }
  }

  //timer
  Future<void> timer() async {
    _timer =
        new Timer.periodic(Duration(milliseconds: 100), (Timer t) => newData());
    _timer2 = new Timer.periodic(
        Duration(milliseconds: 1000), (Timer t) => distance());
  }

  //stopwatch
  Future<void> distance() async {
    if(_speed != null){
      _distance += _speed * 0.00028;
    }
  }

  void data() async {
    this.drives = await DatabaseHandler().Drives();
    distance_old = this.drives.isEmpty ? 0 : this.drives[0].distance;
    count = this.drives.isEmpty ? 0 : this.drives[0].how_many;
  }

  void sum() async {
    if (_distance > 1) {
      var now = Drive(
        id: 0,
        distance: distance_old + _distance.round(),
        how_many: count + 1,
      );

      await DatabaseHandler().insertDrive(now);
    }
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

  get _localPath async {
    final directory = await getExternalStorageDirectory();
    return directory.path;
  }

  void send() async {
    final path = await _localPath;
    final MailOptions mailOptions = MailOptions(
      body: 'data',
      subject: 'data',
      recipients: ['deep.nav.data@gmail.com'],
      isHTML: true,
      attachments: ['$path/locationData.csv'],
    );
    await FlutterMailer.send(mailOptions);
  }

  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
            appBar: AppBar(
                leading: GestureDetector(
                  onTap: () {
                    _launchURL();
                  },
                  child: Icon(
                    Icons.baby_changing_station,
                  ),
                ),
                title: Text('LyftOff'),
                backgroundColor: Color(0xFF282828),
                centerTitle:true,
            ),
            backgroundColor: Color(0xFF333333),
            body: SizedBox(
              height: 325,
              child: StatsGrid(
                  distance: _distance.toStringAsFixed(2),
                  speed: (_speed?.round() ?? 0),
                  time: formatTime(_stopwatch.elapsedMilliseconds)),
            ),
            floatingActionButton:
                 Stack(
                  children: <Widget>[
                    Align(
                      alignment: Alignment(-0.7,0.9),
                      child: SizedBox(
                        height: 70.0,
                        width: MediaQuery.of(context).size.width * 0.45,
                        child: FloatingActionButton.extended(
                          heroTag: 'but1',
                          onPressed: () {
                            _timer.cancel();
                            _stopListen();
                            sum();
                            send();
                            Navigator.pop(context);
                          },
                          backgroundColor: Colors.red,
                          label: Text(
                            'סיים נסיעה',
                            style: TextStyle(
                              fontSize: 24.0,
                              fontWeight: FontWeight.bold
                            ),
                          ),
                          splashColor: Colors.redAccent,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment(1,0.9),
                      child: SizedBox(
                        height: 70.0,
                        width: MediaQuery.of(context).size.width * 0.45,
                        child: FloatingActionButton.extended(
                          heroTag: 'but2',
                          onPressed: () {
                            _distance = 0;
                            _stopwatch.reset();
                            widget.data.deleteFile();
                          },
                          backgroundColor: Colors.green,
                          label: Text(
                            'אפס נסיעה',
                            style: TextStyle(
                              fontSize: 24.0,
                                fontWeight: FontWeight.bold

                            ),
                          ),
                          splashColor: Colors.greenAccent,
                        ),
                      ),
                    ),
                  ],
                )));
  }
}
