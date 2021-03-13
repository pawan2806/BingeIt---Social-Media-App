import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class UploadPage extends StatefulWidget {
  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  File file;
  captureImageWithCamera() async {
    Navigator.pop(context);
    File imageFile= await ImagePicker.pickImage(
        source: ImageSource.camera,
      maxHeight: 680,
      maxWidth: 970,
    );
    setState(() {
      this.file=imageFile;
    });
  }

  pickImageFromGallery() async {
    Navigator.pop(context);
    File imageFile= await ImagePicker.pickImage(
      source: ImageSource.gallery,

    );
    setState(() {
      this.file=imageFile;
    });
  }

  takeImage(mContext){
    return showDialog(
      context: mContext,
      builder: (context){
        return SimpleDialog(
          title: Text(
            "New Post",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),

          ),
          children: <Widget>[
            SimpleDialogOption(
              child: Text("Capture Image with Camera", style: TextStyle(color: Colors.white),),
              onPressed: captureImageWithCamera,
            ),

            SimpleDialogOption(
              child: Text("Select Image from Gallery", style: TextStyle(color: Colors.white),),
              onPressed: pickImageFromGallery,
            ),
            SimpleDialogOption(
              child: Text("Cancel", style: TextStyle(color: Colors.white),),
                onPressed: () {
                  Navigator.pop(context);
                }
            ),
          ],
        );
      }
    );
  }

  displayUploadScreen(){
    return Container(
      color: Theme.of(context).accentColor.withOpacity(0.7),
      child: Column(

        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.add_photo_alternate, color: Colors.grey, size: 200.0,),
          Padding(
              padding:  EdgeInsets.only(top: 20.0),
            child: ElevatedButton(
                onPressed: ()=> takeImage(context),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith<Color>(
                        (Set<MaterialState> states) {
                      if (states.contains(MaterialState.pressed))
                        return Colors.green;
                      return Colors.green; // Use the component's default.
                    },
                  ),
                ),

                child: Container(

                  
                  child: Text(
                    "Upload Image",
                    style: TextStyle(color: Colors.white, fontSize: 20.0),
                  ),
                )
            )
          )
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return displayUploadScreen();
  }
}
