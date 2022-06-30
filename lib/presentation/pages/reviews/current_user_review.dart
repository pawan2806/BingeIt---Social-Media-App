import 'package:community_material_icon/community_material_icon.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:bingeit/application/user_post/user_post_bloc.dart';
import 'package:bingeit/application/user_profile_information/current_user_profile_information/current_user_profile_watchlist_watched/movie_lists/movie_lists_user_profile_bloc.dart';
import 'package:bingeit/application/user_profile_information/current_user_profile_information/current_user_profile_watchlist_watched/tv_show_lists/tv_show_lists_user_profile_bloc.dart';
import 'package:bingeit/application/user_profile_information/other_user_profile_information/other_user_profile_information_bloc.dart';
import 'package:bingeit/presentation/pages/profile_page/other_user_page/other_user_profile_page.dart';
import 'package:bingeit/presentation/pages/profile_page/post_page/post_comments_page.dart';
import 'package:bingeit/presentation/pages/profile_page/post_page/post_likers_page.dart';
import 'package:bingeit/presentation/utilities/utilities.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CurrentUserReview extends StatefulWidget {
  final String postOwnerUid;
  final String postUid;

  CurrentUserReview({
    @required this.postOwnerUid,
    @required this.postUid,
  });

  @override
  _CurrentUserReviewState createState() => _CurrentUserReviewState();
}

class _CurrentUserReviewState extends State<CurrentUserReview> with TickerProviderStateMixin {
  bool isReviewExpanded = false;

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
            return state.isLoadingPost || userState.isSearching
                ? Center(child: CircularProgressIndicator())
                : Padding(
                  padding: const EdgeInsets.only(top:10.0, left:15.0 , right: 15.0, bottom: 10.0),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Color(0xff476072),
                        width: 4,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Column(
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  left: 8.0,
                                  top: 8.0,
                                  bottom: 8.0,
                                  right: 8.0,
                                ),

                                child: Text(
                                  "You reviewed this " + convertPostCreationDate(state.userPost.postCreationDate),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey
                                  ),
                                ),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onTap: () {

                                      },
                                      child: FittedBox(
                                        fit: BoxFit.cover,
                                        child: BuildProfilePhotoAvatar(
                                          profilePhotoUrl: userState.ourUser.profilePhotoUrl,
                                          radius: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 5,
                                  child: RichText(
                                    maxLines: 2,
                                    text: TextSpan(
                                      text: userState.ourUser.username,
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {

                                        },
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                      children: [

                                        TextSpan(
                                          text : "  rated it  ",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.normal,
                                          ),

                                        ),

                                        TextSpan(
                                          text:  state.userPost.rating.toInt().toString(),
                                          style: TextStyle(
                                            color: Colors.amber,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        TextSpan(
                                          text: ' of ',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.normal,
                                          ),
                                        ),
                                        TextSpan(
                                          text: "10",
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.amber,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),







                                      ],
                                    ),
                                  ),
                                ),
                                if (state.isCurrentUserOwnerOfPost)
                                  Expanded(
                                    flex: 1,
                                    child: IconButton(
                                        icon: Icon(Icons.more_horiz_rounded),
                                        onPressed: () {
                                          // ignore: close_sinks
                                          final movieBloc = BlocProvider.of<MovieListsUserProfileBloc>(context, listen: false);
                                          // ignore: close_sinks
                                          final tvShowBloc = BlocProvider.of<TvShowListsUserProfileBloc>(context, listen: false);
                                          // ignore: close_sinks
                                          final userPostBloc = BlocProvider.of<UserPostBloc>(context, listen: false);
                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              return _buildEditPostActionsDialog(
                                                userPostBloc: userPostBloc,
                                                movieListsUserProfileBloc: movieBloc,
                                                tvShowListsUserProfileBloc: tvShowBloc,
                                                state: state,
                                              );
                                            },
                                          );
                                        }),
                                  ),
                              ],
                            ),
                            //Removed spoiler tag in current User Review, since only the current User can see this review in DetailsPage and there is no point for spoiler tag
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      isReviewExpanded = !isReviewExpanded;
                                    });
                                  },
                                  child: ExpandableText(
                                    state.userPost.review,
                                    expandText: "more",
                                    collapseText: "",
                                    maxLines: 3,
                                    expanded: isReviewExpanded,
                                    key: UniqueKey(),
                                  ),
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

                            Divider(),
                          ],
                        ),
                      ),
                  ),
                );
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
