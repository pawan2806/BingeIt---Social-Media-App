import 'dart:ui';
import 'package:buddiesgram/models/user.dart';
import 'package:buddiesgram/pages/HomePage.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:buddiesgram/bloc/get_movie_videos_bloc.dart';
import 'package:buddiesgram/model/movie.dart';
import 'package:buddiesgram/model/video.dart';
import 'package:buddiesgram/model/video_response.dart';
import 'package:buddiesgram/style/theme.dart' as Style;
import 'package:buddiesgram/widgets/casts.dart';
import 'package:buddiesgram/widgets/movie_info.dart';
import 'package:buddiesgram/widgets/similar_movies.dart';
import 'package:sliver_fab/sliver_fab.dart';
import 'package:uuid/uuid.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:buddiesgram/utils/constants.dart';
import 'video_player.dart';

class MovieDetailScreen extends StatefulWidget {
  final Movie movie;
  final User gCurrentUser;
  MovieDetailScreen({Key key, @required this.movie, this.gCurrentUser}) : super(key: key);
  @override
  _MovieDetailScreenState createState() => _MovieDetailScreenState(movie);
}
int height=5;
class _MovieDetailScreenState extends State<MovieDetailScreen> {
  final Movie movie;
  bool uploading = false;
  String postId = Uuid().v4();
  TextEditingController descriptionTextEditingController = TextEditingController();
  TextEditingController locationTextEditingController = TextEditingController();
  _MovieDetailScreenState(this.movie);

  @override
  void initState() {
    super.initState();
    movieVideosBloc.getMovieVideos(movie.id);
  }

  @override
  void dispose() {
    super.dispose();
    movieVideosBloc.drainStream();
  }

  controlUploadAndSave()async {
    setState(() {
      uploading = true;
    });

    String downloadUrl = "https://image.tmdb.org/t/p/original/" + movie.backPoster;

    savePostInfoToFireStore(url: downloadUrl, location: movie.title , description: "Added to Watchlist" );

    locationTextEditingController.clear();
    descriptionTextEditingController.clear();

    setState(() {

      uploading = false;
      postId = Uuid().v4();
    });
  }


  savePostInfoToFireStore({String url, String location, String description})
  {
    postsReference.document(widget.gCurrentUser.id).collection("usersPosts").document(postId).setData({
      "postId": postId,
      "ownerId": widget.gCurrentUser.id,
      "timestamp": DateTime.now(),
      "likes": {},
      "username": widget.gCurrentUser.username,
      "description": description,
      "location": location,
      "url": url,
    });
  }


  controlUploadAndSaveforReview()async {
    setState(() {
      uploading = true;
    });

    String downloadUrl = "https://image.tmdb.org/t/p/original/" + movie.backPoster;

    savePostInfoToFireStoreforReview(url: downloadUrl, location:  movie.title , description: "Rated " + '$height' + " stars - " + descriptionTextEditingController.text );

    locationTextEditingController.clear();
    descriptionTextEditingController.clear();

    setState(() {

      uploading = false;
      postId = Uuid().v4();
    });
  }


