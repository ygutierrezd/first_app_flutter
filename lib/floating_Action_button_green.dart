import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FloatingActionButtonGreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _FloatingActionButtonGreen();
  }
}

class _FloatingActionButtonGreen extends State<FloatingActionButtonGreen> {
  bool favorite = true;
  void onPressedFav() {
    setState(() {
      favorite = !favorite;
    });

    Scaffold.of(context).showSnackBar(SnackBar(
      content:
          Text(!favorite ? "agregaste favorito" : "eliminado de favoritos"),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
        backgroundColor: Color(0xFF11DA53),
        mini: true,
        tooltip: "Fav",
        onPressed: onPressedFav,
        child: Icon(favorite ? Icons.favorite_border : Icons.favorite_sharp));
  }
}
