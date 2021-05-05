import 'package:flutter/material.dart';

class StatsGrid extends StatelessWidget {
  @override
  final int distance;
  final int speed;
  final String time;

  StatsGrid({this.distance, this.speed, this.time});

  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.25,
      child: Column(
        children: <Widget>[
          Flexible(
            child: Row(
              children: <Widget>[
                _mainStatCard('מרחק', distance.toString(), Colors.red),
              ],
            ),
          ),
          Flexible(
            child: Row(
              children: <Widget>[
                _mainStatCard(' זמן', time, Colors.lightBlue),
                _mainStatCard('מהירות נסיעה', speed.toString(), Colors.purple),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Expanded _mainStatCard(String title, String count, MaterialColor color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(8.0),
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Spacer(),
                Text(
                  title,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  count,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 10.0,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Row(),
          ],
        ),
      ),
    );
  }
}
