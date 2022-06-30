import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'package:http/http.dart';
import 'package:dio/dio.dart';
import 'package:bingeit/presentation/pages/profile_page/post_page/comments/neePage.dart';
import 'package:animated_size_and_fade/animated_size_and_fade.dart';
import 'package:bingeit/application/user_profile_information/current_user_profile_information/current_user_profile_information_bloc.dart';
import 'package:bingeit/constants.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:community_material_icon/community_material_icon.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:bingeit/application/feedback/block_user/block_user_bloc.dart';
import 'package:bingeit/application/feedback/report/report_bloc.dart';
import 'package:bingeit/application/user_post/global_news_feed/global_news_feed_bloc.dart';
import 'package:bingeit/application/user_post/user_news_feed/user_news_feed_bloc.dart';
import 'package:bingeit/application/user_post/user_post_bloc.dart';
import 'package:bingeit/application/user_profile_information/current_user_profile_information/current_user_profile_watchlist_watched/movie_lists/movie_lists_user_profile_bloc.dart';
import 'package:bingeit/application/user_profile_information/current_user_profile_information/current_user_profile_watchlist_watched/tv_show_lists/tv_show_lists_user_profile_bloc.dart';
import 'package:bingeit/application/user_profile_information/other_user_profile_information/other_user_profile_information_bloc.dart';
import 'package:bingeit/data/user_profile_db/other_user_profile_db/other_user_profile_repository.dart';
import 'package:bingeit/data/user_profile_db/user_actions_db/user_actions_repository.dart';
import 'package:bingeit/presentation/pages/movie_details_page/movie_details_page.dart';
import 'package:bingeit/presentation/pages/profile_page/other_user_page/other_user_profile_page.dart';
import 'package:bingeit/presentation/pages/profile_page/post_page/post_comments_page.dart';
import 'package:bingeit/presentation/pages/profile_page/post_page/post_likers_page.dart';
import 'package:bingeit/presentation/pages/profile_page/post_page/post_page.dart';
import 'package:bingeit/presentation/pages/tv_show_details_page/tv_show_details_page.dart';
import 'package:bingeit/presentation/utilities/utilities.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bingeit/notifications/pushNotif.dart';
import 'package:google_fonts/google_fonts.dart';

Future<void> saveTokenToDatabase(String token) async {
  // Assume user is logged in for this example
  String userId = FirebaseAuth.instance.currentUser.uid;

  await FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .update({
    'tokens': token,
  });
}
Future<void> _messageHandler(RemoteMessage message) async {
  print('background message ${message.notification.body}');
}

class NewsFeedPage extends StatefulWidget {
  @override
  _NewsFeedPageState createState() => _NewsFeedPageState();
}

