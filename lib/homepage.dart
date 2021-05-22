import 'package:different/db/db.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart';
import 'package:different/refresh_controller.dart';
import 'package:different/widgets/StatGridHome.dart';
import 'package:different/drivescreen.dart';

import 'db/drive_db.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Artboard _artboard;
  RefreshController _controller;
  List<Drive> drives;

  @override
  void initState() {
    super.initState();
    _loadRiveFile();
    data();
  }


  /// Loads a Rive file
  void _loadRiveFile() async {
    final bytes = await rootBundle.load('assets/rocket_reload.riv');
    final file = RiveFile();
    if (file.import(bytes)) {
      setState(() => _artboard = file.mainArtboard
        ..addController(_controller = RefreshController()));
    }
  }

  Widget buildRefreshWidget(
      BuildContext context,
      RefreshIndicatorMode refreshState,
      double pulledExtent,
      double refreshTriggerPullDistance,
      double refreshIndicatorExtent) {
    _controller.refreshState = refreshState;
    _controller.pulledExtent = pulledExtent;
    _controller.triggerThreshold = refreshTriggerPullDistance;
    _controller.refreshIndicatorExtent = refreshIndicatorExtent;

    return _artboard != null
        ? Rive(
            artboard: _artboard,
            fit: BoxFit.cover,
            alignment: Alignment.bottomCenter)
        : Container();
  }
  int count = 0;
  int distance = 0;

  void data() async{
    this.drives = await DatabaseHandler().Drives();
    distance =  this.drives.isEmpty ? 0 : this.drives[0].distance;
    count = this.drives.isEmpty ? 0 : this.drives[0].how_many;
    setState(() {
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: Text('LyftOff'), backgroundColor: Color(0xFF282828),centerTitle: true,),
      backgroundColor: Color(0xFF333333),
      body: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollEndNotification) {
            _controller.reset();
          }
          return true;
        },
        child: CustomScrollView(
          physics: BouncingScrollPhysics(),
          slivers: [
            CupertinoSliverRefreshControl(
              refreshTriggerPullDistance: 240.0,
              refreshIndicatorExtent: 240.0,
              builder: buildRefreshWidget,
              onRefresh: () {
                data();
                return Future<void>.delayed(const Duration(seconds: 5))
                  ..then<void>((_) {
                    if (mounted) {
                      setState(() {});
                    }
                  });
              },
            ),
            SliverToBoxAdapter(
                child: SizedBox(
              height: 350,
              child: StatsGrid(
                  distance: distance,
                  how_many: count,
              ),
            )),
            SliverSafeArea(
              top: false, // Top safe area is consumed by the navigation bar.
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    return SizedBox(
                        height: 150,
                        child: Container(
                          margin: EdgeInsets.only(left: 10, right: 10, top: 10),
                          decoration: BoxDecoration(
                              color: Color(0xFF282828),
                              borderRadius: BorderRadius.circular(5)),
                        ));
                  },
                  childCount: 10,
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: SizedBox(
        height: 66.0,
        width: 190.0,
        child: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => new DriveScreen(data: DataStorage()))).then((value) => setState((){data();}));
          },
          backgroundColor: Colors.green,
          label: Text(
            'התחל נסיעה',
            style: TextStyle(
              fontSize: 22.0,
                fontWeight: FontWeight.w700

            ),
          ),
          icon: Icon(
            Icons.car_rental,
            size: 30.0,
          ),
          splashColor: Colors.greenAccent,
        ),
      ),
    );
  }
}
