import 'package:bingeit/constants.dart';
import 'package:bingeit/notifications/pushNotif.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:community_material_icon/community_material_icon.dart';
import 'package:bingeit/application/feedback/block_user/block_user_bloc.dart';
import 'package:bingeit/application/feedback/report/report_bloc.dart';
import 'package:bingeit/application/user_interactions/follow/follow_bloc.dart';
import 'package:bingeit/application/user_profile_information/current_user_profile_information/current_user_profile_information_bloc.dart';
import 'package:bingeit/application/user_profile_information/other_user_profile_information/other_user_profile_information_bloc.dart';
import 'package:bingeit/application/user_profile_information/other_user_profile_information/other_user_profile_watchlist_watched/movie_lists/other_user_profile_movie_lists_bloc.dart';
import 'package:bingeit/application/user_profile_information/other_user_profile_information/other_user_profile_watchlist_watched/tv_show_lists/other_user_profile_tv_show_lists_bloc.dart';
import 'package:bingeit/data/models/our_user/our_user.dart';
import 'package:bingeit/presentation/pages/movie_details_page/movie_details_page.dart';
import 'package:bingeit/presentation/pages/profile_page/current_user_page/profile_page.dart';
import 'package:bingeit/presentation/pages/profile_page/other_user_page/other_user_followers_page.dart';
import 'package:bingeit/presentation/pages/profile_page/post_page/post_page.dart';
import 'package:bingeit/presentation/pages/tv_show_details_page/tv_show_details_page.dart';
import 'package:bingeit/presentation/utilities/utilities.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'other_user_following_page.dart';

enum VideoType {
  MOVIE_WATCHLIST,
  MOVIE_WATCHED,
  TV_SHOW_WATCHLIST,
  TV_SHOW_WATCHED,
}

class OtherUserProfilePage extends StatefulWidget {
  final String otherUserUid;

  OtherUserProfilePage({@required this.otherUserUid});

  @override
  _OtherUserProfilePageState createState() => _OtherUserProfilePageState();
}

class _OtherUserProfilePageState extends State<OtherUserProfilePage> with TickerProviderStateMixin {



  TabController _watchTypeTabController;
  TabController _moviesTabController;
  TabController _tvShowsTabController;
  ScrollController _scrollController;
  final List<Tab> _watchTypeTabs = <Tab>[
    const Tab(
        text: "Movies",

    ),
    const Tab(
        text: "TV Shows"
    ),
  ];
  final List<Tab> _moviesTabs = <Tab>[
    const Tab(text: "Watchlist"),
    const Tab(text: "Watched"),
  ];
  final List<Tab> _tvShowsTabs = <Tab>[
    const Tab(text: "Watchlist"),
    const Tab(text: "Watched"),
  ];

  @override
  void initState() {
    super.initState();
    _watchTypeTabController = TabController(initialIndex: 0, vsync: this, length: _watchTypeTabs.length);
    _moviesTabController = TabController(initialIndex: 0, vsync: this, length: _moviesTabs.length);
    _tvShowsTabController = TabController(initialIndex: 0, vsync: this, length: _tvShowsTabs.length);
    //Load user profile
    context.read<OtherUserProfileMovieListsBloc>().add(
          OtherUserProfileMovieListsEvent.loadMovieToListInitial(userUid: widget.otherUserUid),
        );
    context.read<OtherUserProfileTvShowListsBloc>().add(
          OtherUserProfileTvShowListsEvent.loadTvShowToListInitial(userUid: widget.otherUserUid),
        );
    context.read<FollowBloc>().add(FollowEvent.checkIfFollowingUserPressed(otherUserUid: widget.otherUserUid));
    context.read<OtherUserProfileInformationBloc>().add(
          OtherUserProfileInformationEvent.otherUserProfileLoaded(otherUserUid: widget.otherUserUid),
        );


  }

  //Method to call when Navigator.pop is called, to update the page
  void sendEvent() {
    context.read<OtherUserProfileMovieListsBloc>().add(
          OtherUserProfileMovieListsEvent.loadMovieToListInitial(userUid: widget.otherUserUid),
        );
    context.read<OtherUserProfileTvShowListsBloc>().add(
          OtherUserProfileTvShowListsEvent.loadTvShowToListInitial(userUid: widget.otherUserUid),
        );
    context.read<FollowBloc>().add(FollowEvent.checkIfFollowingUserPressed(otherUserUid: widget.otherUserUid));
    context.read<OtherUserProfileInformationBloc>().add(
          OtherUserProfileInformationEvent.otherUserProfileLoaded(otherUserUid: widget.otherUserUid),
        );
  }