class _NewsFeedPageState extends State<NewsFeedPage> with TickerProviderStateMixin {
  final Shader linearGradient = LinearGradient(
    colors: <Color>[Color(0xFF7579E7), Color(0xFF96baff)],
  ).createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 70.0));
  ScrollController _userNewsFeedScrollController;
  ScrollController _globalNewsFeedScrollController;
  UserActionsRepository _userActionsRepository;
  OtherUserProfileRepository _otherUserProfileRepository;
  Completer<void> _refreshCompleter;
  TabController _tabController;
  final List<Tab> _tabs = <Tab>[
    const Tab(text: "My Feed"),
    const Tab(text: "Worldwide Feed"),
  ];

  @override
  void initState() {
    super.initState();
    _userNewsFeedScrollController = ScrollController();
    _globalNewsFeedScrollController = ScrollController();
    _userActionsRepository = UserActionsRepository();
    _otherUserProfileRepository = OtherUserProfileRepository();
    _refreshCompleter = Completer<void>();
    _tabController = TabController(initialIndex: 0, vsync: this, length: _tabs.length);
  }

  @override
  void dispose() {
    _userNewsFeedScrollController.dispose();
    _globalNewsFeedScrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  //If at end of the Listview, search for more reviews
  bool _handleUserNewsFeedScrollNotification(ScrollNotification notification) {
    if (notification is ScrollEndNotification && _userNewsFeedScrollController.position.extentAfter == 0) {
      print("Calling fetch next user news feed page");
      context.read<UserNewsFeedBloc>().add(
            UserNewsFeedEvent.loadReviewsPressedNextPage(),
          );
    }
    return false;
  }

  //If at end of the Listview, search for more reviews
  bool _handleGlobalNewsFeedScrollNotification(ScrollNotification notification) {
    if (notification is ScrollEndNotification && _globalNewsFeedScrollController.position.extentAfter == 0) {
      print("Calling fetch next global news feed page");
      context.read<GlobalNewsFeedBloc>().add(
            GlobalNewsFeedEvent.loadReviewsPressedNextPage(),
          );
    }
    return false;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1B1E2B),
      body: SafeArea(
        child: BlocListener<ReportBloc, ReportState>(
          listener: (context, reportState) {
            if (reportState.errorMessage.isNotEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(reportState.errorMessage),
                  duration: Duration(seconds: 2),
                ),
              );
            }
          },
          child: BlocListener<MovieListsUserProfileBloc, MovieListsUserProfileState>(
            listener: (context, movieListState) {
              if (movieListState.errorMessage.isNotEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(movieListState.errorMessage),
                    duration: Duration(seconds: 1),
                  ),
                );
              }
            },
            child: BlocListener<TvShowListsUserProfileBloc, TvShowListsUserProfileState>(
              listener: (context, tvShowListState) {
                if (tvShowListState.errorMessage.isNotEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(tvShowListState.errorMessage),
                      duration: Duration(seconds: 1),
                    ),
                  );
                }
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top : 5.0, left :15.0),
                        child:   Row(
                          children: [
                            // Text(
                            //   "Binge",
                            //   style: GoogleFonts.lexendGiga(
                            //       fontSize: 30.0,
                            //       letterSpacing: 0.005,
                            //       fontWeight: FontWeight.bold,
                            //       color: Color(0xffB1D0E0),
                            //   ),
                            //
                            // ),
                            // Text(
                            //   "it",
                            //   style: GoogleFonts.lexendGiga(
                            //       fontSize: 30.0,
                            //       letterSpacing: 0.005,
                            //       fontWeight: FontWeight.bold,
                            //     color: Color(0xff6398ff),
                            //   ),
                            //
                            // ),
                            Image.asset('assets/images/logo.png', height: 35,),
                          ],
                        ),
                      ),


                    ]
                  ),
                  TabBar(
                    controller: _tabController,
                    tabs: _tabs,
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: _tabViews(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _tabViews(BuildContext context) {
    List<Widget> views = <Widget>[
      _buildUserNewsFeed(context),
      _buildGlobalNewsFeed(context),
    ];
    return views;
  }

  Widget _buildUserNewsFeed(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () {
        context.read<UserNewsFeedBloc>().add(
              UserNewsFeedEvent.refreshReviewsPressed(),
            );
        return _refreshCompleter.future;
      },
      child: BlocConsumer<UserNewsFeedBloc, UserNewsFeedState>(
        listener: (context, state) {
          if (!state.isRefreshingReviews) {
            _refreshCompleter?.complete();
            _refreshCompleter = Completer();
          }
        },
        builder: (context, state) {
          //Have to give A Container with such size to stop bad scrolling inside the listview.builder
          return state.isLoadingReviews
              ? Container(
                  height: MediaQuery.of(context).size.width * 1.5,
                  color: Color(0xFF222831),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              : NotificationListener<ScrollNotification>(
                  onNotification: _handleUserNewsFeedScrollNotification,
                  child: state.reviews.isEmpty
                      ?  Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(30.0),
                child: Center(
                  child: Text("Follow your friends to see what they are up to.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 20,
                        color: Color(0xff476072),
                        fontWeight: FontWeight.bold
                    ),),
                ),
              ),
            ],
          )
                      : ListView.builder(
                          cacheExtent: 5 * MediaQuery.of(context).size.height,
                          physics: const AlwaysScrollableScrollPhysics(),
                          controller: _userNewsFeedScrollController,
                          itemCount: _calculateUserNewsFeedListLength(state),
                          itemBuilder: (context, index) {
                            if (index >= state.reviews.length) {
                              return BuildLoaderNextPage();
                            } else {
                              String postOwnerUid = state.reviews[index].postOwnerUid;
                              String postUid = state.reviews[index].postUid;
                              return BlocBuilder<BlockUserBloc, BlockUserState>(
                                builder: (context, userBlockState) {
                                  return userBlockState.blockedUsers.contains(postOwnerUid) ||
                                          userBlockState.usersBlockedBy.contains(postOwnerUid)
                                      ? SizedBox(width: 0, height: 0)
                                      : BlocProvider(
                                          create: (context) => UserPostBloc(
                                            _userActionsRepository,
                                          ),
                                          child: BlocProvider(
                                            create: (context) => OtherUserProfileInformationBloc(
                                              _otherUserProfileRepository,
                                            ),
                                            child: _UserNewsFeedReview(
                                              postOwnerUid: postOwnerUid,
                                              postUid: postUid,
                                              key: ValueKey(postUid),
                                            ),
                                          ),
                                        );
                                },
                              );
                            }
                          },
                        ),
                );
        },
      ),
    );
  }

  int _calculateUserNewsFeedListLength(UserNewsFeedState state) {
    if (state.isThereMoreReviewsToLoad) {
      return state.reviews.length + 1;
    } else {
      return state.reviews.length;
    }
  }

  Widget _buildGlobalNewsFeed(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () {
        context.read<GlobalNewsFeedBloc>().add(
              GlobalNewsFeedEvent.refreshReviewsPressed(),
            );
        return _refreshCompleter.future;
      },
      child: BlocConsumer<GlobalNewsFeedBloc, GlobalNewsFeedState>(
        listener: (context, state) {
          if (!state.isRefreshingReviews) {
            _refreshCompleter?.complete();
            _refreshCompleter = Completer();
          }
        },
        builder: (context, state) {
          return state.isLoadingReviews
              ? Container(
                  height: MediaQuery.of(context).size.width * 1.5,
                  color: Color(0xFF222831),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              : NotificationListener<ScrollNotification>(
                  onNotification: _handleGlobalNewsFeedScrollNotification,
                  child: state.reviews.isEmpty
                      ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(30.0),
                        child: Center(
                          child: Text("Other user's reviews will show up here.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 20,
                                color: Color(0xff476072),
                                fontWeight: FontWeight.bold
                            ),),
                        ),
                      ),
                    ],
                  )

                      : ListView.builder(
                          cacheExtent: 5 * MediaQuery.of(context).size.height,
                          physics: const AlwaysScrollableScrollPhysics(),
                          controller: _globalNewsFeedScrollController,
                          itemCount: _calculateGlobalNewsFeedListLength(state),
                          itemBuilder: (context, index) {
                            if (index >= state.reviews.length) {
                              return BuildLoaderNextPage();
                            } else {
                              String postOwnerUid = state.reviews[index].postOwnerUid;
                              String postUid = state.reviews[index].postUid;
                              return BlocBuilder<BlockUserBloc, BlockUserState>(
                                builder: (context, userBlockState) {
                                  return userBlockState.blockedUsers.contains(postOwnerUid) ||
                                          userBlockState.usersBlockedBy.contains(postOwnerUid)
                                      ? SizedBox(width: 0, height: 0)
                                      : BlocProvider(
                                          create: (context) => UserPostBloc(
                                            _userActionsRepository,
                                          ),
                                          child: BlocProvider(
                                            create: (context) => OtherUserProfileInformationBloc(
                                              _otherUserProfileRepository,
                                            ),
                                            child: _UserNewsFeedReview(
                                              postOwnerUid: postOwnerUid,
                                              postUid: postUid,
                                              key: ValueKey(postUid),
                                            ),
                                          ),
                                        );
                                },
                              );
                            }
                          },
                        ),
                );
        },
      ),
    );
  }

  int _calculateGlobalNewsFeedListLength(GlobalNewsFeedState state) {
    if (state.isThereMoreReviewsToLoad) {
      return state.reviews.length + 1;
    } else {
      return state.reviews.length;
    }
  }
}

/// ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/// UserFeedReviewItem/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/// ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

class _UserNewsFeedReview extends StatefulWidget {
  final String postOwnerUid;
  final String postUid;
  final Key key;

  _UserNewsFeedReview({
    @required this.postOwnerUid,
    @required this.postUid,
    @required this.key,
  });

  @override
  _UserNewsFeedReviewState createState() => _UserNewsFeedReviewState();
}

class _UserNewsFeedReviewState extends State<_UserNewsFeedReview> with TickerProviderStateMixin {
  bool isReviewExpanded = false;
  bool toggleHeartIconAnimation = false;

  @override
  void initState() {
    super.initState();
    context.read<UserPostBloc>().add(
          UserPostEvent.loadPostPressed(
            postOwnerUid: widget.postOwnerUid,
            postUid: widget.postUid,
          ),
        );
    context.read<OtherUserProfileInformationBloc>().add(
          OtherUserProfileInformationEvent.otherUserProfileLoaded(
            otherUserUid: widget.postOwnerUid,
          ),
        );
  }

  //Method to call when Navigator.pop is called, to update the page
  void sendEvent() {
    context.read<UserPostBloc>().add(
          UserPostEvent.loadPostPressed(
            postOwnerUid: widget.postOwnerUid,
            postUid: widget.postUid,
          ),
        );
    context.read<OtherUserProfileInformationBloc>().add(
          OtherUserProfileInformationEvent.otherUserProfileLoaded(
            otherUserUid: widget.postOwnerUid,
          ),
        );
  }

