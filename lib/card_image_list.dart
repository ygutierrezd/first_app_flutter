import 'package:flutter/cupertino.dart';
import 'package:platzi_app/card_image.dart';

class CardImageList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      height: 350,
      child: ListView(
        padding: EdgeInsets.all(25),
        scrollDirection: Axis.horizontal,
        children: <Widget>[
          CardImage("assets/img/rick1.jpg"),
          CardImage("assets/img/rick2.jpg"),
          CardImage("assets/img/rick3.jpg")
        ],
      ),
    );
  }
}
