import 'package:bingeit/application/search/actor_search/actor_details/actor_details_bloc.dart';
import 'package:bingeit/constants.dart';
import 'package:bingeit/presentation/pages/actor_details_page/actor_all_movies_page.dart';
import 'package:bingeit/presentation/pages/actor_details_page/actor_all_tv_shows_page.dart';
import 'package:bingeit/presentation/pages/actor_details_page/actor_biography_page.dart';
import 'package:bingeit/presentation/pages/movie_details_page/movie_details_page.dart';
import 'package:bingeit/presentation/pages/tv_show_details_page/tv_show_details_page.dart';
import 'package:bingeit/presentation/utilities/utilities.dart';
import 'package:flutter/cupertino.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unicons/unicons.dart';

class ActorDetailsPage extends StatefulWidget {
  final int actorId;

  ActorDetailsPage(this.actorId);

  @override
  _ActorDetailsPageState createState() => _ActorDetailsPageState();
}

class _ActorDetailsPageState extends State<ActorDetailsPage> {
  @override
  void didChangeDependencies() {
    context.read<ActorDetailsBloc>().add(
          ActorDetailsEvent.actorDetailsPressed(widget.actorId),
        );
    super.didChangeDependencies();
  }

  //Method to call, when Navigator.pop is called, to update the movieDetails page
  void sendEvent() {
    context.read<ActorDetailsBloc>().add(
          ActorDetailsEvent.actorDetailsPressed(widget.actorId),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1B1E2B),

      body: SafeArea(
        child: BlocBuilder<ActorDetailsBloc, ActorDetailsState>(
          builder: (context, state) {
            return Scaffold(
              backgroundColor: Color(0xFF1B1E2B),
              appBar: AppBar(

                title: Text(
                  state.errorMessage.isEmpty && !state.isSearching ? state.actorDetails.name : "Loading",
                ),
              ),
              body: Column(
                children: [
                  if (state.isSearching) BuildSearchProgressIndicator(),
                  if (state.errorMessage.isNotEmpty) BuildSearchErrorMessage(state.errorMessage),
                  if (state.errorMessage.isEmpty && !state.isSearching)
                    Expanded(
                      child: MediaQuery.removePadding(
                        context: context,
                        removeTop: true,
                        removeBottom: true,
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: ListView(
                            children: [

                              Column(
                                children: [
                                  CarouselSlider(
                                    items: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Stack(
                                            alignment: Alignment.bottomCenter,
                                            children: [
                                              Center(
                                                child: Container(
                                                  child: BuildPosterImage(
                                                      height: MediaQuery.of(context).size.height*0.8,
                                                      width: MediaQuery.of(context).size.width,
                                                      imagePath: state.actorDetails.profilePath),
                                                ),
                                              ),
                                              Container(
                                                  decoration: BoxDecoration(
                                                      color: Colors.black.withOpacity(0.7)
                                                  ),
                                                  child:Align(
                                                    //alignment: Alignment.bottomCenter,
                                                    child: Padding(
                                                      padding: const EdgeInsets.only(
                                                        left: 16.0,
                                                        top: 16.0,
                                                        right: 16.0,
                                                        bottom: 16.0,

                                                      ),
                                                      child: Row(
                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          Text(
                                                            "Swipe",
                                                            maxLines: 2,
                                                            overflow: TextOverflow.ellipsis,
                                                            style: TextStyle(
                                                              fontWeight: FontWeight.w700,
                                                              fontSize: 20,
                                                            ),
                                                          ),
                                                          Icon(UniconsLine.arrow_circle_right)
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                              )
                                            ],
                                          ),


                                          // Expanded(
                                          //   child: Padding(
                                          //     padding: const EdgeInsets.only(
                                          //       left: 16.0,
                                          //       top: 16.0,
                                          //     ),
                                          //     child: Column(
                                          //       mainAxisSize: MainAxisSize.max,
                                          //       crossAxisAlignment: CrossAxisAlignment.start,
                                          //       children: [
                                          //         InkWell(
                                          //           onTap: () {
                                          //             Navigator.of(context, rootNavigator: false).push(
                                          //               MaterialPageRoute(
                                          //                 builder: (context) => ActorBiographyPage(state.actorDetails.biography),
                                          //               ),
                                          //             );
                                          //           },
                                          //           child: Text(
                                          //             state.actorDetails.biography,
                                          //             maxLines: 6,
                                          //             overflow: TextOverflow.ellipsis,
                                          //           ),
                                          //         ),
                                          //         Padding(
                                          //           padding: const EdgeInsets.only(top: 20.0),
                                          //           child: Text("Born: " + convertBirthDeathDate(state.actorDetails.birthday)),
                                          //         ),
                                          //         Padding(
                                          //           padding: const EdgeInsets.only(top: 4.0),
                                          //           child: Text(
                                          //             state.actorDetails.deathday.isEmpty
                                          //                 ? ""
                                          //                 : "Died: " + convertBirthDeathDate(state.actorDetails.deathday),
                                          //           ),
                                          //         ),
                                          //       ],
                                          //     ),
                                          //   ),
                                          // ),
                                        ],
                                      ),

                                      SingleChildScrollView(
                                        child: Padding(
                                          padding: const EdgeInsets.only(left: 5.0, ),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  const Text(
                                                    "Movies",
                                                    style: TextStyle(fontSize: 20,color: Colors.blueGrey, fontWeight: FontWeight.bold),

                                                  ),
                                                  TextButton(
                                                      style: TextButton.styleFrom(
                                                        primary: dAccent,
                                                      ),
                                                      onPressed: () {
                                                        //Had to add .then and call setState, so that the first page is refreshed if it is popped back, from the second page where the Navigator
                                                        //is going to push right now (otherwise each page will have the identical MovieDetails)
                                                        Navigator.of(context, rootNavigator: false)
                                                            .push(
                                                          MaterialPageRoute(
                                                            builder: (context) => ActorAllMoviesPage(
                                                              actorName: state.actorDetails.name,
                                                              movieCredits: state.actorDetails.movieCredits,
                                                            ),
                                                          ),
                                                        )
                                                            .then(
                                                              (value) => setState(
                                                                () {
                                                              sendEvent();
                                                            },
                                                          ),
                                                        );
                                                      },
                                                      child: Text("SEE ALL",style: TextStyle(fontWeight: FontWeight.bold),
                                                      )),
                                                ],
                                              ),
                                              if (state.actorDetails.movieCredits.cast.isNotEmpty)
                                                const Padding(
                                                  padding: EdgeInsets.only(bottom: 8.0),
                                                  child: Text(
                                                    "Cast",
                                                    textAlign: TextAlign.start,
                                                    style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),
                                                  ),
                                                ),
                                              if (state.actorDetails.movieCredits.cast.isNotEmpty)
                                                Container(
                                                  height: 230,
                                                  padding: const EdgeInsets.only(right: 8.0),
                                                  child: ListView.builder(
                                                    shrinkWrap: true,
                                                    scrollDirection: Axis.horizontal,
                                                    itemCount: state.actorDetails.movieCredits.cast.length,
                                                    itemBuilder: (context, index) {
                                                      return Padding(
                                                        padding: EdgeInsets.only(
                                                          left: index > 0 ? 8.0 : 0.0,
                                                          bottom: 8.0,
                                                          right: 8.0,
                                                        ),
                                                        child: InkWell(
                                                          onTap: () {
                                                            //Had to add .then and call setState, so that the first page is refreshed if it is popped back, from the second page where the Navigator
                                                            //is going to push right now (otherwise each page will have the identical MovieDetails)
                                                            Navigator.of(context, rootNavigator: false)
                                                                .push(
                                                              MaterialPageRoute(
                                                                builder: (context) => MovieDetailsPage(
                                                                  movieId: state.actorDetails.movieCredits.cast[index].movieSummary.id,
                                                                  movieTitle: state.actorDetails.movieCredits.cast[index].movieSummary.title,
                                                                ),
                                                              ),
                                                            )
                                                                .then(
                                                                  (value) => setState(
                                                                    () {
                                                                  sendEvent();
                                                                },
                                                              ),
                                                            );
                                                          },
                                                          child: Container(
                                                            width: 90,
                                                            child: Column(
                                                              children: [
                                                                BuildPosterImage(
                                                                  height: 135,
                                                                  width: 90,
                                                                  imagePath: state.actorDetails.movieCredits.cast[index].movieSummary.posterPath,
                                                                ),
                                                                Padding(
                                                                  padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
                                                                  child: Text(
                                                                    state.actorDetails.movieCredits.cast[index].movieSummary.title,
                                                                    overflow: TextOverflow.ellipsis,
                                                                    textAlign: TextAlign.center,
                                                                    maxLines: 2,
                                                                    style: TextStyle(
                                                                      fontSize: 14,
                                                                      fontWeight: FontWeight.w500,
                                                                    ),
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  child: Text(
                                                                    state.actorDetails.movieCredits.cast[index].character,
                                                                    overflow: TextOverflow.ellipsis,
                                                                    textAlign: TextAlign.center,
                                                                    maxLines: 2,
                                                                    style: TextStyle(
                                                                      fontSize: 12,
                                                                      fontWeight: FontWeight.w300,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),

                                              if (state.actorDetails.movieCredits.crew.isNotEmpty)
                                                const Padding(
                                                  padding: EdgeInsets.only(bottom: 8.0),
                                                  child: Text(
                                                    "Crew",
                                                    style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),
                                                  ),
                                                ),
                                              if (state.actorDetails.movieCredits.crew.isNotEmpty)
                                                Container(
                                                  height: 230,
                                                  padding: const EdgeInsets.only(right: 8.0),
                                                  child: ListView.builder(
                                                    shrinkWrap: true,
                                                    scrollDirection: Axis.horizontal,
                                                    itemCount: state.actorDetails.movieCredits.crew.length,
                                                    itemBuilder: (context, index) {
                                                      return Padding(
                                                        padding: EdgeInsets.only(
                                                          left: index > 0 ? 8.0 : 0.0,
                                                          bottom: 8.0,
                                                          right: 8.0,
                                                        ),
                                                        child: InkWell(
                                                          onTap: () {
                                                            //Had to add .then and call setState, so that the first page is refreshed if it is popped back, from the second page where the Navigator
                                                            //is going to push right now (otherwise each page will have the identical MovieDetails)
                                                            Navigator.of(context, rootNavigator: false)
                                                                .push(
                                                              MaterialPageRoute(
                                                                builder: (context) => MovieDetailsPage(
                                                                  movieId: state.actorDetails.movieCredits.crew[index].movieSummary.id,
                                                                  movieTitle: state.actorDetails.movieCredits.crew[index].movieSummary.title,
                                                                ),
                                                              ),
                                                            )
                                                                .then(
                                                                  (value) => setState(
                                                                    () {
                                                                  sendEvent();
                                                                },
                                                              ),
                                                            );
                                                          },
                                                          child: Container(
                                                            width: 90,
                                                            child: Column(
                                                              children: [
                                                                BuildPosterImage(
                                                                  height: 135,
                                                                  width: 90,
                                                                  imagePath: state.actorDetails.movieCredits.crew[index].movieSummary.posterPath,
                                                                ),
                                                                Padding(
                                                                  padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
                                                                  child: Text(
                                                                    state.actorDetails.movieCredits.crew[index].movieSummary.title,
                                                                    overflow: TextOverflow.ellipsis,
                                                                    textAlign: TextAlign.center,
                                                                    maxLines: 2,
                                                                    style: TextStyle(
                                                                      fontSize: 14,
                                                                      fontWeight: FontWeight.w500,
                                                                    ),
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  child: Text(
                                                                    state.actorDetails.movieCredits.crew[index].job,
                                                                    overflow: TextOverflow.ellipsis,
                                                                    textAlign: TextAlign.center,
                                                                    maxLines: 2,
                                                                    style: TextStyle(
                                                                      fontSize: 12,
                                                                      fontWeight: FontWeight.w300,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),

                                              ///TV SHOWS
                                              Padding(
                                                padding: const EdgeInsets.only(top: 0.0),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    const Text(
                                                      "TV Shows",
                                                      style: TextStyle(fontSize: 20,color: Colors.blueGrey, fontWeight: FontWeight.bold),
                                                    ),
                                                    TextButton(
                                                        style: TextButton.styleFrom(
                                                          primary:dAccent,
                                                        ),
                                                        onPressed: () {
                                                          //Had to add .then and call setState, so that the first page is refreshed if it is popped back, from the second page where the Navigator
                                                          //is going to push right now (otherwise each page will have the identical MovieDetails)
                                                          Navigator.of(context, rootNavigator: false)
                                                              .push(
                                                            MaterialPageRoute(
                                                              builder: (context) => ActorAllTvShowsPage(
                                                                actorName: state.actorDetails.name,
                                                                tvCredits: state.actorDetails.tvCredits,
                                                              ),
                                                            ),
                                                          )
                                                              .then(
                                                                (value) => setState(
                                                                  () {
                                                                sendEvent();
                                                              },
                                                            ),
                                                          );
                                                        },
                                                        child: Text("SEE ALL",style: TextStyle(fontWeight: FontWeight.bold))),
                                                  ],
                                                ),
                                              ),
                                              if (state.actorDetails.tvCredits.cast.isNotEmpty)
                                                const Padding(
                                                  padding: EdgeInsets.only(bottom: 8.0),
                                                  child: Text(
                                                    "Cast",
                                                    style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),
                                                  ),
                                                ),
                                              if (state.actorDetails.tvCredits.cast.isNotEmpty)
                                                Container(
                                                  height: 230,
                                                  padding: const EdgeInsets.only(right: 8.0),
                                                  child: ListView.builder(
                                                    shrinkWrap: true,
                                                    scrollDirection: Axis.horizontal,
                                                    itemCount: state.actorDetails.tvCredits.cast.length,
                                                    itemBuilder: (context, index) {
                                                      return Padding(
                                                        padding: EdgeInsets.only(
                                                          left: index > 0 ? 8.0 : 0.0,
                                                          bottom: 8.0,
                                                          right: 8.0,
                                                        ),
                                                        child: InkWell(
                                                          onTap: () {
                                                            //Had to add .then and call setState, so that the first page is refreshed if it is popped back, from the second page where the Navigator
                                                            //is going to push right now (otherwise each page will have the identical MovieDetails)
                                                            Navigator.of(context, rootNavigator: false)
                                                                .push(
                                                              MaterialPageRoute(
                                                                builder: (context) => TvShowDetailsPage(
                                                                  tvShowName: state.actorDetails.tvCredits.cast[index].tvShowSummary.name,
                                                                  tvShowId: state.actorDetails.tvCredits.cast[index].tvShowSummary.id,
                                                                ),
                                                              ),
                                                            )
                                                                .then(
                                                                  (value) => setState(
                                                                    () {
                                                                  sendEvent();
                                                                },
                                                              ),
                                                            );
                                                          },
                                                          child: Container(
                                                            width: 90,
                                                            child: Column(
                                                              children: [
                                                                BuildPosterImage(
                                                                  height: 135,
                                                                  width: 90,
                                                                  imagePath: state.actorDetails.tvCredits.cast[index].tvShowSummary.posterPath,
                                                                ),
                                                                Padding(
                                                                  padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
                                                                  child: Text(
                                                                    state.actorDetails.tvCredits.cast[index].tvShowSummary.name,
                                                                    overflow: TextOverflow.ellipsis,
                                                                    textAlign: TextAlign.center,
                                                                    maxLines: 2,
                                                                    style: TextStyle(
                                                                      fontSize: 14,
                                                                      fontWeight: FontWeight.w500,
                                                                    ),
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  child: Text(
                                                                    state.actorDetails.tvCredits.cast[index].character,
                                                                    overflow: TextOverflow.ellipsis,
                                                                    textAlign: TextAlign.center,
                                                                    maxLines: 2,
                                                                    style: TextStyle(
                                                                      fontSize: 12,
                                                                      fontWeight: FontWeight.w300,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                              if (state.actorDetails.tvCredits.crew.isNotEmpty)
                                                const Padding(
                                                  padding: EdgeInsets.only(bottom: 8.0),
                                                  child: Text(
                                                    "Crew",
                                                    style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),
                                                  ),
                                                ),
                                              if (state.actorDetails.tvCredits.crew.isNotEmpty)
                                                Container(
                                                  height: 230,
                                                  padding: const EdgeInsets.only(right: 8.0),
                                                  child: ListView.builder(
                                                    shrinkWrap: true,
                                                    scrollDirection: Axis.horizontal,
                                                    itemCount: state.actorDetails.tvCredits.crew.length,
                                                    itemBuilder: (context, index) {
                                                      return Padding(
                                                        padding: EdgeInsets.only(
                                                          left: index > 0 ? 8.0 : 0.0,
                                                          bottom: 8.0,
                                                          right: 8.0,
                                                        ),
                                                        child: InkWell(
                                                          onTap: () {
                                                            //Had to add .then and call setState, so that the first page is refreshed if it is popped back, from the second page where the Navigator
                                                            //is going to push right now (otherwise each page will have the identical MovieDetails)
                                                            Navigator.of(context, rootNavigator: false)
                                                                .push(
                                                              MaterialPageRoute(
                                                                builder: (context) => TvShowDetailsPage(
                                                                  tvShowName: state.actorDetails.tvCredits.crew[index].tvShowSummary.name,
                                                                  tvShowId: state.actorDetails.tvCredits.crew[index].tvShowSummary.id,
                                                                ),
                                                              ),
                                                            )
                                                                .then(
                                                                  (value) => setState(
                                                                    () {
                                                                  sendEvent();
                                                                },
                                                              ),
                                                            );
                                                          },
                                                          child: Container(
                                                            width: 90,
                                                            child: Column(
                                                              children: [
                                                                BuildPosterImage(
                                                                  height: 135,
                                                                  width: 90,
                                                                  imagePath: state.actorDetails.tvCredits.crew[index].tvShowSummary.posterPath,
                                                                ),
                                                                Padding(
                                                                  padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
                                                                  child: Text(
                                                                    state.actorDetails.tvCredits.crew[index].tvShowSummary.name,
                                                                    overflow: TextOverflow.ellipsis,
                                                                    textAlign: TextAlign.center,
                                                                    maxLines: 2,
                                                                    style: TextStyle(
                                                                      fontSize: 14,
                                                                      fontWeight: FontWeight.w500,
                                                                    ),
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  child: Text(
                                                                    state.actorDetails.tvCredits.crew[index].job,
                                                                    overflow: TextOverflow.ellipsis,
                                                                    textAlign: TextAlign.center,
                                                                    maxLines: 2,
                                                                    style: TextStyle(
                                                                      fontSize: 12,
                                                                      fontWeight: FontWeight.w300,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),


                                    ],
                                    options: CarouselOptions(
                                        height: MediaQuery.of(context).size.height*0.85 ,
                                        viewportFraction: 1,
                                        enableInfiniteScroll: false,
                                        reverse: false,
                                        autoPlay: false,
                                        enlargeCenterPage: false,
                                        scrollDirection: Axis.horizontal,
                                        onPageChanged: (index, reason) {
                                          setState(() {
                                           // _current = index;
                                          });
                                        }),
                                  )
                                ],
                              ),

                              ///MOVIES
                              // Padding(
                              //   padding: const EdgeInsets.only(top: 8.0),
                              //   child: Row(
                              //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              //     children: [
                              //       const Text(
                              //         "Movies",
                              //         style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                              //       ),
                              //       TextButton(
                              //           style: TextButton.styleFrom(
                              //             primary: Color(0xFF96baff),
                              //           ),
                              //           onPressed: () {
                              //             //Had to add .then and call setState, so that the first page is refreshed if it is popped back, from the second page where the Navigator
                              //             //is going to push right now (otherwise each page will have the identical MovieDetails)
                              //             Navigator.of(context, rootNavigator: false)
                              //                 .push(
                              //                   MaterialPageRoute(
                              //                     builder: (context) => ActorAllMoviesPage(
                              //                       actorName: state.actorDetails.name,
                              //                       movieCredits: state.actorDetails.movieCredits,
                              //                     ),
                              //                   ),
                              //                 )
                              //                 .then(
                              //                   (value) => setState(
                              //                     () {
                              //                       sendEvent();
                              //                     },
                              //                   ),
                              //                 );
                              //           },
                              //           child: Text("SEE ALL")),
                              //     ],
                              //   ),
                              // ),
                              // if (state.actorDetails.movieCredits.cast.isNotEmpty)
                              //   const Padding(
                              //     padding: EdgeInsets.only(bottom: 8.0),
                              //     child: Text(
                              //       "Cast",
                              //       style: TextStyle(fontWeight: FontWeight.w300),
                              //     ),
                              //   ),
                              // if (state.actorDetails.movieCredits.cast.isNotEmpty)
                              //   Container(
                              //     height: 230,
                              //     padding: const EdgeInsets.only(right: 8.0),
                              //     child: ListView.builder(
                              //       shrinkWrap: true,
                              //       scrollDirection: Axis.horizontal,
                              //       itemCount: state.actorDetails.movieCredits.cast.length,
                              //       itemBuilder: (context, index) {
                              //         return Padding(
                              //           padding: EdgeInsets.only(
                              //             left: index > 0 ? 8.0 : 0.0,
                              //             bottom: 8.0,
                              //             right: 8.0,
                              //           ),
                              //           child: InkWell(
                              //             onTap: () {
                              //               //Had to add .then and call setState, so that the first page is refreshed if it is popped back, from the second page where the Navigator
                              //               //is going to push right now (otherwise each page will have the identical MovieDetails)
                              //               Navigator.of(context, rootNavigator: false)
                              //                   .push(
                              //                     MaterialPageRoute(
                              //                       builder: (context) => MovieDetailsPage(
                              //                         movieId: state.actorDetails.movieCredits.cast[index].movieSummary.id,
                              //                         movieTitle: state.actorDetails.movieCredits.cast[index].movieSummary.title,
                              //                       ),
                              //                     ),
                              //                   )
                              //                   .then(
                              //                     (value) => setState(
                              //                       () {
                              //                         sendEvent();
                              //                       },
                              //                     ),
                              //                   );
                              //             },
                              //             child: Container(
                              //               width: 90,
                              //               child: Column(
                              //                 children: [
                              //                   BuildPosterImage(
                              //                     height: 135,
                              //                     width: 90,
                              //                     imagePath: state.actorDetails.movieCredits.cast[index].movieSummary.posterPath,
                              //                   ),
                              //                   Padding(
                              //                     padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
                              //                     child: Text(
                              //                       state.actorDetails.movieCredits.cast[index].movieSummary.title,
                              //                       overflow: TextOverflow.ellipsis,
                              //                       textAlign: TextAlign.center,
                              //                       maxLines: 2,
                              //                       style: TextStyle(
                              //                         fontSize: 14,
                              //                         fontWeight: FontWeight.w500,
                              //                       ),
                              //                     ),
                              //                   ),
                              //                   Expanded(
                              //                     child: Text(
                              //                       state.actorDetails.movieCredits.cast[index].character,
                              //                       overflow: TextOverflow.ellipsis,
                              //                       textAlign: TextAlign.center,
                              //                       maxLines: 2,
                              //                       style: TextStyle(
                              //                         fontSize: 12,
                              //                         fontWeight: FontWeight.w300,
                              //                       ),
                              //                     ),
                              //                   ),
                              //                 ],
                              //               ),
                              //             ),
                              //           ),
                              //         );
                              //       },
                              //     ),
                              //   ),
                              //
                              // if (state.actorDetails.movieCredits.crew.isNotEmpty)
                              //   const Padding(
                              //     padding: EdgeInsets.only(bottom: 8.0),
                              //     child: Text(
                              //       "Crew",
                              //       style: TextStyle(fontWeight: FontWeight.w300),
                              //     ),
                              //   ),
                              // if (state.actorDetails.movieCredits.crew.isNotEmpty)
                              //   Container(
                              //     height: 230,
                              //     padding: const EdgeInsets.only(right: 8.0),
                              //     child: ListView.builder(
                              //       shrinkWrap: true,
                              //       scrollDirection: Axis.horizontal,
                              //       itemCount: state.actorDetails.movieCredits.crew.length,
                              //       itemBuilder: (context, index) {
                              //         return Padding(
                              //           padding: EdgeInsets.only(
                              //             left: index > 0 ? 8.0 : 0.0,
                              //             bottom: 8.0,
                              //             right: 8.0,
                              //           ),
                              //           child: InkWell(
                              //             onTap: () {
                              //               //Had to add .then and call setState, so that the first page is refreshed if it is popped back, from the second page where the Navigator
                              //               //is going to push right now (otherwise each page will have the identical MovieDetails)
                              //               Navigator.of(context, rootNavigator: false)
                              //                   .push(
                              //                     MaterialPageRoute(
                              //                       builder: (context) => MovieDetailsPage(
                              //                         movieId: state.actorDetails.movieCredits.crew[index].movieSummary.id,
                              //                         movieTitle: state.actorDetails.movieCredits.crew[index].movieSummary.title,
                              //                       ),
                              //                     ),
                              //                   )
                              //                   .then(
                              //                     (value) => setState(
                              //                       () {
                              //                         sendEvent();
                              //                       },
                              //                     ),
                              //                   );
                              //             },
                              //             child: Container(
                              //               width: 90,
                              //               child: Column(
                              //                 children: [
                              //                   BuildPosterImage(
                              //                     height: 135,
                              //                     width: 90,
                              //                     imagePath: state.actorDetails.movieCredits.crew[index].movieSummary.posterPath,
                              //                   ),
                              //                   Padding(
                              //                     padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
                              //                     child: Text(
                              //                       state.actorDetails.movieCredits.crew[index].movieSummary.title,
                              //                       overflow: TextOverflow.ellipsis,
                              //                       textAlign: TextAlign.center,
                              //                       maxLines: 2,
                              //                       style: TextStyle(
                              //                         fontSize: 14,
                              //                         fontWeight: FontWeight.w500,
                              //                       ),
                              //                     ),
                              //                   ),
                              //                   Expanded(
                              //                     child: Text(
                              //                       state.actorDetails.movieCredits.crew[index].job,
                              //                       overflow: TextOverflow.ellipsis,
                              //                       textAlign: TextAlign.center,
                              //                       maxLines: 2,
                              //                       style: TextStyle(
                              //                         fontSize: 12,
                              //                         fontWeight: FontWeight.w300,
                              //                       ),
                              //                     ),
                              //                   ),
                              //                 ],
                              //               ),
                              //             ),
                              //           ),
                              //         );
                              //       },
                              //     ),
                              //   ),
                              //
                              // ///TV SHOWS
                              // Padding(
                              //   padding: const EdgeInsets.only(top: 0.0),
                              //   child: Row(
                              //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              //     children: [
                              //       const Text(
                              //         "TV Shows",
                              //         style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                              //       ),
                              //       TextButton(
                              //           style: TextButton.styleFrom(
                              //             primary: Color(0xFF96baff),
                              //           ),
                              //           onPressed: () {
                              //             //Had to add .then and call setState, so that the first page is refreshed if it is popped back, from the second page where the Navigator
                              //             //is going to push right now (otherwise each page will have the identical MovieDetails)
                              //             Navigator.of(context, rootNavigator: false)
                              //                 .push(
                              //                   MaterialPageRoute(
                              //                     builder: (context) => ActorAllTvShowsPage(
                              //                       actorName: state.actorDetails.name,
                              //                       tvCredits: state.actorDetails.tvCredits,
                              //                     ),
                              //                   ),
                              //                 )
                              //                 .then(
                              //                   (value) => setState(
                              //                     () {
                              //                       sendEvent();
                              //                     },
                              //                   ),
                              //                 );
                              //           },
                              //           child: Text("SEE ALL")),
                              //     ],
                              //   ),
                              // ),
                              // if (state.actorDetails.tvCredits.cast.isNotEmpty)
                              //   const Padding(
                              //     padding: EdgeInsets.only(bottom: 8.0),
                              //     child: Text(
                              //       "Cast",
                              //       style: TextStyle(fontWeight: FontWeight.w300),
                              //     ),
                              //   ),
                              // if (state.actorDetails.tvCredits.cast.isNotEmpty)
                              //   Container(
                              //     height: 230,
                              //     padding: const EdgeInsets.only(right: 8.0),
                              //     child: ListView.builder(
                              //       shrinkWrap: true,
                              //       scrollDirection: Axis.horizontal,
                              //       itemCount: state.actorDetails.tvCredits.cast.length,
                              //       itemBuilder: (context, index) {
                              //         return Padding(
                              //           padding: EdgeInsets.only(
                              //             left: index > 0 ? 8.0 : 0.0,
                              //             bottom: 8.0,
                              //             right: 8.0,
                              //           ),
                              //           child: InkWell(
                              //             onTap: () {
                              //               //Had to add .then and call setState, so that the first page is refreshed if it is popped back, from the second page where the Navigator
                              //               //is going to push right now (otherwise each page will have the identical MovieDetails)
                              //               Navigator.of(context, rootNavigator: false)
                              //                   .push(
                              //                     MaterialPageRoute(
                              //                       builder: (context) => TvShowDetailsPage(
                              //                         tvShowName: state.actorDetails.tvCredits.cast[index].tvShowSummary.name,
                              //                         tvShowId: state.actorDetails.tvCredits.cast[index].tvShowSummary.id,
                              //                       ),
                              //                     ),
                              //                   )
                              //                   .then(
                              //                     (value) => setState(
                              //                       () {
                              //                         sendEvent();
                              //                       },
                              //                     ),
                              //                   );
                              //             },
                              //             child: Container(
                              //               width: 90,
                              //               child: Column(
                              //                 children: [
                              //                   BuildPosterImage(
                              //                     height: 135,
                              //                     width: 90,
                              //                     imagePath: state.actorDetails.tvCredits.cast[index].tvShowSummary.posterPath,
                              //                   ),
                              //                   Padding(
                              //                     padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
                              //                     child: Text(
                              //                       state.actorDetails.tvCredits.cast[index].tvShowSummary.name,
                              //                       overflow: TextOverflow.ellipsis,
                              //                       textAlign: TextAlign.center,
                              //                       maxLines: 2,
                              //                       style: TextStyle(
                              //                         fontSize: 14,
                              //                         fontWeight: FontWeight.w500,
                              //                       ),
                              //                     ),
                              //                   ),
                              //                   Expanded(
                              //                     child: Text(
                              //                       state.actorDetails.tvCredits.cast[index].character,
                              //                       overflow: TextOverflow.ellipsis,
                              //                       textAlign: TextAlign.center,
                              //                       maxLines: 2,
                              //                       style: TextStyle(
                              //                         fontSize: 12,
                              //                         fontWeight: FontWeight.w300,
                              //                       ),
                              //                     ),
                              //                   ),
                              //                 ],
                              //               ),
                              //             ),
                              //           ),
                              //         );
                              //       },
                              //     ),
                              //   ),
                              // if (state.actorDetails.tvCredits.crew.isNotEmpty)
                              //   const Padding(
                              //     padding: EdgeInsets.only(bottom: 8.0),
                              //     child: Text(
                              //       "Crew",
                              //       style: TextStyle(fontWeight: FontWeight.w300),
                              //     ),
                              //   ),
                              // if (state.actorDetails.tvCredits.crew.isNotEmpty)
                              //   Container(
                              //     height: 230,
                              //     padding: const EdgeInsets.only(right: 8.0),
                              //     child: ListView.builder(
                              //       shrinkWrap: true,
                              //       scrollDirection: Axis.horizontal,
                              //       itemCount: state.actorDetails.tvCredits.crew.length,
                              //       itemBuilder: (context, index) {
                              //         return Padding(
                              //           padding: EdgeInsets.only(
                              //             left: index > 0 ? 8.0 : 0.0,
                              //             bottom: 8.0,
                              //             right: 8.0,
                              //           ),
                              //           child: InkWell(
                              //             onTap: () {
                              //               //Had to add .then and call setState, so that the first page is refreshed if it is popped back, from the second page where the Navigator
                              //               //is going to push right now (otherwise each page will have the identical MovieDetails)
                              //               Navigator.of(context, rootNavigator: false)
                              //                   .push(
                              //                     MaterialPageRoute(
                              //                       builder: (context) => TvShowDetailsPage(
                              //                         tvShowName: state.actorDetails.tvCredits.crew[index].tvShowSummary.name,
                              //                         tvShowId: state.actorDetails.tvCredits.crew[index].tvShowSummary.id,
                              //                       ),
                              //                     ),
                              //                   )
                              //                   .then(
                              //                     (value) => setState(
                              //                       () {
                              //                         sendEvent();
                              //                       },
                              //                     ),
                              //                   );
                              //             },
                              //             child: Container(
                              //               width: 90,
                              //               child: Column(
                              //                 children: [
                              //                   BuildPosterImage(
                              //                     height: 135,
                              //                     width: 90,
                              //                     imagePath: state.actorDetails.tvCredits.crew[index].tvShowSummary.posterPath,
                              //                   ),
                              //                   Padding(
                              //                     padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
                              //                     child: Text(
                              //                       state.actorDetails.tvCredits.crew[index].tvShowSummary.name,
                              //                       overflow: TextOverflow.ellipsis,
                              //                       textAlign: TextAlign.center,
                              //                       maxLines: 2,
                              //                       style: TextStyle(
                              //                         fontSize: 14,
                              //                         fontWeight: FontWeight.w500,
                              //                       ),
                              //                     ),
                              //                   ),
                              //                   Expanded(
                              //                     child: Text(
                              //                       state.actorDetails.tvCredits.crew[index].job,
                              //                       overflow: TextOverflow.ellipsis,
                              //                       textAlign: TextAlign.center,
                              //                       maxLines: 2,
                              //                       style: TextStyle(
                              //                         fontSize: 12,
                              //                         fontWeight: FontWeight.w300,
                              //                       ),
                              //                     ),
                              //                   ),
                              //                 ],
                              //               ),
                              //             ),
                              //           ),
                              //         );
                              //       },
                              //     ),
                              //   ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
