import 'package:flutter/material.dart';


class CommentsPage extends StatefulWidget
{
  final String postId;
  final String postOwnerId;
  final String postImageUrl;

  CommentsPage({this.postId, this.postOwnerId, this.postImageUrl});

  @override
  CommentsPageState createState() => CommentsPageState(postId: postId, postOwnerId: postOwnerId, postImageUrl: postImageUrl);
}


class CommentsPageState extends State<CommentsPage> {
  @override
  Widget build(BuildContext context) {
    return Text('Here goes Comments Page');
  }
}

class Comment extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text('Comment');
  }
}
