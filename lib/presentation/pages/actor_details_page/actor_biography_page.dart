import 'package:flutter/material.dart';

class ActorBiographyPage extends StatelessWidget {
  final String biography;

  ActorBiographyPage(this.biography);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1B1E2B),
      appBar: AppBar(

        title: Text(
          "Biography",
        ),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(biography),
          ),
        ],
      ),
    );
  }
}
