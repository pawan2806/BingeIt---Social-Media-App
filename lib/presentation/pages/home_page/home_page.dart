import 'package:bingeit/presentation/pages/search_user_page/search_users.dart';
import 'package:community_material_icon/community_material_icon.dart';

import 'package:unicons/unicons.dart';
import 'package:bingeit/application/feedback/block_user/block_user_bloc.dart';
import 'package:bingeit/application/feedback/report/report_bloc.dart';
import 'package:bingeit/application/search/actor_search/actor_details/actor_details_bloc.dart';
import 'package:bingeit/application/search/movie_search/movie_details/movie_details_bloc.dart';
import 'package:bingeit/application/search/movie_search/movie_search_bloc.dart';
import 'package:bingeit/application/search/tv_show_search/tv_show_details/tv_show_details_bloc.dart';
import 'package:bingeit/application/user_interactions/follow/follow_bloc.dart';
import 'package:bingeit/application/user_interactions/notifications/notifications_bloc.dart';
import 'package:bingeit/application/user_post/global_news_feed/global_news_feed_bloc.dart';
import 'package:bingeit/application/user_post/reviews_posts/reviews_posts_bloc.dart';
import 'package:bingeit/application/user_post/user_news_feed/user_news_feed_bloc.dart';
import 'package:bingeit/application/user_post/user_post_bloc.dart';
import 'package:bingeit/application/user_profile_information/current_user_profile_information/current_user_profile_information_bloc.dart';
import 'package:bingeit/application/user_profile_information/current_user_profile_information/current_user_profile_watchlist_watched/movie_lists/movie_lists_user_profile_bloc.dart';
import 'package:bingeit/application/user_profile_information/current_user_profile_information/current_user_profile_watchlist_watched/tv_show_lists/tv_show_lists_user_profile_bloc.dart';
import 'package:bingeit/application/user_profile_information/other_user_profile_information/other_user_profile_information_bloc.dart';
import 'package:bingeit/application/user_profile_information/other_user_profile_information/other_user_profile_watchlist_watched/movie_lists/other_user_profile_movie_lists_bloc.dart';
import 'package:bingeit/application/user_profile_information/other_user_profile_information/other_user_profile_watchlist_watched/tv_show_lists/other_user_profile_tv_show_lists_bloc.dart';
import 'package:bingeit/data/search_db/actor_db/actor_repository.dart';
import 'package:bingeit/data/search_db/movie_db/movie_repository.dart';
import 'package:bingeit/data/search_db/tv_show_db/tv_show_repository.dart';
import 'package:bingeit/data/user_profile_db/current_user_profile_db/user_feedback_repository.dart';
import 'package:bingeit/data/user_profile_db/other_user_profile_db/other_user_profile_repository.dart';
import 'package:bingeit/data/user_profile_db/user_actions_db/user_actions_repository.dart';
import 'package:bingeit/presentation/pages/feedback_page/feedback_page.dart';
import 'package:bingeit/presentation/pages/home_page/one.dart';
import 'package:bingeit/presentation/pages/news_feed_page/news_feed_page.dart';
import 'package:bingeit/presentation/pages/notifications_page/notifications_page.dart';
import 'package:bingeit/presentation/pages/profile_page/current_user_page/profile_page.dart';
import 'package:bingeit/presentation/pages/search_page/search_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  http.Client client;
  MovieRepository _movieRepository;
  TvShowRepository _tvShowRepository;
  ActorRepository _actorRepository;
  UserActionsRepository _userActionsRepository;
  OtherUserProfileRepository _otherUserProfileRepository;
  UserFeedbackRepository _userFeedbackRepository;

  final List<GlobalKey<NavigatorState>> tabNavKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];
  CupertinoTabController _tabController;
  //CurrentIndex needs to be equal to initialIndex so that an exception is not thrown
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    //Put the Search page as the starting one? For the time being until the app is populated
    _tabController = CupertinoTabController(initialIndex: 0);
    client = http.Client();
    _movieRepository = MovieRepository(client);
    _tvShowRepository = TvShowRepository(client);
    _actorRepository = ActorRepository(client);
    _userActionsRepository = UserActionsRepository();
    _otherUserProfileRepository = OtherUserProfileRepository();
    _userFeedbackRepository = UserFeedbackRepository();

    //Calling events here, since if they are called with BlocProvider initialization they don't get updated when the user logs out
    context.read<MovieListsUserProfileBloc>().add(
          MovieListsUserProfileEvent.loadMovieToListInitial(),
        );
    context.read<TvShowListsUserProfileBloc>().add(
          TvShowListsUserProfileEvent.loadTvShowToListInitial(),
        );
    context.read<CurrentUserProfileInformationBloc>().add(
          CurrentUserProfileInformationEvent.loadCurrentUserProfilePressed(),
        );
    context.read<NotificationsBloc>().add(
          NotificationsEvent.loadInitialNotifications(),
        );
    context.read<GlobalNewsFeedBloc>().add(
          GlobalNewsFeedEvent.loadReviewsPressed(),
        );
    context.read<UserNewsFeedBloc>().add(
          UserNewsFeedEvent.loadReviewsPressed(),
        );
    context.read<BlockUserBloc>().add(
          BlockUserEvent.loadInitialListOfBlockedUsersPressed(),
        );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return !await tabNavKeys[_tabController.index].currentState.maybePop();
      },
      child: CupertinoTabScaffold(
        controller: _tabController,
        tabBar: CupertinoTabBar(
          backgroundColor: Color(0xFF1B1E2B),
          activeColor: Color(0xFF7579E7),
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Padding(
              padding: EdgeInsets.only(top : 4.0),
              child: Icon(UniconsLine.home_alt),
            ), title: Padding(
              padding: EdgeInsets.only(top : 4.0),
              child: Text("Feed", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12.0),),
            )),
            BottomNavigationBarItem(icon: Padding(
              padding: EdgeInsets.only(top : 4.0),
              child: Icon(UniconsLine.fire),
            ),title: Padding(
              padding: EdgeInsets.only(top : 4.0),
              child: Text("Discover", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12.0),),
            )),
            BottomNavigationBarItem(icon: Padding(
              padding: EdgeInsets.only(top : 4.0),
              child: Icon(UniconsLine.heart_alt),
            ),title: Padding(
              padding: EdgeInsets.only(top : 4.0),
              child: Text("Activity", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12.0),),
            )),
            BottomNavigationBarItem(icon: Padding(
              padding: EdgeInsets.only(top : 4.0),
              child: Icon(UniconsLine.user),
            ), title: Padding(
              padding: EdgeInsets.only(top : 4.0),
              child: Text("Profile", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12.0),),
            )
            ),
            // BottomNavigationBarItem(icon: Icon(Icons.help_outline_sharp)),

          ],
          onTap: (index) {
            if (currentIndex == index) {
              switch (index) {
                case 0:
                  BlocProvider.of<GlobalNewsFeedBloc>(context, listen: false).add(GlobalNewsFeedEvent.loadReviewsPressed());
                  BlocProvider.of<UserNewsFeedBloc>(context, listen: false).add(UserNewsFeedEvent.loadReviewsPressed());
                  tabNavKeys[0].currentState.popUntil((route) => route.isFirst);
                  break;
                case 1:
                  BlocProvider.of<MovieSearchBloc>(context, listen: false).add(MovieSearchEvent.searchPageDoublePressed());
                  tabNavKeys[2].currentState.popUntil((route) => route.isFirst);
                  break;
                case 2:
                  tabNavKeys[2].currentState.popUntil((route) => route.isFirst);
                  break;
                case 3:
                  tabNavKeys[3].currentState.popUntil((route) => route.isFirst);
                  break;
                // case 4 :
                //   tabNavKeys[4].currentState.popUntil((route) => route.isFirst);
                //   break;
                default:
              }
            }
            currentIndex = index;
          },
        ),
        tabBuilder: (context, index) {
          switch (index) {
            case 0:
              return MultiBlocProvider(
                providers: [
                  BlocProvider(
                    create: (context) => MovieDetailsBloc(
                      _movieRepository,
                    ),
                  ),
                  BlocProvider(
                    create: (context) => TvShowDetailsBloc(
                      _tvShowRepository,
                    ),
                  ),
                  BlocProvider(
                    create: (context) => ActorDetailsBloc(
                      _actorRepository,
                    ),
                  ),
                  BlocProvider(
                    create: (context) => OtherUserProfileMovieListsBloc(
                      _otherUserProfileRepository,
                    ),
                  ),
                  BlocProvider(
                    create: (context) => OtherUserProfileTvShowListsBloc(
                      _otherUserProfileRepository,
                    ),
                  ),
                  BlocProvider(
                    create: (context) => OtherUserProfileInformationBloc(
                      _otherUserProfileRepository,
                    ),
                  ),
                  BlocProvider(
                    create: (context) => FollowBloc(
                      _userActionsRepository,
                    ),
                  ),
                  BlocProvider(
                    create: (context) => UserPostBloc(
                      _userActionsRepository,
                    ),
                  ),

                  ///Reviews
                  BlocProvider(
                    create: (context) => ReviewsPostsBloc(
                      _userActionsRepository,
                    ),
                  ),

                  ///Report content
                  BlocProvider(
                    create: (context) => ReportBloc(
                      _userFeedbackRepository,
                    ),
                  ),
                ],
                child: CupertinoTabView(
                  navigatorKey: tabNavKeys[0],
                  builder: (context) {
                    return CupertinoPageScaffold(
                      child: NewsFeedPage(),
                    );
                  },
                ),
              );
            case 1:
              return MultiBlocProvider(
                providers: [
                  ///Details Tmdb
                  BlocProvider(
                    create: (context) => MovieDetailsBloc(
                      _movieRepository,
                    ),
                  ),
                  BlocProvider(
                    create: (context) => TvShowDetailsBloc(
                      _tvShowRepository,
                    ),
                  ),
                  BlocProvider(
                    create: (context) => ActorDetailsBloc(
                      _actorRepository,
                    ),
                  ),

                  ///Other user info
                  BlocProvider(
                    create: (context) => OtherUserProfileMovieListsBloc(
                      _otherUserProfileRepository,
                    ),
                  ),
                  BlocProvider(
                    create: (context) => OtherUserProfileTvShowListsBloc(
                      _otherUserProfileRepository,
                    ),
                  ),
                  BlocProvider(
                    create: (context) => OtherUserProfileInformationBloc(
                      _otherUserProfileRepository,
                    ),
                  ),

                  ///Follow
                  BlocProvider(
                    create: (context) => FollowBloc(
                      _userActionsRepository,
                    ),
                  ),

                  ///Post
                  BlocProvider(
                    create: (context) => UserPostBloc(
                      _userActionsRepository,
                    ),
                  ),

                  ///Reviews
                  BlocProvider(
                    create: (context) => ReviewsPostsBloc(
                      _userActionsRepository,
                    ),
                  ),

                  ///Report content
                  BlocProvider(
                    create: (context) => ReportBloc(
                      _userFeedbackRepository,
                    ),
                  ),
                ],
                child: CupertinoTabView(
                  navigatorKey: tabNavKeys[1],
                  builder: (context) {
                    return CupertinoPageScaffold(
                      child: SearchPage(),
                    );
                  },
                ),
              );
            case 2:
              return MultiBlocProvider(
                providers: [
                  BlocProvider(
                    create: (context) => MovieDetailsBloc(
                      _movieRepository,
                    ),
                  ),
                  BlocProvider(
                    create: (context) => TvShowDetailsBloc(
                      _tvShowRepository,
                    ),
                  ),
                  BlocProvider(
                    create: (context) => ActorDetailsBloc(
                      _actorRepository,
                    ),
                  ),
                  BlocProvider(
                    create: (context) => OtherUserProfileMovieListsBloc(
                      _otherUserProfileRepository,
                    ),
                  ),
                  BlocProvider(
                    create: (context) => OtherUserProfileTvShowListsBloc(
                      _otherUserProfileRepository,
                    ),
                  ),
                  BlocProvider(
                    create: (context) => OtherUserProfileInformationBloc(
                      _otherUserProfileRepository,
                    ),
                  ),
                  BlocProvider(
                    create: (context) => FollowBloc(
                      _userActionsRepository,
                    ),
                  ),
                  BlocProvider(
                    create: (context) => UserPostBloc(
                      _userActionsRepository,
                    ),
                  ),

                  ///Reviews
                  BlocProvider(
                    create: (context) => ReviewsPostsBloc(
                      _userActionsRepository,
                    ),
                  ),

                  ///Report content
                  BlocProvider(
                    create: (context) => ReportBloc(
                      _userFeedbackRepository,
                    ),
                  ),
                ],
                child: CupertinoTabView(
                  navigatorKey: tabNavKeys[2],
                  builder: (context) {
                    return CupertinoPageScaffold(
                      child: NotificationsPage(),
                    );
                  },
                ),
              );
            case 3:
              return MultiBlocProvider(
                providers: [
                  BlocProvider(
                    create: (context) => MovieDetailsBloc(
                      _movieRepository,
                    ),
                  ),
                  BlocProvider(
                    create: (context) => TvShowDetailsBloc(
                      _tvShowRepository,
                    ),
                  ),
                  BlocProvider(
                    create: (context) => ActorDetailsBloc(
                      _actorRepository,
                    ),
                  ),
                  BlocProvider(
                    create: (context) => OtherUserProfileMovieListsBloc(
                      _otherUserProfileRepository,
                    ),
                  ),
                  BlocProvider(
                    create: (context) => OtherUserProfileTvShowListsBloc(
                      _otherUserProfileRepository,
                    ),
                  ),
                  BlocProvider(
                    create: (context) => OtherUserProfileInformationBloc(
                      _otherUserProfileRepository,
                    ),
                  ),
                  BlocProvider(
                    create: (context) => FollowBloc(
                      _userActionsRepository,
                    ),
                  ),
                  BlocProvider(
                    create: (context) => UserPostBloc(
                      _userActionsRepository,
                    ),
                  ),

                  ///Reviews
                  BlocProvider(
                    create: (context) => ReviewsPostsBloc(
                      _userActionsRepository,
                    ),
                  ),

                  ///Report content
                  BlocProvider(
                    create: (context) => ReportBloc(
                      _userFeedbackRepository,
                    ),
                  ),
                ],
                child: CupertinoTabView(
                  navigatorKey: tabNavKeys[3],
                  builder: (context) {
                    return CupertinoPageScaffold(
                      child: ProfilePage(),
                    );
                  },
                ),
              );
            // case 4:
            //   return CupertinoTabView(
            //     navigatorKey: tabNavKeys[4],
            //     builder: (context) {
            //       return CupertinoPageScaffold(
            //         child:FeedbackPage(),
            //       );
            //     },
            //   );
            default:
              return CupertinoTabView(
                navigatorKey: tabNavKeys[0],
                builder: (context) {
                  return CupertinoPageScaffold(
                    child: OnePage(),
                  );
                },
              );
          }
        },
      ),
    );
  }
}