  void updateHeartIconAnimation() {
    setState(() {
      toggleHeartIconAnimation = !toggleHeartIconAnimation;
    });
  }

  Widget _buildConfirmUnlikeDialog({@required UserPostBloc bloc}) {
    return AlertDialog(
      title: Text("Are you sure you want to unlike this post?"),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop();
          },
          style: TextButton.styleFrom(
            primary: Color(0xFF96baff),
          ),
          child: Text("No"),
        ),
        TextButton(
          onPressed: () {
            bloc.add(
              UserPostEvent.unlikePostPressed(postOwnerUid: widget.postOwnerUid, postUid: widget.postUid),
            );
            Navigator.of(context, rootNavigator: true).pop();
          },
          style: TextButton.styleFrom(
            primary: Color(0xFF96baff),
          ),
          child: Text("Yes"),
        ),
      ],
    );
  }

  Widget _buildEditPostActionsDialog({
    UserPostBloc userPostBloc,
    MovieListsUserProfileBloc movieListsUserProfileBloc,
    TvShowListsUserProfileBloc tvShowListsUserProfileBloc,
    @required UserPostState state,
  }) {
    return SimpleDialog(
      children: [
        SimpleDialogOption(
          padding: EdgeInsets.all(16),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) {
                return _BuildUpdateReviewDialog(
                  state: state,
                  movieListsBloc: movieListsUserProfileBloc,
                  tvShowListsUserProfileBloc: tvShowListsUserProfileBloc,
                );
              },
            ).then((value) {
              userPostBloc.add(
                UserPostEvent.loadPostPressed(
                  postOwnerUid: widget.postOwnerUid,
                  postUid: widget.postUid,
                ),
              );
            });
          },
          child: Text(
            "Edit Review",
            textAlign: TextAlign.center,
          ),
        ),
        SimpleDialogOption(
          padding: EdgeInsets.all(16),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) {
                return _buildConfirmDeletePostDialog(
                  state: state,
                  movieListsBloc: movieListsUserProfileBloc,
                  tvShowListsUserProfileBloc: tvShowListsUserProfileBloc,
                );
              },
            );
          },
          child: Text(
            "Delete Review",
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmDeletePostDialog({
    MovieListsUserProfileBloc movieListsBloc,
    TvShowListsUserProfileBloc tvShowListsUserProfileBloc,
    @required UserPostState state,
  }) {
    return AlertDialog(
      title:
          Text("Are you sure you want to delete this post?\nAll the comments will be deleted and this action cannot be undone."),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop();
          },
          style: TextButton.styleFrom(
            primary: Color(0xFF96baff),
          ),
          child: Text("No"),
        ),
        TextButton(
          onPressed: () {
            state.userPost.isOfTypeMovie
                ? movieListsBloc.add(
                    MovieListsUserProfileEvent.removeMovieFromWatchedPressed(
                      movieTitle: state.userPost.title,
                      movieId: state.userPost.tmdbId,
                    ),
                  )
                : tvShowListsUserProfileBloc.add(
                    TvShowListsUserProfileEvent.removeTvShowFromWatchedPressed(
                      tvShowTitle: state.userPost.title,
                      tvShowId: state.userPost.tmdbId,
                    ),
                  );
            Navigator.of(context, rootNavigator: true).pop();
            Navigator.of(context, rootNavigator: true).pop();
            //Refresh news feed
            context.read<GlobalNewsFeedBloc>().add(
                  GlobalNewsFeedEvent.refreshReviewsPressed(),
                );
            context.read<UserNewsFeedBloc>().add(
                  UserNewsFeedEvent.refreshReviewsPressed(),
                );
          },
          style: TextButton.styleFrom(
            primary: Color(0xFF96baff),
          ),
          child: Text("Yes"),
        ),
      ],
    );
  }

  Widget _reportPostDialogConfirmation({
    @required String otherUserUid,
    @required String postUid,
    @required String postText,
    @required ReportBloc bloc,
  }) {
    return SimpleDialog(
      children: [
        SimpleDialogOption(
          padding: EdgeInsets.all(16),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) {
                return ReportPostDialog(
                  otherUserUid: otherUserUid,
                  postUid: postUid,
                  postText: postText,
                  bloc: bloc,
                );
              },
            );
          },
          child: Text(
            "Report Post",
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OtherUserProfileInformationBloc, OtherUserProfileInformationState>(
      builder: (context, userState) {
        return BlocConsumer<UserPostBloc, UserPostState>(
          listener: (context, state) {
            if (state.errorMessage.isNotEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage),
                  duration: Duration(seconds: 2),
                ),
              );
            }
          },
          builder: (context, state) {
            if (state.isLoadingPost || userState.isSearching) {
              return Container(
                height: MediaQuery.of(context).size.width * 1.5,
                color: Color(0xFF222831),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              );
            } else {
              if (state.userPost.posterPath.isEmpty || userState.ourUser.uid.isEmpty) {
                return SizedBox(width: 0, height: 0);
              } else {
                return Padding(
                  padding: const EdgeInsets.only(top: 12.0, bottom: 6.0 ),
                  child: Container(
                    // decoration: BoxDecoration(
                    //   border: Border.all(
                    //     color: Color(0xFFB8B5FF),
                    //     width: 5,
                    //   ),
                    //   //borderRadius: BorderRadius.circular(10),
                    //   boxShadow: [
                    //     new BoxShadow(
                    //       color: Color(0xFF7868E6),
                    //       offset: new Offset(2.0, 2.0),
                    //     ),
                    //   ],
                    // ),

                    child: Expanded(
                      child: Column(

                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(left : 15.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      GestureDetector(
                                        behavior: HitTestBehavior.opaque,
                                        onTap: () {
                                          Navigator.of(context)
                                              .push(
                                                MaterialPageRoute(
                                                  builder: (context) => OtherUserProfilePage(otherUserUid: widget.postOwnerUid),
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

                                              child: Material(
                                                elevation: 10,
                                                borderRadius: const BorderRadius.all(
                                                  Radius.circular(20.0),
                                                ),
                                                child:
                                                BuildProfilePhotoAvatar(profilePhotoUrl: userState.ourUser.profilePhotoUrl, radius: 20),
                                              ),



                                      ),
                                      Column(

                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(left : 10.0),
                                            child: Text(
                                              userState.ourUser.username,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),

                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              IconButton(
                                icon: Icon(Icons.more_horiz_rounded),
                                onPressed: () {
                                  // ignore: close_sinks
                                  final movieBloc = BlocProvider.of<MovieListsUserProfileBloc>(context, listen: false);
                                  // ignore: close_sinks
                                  final tvShowBloc = BlocProvider.of<TvShowListsUserProfileBloc>(context, listen: false);
                                  // ignore: close_sinks
                                  final userPostBloc = BlocProvider.of<UserPostBloc>(context, listen: false);
                                  // ignore: close_sinks
                                  final reportBloc = BlocProvider.of<ReportBloc>(context, listen: false);

                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return state.isCurrentUserOwnerOfPost
                                          ? _buildEditPostActionsDialog(
                                              userPostBloc: userPostBloc,
                                              movieListsUserProfileBloc: movieBloc,
                                              tvShowListsUserProfileBloc: tvShowBloc,
                                              state: state,
                                            )
                                          : _reportPostDialogConfirmation(
                                              otherUserUid: widget.postOwnerUid,
                                              postUid: widget.postUid,
                                              postText: state.userPost.review,
                                              bloc: reportBloc,
                                            );
                                    },
                                  );
                                },
                              ),
                            ],
                          ),

                          GestureDetector(
                            onDoubleTap: () async {
                              updateHeartIconAnimation();
                              Future.delayed(Duration(milliseconds: 1000), () {
                                updateHeartIconAnimation();
                              });
                              // if (!state.isPostLiked) {
                              //   String tok;
                              //   FirebaseFirestore.instance
                              //       .collection('users')
                              //       .doc(widget.postOwnerUid.toString())
                              //       .get()
                              //       .then((DocumentSnapshot documentSnapshot) {
                              //     if (documentSnapshot.exists) {
                              //       tok=documentSnapshot['tokens'].toString();
                              //       print(tok);
                              //     } else {
                              //       print('Document does not exist on the database');
                              //     }
                              //   });
                              //   String userId = FirebaseAuth.instance.currentUser.displayName;
                              //   String mssg=userId;
                              //   print(mssg);
                              //   var dio = Dio();
                              //   var response =  await dio.post('https://fcm.googleapis.com/fcm/send',
                              //     options: Options(
                              //       headers: {
                              //         "content-type": "application/json",
                              //         "Authorization": "key=AAAA47z86Vw:APA91bGbR_p5ZUQ1QvQqUwzW079EG2FM6dvLQEyhie3aXIvcGTtAk6OjBRzCse4GpuDIKQQqeWM4pE4lKqcbbss26dsEvX0DUyUz-vr7s7iwH1FvqDiFa2SUpka8e9OQTVaHUPh3tE85"
                              //       },
                              //     ),
                              //     data: jsonEncode(
                              //         {
                              //           "to" : "$tok",
                              //           "notification" : {
                              //             "body" : "New Notification",
                              //             "title": "$mssg",
                              //             "sound": "Tri-tone"
                              //           },
                              //           "data": {
                              //             "click_action": "FLUTTER_NOTIFICATION_CLICK",
                              //             "id": "1",
                              //             "status": "done"
                              //           },
                              //
                              //         }
                              //     ),
                              //   );
                              //   print(response.statusCode);
                              //
                              //
                              // }
                              if (!state.isPostLiked) {

                                context.read<UserPostBloc>().add(
                                  UserPostEvent.likePostPressed(
                                    postOwnerUid: widget.postOwnerUid,
                                    postUid: widget.postUid,
                                    postPhotoUrl: state.userPost.posterPath,
                                  ),
                                );

                                sendit(widget.postOwnerUid, " liked your post - " + state.userPost.title);

                              }

                            },
                            child: Stack(
                              alignment: AlignmentDirectional.center,
                              children: [
                                BuildPosterImage(
                                  resolution: "w780",
                                  height: MediaQuery.of(context).size.width * 0.7* 1.5,
                                  width: MediaQuery.of(context).size.width * 0.7,
                                  imagePath: state.userPost.posterPath,
                                ),
                                AnimatedSizeAndFade.showHide(
                                  show: toggleHeartIconAnimation,
                                  vsync: this,
                                  child: Icon(
                                    Icons.favorite,
                                    color: Colors.red,
                                    size: MediaQuery.of(context).size.width * 0.25,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top : 10.0, left : 15.0 , right:  15.0),
                            child: Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      style: kWatchedButton ,
                                      onPressed: () {
                                        state.userPost.isOfTypeMovie
                                            ? Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) => MovieDetailsPage(
                                              movieId: state.userPost.tmdbId,
                                              movieTitle: state.userPost.title,
                                            ),
                                          ),
                                        )
                                            : Navigator.of(context)
                                            .push(
                                          MaterialPageRoute(
                                            builder: (context) => TvShowDetailsPage(
                                              tvShowName: state.userPost.title,
                                              tvShowId: state.userPost.tmdbId,
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
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                        state.userPost.title,
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  )
                                ],

                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    IconButton(
                                      padding: EdgeInsets.only(),
                                      icon: state.isPostLiked
                                          ? const Icon(
                                              Icons.favorite,
                                              color: Colors.red,
                                            )
                                          : const Icon(
                                              Icons.favorite_border,
                                              //color: Colors.black,
                                            ),
                                      onPressed: () async {
                                        // ignore: close_sinks
                                        final bloc = BlocProvider.of<UserPostBloc>(context, listen: false);
                                          if(state.isPostLiked) {
                                            showDialog(
                                              context: context,
                                              builder: (context) {
                                                return _buildConfirmUnlikeDialog(
                                                    bloc: bloc);
                                              },
                                            );
                                          } else {
                                              context.read<UserPostBloc>().add(
                                                UserPostEvent.likePostPressed(
                                                  postOwnerUid: widget
                                                      .postOwnerUid,
                                                  postUid: widget.postUid,
                                                  postPhotoUrl: state.userPost
                                                      .posterPath,
                                                ),
                                              );
                                              sendit(widget.postOwnerUid, " liked your post - " + state.userPost.title);

                                          }





                                      },
                                    ),
                                    InkWell(
                                      onTap: () {
                                        Navigator.of(context)
                                            .push(
                                              MaterialPageRoute(
                                                builder: (context) => PostLikersPage(
                                                  postOwnerUid: widget.postOwnerUid,
                                                  postUid: widget.postUid,
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
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                          right: 8.0,
                                          bottom: 8.0,
                                          top: 8.0,
                                        ),
                                        child: Text(
                                          convertNumberOfLikesAndComments(state.numberOfLikes),
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      padding: EdgeInsets.only(),
                                      icon: const Icon(
                                        Icons.people_alt_outlined,
                                      ),
                                      onPressed: () {
                                        Navigator.of(context)
                                            .push(
                                              MaterialPageRoute(
                                                builder: (context) => PostCommentsPage(
                                                  postOwnerUid: widget.postOwnerUid,
                                                  postUid: widget.postUid,
                                                  postOwnerUsername: userState.ourUser.username,
                                                  postOwnerProfilePhoto: userState.ourUser.profilePhotoUrl,
                                                  postOwnerRating: state.userPost.rating,
                                                  postOwnerReview: state.userPost.review,
                                                  isPostSpoiler: state.isSpoiler,
                                                  postCreationDate: state.userPost.postCreationDate,
                                                  isKeyboardFocused: true,
                                                  postPhotoUrl: state.userPost.posterPath,
                                                  postTitle:state.userPost.title
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
                                    ),
                                    InkWell(
                                      onTap: () {
                                        Navigator.of(context)
                                            .push(
                                              MaterialPageRoute(
                                                builder: (context) => PostCommentsPage(
                                                  postOwnerUid: widget.postOwnerUid,
                                                  postUid: widget.postUid,
                                                  postOwnerUsername: userState.ourUser.username,
                                                  postOwnerProfilePhoto: userState.ourUser.profilePhotoUrl,
                                                  postOwnerRating: state.userPost.rating,
                                                  postOwnerReview: state.userPost.review,
                                                  isPostSpoiler: state.isSpoiler,
                                                  postCreationDate: state.userPost.postCreationDate,
                                                  isKeyboardFocused: false,
                                                  postPhotoUrl: state.userPost.posterPath,
                                                    postTitle:state.userPost.title
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
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                          right: 8.0,
                                          bottom: 8.0,
                                          top: 8.0,
                                        ),
                                        child: Text(

                                          convertNumberOfLikesAndComments(state.numberOfComments),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            ],
                          ),

                          /// //////////////////////////////////////////////////////////
                          /// Show Add to watchlist and Rate this Buttons inside News feed
                          /// //////////////////////////////////////////////////////////
                          Padding(
                            padding: const EdgeInsets.only(left: 15.0),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Row(
                                children: [
                                  Text(
                                    userState.ourUser.username,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),

                                  ),
                                  Text(
                                    "  rates it  ",
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.normal,
                                    ),

                                  ),
                                  Container(

                                    child: Row(
                                      children: [
                                        Text(
                                          state.userPost.rating.toInt().toString(),
                                          style: TextStyle(
                                            color: Colors.amber,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),

                                        ),
                                        Text(
                                          ' of ',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.normal,
                                          ),

                                        ),
                                        Text(
                                          '10',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.amber,
                                            fontWeight: FontWeight.bold,
                                          ),

                                        )
                                      ],
                                    ),
                                  )



                                ],
                              ),

                            ),
                          ),
                          state.isSpoiler
                              ? OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    primary: Color(0xff476072),
                                  ),
                                  onPressed: () {
                                    context.read<UserPostBloc>().add(
                                          UserPostEvent.showSpoilerPressed(),
                                        );
                                  },
                                  child: Text("This review contains spoilers, press to see"),
                                )
                              : Padding(
                                  padding: const EdgeInsets.only(left: 15.0),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      state.userPost.review,
                                    )

                                  ),
                                ),
                          Padding(
                            padding: const EdgeInsets.only(left: 15.0),
                            child: Align(
                              alignment: Alignment.bottomLeft,
                              child: Text(
                                convertPostCreationDate(state.userPost.postCreationDate),
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
            }
          },
        );
      },
    );
  }
}

class _BuildUpdateReviewDialog extends StatefulWidget {
  final MovieListsUserProfileBloc movieListsBloc;
  final TvShowListsUserProfileBloc tvShowListsUserProfileBloc;
  final UserPostState state;

  _BuildUpdateReviewDialog({
    this.movieListsBloc,
    this.tvShowListsUserProfileBloc,
    this.state,
  });

  @override
  __BuildUpdateReviewDialogState createState() => __BuildUpdateReviewDialogState();
}

class __BuildUpdateReviewDialogState extends State<_BuildUpdateReviewDialog> {
  double rating=5.0;
  bool isSpoiler;
  TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    rating = widget.state.userPost.rating;
    isSpoiler = widget.state.userPost.isSpoiler;
    _controller = TextEditingController(text: widget.state.userPost.review);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20.0)),
        ),
        actionsPadding: EdgeInsets.only(right: 12),
        contentPadding: const EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 0.0),
        insetPadding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
        content: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [


              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  "Updating review ",
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline


                  ),

                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Container(

                  child: Text(
                    widget.state.userPost.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFB8B5FF),
                    ),

                  ),
                ),
              ),
              Expanded(
                child: TextField(
                  controller: _controller,
                  maxLines: 80,
                  maxLength: 1000,
                  decoration: InputDecoration(
                    counter: Offstage(),
                  ),
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top : 10.0, left:10.0),
                  child: Text(
                    "${rating.toInt().toString()} of 10",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                ),
              ),
              Slider(
                  min: 1.0,
                  max: 10.0,
                  divisions: 9,
                  value: rating,
                  activeColor: Color(0xFF6398ff),
                  onChanged: (double value) {
                    setState(() {
                      rating = value;
                    });
                  }),
              CheckboxListTile(
                activeColor: Color(0xFF6398ff),
                value: isSpoiler,
                title: Text("Contains spoilers"),
                controlAffinity: ListTileControlAffinity.leading,
                onChanged: (bool value) {
                  setState(() {
                    isSpoiler = value;
                  });
                },
              )
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop();
            },
            style: TextButton.styleFrom(
              primary: Color(0xFF96baff),
            ),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              widget.state.userPost.isOfTypeMovie
                  ? widget.movieListsBloc.add(
                      MovieListsUserProfileEvent.updateMovieWatchedReviewPressed(
                        movieTitle: widget.state.userPost.title,
                        movieId: widget.state.userPost.tmdbId,
                        review: _controller.text,
                        rating: rating,
                        isSpoiler: isSpoiler,
                      ),
                    )
                  : widget.tvShowListsUserProfileBloc.add(
                      TvShowListsUserProfileEvent.updateTvShowWatchedReviewPressed(
                        tvShowTitle: widget.state.userPost.title,
                        tvShowId: widget.state.userPost.tmdbId,
                        review: _controller.text,
                        rating: rating,
                        isSpoiler: isSpoiler,
                      ),
                    );
              Navigator.of(context, rootNavigator: true).pop();
              Navigator.of(context, rootNavigator: true).pop();
            },
            style: ElevatedButton.styleFrom(
              primary: Color(0xFF6398ff),
            ),
            child: Text("Submit"),
          ),
        ],
      ),
    );
  }
}
