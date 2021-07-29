import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:buddiesgram/screens/search_screen.dart';
import 'package:buddiesgram/style/theme.dart' as Style;
import 'package:buddiesgram/widgets/best_movies.dart';
import 'package:buddiesgram/widgets/genres.dart';
import 'package:buddiesgram/widgets/now_playing.dart';
import 'package:buddiesgram/widgets/persons.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor:Colors.black,
        centerTitle: true,
        leading: Icon(EvaIcons.menu2Outline, color: Colors.white,),
        title: Text("Discover",
        style: TextStyle(color: Colors.white),),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SearchScreen()
                ),
              );
            },
            icon: Icon(EvaIcons.searchOutline, color: Colors.white,)
          )
        ],
      ),
      body: ListView(
        children: <Widget>[
          NowPlaying(),
          GenresScreen(),
          PersonsList(),
          BestMovies(),
        ],
      ),
    );
  }
}