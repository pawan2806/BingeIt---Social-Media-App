import 'package:bingeit/constants.dart';
import 'package:bingeit/notifications/pushNotif.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:community_material_icon/community_material_icon.dart';
import 'package:bingeit/application/user_profile_information/current_user_profile_information/current_user_profile_information_bloc.dart';
import 'package:bingeit/application/user_profile_information/current_user_profile_information/current_user_profile_watchlist_watched/movie_lists/movie_lists_user_profile_bloc.dart';
import 'package:bingeit/application/user_profile_information/current_user_profile_information/current_user_profile_watchlist_watched/tv_show_lists/tv_show_lists_user_profile_bloc.dart';
import 'package:bingeit/presentation/pages/movie_details_page/movie_details_page.dart';
import 'package:bingeit/presentation/pages/profile_page/current_user_page/current_user_followers_page.dart';
import 'package:bingeit/presentation/pages/profile_page/current_user_page/current_user_following_page.dart';
import 'package:bingeit/presentation/pages/profile_page/current_user_page/edit_profile_page.dart';
import 'package:bingeit/presentation/pages/profile_page/current_user_page/user_settings_page.dart';
import 'package:bingeit/presentation/pages/profile_page/post_page/post_page.dart';
import 'package:bingeit/presentation/pages/tv_show_details_page/tv_show_details_page.dart';
import 'package:bingeit/presentation/utilities/utilities.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum VideoType {
  MOVIE_WATCHLIST,
  MOVIE_WATCHED,
  TV_SHOW_WATCHLIST,
  TV_SHOW_WATCHED,
}

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with TickerProviderStateMixin {
  TabController _watchTypeTabController;
  TabController _moviesTabController;
  TabController _tvShowsTabController;
  ScrollController _scrollController;
  final List<Tab> _watchTypeTabs = <Tab>[
    const Tab(
     text: "Movies",
    ),
    const Tab(
  text: "TV Shows",

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
              context.read<MovieListsUserProfileBloc>().add(
                    MovieListsUserProfileEvent.nextMovieWatchlistPageCalled(),
                  );
              break;
            case (1):
              context.read<MovieListsUserProfileBloc>().add(
                    MovieListsUserProfileEvent.nextMovieWatchedPageCalled(),
                  );
              break;
            default:
          }
          break;
        case (1):
          switch (_tvShowsTabController.index) {
            case (0):
              context.read<TvShowListsUserProfileBloc>().add(
                    TvShowListsUserProfileEvent.nextTvShowWatchlistPageCalled(),
                  );
              break;
            case (1):
              context.read<TvShowListsUserProfileBloc>().add(
                    TvShowListsUserProfileEvent.nextTvShowWatchedPageCalled(),
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
    return BlocBuilder<MovieListsUserProfileBloc, MovieListsUserProfileState>(
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

  int _calculateMovieWatchlistItemCount(MovieListsUserProfileState state) {
    if (state.movieWatchlist.length < 18 || state.movieWatchlist.length % 3 != 0 || !state.isThereMoreMovieWatchlistPageToLoad) {
      return state.movieWatchlist.length;
    } else {
      return state.movieWatchlist.length + 1;
    }
  }

  Widget _buildMovieWatchedTab(BuildContext context) {
    return BlocBuilder<MovieListsUserProfileBloc, MovieListsUserProfileState>(
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

  int _calculateMovieWatchedItemCount(MovieListsUserProfileState state) {
    if (state.movieWatched.length < 18 || state.movieWatched.length % 3 != 0 || !state.isThereMoreMovieWatchedPageToLoad) {
      return state.movieWatched.length;
    } else {
      return state.movieWatched.length + 1;
    }
  }

  Widget _buildTvShowWatchlistTab(BuildContext context) {
    return BlocBuilder<TvShowListsUserProfileBloc, TvShowListsUserProfileState>(
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

  int _calculateTvShowWatchlistItemCount(TvShowListsUserProfileState state) {
    if (state.tvShowWatchlist.length < 18 ||
        state.tvShowWatchlist.length % 3 != 0 ||
        !state.isThereMoreTvShowWatchlistPageToLoad) {
      return state.tvShowWatchlist.length;
    } else {
      return state.tvShowWatchlist.length + 1;
    }
  }

  Widget _buildTvShowWatchedTab(BuildContext context) {
    return BlocBuilder<TvShowListsUserProfileBloc, TvShowListsUserProfileState>(
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
          ) : NotificationListener<ScrollNotification>(
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

  int _calculateTvShowWatchedItemCount(TvShowListsUserProfileState state) {
    if (state.tvShowWatched.length < 18 || state.tvShowWatched.length % 3 != 0 || !state.isThereMoreTvShowWatchedPageToLoad) {
      return state.tvShowWatched.length;
    } else {
      return state.tvShowWatched.length + 1;
    }
  }

  Widget _buildGridImage({
    @required String posterPath,
    @required String title,
    @required int id,
    @required VideoType videoType,
    String postUid = "",
  }) {
    return BlocBuilder<CurrentUserProfileInformationBloc, CurrentUserProfileInformationState>(
      builder: (context, state) {
        return GestureDetector(
          onTap: () {
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
                        postOwnerUid: state.ourUser.uid,
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
                        postOwnerUid: state.ourUser.uid,
                        postUid: postUid,
                      );
                      break;
                  }
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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CurrentUserProfileInformationBloc, CurrentUserProfileInformationState>(
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
        return Scaffold(
          backgroundColor: Color(0xFF1B1E2B),
          body: SafeArea(
            child: NestedScrollView(
              physics: NeverScrollableScrollPhysics(),
              headerSliverBuilder: (context, isScrolled) {
                return [
                  SliverAppBar(
                    backgroundColor: Color(0xFF1B1E2B),
                    collapsedHeight: 300,
                    expandedHeight: 300,
                    flexibleSpace: Column(
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
                                    child: Center(
                                      child: GestureDetector(
                                        onTap: () {
                                          context.read<CurrentUserProfileInformationBloc>().add(
                                                CurrentUserProfileInformationEvent.uploadProfilePhotoPressed(),
                                              );
                                        },
                                        child: _profilePhoto(state),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                Text(
                          state.isSearching ? "" : '@'+ state.ourUser.username,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                          ),
                      ),
                                        Padding(
                                          padding: const EdgeInsets.only( bottom: 4),
                                          child: Text(
                                            state.isSearching ? "" : state.ourUser.fullName,
                                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Text( state.isSearching ? "" : state.ourUser.bio, maxLines: 8,
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

                            child: state.isSearching
                                ? Center(
                                    child: CircularProgressIndicator(),
                                  )
                                : ListView(
                                    shrinkWrap: true,
                                    scrollDirection: Axis.horizontal,
                                    children: [
                                      _userInformationCard(title: "Watched", state: state),
                                      _userInformationCard(title: "Watchlist", state: state),
                                      GestureDetector(
                                        behavior: HitTestBehavior.opaque,
                                        onTap: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) => CurrentUserFollowersPage(
                                                profileOwnerUid: state.ourUser.uid,
                                              ),
                                            ),
                                          );
                                        },
                                        child: _userInformationCard(title: "Followers", state: state),
                                      ),
                                      GestureDetector(
                                        behavior: HitTestBehavior.opaque,
                                        onTap: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) => CurrentUserFollowingPage(
                                                profileOwnerUid: state.ourUser.uid,
                                              ),
                                            ),
                                          );
                                        },
                                        child: _userInformationCard(title: "Following", state: state),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                        Row(
                                  children: [
                state.isSearching
                ? LinearProgressIndicator()
                    : Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 15.0, ),

                        child: ElevatedButton(
                style: kWatchedButton,
                onPressed: () {
                Navigator.of(context).push(
                MaterialPageRoute(
                builder: (context) => EditProfilePage(
                ourUser: state.ourUser,
                ),
                ),
                );
                },
                child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48.0),
                child: Text("Edit Profile"),
                ),
                ),
                      ),
                    ),

                                    IconButton(
                                        icon: Icon(
                                          Icons.settings,
                                          size: 30,
                                        ),
                                        onPressed: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(builder: (context) => UserSettingsPage()),
                                          );
                                        }),
                                    // IconButton(
                                    //     icon: Icon(
                                    //       Icons.usb,
                                    //       size: 30,
                                    //     ),
                                    //     onPressed: () {
                                    //       sendit("nO3K7u0nYHSVlfySKbhyiJhQXue2", " has like your post.");
                                    //     }),



                ],
                                  ),




                      ],
                    ),
                  ),
                  SliverPersistentHeader(
                    floating: true,
                    pinned: true,
                    delegate: MyDelegate(
                      TabBar(
                        controller: _watchTypeTabController,
                        tabs: _watchTypeTabs,

                        unselectedLabelColor: Colors.grey,
                      ),
                    ),
                  ),
                ];
              },
              body: Builder(
                builder: (context) {
                  _scrollController = PrimaryScrollController.of(context);
                  return TabBarView(
                    controller: _watchTypeTabController,
                    children: _watchTypeTabViews(context),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _profilePhoto(CurrentUserProfileInformationState state) {
    if (state.isUploadingPhoto || state.isSearching) {
      return Padding(
        padding: const EdgeInsets.only(top: 20.0),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      return CachedNetworkImage(
        imageUrl: state.ourUser.profilePhotoUrl,
        imageBuilder: (context, imageProvider) => CircleAvatar(
          radius: 60.0,
          
          child: ClipRRect(
            child: Image.network(state.ourUser.profilePhotoUrl),
            borderRadius: BorderRadius.circular(10000.0),
          ),

        ),
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
          return state.ourUser.profilePhotoUrl.isEmpty
              ? CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  'Add\nImage',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 15,
                      color: Color(0xff476072),
                      fontWeight: FontWeight.bold
                  ),),
                radius: 60,
              )
              : CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.error, color: Colors.black),
                   radius: 60.0,
                );
        },
      );
    }
  }

  Widget _userInformationCard({String title, CurrentUserProfileInformationState state}) {
    String categoryCount = "";
    if (title == "Watched") {
      categoryCount = state.ourUser.watchedLength.toString();
    } else if (title == "Followers") {
      categoryCount = state.ourUser.followers.toString();
    } else if (title=="Following"){
      categoryCount = state.ourUser.following.toString();
    } else {
      categoryCount=state.ourUser.watchlistLength.toString();
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
}

class MyDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  MyDelegate(this.tabBar);

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Color(0xFF1B1E2B),
      child: this.tabBar,
    );
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