  savePostInfoToFireStoreforReview({String url, String location, String description})
  {
    postsReference.document(widget.gCurrentUser.id).collection("usersPosts").document(postId).setData({
      "postId": postId,
      "ownerId": widget.gCurrentUser.id,
      "timestamp": DateTime.now(),
      "likes": {},
      "username": widget.gCurrentUser.username,
      "description": description,
      "location": location,
      "url": url,
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Style.Colors.mainColor,
      body: Builder(
        builder: (context) {
          return SliverFab(
            floatingPosition: FloatingPosition(right: 20),
            floatingWidget: StreamBuilder<VideoResponse>(
              stream: movieVideosBloc.subject.stream,
              builder: (context, AsyncSnapshot<VideoResponse> snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data.error != null &&
                      snapshot.data.error.length > 0) {
                    return _buildErrorWidget(snapshot.data.error);
                  }
                  return _buildVideoWidget(snapshot.data);
                } else if (snapshot.hasError) {
                  return _buildErrorWidget(snapshot.error);
                } else {
                  return _buildLoadingWidget();
                }
              },
            ),
            expandedHeight: 200.0,
            slivers: <Widget>[
              new SliverAppBar(
                backgroundColor: Style.Colors.mainColor,
                expandedHeight: 200.0,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                    title: Text(
                      movie.title.length > 40
                          ? movie.title.substring(0, 37) + "..."
                          : movie.title,
                      style: TextStyle(color: Colors.white,
                          fontSize: 12.0, fontWeight: FontWeight.normal),
                    ),
                    background: Stack(
                      children: <Widget>[
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            image: DecorationImage(
                                fit: BoxFit.cover,
                                image: NetworkImage(
                                    "https://image.tmdb.org/t/p/original/" +
                                        movie.backPoster)),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5)),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                stops: [
                                  0.1,
                                  0.9
                                ],
                                colors: [
                                  Colors.black.withOpacity(0.9),
                                  Colors.black.withOpacity(0.0)
                                ]),
                          ),
                        ),
                      ],
                    )),
              ),
              SliverPadding(
                  padding: EdgeInsets.all(0.0),
                  sliver: SliverList(
                      delegate: SliverChildListDelegate([
                    Padding(
                      padding: EdgeInsets.only(left: 10.0, top: 20.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            movie.rating.toString(),
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 14.0,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            width: 5.0,
                          ),
                          // RatingBar(
                          //   itemSize: 10.0,
                          //   initialRating: movie.rating / 2,
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
                      ),
                    ),
                        ElevatedButton(
                          onPressed: () => controlUploadAndSave() ,
                          child: Text(
                            'Add to Watchlist',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black45

                            ),
                          ),
                          style:ElevatedButton.styleFrom(
                            onPrimary: Colors.white,
                            primary: Colors.amber,
                          ),
                        ),

                        ElevatedButton(
                          onPressed: () {
                            showDialog(
                                context: context,
                                barrierDismissible: true,
                                builder: (context) {
                                  return StatefulBuilder(
                                      builder: (context, setState) {
                                        return AlertDialog(
                                          backgroundColor: darkBG,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(20.0),
                                          ),
                                          content: SingleChildScrollView(
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 0.0, top: 0.0, right: 0.0, bottom: 0.0),
                                              child: Container(
                                                width: MediaQuery.of(context).size.width * 0.9,
                                                // height: MediaQuery.of(context).size.height*0.7,
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'You are rating',
                                                      style: TextStyle(color: kPink,
                                                        fontWeight: FontWeight.w500,
                                                        fontSize: 14,),
                                                      textAlign: TextAlign.start,
                                                    ),
                                                    Text(
                                                      movie.title.length > 40
                                                          ? movie.title.substring(0, 37) + "..."
                                                          : movie.title,
                                                      style: TextStyle(
                                                        color: kBlue,
                                                        fontWeight: FontWeight.w500,
                                                        fontSize: 16,
                                                      ),
                                                      textAlign: TextAlign.start,
                                                    ),

                                                    Divider(
                                                      color:  Colors.white,
                                                      height: 10,
                                                      thickness: 1,
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets.only(top: 8.0),
                                                      child: TextFormField(
                                                        controller: descriptionTextEditingController,
                                                        textAlign: TextAlign.justify,
                                                        maxLength: 250,
                                                        maxLines: 7,
                                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w300),
                                                        decoration: new InputDecoration(

                                                          labelText: "Enter Review",

                                                          labelStyle: TextStyle(

                                                            color: kBlue,
                                                            fontWeight: FontWeight.w500,
                                                            fontSize: 15,

                                                          ),
                                                          // hintText: "Give a description",
                                                          // hintStyle: TextStyle(color:Colors.white),
                                                          fillColor: Colors.red,
                                                          focusedBorder: OutlineInputBorder(
                                                            borderSide: BorderSide(color: blueDark, width: 3.0),
                                                          ),
                                                          counterStyle: TextStyle(color: Colors.white),
                                                          enabledBorder: OutlineInputBorder(
                                                            borderSide: BorderSide(color: Colors.white, width: 3.0),
                                                          ),
                                                          border: new OutlineInputBorder(


                                                            borderRadius: new BorderRadius.circular(20.0),

                                                            borderSide: new BorderSide(

                                                            ),
                                                          ),
                                                          //fillColor: Colors.green
                                                        ),
                                                      ),
                                                    ),
                                                    ReusableCard(
                                                      colour: kActiveCardColour,
                                                      cardChild: Column(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: <Widget>[
                                                          Padding(
                                                            padding: const EdgeInsets.only(top: 10.0),
                                                            child: Text(
                                                              'HEIGHT',
                                                              style: TextStyle(color: Colors.white),
                                                            ),
                                                          ),
                                                          Row(
                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                            crossAxisAlignment: CrossAxisAlignment.baseline,
                                                            textBaseline: TextBaseline.alphabetic,
                                                            children: <Widget>[
                                                              Text(
                                                                height.toString(),
                                                                style: TextStyle(color: kPink,
                                                                  fontWeight: FontWeight.w500,
                                                                  fontSize: 14,),
                                                              ),
                                                              Text(
                                                                '  Stars',
                                                                style: TextStyle(color: Colors.white),
                                                              )
                                                            ],
                                                          ),
                                                          SliderTheme(
                                                            data: SliderTheme.of(context).copyWith(
                                                              inactiveTrackColor: Color(0xFF8D8E98),
                                                              activeTrackColor: Colors.white,
                                                              thumbColor: Color(0xFFEB1555),
                                                              overlayColor: Color(0x29EB1555),
                                                              thumbShape:
                                                              RoundSliderThumbShape(enabledThumbRadius: 15.0),
                                                              overlayShape:
                                                              RoundSliderOverlayShape(overlayRadius: 30.0),
                                                            ),
                                                            child: Slider(
                                                              value: height.toDouble(),
                                                              min: 0.0,
                                                              max: 10.0,
                                                              onChanged: (double newValue) {
                                                                setState(() {
                                                                  print(height);
                                                                  height = newValue.round();
                                                                });
                                                              },
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Center(
                                                      child: ElevatedButton(
                                                        onPressed: () => controlUploadAndSaveforReview() ,
                                                        child: Text(
                                                          'Add Review',
                                                          style: TextStyle(
                                                              fontSize: 12,
                                                              color: Colors.black45

                                                          ),
                                                        ),
                                                        style:ElevatedButton.styleFrom(
                                                          onPrimary: Colors.white,
                                                          primary: Colors.amber,
                                                        ),
                                                      ),
                                                    ),



                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        );

                                      }

                                  );
                                });

                          },
                          child: Text(
                            'Rate it',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black45,

                            ),
                          ),
                          style:ElevatedButton.styleFrom(
                            onPrimary: Colors.white,
                            primary: Colors.amber,
                          ),
                        ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0, top: 20.0),
                      child: Text(
                        "OVERVIEW",
                        style: TextStyle(
                            color: Style.Colors.titleColor,
                            fontWeight: FontWeight.w500,
                            fontSize: 12.0),
                      ),
                    ),
                    SizedBox(
                      height: 5.0,
                    ),
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Text(
                        movie.overview,
                        style: TextStyle(
                            color: Colors.white, fontSize: 12.0, height: 1.5),
                      ),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    MovieInfo(id: movie.id,),
                    Casts(
                      id: movie.id,
                    ),
                    SimilarMovies(id: movie.id)
                  ])))
            ],
          );
        },
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [],
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

  Widget _buildVideoWidget(VideoResponse data) {
    List<Video> videos = data.videos;
    return FloatingActionButton(
      backgroundColor: Style.Colors.secondColor,
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideoPlayerScreen(
              controller: YoutubePlayerController(
                initialVideoId: videos[0].key,
                flags: YoutubePlayerFlags(
                  autoPlay: true,
                  mute: true,
                ),
              ),
            ),
          ),
        );
      },
      child: Icon(Icons.play_arrow),
    );
  }
}
