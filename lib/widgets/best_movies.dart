import 'dart:convert';
import 'dart:io';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:buddiesgram/bloc/get_movies_bloc.dart';
import 'package:buddiesgram/model/movie.dart';
import 'package:buddiesgram/model/movie_response.dart';
import 'package:buddiesgram/screens/detail_screen.dart';
import 'package:buddiesgram/style/theme.dart' as Style;
import 'package:buddiesgram/models/user.dart';
import 'package:buddiesgram/pages/CreateAccountPage.dart';
import 'package:buddiesgram/pages/NotificationsPage.dart';
import 'package:buddiesgram/pages/ProfilePage.dart';
import 'package:buddiesgram/pages/SearchPage.dart';
import 'package:buddiesgram/pages/TimeLinePage.dart';
import 'package:buddiesgram/pages/UploadPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:buddiesgram/screens/home_screen.dart';


final GoogleSignIn gSignIn = GoogleSignIn();
final usersReference = Firestore.instance.collection("users");
final StorageReference storageReference = FirebaseStorage.instance.ref().child("Posts Pictures");
final postsReference = Firestore.instance.collection("posts");
final activityFeedReference = Firestore.instance.collection("feed");
final commentsRefrence = Firestore.instance.collection("comments");
final followersRefrence = Firestore.instance.collection("followers");
final followingRefrence = Firestore.instance.collection("following");
final timelineRefrence = Firestore.instance.collection("timeline");

final DateTime timestamp = DateTime.now();
User currentUser;

class BestMovies extends StatefulWidget {
  @override
  _BestMoviesState createState() => _BestMoviesState();
}

class _BestMoviesState extends State<BestMovies> {
  bool isSignedIn = false;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  @override
  void initState() {
    super.initState();
    moviesBloc..getMovies();
    gSignIn.onCurrentUserChanged.listen((gSigninAccount){
      controlSignIn(gSigninAccount);
    }, onError: (gError){
      print("Error Message: " + gError);
    });

    gSignIn.signInSilently(suppressErrors: false).then((gSignInAccount){
      controlSignIn(gSignInAccount);
    }).catchError((gError){
      print("Error Message: " + gError);
    });
  }

