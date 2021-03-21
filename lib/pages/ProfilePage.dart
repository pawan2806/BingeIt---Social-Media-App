import 'package:buddiesgram/models/user.dart';
import 'package:buddiesgram/pages/HomePage.dart';
import 'package:buddiesgram/widgets/ProgressWidget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:buddiesgram/pages/EditProfilePage.dart';
import 'package:buddiesgram/widgets/HeaderWidget.dart';
class ProfilePage extends StatefulWidget {
  final String userProfileId;
  ProfilePage({this.userProfileId});
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final String currentOnlineUserId = currentUser?.id;

  void initState(){
    super.initState();


  }




  createProfileTopView(){
    return FutureBuilder(
        future: usersReference.document(widget.userProfileId).get(),
        builder: (context, dataSnapshot){
          if(!dataSnapshot.hasData){
            return circularProgress();
          }
          User user=User.fromDocument(dataSnapshot.data);
          return Padding(
              padding: EdgeInsets.all(17.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,


              children: <Widget>[
                // Container(
                //   alignment: Alignment.topLeft,
                //   //padding: EdgeInsets.only(top: 13.0),
                //   child: Text(
                //     user.username,
                //     textAlign: TextAlign.end,
                //     style: TextStyle(fontSize: 14.0, color: Colors.white, fontWeight: FontWeight.w500),
                //   ),
                // ),
                Row(

                  children: <Widget>[
                    CircleAvatar(
                      radius: 45.0,
                      backgroundColor: Colors.grey,
                      backgroundImage: CachedNetworkImageProvider(user.url),
                    ),
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: <Widget>[
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              createColumn("Posts", 0),
                              createColumn("Followers", 0),
                              createColumn("Following", 0),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              createButton(),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(top: 10.0),

                  child: Text(
                    user.profileName + " | @"+ user.username , style: TextStyle(fontSize: 16.0, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(top: 3.0),

                  child: Text(
                    user.bio, style: TextStyle(fontSize: 16.0, color: Colors.white70, fontWeight: FontWeight.bold),
                  ),
                ),

              ],
            ),
          );
        },
    );
  }







  Column createColumn(String title, int count) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          count.toString(),
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20.0),

        ),
        Container(
          margin: EdgeInsets.only(top: 5.0),
          child: Text(
            title,
            style: TextStyle(fontWeight: FontWeight.w400, color: Colors.grey, fontSize: 16.0),

          ),
        )
      ],
    );
  }
  createButton(){
    bool ownProfile=currentOnlineUserId==widget.userProfileId;
    if(ownProfile){
      return createButtonTitleAndFunction(title:"Edit Profile", performFunction:editUserProfile);
    }
  }

  Container createButtonTitleAndFunction({String title, Function performFunction}){
    return Container(
      padding: EdgeInsets.only(top: 3.0),
      child: FlatButton(
        onPressed: performFunction,
        child: Container(

          width: MediaQuery.of(context).size.width*0.6,
          height: 26.0,
          child: Text(
            title,
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
          ),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.black,
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      ),
    );
  }

  editUserProfile(){
    Navigator.push(context, MaterialPageRoute(builder: (context)=> EditProfilePage(currentOnlineUserId: currentOnlineUserId)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, strTitle:"Profile"),
      body: ListView(

        children: <Widget>[
          createProfileTopView(),
        ],
      ),
    );
  }
}
