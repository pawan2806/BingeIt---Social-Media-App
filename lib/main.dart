import 'package:bingeit/application/auth/auth_check/auth_check_bloc.dart';
import 'package:bingeit/application/auth/sign_in_form/delete_account/delete_account_bloc.dart';
import 'package:bingeit/application/auth/sign_in_form/edit_profile/edit_profile_bloc.dart';
import 'package:bingeit/application/auth/sign_in_form/sign_in_form_bloc.dart';
import 'package:bingeit/application/feedback/block_user/block_user_bloc.dart';
import 'package:bingeit/application/feedback/feedback_bloc.dart';
import 'package:bingeit/screens/liquidSwipe.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:bingeit/application/search/actor_search/actor_search_bloc.dart';
import 'package:bingeit/application/search/movie_search/movie_search_bloc.dart';
import 'package:bingeit/application/search/tv_show_search/tv_show_search_bloc.dart';
import 'package:bingeit/application/search/user_search/user_search_bloc.dart';
import 'package:bingeit/application/user_interactions/notifications/notifications_bloc.dart';
import 'package:bingeit/application/user_post/global_news_feed/global_news_feed_bloc.dart';
import 'package:bingeit/application/user_post/user_news_feed/user_news_feed_bloc.dart';
import 'package:bingeit/application/user_profile_information/current_user_profile_information/current_user_profile_information_bloc.dart';
import 'package:bingeit/application/user_profile_information/current_user_profile_information/current_user_profile_watchlist_watched/movie_lists/movie_lists_user_profile_bloc.dart';
import 'package:bingeit/application/user_profile_information/current_user_profile_information/current_user_profile_watchlist_watched/tv_show_lists/tv_show_lists_user_profile_bloc.dart';
import 'package:bingeit/data/auth/auth_repository.dart';
import 'package:bingeit/data/search_db/actor_db/actor_repository.dart';
import 'package:bingeit/data/search_db/movie_db/movie_repository.dart';
import 'package:bingeit/data/search_db/tv_show_db/tv_show_repository.dart';
import 'package:bingeit/data/user_profile_db/current_user_profile_db/user_feedback_repository.dart';
import 'package:bingeit/data/user_profile_db/current_user_profile_db/user_profile_repository.dart';
import 'package:bingeit/data/user_profile_db/user_actions_db/user_actions_repository.dart';
import 'package:bingeit/presentation/pages/splash_page/splash_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bingeit/constants.dart';
import 'package:google_sign_in/google_sign_in.dart';

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

//


FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    //DeviceOrientation.landscapeRight,
    //DeviceOrientation.portraitDown,
    DeviceOrientation.portraitUp,
  ]);

  await Firebase.initializeApp();


  //String token=await FirebaseMessaging.instance.getToken();
  //await saveTokenToDatabase(token);
  FirebaseMessaging.onBackgroundMessage(_messageHandler);
  // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  //   print('Message received!');
  // });
  // FirebaseMessaging.onMessageOpenedApp.listen((message) {
  //   print('Message clicked!');
  // });
  // Any time the token refreshes, store this in the database too.
  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
    String userId = FirebaseAuth.instance.currentUser.uid;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .update({
      'tokens': newToken.toString(),
    });
  });
  FirebaseMessaging.instance.onTokenRefresh.listen(saveTokenToDatabase);

  Widget screenToShow;
  var connectivityResult = await (Connectivity().checkConnectivity());
  if (connectivityResult == ConnectivityResult.mobile ||
      connectivityResult == ConnectivityResult.wifi){
    screenToShow=SplashPage();
  } else {
    screenToShow=Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        child: Column(
          children: [
            Text("Please connect to internet.",
              style: TextStyle(
                fontSize: 25,
                color: darkBG,
                fontWeight: FontWeight.bold
              ),
            )
          ],
        ),
      ),
    );
  }

    var channel = const AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    'This channel is used for important notifications.', // description
    importance: Importance.high,
  );

  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  /// Create an Android Notification Channel.
  ///
  /// We use this channel in the `AndroidManifest.xml` file to override the
  /// default FCM channel to enable heads up notifications.
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  /// Update the iOS foreground notification presentation options to allow
  /// heads up notifications.
  await FirebaseMessaging.instance
      .setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage message) {
    print('getInitialMessage data: ${message.data}');

  });
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    RemoteNotification notification = message.notification;
    AndroidNotification android = message.notification?.android;

    if (notification != null && android != null) {


      flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channel.description,
              // TODO add a proper drawable resource to android, for now using
              //      one that already exists in example app.
              icon: 'launch_background',
            ),
          ));
    }
  });

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print('A new onMessageOpenedApp event was published!');

  });



  runApp(
    MyApp(screenToShow: screenToShow),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({
    Key key,
    @required this.screenToShow,
  }) : super(key: key);

  final Widget screenToShow;
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  AuthRepository _authRepository;
  UserProfileRepository _userProfileRepository;
  UserFeedbackRepository _userFeedbackRepository;
  MovieRepository _movieRepository;
  TvShowRepository _tvShowRepository;
  ActorRepository _actorRepository;
  UserActionsRepository _userActionsRepository;
  http.Client client;

  @override
  void initState() {
    super.initState();
    client = http.Client();
    _authRepository = AuthRepository();
    _userProfileRepository = UserProfileRepository();
    _userFeedbackRepository = UserFeedbackRepository();
    _movieRepository = MovieRepository(client);
    _tvShowRepository = TvShowRepository(client);
    _actorRepository = ActorRepository(client);
    _userActionsRepository = UserActionsRepository();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthCheckBloc(
            _authRepository,
          ),
        ),
        BlocProvider(
          create: (context) => SignInFormBloc(
            _authRepository,
          ),
        ),

        ///Search
        BlocProvider(
          create: (context) => MovieSearchBloc(
            _movieRepository,
          ),
        ),
        BlocProvider(
          create: (context) => TvShowSearchBloc(
            _tvShowRepository,
          ),
        ),
        BlocProvider(
          create: (context) => ActorSearchBloc(
            _actorRepository,
          ),
        ),
        BlocProvider(
          create: (context) => UserSearchBloc(
            _userActionsRepository,
          ),
        ),

        ///Current user info blocs
        BlocProvider(
            create: (context) => MovieListsUserProfileBloc(
                  _userProfileRepository,
                )),
        BlocProvider(
            create: (context) => TvShowListsUserProfileBloc(
                  _userProfileRepository,
                )),
        BlocProvider(
          create: (context) => FeedbackBloc(
            _userFeedbackRepository,
          ),
        ),
        BlocProvider(
          create: (context) => CurrentUserProfileInformationBloc(
            _userProfileRepository,
          ),
        ),
        BlocProvider(
          create: (context) => DeleteAccountBloc(
            _authRepository,
          ),
        ),
        BlocProvider(
          create: (context) => EditProfileBloc(
            _authRepository,
          ),
        ),
        BlocProvider(
          create: (context) => NotificationsBloc(
            _userActionsRepository,
          ),
        ),

        ///Global news feed
        BlocProvider(
          create: (context) => GlobalNewsFeedBloc(
            _userActionsRepository,
          ),
        ),

        ///User News feed
        BlocProvider(
          create: (context) => UserNewsFeedBloc(
            _userActionsRepository,
          ),
        ),

        ///Block Other Users
        BlocProvider(
          create: (context) => BlockUserBloc(
            _userFeedbackRepository,
          ),
        ),
      ],
      child: MaterialApp(
        title: 'bingeit',
        theme: ThemeData(
            fontFamily: 'Circular',
            primaryColor: darkBG,
            brightness: Brightness.dark,
            accentColor: Color(0xFF7579E7),
            cursorColor:Color(0xFF7579E7),
            textSelectionHandleColor: Color(0xFF7579E7),

        ),

        darkTheme: ThemeData(
            fontFamily: 'Circular',
            brightness: Brightness.dark,
            primaryColor: darkBG,
            accentColor:Color(0xFF7579E7),
            cursorColor: Color(0xFF7579E7),
            textSelectionHandleColor:Color(0xFF7579E7)),

        // theme: ThemeData(fontFamily: 'Circular',
        //   primaryColor: Color(0xff6398ff),
        // ),
        debugShowCheckedModeBanner: false,
        // theme: ThemeData.dark().copyWith(
        //   scaffoldBackgroundColor: Color(0xFF222831),
        //   fontFa
        //   inputDecorationTheme: InputDecorationTheme(
        //     border: OutlineInputBorder(
        //       borderRadius: BorderRadius.circular(25),
        //     ),
        //   ),
        // ),
        home: SplashPage(),
      ),
    );
  }
}
