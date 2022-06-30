import 'package:bingeit/application/search/actor_search/actor_search_bloc.dart';
import 'package:bingeit/application/search/movie_search/movie_search_bloc.dart';
import 'package:bingeit/application/search/tv_show_search/tv_show_search_bloc.dart';
import 'package:bingeit/application/search/user_search/user_search_bloc.dart';
import 'package:bingeit/presentation/pages/actor_details_page/actor_details_page.dart';
import 'package:bingeit/presentation/pages/movie_details_page/movie_details_page.dart';
import 'package:bingeit/presentation/pages/profile_page/other_user_page/other_user_profile_page.dart';
import 'package:bingeit/presentation/pages/tv_show_details_page/tv_show_details_page.dart';
import 'package:bingeit/presentation/utilities/utilities.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class SearchUsers extends StatefulWidget {
  @override
  _SearchUsersState createState() => _SearchUsersState();
}

class _SearchUsersState extends State<SearchUsers> with TickerProviderStateMixin {
  TextEditingController _searchController;
  ScrollController _scrollController;
  TabController _tabController;
  final List<Tab> _myTabs = <Tab>[

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
          context.read<UserSearchBloc>().add(
            UserSearchEvent.nextSearchResultPageCalled(),
          );
          break;
        case (1):
          context.read<UserSearchBloc>().add(
            UserSearchEvent.nextSearchResultPageCalled(),
          );
          break;
        case (2):
          context.read<UserSearchBloc>().add(
            UserSearchEvent.nextSearchResultPageCalled(),
          );
          break;
        case (3):
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
          print("Popular Users SEARCH NEXT PAGE CALLED");
          break;
        case (1):
          print("Popular Users SEARCH NEXT PAGE CALLED");
          break;
        case (2):
          print("Popular Users SEARCH NEXT PAGE CALLED");
          break;
        case (3):
          print("Popular Users SEARCH NEXT PAGE CALLED");
          break;
        default:
      }
    }
    return false;
  }

  List<Widget> _tabViews(BuildContext context) {
    List<Widget> views = <Widget>[

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
              context.read<ActorSearchBloc>().add(
                ActorSearchEvent.deleteSearchPressed(),
              );
              context.read<UserSearchBloc>().add(
                UserSearchEvent.deleteSearchPressed(),
              );
            }
          },
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  left: 20.0,
                  right: 20.0,
                  top: 20.0,
                  bottom: 5.0,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _searchController,
                        maxLength: 100,
                        autocorrect: false,
                        decoration: InputDecoration(
                          counterText: "",
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Colors.grey,
                          ),
                          labelText: 'Search',
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                              });
                              context.read<UserSearchBloc>().add(
                                UserSearchEvent.deleteSearchPressed(),
                              );
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
                            context.read<UserSearchBloc>().add(
                              UserSearchEvent.searchUsernameChanged(value),
                            );
                          });
                        },
                        onFieldSubmitted: (value) {
                          context.read<UserSearchBloc>().add(
                            UserSearchEvent.searchUsernameChanged(value),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: _buildSearchUserTabView(context),
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



}
