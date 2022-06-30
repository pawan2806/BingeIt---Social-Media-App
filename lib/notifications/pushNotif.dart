import 'dart:async';
import 'dart:convert';

import 'package:bingeit/application/auth/auth_check/auth_check_bloc.dart';
import 'package:bingeit/application/auth/sign_in_form/delete_account/delete_account_bloc.dart';
import 'package:bingeit/application/auth/sign_in_form/edit_profile/edit_profile_bloc.dart';
import 'package:bingeit/application/auth/sign_in_form/sign_in_form_bloc.dart';
import 'package:bingeit/application/feedback/block_user/block_user_bloc.dart';
import 'package:bingeit/application/feedback/feedback_bloc.dart';
import 'package:bingeit/data/models/our_user/our_user.dart';
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
import 'package:dio/dio.dart';

var postUrl = "fcm.googleapis.com/fcm/send";

Future<void> sendNotification(String receiver, String msg) async {
  String tok;
  FirebaseFirestore.instance
      .collection('users')
      .doc(receiver)
      .get()
      .then((DocumentSnapshot documentSnapshot) {
    if (documentSnapshot.exists) {
      tok=documentSnapshot['tokens'].toString();
      print(tok);
    } else {
      print('Document does not exist on the database');
    }
  });
  String userId = FirebaseAuth.instance.currentUser.displayName;
  String mssg=userId + msg;
  print(mssg);



  try  {
    var dio = Dio();
    var response =  await dio.post('https://fcm.googleapis.com/fcm/send',
      options: Options(
        headers: {
          "content-type": "application/json",
          "Authorization": "key=AAAA47z86Vw:APA91bGbR_p5ZUQ1QvQqUwzW079EG2FM6dvLQEyhie3aXIvcGTtAk6OjBRzCse4GpuDIKQQqeWM4pE4lKqcbbss26dsEvX0DUyUz-vr7s7iwH1FvqDiFa2SUpka8e9OQTVaHUPh3tE85"
        },
      ),
      data: jsonEncode(
          {
            "to" : "$tok",
            "notification" : {
              "body" : "New Notification",
              "title": "$mssg",
              "sound": "Tri-tone"
            },
            "data": {
              "click_action": "FLUTTER_NOTIFICATION_CLICK",
              "id": "1",
              "status": "done"
            },

          }
      ),
    );
    print(response.statusCode);
  } catch (e) {
    print('exception $e');
  }

}
final FirebaseAuth auth = FirebaseAuth.instance;
Future<void> sendit(String ownerId, String msg) async {
  final uri = Uri.parse('https://fcm.googleapis.com/fcm/send');
  final User user = auth.currentUser;
  final uid = user.uid;
  String tok="error404";
  String name="error404";
  String use=ownerId;

  if(ownerId==uid){
    return ;
  }

  await FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .get()
      .then((DocumentSnapshot documentSnapshot) {
    if (documentSnapshot.exists) {
      name=documentSnapshot['username'].toString() + msg;

      print(name);
    } else {
      print('Document does not exist on the database');
    }
  });
  await FirebaseFirestore.instance
      .collection('users')
      .doc(use)
      .get()
      .then((DocumentSnapshot documentSnapshot) {
    if (documentSnapshot.exists) {
      tok=documentSnapshot['tokens'].toString();
      print(tok);
    } else {
      print('Document does not exist on the database');
    }
  });




  var body={
    "notification" : {
      "body": "$name",
      "title": "New Notification",
      "click_action": "FLUTTER_NOTIFICATION_CLICK",
    },
    "priority":"high",
    "data": {
      "body":"$name",
      "title": "New Notification",
      "click_action": "FLUTTER_NOTIFICATION_CLICK",
      "id": "1",
      "status": "done"
    },
//          "data":null,
    //"data":{},
    "to": "$tok"
  };
  http.Response response = await http.post( uri ,headers: {"Authorization": "key=AAAA47z86Vw:APA91bGbR_p5ZUQ1QvQqUwzW079EG2FM6dvLQEyhie3aXIvcGTtAk6OjBRzCse4GpuDIKQQqeWM4pE4lKqcbbss26dsEvX0DUyUz-vr7s7iwH1FvqDiFa2SUpka8e9OQTVaHUPh3tE85"
    ,"Content-Type": "application/json"},body: jsonEncode(body));

  print(response);
  print("===========================");
}

// Future<String> getToken(String userId) async {
//
//
//   var temp="343434";
//   FirebaseFirestore.instance
//       .collection('users')
//       .doc(userId)
//       .get()
//       .then((DocumentSnapshot documentSnapshot) {
//     if (documentSnapshot.exists) {
//       temp=documentSnapshot['tokens'];
//       print(temp);
//     } else {
//       print('Document does not exist on the database');
//     }
//   });
//   return temp.toString();
//
// }

class termsOfUse extends StatelessWidget {
  @override

  Widget build(BuildContext context) {

    return Padding(
      padding: EdgeInsets.all(8.0),
      child: AlertDialog(
         content: Text("hi"),
      )
    );
  }
}