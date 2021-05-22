import 'package:flutter/material.dart';

class StatsGrid extends StatelessWidget {
  @override
  final int distance;
  final int how_many;

  StatsGrid({this.distance, this.how_many});

  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.25,
      child: Column(
        children: <Widget>[
          Flexible(
            child: Row(
              children: <Widget>[
                _mainStatCard('מרחק מצטבר', distance.toString(), Colors.pink),
              ],
            ),
          ),
          Flexible(
            child: Row(
              children: <Widget>[
                _mainStatCard('מספר נסיעות', how_many.toString(), Colors.lightBlue),
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
                      fontSize: 25.0,
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
                      fontSize: 40.0,
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
