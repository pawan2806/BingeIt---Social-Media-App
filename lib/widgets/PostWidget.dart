import 'package:buddiesgram/models/user.dart';
import 'package:buddiesgram/pages/HomePage.dart';
import 'package:buddiesgram/widgets/CImageWidget.dart';
import 'package:buddiesgram/widgets/ProgressWidget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Post extends StatefulWidget {
  final String postID;
  final String ownerID;
  //final String timestamp;
  final dynamic likes ;
  final String username;
  final String description;
  final String location;
  final String url;
  Post({
    this.postID,
    this.ownerID,
    //this.timestamp,
    this.likes,
    this.username,
    this.description,
    this.location,
    this.url

});

  factory Post.fromDocument(DocumentSnapshot documentSnapshot){
    return Post(
      postID: documentSnapshot["postID"],
      ownerID: documentSnapshot["ownerID"],
      //timestamp: documentSnapshot["timestamp"],
      likes: documentSnapshot["likes"],
      username: documentSnapshot["username"],
      description: documentSnapshot["description"],
      location: documentSnapshot["location"],
      url: documentSnapshot["url"],

    );
  }

  int getTotalNumberofLikes(likes){
    if(likes==null){
      return 0;
    }
    int counter=0;
    likes.values.forEach((eachValue){
      if(eachValue==true){
        counter=counter+1;
      }
    });

    return counter;
  }

  @override
  _PostState createState() => _PostState(
    postID:this.postID,

      ownerID: this.ownerID,
      //this.timestamp,
      likes: this.likes,
      username:this.username,
      description:this.description,
      location: this.location,
      url: this.url,
    likeCount:getTotalNumberofLikes(this.likes),

  );
}

class _PostState extends State<Post> {
  final String postID;
  final String ownerID;
  //final String timestamp;
  Map likes ;
  final String username;
  final String description;
  final String location;
  final String url;
  int likeCount;
  bool isLiked;
  bool showHeart=false;
  final String currentOnlineUserId=currentUser?.id;
  _PostState({
    this.postID,
    this.ownerID,
    //this.timestamp,
    this.likes,
    this.username,
    this.description,
    this.location,
    this.url,
    this.likeCount

  });
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          createPostHead(),
          createPostPicture(),
          createPostFooter(),
        ],
      ),
    );
  }

  createPostHead() {
    return FutureBuilder(
        future:usersReference.document(ownerID).get(),
      builder: (context, dataSnapshot){
          if(!dataSnapshot.hasData){
            return circularProgress();
          }

          User user=User.fromDocument(dataSnapshot.data);
          bool isPostOwner=currentOnlineUserId==ownerID;
          return ListTile(
            leading: CircleAvatar(backgroundImage: CachedNetworkImageProvider(user.url), backgroundColor: Colors.grey,),
            title: GestureDetector(
              onTap: ()=> print("show profile"),
              child: Text(
                user.username,
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            subtitle: Text(location, style: TextStyle(color: Colors.white),),
            trailing: isPostOwner ? IconButton(
              icon: Icon(Icons.more_vert, color: Colors.white,),
              onPressed: ()=> print("deleted"),
            ) : Text(""),
          );
      },
    );
  }

  createPostPicture(){
    return GestureDetector(
      onDoubleTap: ()=> print("post liked"),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.network(url),
        ],
      ),
    );
  }

  createPostFooter(){
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(padding : EdgeInsets.only(top: 40.0, left: 20.0)),
            GestureDetector(
              onTap: ()=> print("LIKED"),
              child: Icon(
                Icons.favorite,color: Colors.grey,
                // isLiked?Icons.favorite: Icons.favorite_border,
                // size: 20.0,
                //   color: Colors.pink ,
              ),
            ),
            Padding(padding : EdgeInsets.only(right: 20.0)),
            GestureDetector(
              onTap: ()=> print("show comment"),
              child: Icon(
                Icons.chat_bubble_outline,
                size: 28.0,
                color: Colors.white,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Container(
              margin: EdgeInsets.only(left: 20.0),
              child: Text(
                "$likeCount likes",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
        Row(
          crossAxisAlignment:CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(left: 20.0),
              child: Text(
                "$username",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(child: Text(description,
            style: TextStyle(color: Colors.white),)),
          ],
        )
      ],
    );
  }

}
