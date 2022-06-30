import 'dart:core';

import 'package:animated_size_and_fade/animated_size_and_fade.dart';
import 'package:community_material_icon/community_material_icon.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:bingeit/application/feedback/report/report_bloc.dart';
import 'package:bingeit/application/user_post/user_post_bloc.dart';
import 'package:bingeit/application/user_profile_information/current_user_profile_information/current_user_profile_watchlist_watched/movie_lists/movie_lists_user_profile_bloc.dart';
import 'package:bingeit/application/user_profile_information/current_user_profile_information/current_user_profile_watchlist_watched/tv_show_lists/tv_show_lists_user_profile_bloc.dart';
import 'package:bingeit/application/user_profile_information/other_user_profile_information/other_user_profile_information_bloc.dart';
import 'package:bingeit/presentation/pages/movie_details_page/movie_details_page.dart';
import 'package:bingeit/presentation/pages/profile_page/other_user_page/other_user_profile_page.dart';
import 'package:bingeit/presentation/pages/profile_page/post_page/post_comments_page.dart';
import 'package:bingeit/presentation/pages/profile_page/post_page/post_likers_page.dart';
import 'package:bingeit/presentation/pages/tv_show_details_page/tv_show_details_page.dart';
import 'package:bingeit/presentation/utilities/utilities.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PostPage extends StatefulWidget {
  final String postOwnerUid;
  final String postUid;

  PostPage({@required this.postOwnerUid, @required this.postUid});

  @override
  _PostPageState createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> with TickerProviderStateMixin {
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
            Navigator.of(context, rootNavigator: false).pop();
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
    return Scaffold(
      backgroundColor: Color(0xFF1B1E2B),
      appBar: AppBar(
        title: Text("Posts"),
      ),
      body: SafeArea(
        child: BlocBuilder<OtherUserProfileInformationBloc, OtherUserProfileInformationState>(
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
                return state.isLoadingPost || userState.isSearching
                    ? Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        physics: AlwaysScrollableScrollPhysics(),
                        child: Column(
                          children: [
                            BlocListener<ReportBloc, ReportState>(
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
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: GestureDetector(
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
                                      child: Row(
                                        children: [
                                          Material(
                                            elevation: 20,
                                            borderRadius: const BorderRadius.all(
                                              Radius.circular(20.0),
                                            ),
                                            child: BuildProfilePhotoAvatar(
                                                profilePhotoUrl: userState.ourUser.profilePhotoUrl, radius: 20),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(left: 12.0),
                                            child: Text(
                                              userState.ourUser.username,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
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
                            ),
                            GestureDetector(
                              onDoubleTap: () {
                                updateHeartIconAnimation();
                                Future.delayed(Duration(milliseconds: 1000), () {
                                  updateHeartIconAnimation();
                                });
                                if (!state.isPostLiked)
                                  context.read<UserPostBloc>().add(
                                        UserPostEvent.likePostPressed(
                                          postOwnerUid: widget.postOwnerUid,
                                          postUid: widget.postUid,
                                          postPhotoUrl: state.userPost.posterPath,
                                        ),
                                      );
                              },
                              child: Stack(
                                alignment: AlignmentDirectional.center,
                                children: [
                                  BuildPosterImage(
                                    resolution: "w500",
                                    height: MediaQuery.of(context).size.width * 0.65 * 1.5,
                                    width: MediaQuery.of(context).size.width * 0.65,
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
                                            ? Icon(
                                                Icons.favorite,
                                                color: Colors.red,
                                              )
                                            : Icon(
                                                Icons.favorite_border,
                                                //color: Colors.black,
                                              ),
                                        onPressed: () {
                                          // ignore: close_sinks
                                          final bloc = BlocProvider.of<UserPostBloc>(context, listen: false);
                                          state.isPostLiked
                                              ? showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return _buildConfirmUnlikeDialog(bloc: bloc);
                                                  },
                                                )
                                              : context.read<UserPostBloc>().add(
                                                    UserPostEvent.likePostPressed(
                                                      postOwnerUid: widget.postOwnerUid,
                                                      postUid: widget.postUid,
                                                      postPhotoUrl: state.userPost.posterPath,
                                                    ),
                                                  );
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
                                        icon: Icon(
                                          Icons.people_alt_outlined,
                                          //color: Colors.black,
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
                                      child: Text(state.userPost.review)
                                      // GestureDetector(
                                      //   onTap: () {
                                      //     setState(() {
                                      //       isReviewExpanded = !isReviewExpanded;
                                      //     });
                                      //   },
                                      //   child: ExpandableText(
                                      //     state.userPost.review,
                                      //     expandText: "more",
                                      //     collapseText: "",
                                      //     maxLines: 3,
                                      //     expanded: isReviewExpanded,
                                      //     key: UniqueKey(),
                                      //   ),
                                      // ),
                                    ),
                                  ),
                            Padding(
                              padding: const EdgeInsets.only(left:15.0, top:15.0),
                              child: Align(
                                alignment: Alignment.centerLeft,
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
                      );
              },
            );
          },
        ),
      ),
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


class ReportPostDialog extends StatefulWidget {
  final String otherUserUid;
  final ReportBloc bloc;
  final String postUid;
  final String postText;

  ReportPostDialog({
    @required this.otherUserUid,
    @required this.bloc,
    @required this.postUid,
    @required this.postText,
  });

  @override
  _ReportPostDialogState createState() => _ReportPostDialogState();
}

class _ReportPostDialogState extends State<ReportPostDialog> {
  TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
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
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
        ),
        actionsPadding: EdgeInsets.only(right: 12),
        contentPadding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 0.0),
        insetPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
        content: SizedBox(
          width: MediaQuery.of(context).size.width*0.5,
          height:MediaQuery.of(context).size.height*0.5,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  "Why are you reporting this post?",
                  textAlign: TextAlign.start,
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold
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
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop();
              Navigator.of(context, rootNavigator: true).pop();
            },
            style: TextButton.styleFrom(
              primary: Color(0xFF6398ff),
            ),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              widget.bloc.add(
                ReportEvent.reportPostPressed(
                  reportedUserUid: widget.otherUserUid,
                  reportMessage: _controller.text,
                  reportedPostText: widget.postText,
                  reportedPostUid: widget.postUid,
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
