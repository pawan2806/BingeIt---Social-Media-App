import 'package:bingeit/application/search/actor_search/actor_search_bloc.dart';
import 'package:bingeit/application/search/movie_search/movie_search_bloc.dart';
import 'package:bingeit/application/search/tv_show_search/tv_show_search_bloc.dart';
import 'package:bingeit/application/search/user_search/user_search_bloc.dart';
import 'package:bingeit/presentation/pages/actor_details_page/actor_details_page.dart';
import 'package:bingeit/presentation/pages/movie_details_page/movie_details_page.dart';
import 'package:bingeit/presentation/pages/profile_page/other_user_page/other_user_profile_page.dart';
import 'package:bingeit/presentation/pages/tv_show_details_page/tv_show_details_page.dart';
import 'package:bingeit/presentation/utilities/utilities.dart';
import 'package:bingeit/presentation/pages/search_user_page/search_users.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with TickerProviderStateMixin {
  TextEditingController _searchController;
  ScrollController _scrollController;
  TabController _tabController;
  double _crossAxisSpacing = 8, _mainAxisSpacing = 12, _aspectRatio = 2;
  int _crossAxisCount = 2;
  final List<Tab> _myTabs = <Tab>[
    const Tab(text: "Movies"),
    const Tab(text: "TV Shows"),
    const Tab(text: "Users"),
  ];
  final _debouncer = Debouncer(milliseconds: 500);

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _scrollController = ScrollController();
    _tabController = TabController(initialIndex: 0, vsync: this, length: _myTabs.length);
    context.read<MovieSearchBloc>().add(MovieSearchEvent.getPopularMoviesCalled());
    context.read<TvShowSearchBloc>().add(TvShowSearchEvent.getPopularTvShowsCalled());
    context.read<ActorSearchBloc>().add(ActorSearchEvent.getPopularActorsCalled());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  //If at end of the Listview, search for more Results
  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification is ScrollEndNotification && _scrollController.position.extentAfter == 0) {
      print("Calling FETCH NEXT PAGE");
      switch (_tabController.index) {
        case (0):
          context.read<MovieSearchBloc>().add(
                MovieSearchEvent.nextResultPageCalled(),
              );
          break;
        case (1):
          context.read<TvShowSearchBloc>().add(
                TvShowSearchEvent.nextResultPageCalled(),
              );
          break;
        case (2):
          context.read<UserSearchBloc>().add(
                UserSearchEvent.nextSearchResultPageCalled(),
              );
          break;
        default:
      }
    }
    return false;
  }

  //If at end of the GridView (popular movies, tv shows...) search for more Results
  bool _handlePopularScrollNotification(ScrollNotification notification) {
    if (notification is ScrollEndNotification && _scrollController.position.extentAfter == 0) {
      print("Calling FETCH NEXT PAGE");
      switch (_tabController.index) {
        case (0):
          context.read<MovieSearchBloc>().add(
                MovieSearchEvent.nextPopularMoviesPageCalled(),
              );
          break;
        case (1):
          context.read<TvShowSearchBloc>().add(
                TvShowSearchEvent.nextPopularTvShowsPageCalled(),
              );
          break;
        case (2):
          print("Popular Users SEARCH NEXT PAGE CALLED");
          break;
        default:
      }
    }
    return false;
  }

  List<Widget> _tabViews(BuildContext context) {
    List<Widget> views = <Widget>[
      _buildSearchMovieTabView(context),
      _buildSearchTvShowTabView(context),
      _buildSearchUserTabView(context),
    ];
    return views;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1B1E2B),
      body: SafeArea(
        child: BlocListener<MovieSearchBloc, MovieSearchState>(
          listener: (context, state) {
            if (state.isSearchPageDoublePressed) {
              setState(() {
                _searchController.clear();
              });
              _tabController.animateTo(0);
              context.read<MovieSearchBloc>().add(
                    MovieSearchEvent.changeIsSearchPageDoublePressed(),
                  );
              context.read<TvShowSearchBloc>().add(
                    TvShowSearchEvent.deleteSearchPressed(),
                  );
              context.read<UserSearchBloc>().add(
                    UserSearchEvent.deleteSearchPressed(),
                  );
            }
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Padding(
                padding: const EdgeInsets.only(
                  left: 20.0,
                  right: 20.0,

                  top: 20.0,
                ),
                child: Text(


                  "Discover",
                  style: TextStyle(

                      fontWeight: FontWeight.bold,
                      fontSize: 25
                  ),
                  textAlign: TextAlign.start,
                ),
              ),




              Padding(
                padding: const EdgeInsets.only(
                  left: 10.0,
                  right: 10.0,

                  bottom: 5.0,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _searchController,
                        maxLength: 100,
                        autocorrect: false,
                        cursorColor: Color(0xFF7868E6),
                        decoration: InputDecoration(
                          hintText: "Search Movies, TV-Shows or Users.",
                          counterText: "",
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Colors.grey,
                          ),
                         // labelText: 'Search',

                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                              });
                              switch (_tabController.index) {
                                case (0):
                                  context.read<MovieSearchBloc>().add(
                                    MovieSearchEvent.deleteSearchPressed(),
                                  );
                                  break;
                                case (1):
                                  context.read<TvShowSearchBloc>().add(
                                    TvShowSearchEvent.deleteSearchPressed(),
                                  );
                                  break;
                                case (2):
                                  context.read<UserSearchBloc>().add(
                                    UserSearchEvent.deleteSearchPressed(),
                                  );
                                  break;
                                default:
                              }
                            },
                          )
                              : null,
                        ),
                        onChanged: (value) {
                          //Calling this setState so that the _searchController gets updated, the deleteSearch button doesn't show in other tabs from the start
                          setState(() {});
                          //Debouncer, so that the search gets initiated when the user stops typing (for 500 milliseconds)
                          _debouncer.run(() {
                            print(value);
                            switch (_tabController.index) {
                              case (0):
                                context.read<MovieSearchBloc>().add(
                                  MovieSearchEvent.searchTitleChanged(value),
                                );
                                break;
                              case (1):
                                context.read<TvShowSearchBloc>().add(
                                  TvShowSearchEvent.searchNameChanged(value),
                                );
                                break;
                              case (2):
                                context.read<UserSearchBloc>().add(
                                  UserSearchEvent.searchUsernameChanged(value),
                                );
                                break;
                              default:
                            }
                          });
                        },
                        onFieldSubmitted: (value) {
                          switch (_tabController.index) {
                            case (0):
                              context.read<MovieSearchBloc>().add(
                                MovieSearchEvent.searchTitleChanged(value),
                              );
                              break;
                            case (1):
                              context.read<TvShowSearchBloc>().add(
                                TvShowSearchEvent.searchNameChanged(value),
                              );
                              break;
                            case (2):
                              context.read<UserSearchBloc>().add(
                                UserSearchEvent.searchUsernameChanged(value),
                              );
                              break;
                            default:
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              TabBar(
                controller: _tabController,
                tabs: _myTabs,
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
    );
  }

  ///BUILD USER SEARCH TAB View
  Widget _buildSearchUserTabView(BuildContext context) {
    return BlocBuilder<UserSearchBloc, UserSearchState>(
      builder: (context, state) {
        return Column(
          children: [
            if (!state.isSearching && state.errorMessage.isEmpty && !state.isSearchCompleted)
              Expanded(
                child: Center(
                  child: Text("Search users by username.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 20,
                        color: Color(0xff476072),
                        fontWeight: FontWeight.bold
                    ),),

                ),
              ),
            if (state.isSearching) BuildSearchProgressIndicator(),
            if (state.errorMessage.isNotEmpty) BuildSearchErrorMessage(state.errorMessage),
            if (state.isSearchCompleted)
              Expanded(
                child: NotificationListener<ScrollNotification>(
                  onNotification: _handleScrollNotification,
                  child: ListView.builder(
                    controller: _scrollController,
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                    itemCount: _calculateSearchUserListItemCount(state),
                    itemBuilder: (context, index) {
                      return index >= state.userSearchResults.length
                          ? BuildLoaderNextPage()
                          : _buildUserSearchCard(context, state, index);
                    },
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  int _calculateSearchUserListItemCount(UserSearchState state) {
    if (state.isThereMoreUserSearchPageToLoad) {
      return state.userSearchResults.length + 1;
    } else {
      return state.userSearchResults.length;
    }
  }

  Widget _buildUserSearchCard(BuildContext context, UserSearchState state, int index) {
    var user = state.userSearchResults[index];
    return ListTile(
      leading: Container(
        height: 60,
        width: 60,
        child: BuildProfilePhotoAvatar(profilePhotoUrl: user.profilePhotoUrl),
      ),
      title: Text(user.username),
      subtitle: Text(user.fullName),
      onTap: () {
        Navigator.of(context, rootNavigator: false).push(
          MaterialPageRoute(
            builder: (context) => OtherUserProfilePage(
              otherUserUid: user.uid,
            ),
          ),
        );
      },
    );
  }

  ///BUILD ACTOR SEARCH TAB View
  Widget _buildSearchActorTabView(BuildContext context) {
    return BlocBuilder<ActorSearchBloc, ActorSearchState>(
      builder: (context, state) {
        return Column(
          children: [
            if (!state.isSearching && state.errorMessage.isEmpty && !state.isSearchCompleted)
              //Show here popular movies? Or trending, or recommendations? Also the same for TV shows tabs?

            if (state.isSearching) BuildSearchProgressIndicator(),
            if (state.isSearchCompleted)
              Expanded(
                child: NotificationListener<ScrollNotification>(
                  onNotification: _handleScrollNotification,
                  child: ListView.builder(
                    controller: _scrollController,
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                    itemCount: _calculateActorListItemCount(state),
                    itemBuilder: (context, index) {
                      return index >= state.actorSearchResults.actorSummaries.length
                          ? BuildLoaderNextPage()
                          : _buildActorCard(context, state, index);
                    },
                  ),
                ),
              ),
            if (state.errorMessage.isNotEmpty) BuildSearchErrorMessage(state.errorMessage),
          ],
        );
      },
    );
  }

  int _calculatePopularActorsItemCount(ActorSearchState state) {
    if (state.popularPageNum < state.popularActors.totalPages) {
      return state.popularActors.actorSummaries.length + 1;
    } else {
      return state.popularActors.actorSummaries.length;
    }
  }

  int _calculateActorListItemCount(ActorSearchState state) {
    if (state.searchPageNum < state.actorSearchResults.totalPages) {
      return state.actorSearchResults.actorSummaries.length + 1;
    } else {
      return state.actorSearchResults.actorSummaries.length;
    }
  }

  Widget _buildActorCard(BuildContext context, ActorSearchState state, int index) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: InkWell(
        onTap: () {
          Navigator.of(context, rootNavigator: false).push(
            MaterialPageRoute(
              builder: (context) => ActorDetailsPage(state.actorSearchResults.actorSummaries[index].id),
            ),
          );
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 1,
              child: BuildPosterImage(
                height: 190,
                width: 132,
                imagePath: state.actorSearchResults.actorSummaries[index].profilePath,
              ),
            ),
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 12.0, right: 12.0, top: 45.0),
                    child: Text(
                      state.actorSearchResults.actorSummaries[index].name,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 20.0),
                    child: Text(
                      "Known for: " + state.actorSearchResults.actorSummaries[index].knownForDepartment,
                      maxLines: 5,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  ///BUILD TV SHOWS SEARCH TAB View
  Widget _buildSearchTvShowTabView(BuildContext context) {
    return BlocBuilder<TvShowSearchBloc, TvShowSearchState>(
      builder: (context, state) {
        return Column(
          children: [
            if (!state.isSearching && state.errorMessage.isEmpty && !state.isSearchCompleted)
              //Show here popular movies? Or trending, or recommendations? Also the same for TV shows tabs?
              Expanded(
                child: Center(
                  child: Text("Start typing to search for TV Shows.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 20,
                        color: Color(0xff476072),
                        fontWeight: FontWeight.bold
                    ),),
                ),
              ),
            if (state.isSearching) BuildSearchProgressIndicator(),
            if (state.isSearchCompleted)
              Expanded(
                child: NotificationListener<ScrollNotification>(
                  onNotification: _handleScrollNotification,
                  child: Center(
                    child: GridView.builder(

                      controller: _scrollController,
                      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                      scrollDirection: Axis.vertical,


                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCountAndFixedHeight( crossAxisCount: 3,
                        crossAxisSpacing: 2,
                        mainAxisSpacing: 2,
                        height: 270,),
                      itemBuilder: (_, index) => index >= state.tvShowSearchResults.tvShowSummaries.length
                    ? BuildLoaderNextPage()
                    : _buildTvShowCard(context, state, index),
                      itemCount: _calculateTvShowListItemCount(state),
                    ),
                  )
                )
              ),


            if (state.errorMessage.isNotEmpty) BuildSearchErrorMessage(state.errorMessage),
          ],
        );
      },
    );
  }

  int _calculatePopularTvShowsItemCount(TvShowSearchState state) {
    if (state.popularPageNum < state.popularTvShows.totalPages) {
      return state.popularTvShows.tvShowSummaries.length + 1;
    } else {
      return state.popularTvShows.tvShowSummaries.length;
    }
  }

  int _calculateTvShowListItemCount(TvShowSearchState state) {
    if (state.searchPageNum < state.tvShowSearchResults.totalPages) {
      return state.tvShowSearchResults.tvShowSummaries.length + 1;
    } else {
      return state.tvShowSearchResults.tvShowSummaries.length;
    }
  }

  Widget _buildTvShowCard(BuildContext context, TvShowSearchState state, int index) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: InkWell(
          onTap: () {
            Navigator.of(context, rootNavigator: false).push(
              MaterialPageRoute(
                builder: (context) => TvShowDetailsPage(
                  tvShowName: state.tvShowSearchResults.tvShowSummaries[index].name,
                  tvShowId: state.tvShowSearchResults.tvShowSummaries[index].id,
                ),
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  children: [
                    BuildPosterImage(
                      height: 200,
                      width: 130,
                      imagePath: state.tvShowSearchResults.tvShowSummaries[index].posterPath,
                    ),
                Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                          child: Text(
                            state.tvShowSearchResults.tvShowSummaries[index].name,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            maxLines: 3,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                        ),


                  ],
                ),
              )

            ],
          ),
        ),
      ),
    );
  }

  ///Build Movie Search Tab View
  Widget _buildSearchMovieTabView(BuildContext context) {
    return BlocBuilder<MovieSearchBloc, MovieSearchState>(
      builder: (context, state) {
        return Column(
          children: [
            if (!state.isSearching && state.errorMessage.isEmpty && !state.isSearchCompleted)
              //Show here popular movies? Or trending, or recommendations? Also the same for TV shows tabs?
              Expanded(
                child: Center(
                  child: Text("Start typing to search for Movies.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 20,
                        color: Color(0xff476072),
                        fontWeight: FontWeight.bold
                    ),),
                ),
              ),
            if (state.isSearching) BuildSearchProgressIndicator(),
            if (state.isSearchCompleted)
              Expanded(
                  child: NotificationListener<ScrollNotification>(
                      onNotification: _handleScrollNotification,
                      child: Center(
                        child: GridView.builder(

                          controller: _scrollController,
                          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                          scrollDirection: Axis.vertical,


                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCountAndFixedHeight( crossAxisCount: 3,
                            crossAxisSpacing: 2,
                            mainAxisSpacing: 2,
                            height: 270,),
                          itemBuilder: (_, index) => index >= state.movieSearchResults.movieSummaries.length
        ? BuildLoaderNextPage()
            : _buildMovieCard(context, state, index),
                          itemCount: _calculateMovieListItemCount(state),
                        ),
                      )
                  )
              ),

            if (state.errorMessage.isNotEmpty) BuildSearchErrorMessage(state.errorMessage),
          ],
        );
      },
    );
  }

  int _calculatePopularMoviesItemCount(MovieSearchState state) {
    if (state.popularPageNum < state.popularMovies.totalPages) {
      return state.popularMovies.movieSummaries.length + 1;
    } else {
      return state.popularMovies.movieSummaries.length;
    }
  }

  int _calculateMovieListItemCount(MovieSearchState state) {
    if (state.searchPageNum < state.movieSearchResults.totalPages) {
      return state.movieSearchResults.movieSummaries.length + 1;
    } else {
      return state.movieSearchResults.movieSummaries.length;
    }
  }

  Widget _buildMovieCard(BuildContext context, MovieSearchState state, int index) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: InkWell(
        onTap: () {
          Navigator.of(context, rootNavigator: false).push(
            MaterialPageRoute(
              builder: (context) => MovieDetailsPage(
                movieId: state.movieSearchResults.movieSummaries[index].id,
                movieTitle: state.movieSearchResults.movieSummaries[index].title,
              ),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                children: [
                  BuildPosterImage(
                    height: 200,
                    width: 130,
                    imagePath:state.movieSearchResults.movieSummaries[index].posterPath,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                    child: Text(
                      state.movieSearchResults.movieSummaries[index].title,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ),


                ],
              ),
            )


          ],
        ),

      ),
    );
  }
}
class SliverGridDelegateWithFixedCrossAxisCountAndFixedHeight
    extends SliverGridDelegate {
  /// Creates a delegate that makes grid layouts with a fixed number of tiles in
  /// the cross axis.
  ///
  /// All of the arguments must not be null. The `mainAxisSpacing` and
  /// `crossAxisSpacing` arguments must not be negative. The `crossAxisCount`
  /// and `childAspectRatio` arguments must be greater than zero.
  const SliverGridDelegateWithFixedCrossAxisCountAndFixedHeight({
    @required this.crossAxisCount,
    this.mainAxisSpacing = 0.0,
    this.crossAxisSpacing = 0.0,
    this.height = 56.0,
  })  : assert(crossAxisCount != null && crossAxisCount > 0),
        assert(mainAxisSpacing != null && mainAxisSpacing >= 0),
        assert(crossAxisSpacing != null && crossAxisSpacing >= 0),
        assert(height != null && height > 0);

  /// The number of children in the cross axis.
  final int crossAxisCount;

  /// The number of logical pixels between each child along the main axis.
  final double mainAxisSpacing;

  /// The number of logical pixels between each child along the cross axis.
  final double crossAxisSpacing;

  /// The height of the crossAxis.
  final double height;

  bool _debugAssertIsValid() {
    assert(crossAxisCount > 0);
    assert(mainAxisSpacing >= 0.0);
    assert(crossAxisSpacing >= 0.0);
    assert(height > 0.0);
    return true;
  }

  @override
  SliverGridLayout getLayout(SliverConstraints constraints) {
    assert(_debugAssertIsValid());
    final double usableCrossAxisExtent =
        constraints.crossAxisExtent - crossAxisSpacing * (crossAxisCount - 1);
    final double childCrossAxisExtent = usableCrossAxisExtent / crossAxisCount;
    final double childMainAxisExtent = height;
    return SliverGridRegularTileLayout(
      crossAxisCount: crossAxisCount,
      mainAxisStride: childMainAxisExtent + mainAxisSpacing,
      crossAxisStride: childCrossAxisExtent + crossAxisSpacing,
      childMainAxisExtent: childMainAxisExtent,
      childCrossAxisExtent: childCrossAxisExtent,
      reverseCrossAxis: axisDirectionIsReversed(constraints.crossAxisDirection),
    );
  }

  @override
  bool shouldRelayout(
      SliverGridDelegateWithFixedCrossAxisCountAndFixedHeight oldDelegate) {
    return oldDelegate.crossAxisCount != crossAxisCount ||
        oldDelegate.mainAxisSpacing != mainAxisSpacing ||
        oldDelegate.crossAxisSpacing != crossAxisSpacing ||
        oldDelegate.height != height;
  }
}