  @override
  void dispose() {
    _watchTypeTabController.dispose();
    _moviesTabController.dispose();
    _tvShowsTabController.dispose();
    super.dispose();
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification is ScrollEndNotification && _scrollController.position.extentAfter == 0) {
      print("Calling FETCH NEXT WATCH TYPE PAGE");
      switch (_watchTypeTabController.index) {
        case (0):
          switch (_moviesTabController.index) {
            case (0):
              context.read<OtherUserProfileMovieListsBloc>().add(
                    OtherUserProfileMovieListsEvent.nextMovieWatchlistPageCalled(userUid: widget.otherUserUid),
                  );
              break;
            case (1):
              context.read<OtherUserProfileMovieListsBloc>().add(
                    OtherUserProfileMovieListsEvent.nextMovieWatchedPageCalled(userUid: widget.otherUserUid),
                  );
              break;
            default:
          }
          break;
        case (1):
          switch (_tvShowsTabController.index) {
            case (0):
              context.read<OtherUserProfileTvShowListsBloc>().add(
                    OtherUserProfileTvShowListsEvent.nextTvShowWatchlistPageCalled(userUid: widget.otherUserUid),
                  );
              break;
            case (1):
              context.read<OtherUserProfileTvShowListsBloc>().add(
                    OtherUserProfileTvShowListsEvent.nextTvShowWatchedPageCalled(userUid: widget.otherUserUid),
                  );
              break;
            default:
          }
          break;
        default:
      }
    }
    return false;
  }

  List<Widget> _watchTypeTabViews(BuildContext context) {
    List<Widget> views = <Widget>[
      _buildMoviesTabs(context),
      _buildTvShowsTabs(context),
    ];
    return views;
  }

  Widget _buildMoviesTabs(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: TabBarView(
              physics: NeverScrollableScrollPhysics(),
              controller: _moviesTabController,
              children: _moviesTabViews(context),
            ),
          ),
          TabBar(
            controller: _moviesTabController,
            tabs: _moviesTabs,
          ),
        ],
      ),
    );
  }

  Widget _buildTvShowsTabs(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: TabBarView(
              physics: NeverScrollableScrollPhysics(),
              controller: _tvShowsTabController,
              children: _tvShowsTabViews(context),
            ),
          ),
          TabBar(
            controller: _tvShowsTabController,
            tabs: _tvShowsTabs,
          ),
        ],
      ),
    );
  }

  List<Widget> _moviesTabViews(BuildContext context) {
    List<Widget> views = <Widget>[
      _buildMovieWatchlistTab(context),
      _buildMovieWatchedTab(context),
    ];
    return views;
  }

  List<Widget> _tvShowsTabViews(BuildContext context) {
    List<Widget> views = <Widget>[
      _buildTvShowWatchlistTab(context),
      _buildTvShowWatchedTab(context),
    ];
    return views;
  }

  Widget _buildMovieWatchlistTab(BuildContext context) {
    return BlocBuilder<OtherUserProfileMovieListsBloc, OtherUserProfileMovieListsState>(
      builder: (context, state) {
        if (state.isLoading) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else {
          final movieWatchlist = state.movieWatchlist;
          return movieWatchlist.isEmpty
              ? Expanded(
            child: Center(
              child: Text("No movies added to watchlist yet.",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 20,
                    color: Color(0xff476072),
                    fontWeight: FontWeight.bold
                ),),
            ),
          )
              : NotificationListener<ScrollNotification>(
                  onNotification: _handleScrollNotification,
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 0.69,
                    ),
                    itemCount: _calculateMovieWatchlistItemCount(state),
                    itemBuilder: (context, index) {
                      return index >= movieWatchlist.length
                          ? BuildLoaderNextPage()
                          : _buildGridImage(
                              posterPath: movieWatchlist[index].posterPath,
                              title: movieWatchlist[index].title,
                              id: movieWatchlist[index].id,
                              videoType: VideoType.MOVIE_WATCHLIST,
                            );
                    },
                  ),
                );
        }
      },
    );
  }

  int _calculateMovieWatchlistItemCount(OtherUserProfileMovieListsState state) {
    if (state.isThereMoreMovieWatchlistPageToLoad) {
      return state.movieWatchlist.length + 1;
    } else {
      return state.movieWatchlist.length;
    }
  }

  Widget _buildMovieWatchedTab(BuildContext context) {
    return BlocBuilder<OtherUserProfileMovieListsBloc, OtherUserProfileMovieListsState>(
      builder: (context, state) {
        if (state.isLoading) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else {
          final movieWatched = state.movieWatched;
          return movieWatched.isEmpty
              ? Expanded(
            child: Center(
              child: Text( "No movies watched yet.",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 20,
                    color: Color(0xff476072),
                    fontWeight: FontWeight.bold
                ),),
            ),
          )
              : NotificationListener<ScrollNotification>(
                  onNotification: _handleScrollNotification,
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 0.69,
                    ),
                    itemCount: _calculateMovieWatchedItemCount(state),
                    itemBuilder: (context, index) {
                      return index >= movieWatched.length
                          ? BuildLoaderNextPage()
                          : _buildGridImage(
                              posterPath: movieWatched[index].posterPath,
                              title: movieWatched[index].title,
                              id: movieWatched[index].id,
                              videoType: VideoType.MOVIE_WATCHED,
                              postUid: movieWatched[index].postUid,
                            );
                    },
                  ),
                );
        }
      },
    );
  }

  int _calculateMovieWatchedItemCount(OtherUserProfileMovieListsState state) {
    if (state.isThereMoreMovieWatchedPageToLoad) {
      return state.movieWatched.length + 1;
    } else {
      return state.movieWatched.length;
    }
  }

  Widget _buildTvShowWatchlistTab(BuildContext context) {
    return BlocBuilder<OtherUserProfileTvShowListsBloc, OtherUserProfileTvShowListsState>(
      builder: (context, state) {
        if (state.isLoading) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else {
          final tvShowWatchlist = state.tvShowWatchlist;
          return tvShowWatchlist.isEmpty
              ? Expanded(
            child: Center(
              child: Text( "No TV shows added to watchlist yet.",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 20,
                    color: Color(0xff476072),
                    fontWeight: FontWeight.bold
                ),),
            ),
          )
              : NotificationListener<ScrollNotification>(
                  onNotification: _handleScrollNotification,
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 0.69,
                    ),
                    itemCount: _calculateTvShowWatchlistItemCount(state),
                    itemBuilder: (context, index) {
                      return index >= tvShowWatchlist.length
                          ? BuildLoaderNextPage()
                          : _buildGridImage(
                              posterPath: tvShowWatchlist[index].posterPath,
                              title: tvShowWatchlist[index].name,
                              id: tvShowWatchlist[index].id,
                              videoType: VideoType.TV_SHOW_WATCHLIST,
                            );
                    },
                  ),
                );
        }
      },
    );
  }

  int _calculateTvShowWatchlistItemCount(OtherUserProfileTvShowListsState state) {
    if (state.isThereMoreTvShowWatchlistPageToLoad) {
      return state.tvShowWatchlist.length + 1;
    } else {
      return state.tvShowWatchlist.length;
    }
  }

  Widget _buildTvShowWatchedTab(BuildContext context) {
    return BlocBuilder<OtherUserProfileTvShowListsBloc, OtherUserProfileTvShowListsState>(
      builder: (context, state) {
        if (state.isLoading) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else {
          final tvShowWatched = state.tvShowWatched;
          return tvShowWatched.isEmpty
              ? Expanded(
            child: Center(
              child: Text("No TV shows watched yet.",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 20,
                    color: Color(0xff476072),
                    fontWeight: FontWeight.bold
                ),),
            ),
          )
              : NotificationListener<ScrollNotification>(
                  onNotification: _handleScrollNotification,
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 0.69,
                    ),
                    itemCount: _calculateTvShowWatchedItemCount(state),
                    itemBuilder: (context, index) {
                      return index >= tvShowWatched.length
                          ? BuildLoaderNextPage()
                          : _buildGridImage(
                              posterPath: tvShowWatched[index].posterPath,
                              title: tvShowWatched[index].name,
                              id: tvShowWatched[index].id,
                              videoType: VideoType.TV_SHOW_WATCHED,
                              postUid: tvShowWatched[index].postUid,
                            );
                    },
                  ),
                );
        }
      },
    );
  }

  int _calculateTvShowWatchedItemCount(OtherUserProfileTvShowListsState state) {
    if (state.isThereMoreTvShowWatchedPageToLoad) {
      return state.tvShowWatched.length + 1;
    } else {
      return state.tvShowWatched.length;
    }
  }

  Widget _buildGridImage({
    @required String posterPath,
    @required String title,
    @required int id,
    @required VideoType videoType,
    String postUid = "",
  }) {
    return GestureDetector(
      onTap: () {
        //Calling then and setState when Navigator is popped to update the page
        Navigator.of(context, rootNavigator: false).push(
          MaterialPageRoute(
            // ignore: missing_return
            builder: (context) {
              switch (videoType) {
                case VideoType.MOVIE_WATCHLIST:
                  return MovieDetailsPage(
                    movieId: id,
                    movieTitle: title,
                  );
                  break;
                case VideoType.MOVIE_WATCHED:
                  return PostPage(
                    postOwnerUid: widget.otherUserUid,
                    postUid: postUid,
                  );
                  break;
                case VideoType.TV_SHOW_WATCHLIST:
                  return TvShowDetailsPage(
                    tvShowId: id,
                    tvShowName: title,
                  );
                  break;
                case VideoType.TV_SHOW_WATCHED:
                  return PostPage(
                    postOwnerUid: widget.otherUserUid,
                    postUid: postUid,
                  );
                  break;
              }
            },
          ),
        ).then(
          (value) => setState(
            () {
              sendEvent();
            },
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: AspectRatio(
          aspectRatio: 0.69,
          child: BuildPosterImage(
            height: 135,
            width: 90,
            imagePath: posterPath,
          ),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Color(0xFF1B1E2B),
      body: SafeArea(
        child: BlocBuilder<OtherUserProfileInformationBloc, OtherUserProfileInformationState>(
          builder: (context, userInfoState) {

            return NestedScrollView(
              physics: NeverScrollableScrollPhysics(),
              headerSliverBuilder: (context, isScrolled) {
                return [
                  SliverAppBar(
                    automaticallyImplyLeading: false,
                    backgroundColor: Color(0xFF1B1E2B),
                    collapsedHeight: 300,
                    expandedHeight: 300,
                    flexibleSpace: Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [


                          Center(
                            child: Padding(
                              padding: const EdgeInsets.only(right : 15.0, top : 15.0, ),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: userInfoState.isSearching
                                          ? Padding(
                                        padding: const EdgeInsets.only(top: 20.0),
                                        child: Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      )
                                          : _profilePhoto(userInfoState.ourUser.profilePhotoUrl),
                                    ),
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            userInfoState.isSearching ? "" : '@' + userInfoState.ourUser.username,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only( bottom: 4),
                                            child: Text(
                                              userInfoState.isSearching ? "" : userInfoState.ourUser.fullName,
                                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Text( userInfoState.isSearching ? "" : userInfoState.ourUser.bio, maxLines: 8,
                                            overflow: TextOverflow.ellipsis,
                                            textDirection: TextDirection.ltr,
                                          ),

                                        ],
                                      ),
                                    )

                                  ],
                                ),
                              ),
                            ),
                          ),
                          Center(
                            child: Container(
                              height: 80,

                              child: userInfoState.isSearching
                                  ? Center(
                                child: CircularProgressIndicator(),
                              )
                                  :  ListView(
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                                children: [

                                  _userInformationCard(title: "Watched", user: userInfoState.ourUser),
                                  _userInformationCard(title: "Watchlist", user: userInfoState.ourUser),
                                  GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () {
                                      //Calling then and setState when Navigator is popped to update the page
                                      Navigator.of(context)
                                          .push(
                                        MaterialPageRoute(
                                          builder: (context) => OtherUserFollowersPage(
                                            profileOwnerUid: widget.otherUserUid,
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
                                    child:  _userInformationCard(title: "Followers", user: userInfoState.ourUser),
                                    //Bird(ourUser: userInfoState.ourUser,title: "Followers")
                                    //_userInformationCardDuble(title: "Followers", user: userInfoState.ourUser),
                                  ),
                                  GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () {
                                      Navigator.of(context)
                                          .push(
                                        MaterialPageRoute(
                                          builder: (context) => OtherUserFollowingPage(
                                            profileOwnerUid: widget.otherUserUid,
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
                                    child:  _userInformationCard(title: "Following", user: userInfoState.ourUser),
                                  ),
                                ],
                              ),
                            ),
                          ),


                          BlocBuilder<CurrentUserProfileInformationBloc, CurrentUserProfileInformationState>(
                            builder: (context, state) {
                              if (state.ourUser.uid != widget.otherUserUid) {
                                return BlocConsumer<FollowBloc, FollowState>(
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
                                    // ignore: close_sinks
                                    final followBloc = BlocProvider.of<FollowBloc>(context, listen: false);
                                    return BlocBuilder<BlockUserBloc, BlockUserState>(
                                      builder: (context, userBlockState) {
                                        if (state.isSubmitting) {
                                          return Center(child: CircularProgressIndicator());
                                        } else {
                                          bool isTheOtherUserBlocked = userBlockState.blockedUsers.contains(widget.otherUserUid);
                                          bool isBlockedByOtherUser = userBlockState.usersBlockedBy.contains(widget.otherUserUid);
                                          if (isTheOtherUserBlocked) {
                                            return Row(
                                              children: [
                                                Expanded(
                                                  child: Padding(
                                                    padding: const EdgeInsets.only(left: 15.0, ),
                                                    child: ElevatedButton(
                                                      style: kNotWatchedButton,
                                                      onPressed: () {
                                                        context.read<BlockUserBloc>().add(
                                                              BlockUserEvent.unblockUserPressed(
                                                                blockedUserUid: widget.otherUserUid,
                                                              ),
                                                            );
                                                      },
                                                      child: Padding(
                                                        padding: const EdgeInsets.symmetric(horizontal: 48.0),
                                                        child: Text(
                                                          "Unblock",
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                BlocListener<BlockUserBloc, BlockUserState>(
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
                                                  child: BlocListener<ReportBloc, ReportState>(
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
                                                    child: BlocBuilder<CurrentUserProfileInformationBloc, CurrentUserProfileInformationState>(
                                                      builder: (context, state) {
                                                        return Row(
                                                          mainAxisAlignment: MainAxisAlignment.start,
                                                          children: [
                                                            if (state.ourUser.uid != widget.otherUserUid)
                                                              IconButton(
                                                                  icon: Icon(Icons.more_horiz_rounded),
                                                                  onPressed: () {
                                                                    // ignore: close_sinks
                                                                    final bloc = BlocProvider.of<ReportBloc>(context, listen: false);
                                                                    // ignore: close_sinks
                                                                    final blockUserBloc = BlocProvider.of<BlockUserBloc>(context, listen: false);
                                                                    showDialog(
                                                                      context: context,
                                                                      builder: (context) {
                                                                        return _reportUserDialogConfirmation(
                                                                          otherUserUid: widget.otherUserUid,
                                                                          bloc: bloc,
                                                                          blockUserBloc: blockUserBloc,
                                                                        );
                                                                      },
                                                                    );
                                                                  }),
                                                          ],
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            );
                                          } else {
                                            if (isBlockedByOtherUser) {
                                              return Row(
                                                children: [
                                                  Expanded(
                                                    child: Padding(
                                                      padding: const EdgeInsets.only(left: 15.0, ),
                                                      child: ElevatedButton(
                                                        style: kNotWatchedButton,
                                                        onPressed: null,
                                                        child: Padding(
                                                          padding: const EdgeInsets.symmetric(horizontal: 48.0),
                                                          child: Text(
                                                            "Unavailable",
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  BlocListener<BlockUserBloc, BlockUserState>(
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
                                                    child: BlocListener<ReportBloc, ReportState>(
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
                                                      child: BlocBuilder<CurrentUserProfileInformationBloc, CurrentUserProfileInformationState>(
                                                        builder: (context, state) {
                                                          return Row(
                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                            children: [
                                                              if (state.ourUser.uid != widget.otherUserUid)
                                                                IconButton(
                                                                    icon: Icon(Icons.more_horiz_rounded),
                                                                    onPressed: () {
                                                                      // ignore: close_sinks
                                                                      final bloc = BlocProvider.of<ReportBloc>(context, listen: false);
                                                                      // ignore: close_sinks
                                                                      final blockUserBloc = BlocProvider.of<BlockUserBloc>(context, listen: false);
                                                                      showDialog(
                                                                        context: context,
                                                                        builder: (context) {
                                                                          return _reportUserDialogConfirmation(
                                                                            otherUserUid: widget.otherUserUid,
                                                                            bloc: bloc,
                                                                            blockUserBloc: blockUserBloc,
                                                                          );
                                                                        },
                                                                      );
                                                                    }),
                                                            ],
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              );
                                            } else {
                                              return Row(
                                                children: [
                                                  Expanded(
                                                    child: Padding(
                                                      padding: const EdgeInsets.only(left: 15.0, ),
                                                      child: ElevatedButton(
                                                        style: state.isFollowing ? kWatchedButton : kNotWatchedButton,
                                                        onPressed: () {
                                                          if(state.isFollowing) {
                                                            showDialog(
                                                              context: context,
                                                              builder: (context) {
                                                                return UnfollowUserDialog(
                                                                    otherUserUid: widget.otherUserUid, bloc: followBloc);
                                                              },
                                                            );
                                                            } else {

                                                            context.read<FollowBloc>().add(
                                                              FollowEvent.followUserPressed(otherUserUid: widget.otherUserUid),
                                                            );
                                                            sendit(widget.otherUserUid, " started following you");
                                                          }

                                                        },
                                                        child: Padding(
                                                          padding: const EdgeInsets.symmetric(horizontal: 48.0),
                                                          child: Text(
                                                            state.isFollowing ? "Following" : "Follow",
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  BlocListener<BlockUserBloc, BlockUserState>(
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
                                                    child: BlocListener<ReportBloc, ReportState>(
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
                                                      child: BlocBuilder<CurrentUserProfileInformationBloc, CurrentUserProfileInformationState>(
                                                        builder: (context, state) {
                                                          return Row(
                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                            children: [
                                                              if (state.ourUser.uid != widget.otherUserUid)
                                                                IconButton(
                                                                    icon: Icon(Icons.more_horiz_rounded),
                                                                    onPressed: () {
                                                                      // ignore: close_sinks
                                                                      final bloc = BlocProvider.of<ReportBloc>(context, listen: false);
                                                                      // ignore: close_sinks
                                                                      final blockUserBloc = BlocProvider.of<BlockUserBloc>(context, listen: false);
                                                                      showDialog(
                                                                        context: context,
                                                                        builder: (context) {
                                                                          return _reportUserDialogConfirmation(
                                                                            otherUserUid: widget.otherUserUid,
                                                                            bloc: bloc,
                                                                            blockUserBloc: blockUserBloc,
                                                                          );
                                                                        },
                                                                      );
                                                                    }),
                                                            ],
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              );
                                            }
                                          }
                                        }
                                      },
                                    );
                                  },
                                );
                              } else {
                                return Offstage();
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverPersistentHeader(
                    floating: true,
                    pinned: true,
                    delegate: MyDelegate(
                      TabBar(
                        controller: _watchTypeTabController,
                        tabs: _watchTypeTabs,
                        labelColor: Color(0xFF7579e7),
                        unselectedLabelColor: Colors.grey,
                      ),
                    ),
                  ),
                ];
              },
              body: BlocBuilder<BlockUserBloc, BlockUserState>(
                builder: (context, userBlockState) {
                  _scrollController = PrimaryScrollController.of(context);
                  if (userBlockState.blockedUsers.contains(widget.otherUserUid)) {
                    return Center(child: Text("Unblock the user to see more"));
                  } else {
                    return userBlockState.usersBlockedBy.contains(widget.otherUserUid)
                        ? Center(child: Text("Currently unavailable"))
                        : TabBarView(
                            controller: _watchTypeTabController,
                            children: _watchTypeTabViews(context),
                          );
                  }
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _profilePhoto(String profilePhotoUrl) {
    return CachedNetworkImage(
      imageUrl: profilePhotoUrl,
      imageBuilder: (context, imageProvider) => CircleAvatar(
        radius: 60.0,
        backgroundColor:darkBG,
        child: ClipRRect(
          child: Image.network(profilePhotoUrl),
          borderRadius: BorderRadius.circular(10000.0),
        ),

      ),
      //
      //     CircleAvatar(
      //   foregroundImage: imageProvider,
      //   backgroundColor: Colors.black,
      //   radius: 60,
      // ),
      placeholder: (context, url) => Padding(
        padding: const EdgeInsets.only(top: 20.0),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      errorWidget: (context, url, error) {
        return profilePhotoUrl.isEmpty
            ? CircleAvatar(
          backgroundColor: Colors.white,
                child: Text(
                  'No\nImage',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 15,
                      color: Color(0xff476072),
                      fontWeight: FontWeight.bold
                  ),),
                radius:60,
              )
            : CircleAvatar(
                backgroundColor: Colors.black,
                child: Icon(Icons.error, color: Colors.white),
                radius:60,
              );
      },
    );
  }

  Widget _userInformationCard({@required String title, @required OurUser user}) {
    String categoryCount = "";
    if (title == "Watched") {
      categoryCount = user.watchedLength.toString();
    } else if(title == "Watchlist"){
      categoryCount = user.watchlistLength.toString();
    } else if(title == "Followers") {
      categoryCount = user.followers.toString();
    } else {
      categoryCount = user.following.toString();
    }


    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            categoryCount,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          Text(
            title,
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }


  Widget _reportUserDialogConfirmation({
    @required String otherUserUid,
    @required ReportBloc bloc,
    @required BlockUserBloc blockUserBloc,
  }) {
    return SimpleDialog(
      children: [
        SimpleDialogOption(
          padding: EdgeInsets.all(16),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) {
                return ReportUserDialog(
                  otherUserUid: otherUserUid,
                  bloc: bloc,
                );
              },
            );
          },
          child: Text(
            "Report User",
            textAlign: TextAlign.center,
          ),
        ),

      ],
    );
  }
}

class UnfollowUserDialog extends StatefulWidget {
  final String otherUserUid;
  final FollowBloc bloc;

  UnfollowUserDialog({this.otherUserUid, this.bloc});

  @override
  _UnfollowUserDialogState createState() => _UnfollowUserDialogState();
}

class _UnfollowUserDialogState extends State<UnfollowUserDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Are you sure you want to unfollow this user?"),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop();
          },
          style: TextButton.styleFrom(
            primary:  Color(0xFF6398ff),
          ),
          child: Text("No"),
        ),
        TextButton(
          onPressed: () {
            widget.bloc.add(
              FollowEvent.unfollowUserPressed(otherUserUid: widget.otherUserUid),
            );
            Navigator.of(context, rootNavigator: true).pop();
          },
          style: TextButton.styleFrom(
            primary:  Color(0xFF6398ff),
          ),
          child: Text("Yes"),
        ),
      ],
    );
  }
}

class ReportUserDialog extends StatefulWidget {
  final String otherUserUid;
  final ReportBloc bloc;

  ReportUserDialog({
    @required this.otherUserUid,
    @required this.bloc,
  });

  @override
  _ReportUserDialogState createState() => _ReportUserDialogState();
}

class _ReportUserDialogState extends State<ReportUserDialog> {
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
                  "Why are you reporting this user?",
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
              primary:  Color(0xFF6398ff),
            ),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              widget.bloc.add(
                ReportEvent.reportUserPressed(reportedUserUid: widget.otherUserUid, reportMessage: _controller.text),
              );
              Navigator.of(context, rootNavigator: true).pop();
              Navigator.of(context, rootNavigator: true).pop();
            },
            style: ElevatedButton.styleFrom(
              primary:Color(0xFF6398ff),
            ),
            child: Text("Submit"),
          ),
        ],
      ),
    );
  }
}

class BlockUserDialog extends StatefulWidget {
  @override
  _BlockUserDialogState createState() => _BlockUserDialogState();
}

class _BlockUserDialogState extends State<BlockUserDialog> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