  controlSignIn(GoogleSignInAccount signInAccount) async
  {
    if(signInAccount != null)
    {
      await saveUserInfoToFireStore();

      setState(() {
        isSignedIn = true;
      });

      configureRealTimePushNotifications();
    }
    else
    {
      setState(() {
        isSignedIn = false;
      });
    }
  }
  configureRealTimePushNotifications()
  {
    final GoogleSignInAccount gUser = gSignIn.currentUser;

    if(Platform.isIOS)
    {
      getIOSPermissions();
    }

    _firebaseMessaging.getToken().then((token){
      usersReference.document(gUser.id).updateData({"androidNotificationToken": token});
    });

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> msg) async
      {
        final String recipientId = msg["data"]["recipient"];
        final String body = msg["notification"]["body"];

        if(recipientId == gUser.id)
        {
          SnackBar snackBar = SnackBar(
            backgroundColor: Colors.grey,
            content: Text(body, style: TextStyle(color: Colors.black), overflow: TextOverflow.ellipsis,),
          );
          _scaffoldKey.currentState.showSnackBar(snackBar);
        }
      },
    );
  }

  getIOSPermissions()
  {
    _firebaseMessaging.requestNotificationPermissions(IosNotificationSettings(alert: true, badge: true, sound: true));

    _firebaseMessaging.onIosSettingsRegistered.listen((settings){
      print("Settings Registered :  $settings");
    });
  }

  saveUserInfoToFireStore() async {
    final GoogleSignInAccount gCurrentUser = gSignIn.currentUser;
    DocumentSnapshot documentSnapshot = await usersReference.document(gCurrentUser.id).get();

    if(!documentSnapshot.exists){
      final username = await Navigator.push(context, MaterialPageRoute(builder: (context) => CreateAccountPage()));

      usersReference.document(gCurrentUser.id).setData({
        "id": gCurrentUser.id,
        "profileName": gCurrentUser.displayName,
        "username": username,
        "url": gCurrentUser.photoUrl,
        "email": gCurrentUser.email,
        "bio": "",
        "timestamp": timestamp,
      });

      await followersRefrence.document(gCurrentUser.id).collection("userFollowers").document(gCurrentUser.id).setData({});

      documentSnapshot = await usersReference.document(gCurrentUser.id).get();
    }

    currentUser = User.fromDocument(documentSnapshot);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(left: 10.0, top: 20.0),
          child: Text(
            "BEST POPULAR MOVIES",
            style: TextStyle(
                color: Style.Colors.titleColor,
                fontWeight: FontWeight.w500,
                fontSize: 12.0),
          ),
        ),
        SizedBox(
          height: 5.0,
        ),
        StreamBuilder<MovieResponse>(
          stream: moviesBloc.subject.stream,
          builder: (context, AsyncSnapshot<MovieResponse> snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data.error != null &&
                  snapshot.data.error.length > 0) {
                return _buildErrorWidget(snapshot.data.error);
              }
              return _buildHomeWidget(snapshot.data);
            } else if (snapshot.hasError) {
              return _buildErrorWidget(snapshot.error);
            } else {
              return _buildLoadingWidget();
            }
          },
        )
      ],
    );
  }

  Widget _buildLoadingWidget() {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 25.0,
          width: 25.0,
          child: CircularProgressIndicator(
            valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
            strokeWidth: 4.0,
          ),
        )
      ],
    ));
  }

  Widget _buildErrorWidget(String error) {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Error occured: $error"),
      ],
    ));
  }

  Widget _buildHomeWidget(MovieResponse data) {
    List<Movie> movies = data.movies;
    if (movies.length == 0) {
      return Container(
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Column(
              children: <Widget>[
                Text(
                  "No More Movies",
                  style: TextStyle(color: Colors.black45),
                )
              ],
            )
          ],
        ),
      );
    } else
      return Container(
        height: 270.0,
        padding: EdgeInsets.only(left: 10.0),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: movies.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: EdgeInsets.only(top: 10.0, bottom: 10.0, right: 15.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          MovieDetailScreen(movie: movies[index], gCurrentUser: currentUser,),
                    ),
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Hero(
                      tag: movies[index].id,
                      child: Container(
                          width: 120.0,
                          height: 180.0,
                          decoration: new BoxDecoration(
                            borderRadius:
                                BorderRadius.all(Radius.circular(2.0)),
                            shape: BoxShape.rectangle,
                            image: new DecorationImage(
                                fit: BoxFit.cover,
                                image: NetworkImage(
                                    "https://image.tmdb.org/t/p/w200/" +
                                        movies[index].poster)),
                          )),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Container(
                      width: 100,
                      child: Text(
                        movies[index].title,
                        maxLines: 2,
                        style: TextStyle(
                            height: 1.4,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 11.0),
                      ),
                    ),
                    SizedBox(
                      height: 5.0,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          movies[index].rating.toString(),
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 10.0,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          width: 5.0,
                        ),
                        // RatingBar(
                        //   itemSize: 8.0,
                        //   initialRating: movies[index].rating / 2,
                        //   minRating: 1,
                        //   direction: Axis.horizontal,
                        //   allowHalfRating: true,
                        //   itemCount: 5,
                        //   itemPadding: EdgeInsets.symmetric(horizontal: 2.0),
                        //   itemBuilder: (context, _) => Icon(
                        //     EvaIcons.star,
                        //     color: Style.Colors.secondColor,
                        //   ),
                        //   onRatingUpdate: (rating) {
                        //     print(rating);
                        //   },
                        // )
                      ],
                    )
                  ],
                ),
              ),
            );
          },
        ),
      );
  }
}
