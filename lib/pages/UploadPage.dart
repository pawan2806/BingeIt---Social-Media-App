
import 'package:buddiesgram/pages/HomePage.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:buddiesgram/models/user.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:image/image.dart' as InD;

class UploadPage extends StatefulWidget {
  final User gCurrentUser;
  UploadPage({this.gCurrentUser});

  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> with AutomaticKeepAliveClientMixin<UploadPage>{
  bool uploading=false;
  String postID=Uuid().v4();
  File file;
  TextEditingController descriptionTextEditingController = TextEditingController();
  TextEditingController locationTextEditingController = TextEditingController();

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

  clearPostInfo(){
    setState(() {
      file=null;
      locationTextEditingController.clear();
      descriptionTextEditingController.clear();
    });
  }

  getUserCurrentLocation() async {
    Position position= await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    List<Placemark> placeMarks= await Geolocator().placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark mPlaceMark= placeMarks[0];
    String completeAddressInfo = '${mPlaceMark.subThoroughfare} ${mPlaceMark.thoroughfare}, ${mPlaceMark.subLocality} ${mPlaceMark.locality}, ${mPlaceMark.subAdministrativeArea} ${mPlaceMark.administrativeArea}, ${mPlaceMark.postalCode} ${mPlaceMark.country},';
    String specificAddress = '${mPlaceMark.locality}, ${mPlaceMark.country}';
    locationTextEditingController.text = specificAddress;

  }
  compressingPhoto() async {
    final tDirectory=await getTemporaryDirectory();
    final path=tDirectory.path;
    InD.Image mImageFile=InD.decodeImage(file.readAsBytesSync());
    final compressesImageFile=File('$path/img_$postID.jpg')..writeAsBytesSync(InD.encodeJpg(mImageFile, quality: 60));
    setState(() {

      file=compressesImageFile;
    });
  }


  controlUploadAndSave() async {
    setState(() {
      uploading=true;
    });

    await compressingPhoto();
    String downloadUrl=await uploadPhoto(file);

    savePostInfoToFireStore(downloadUrl, locationTextEditingController.text, descriptionTextEditingController.text);

    locationTextEditingController.clear();
    setState(() {
      file=null;
      uploading=false;
      postID=Uuid().v4();
    });
  }
  savePostInfoToFireStore(String url, String location, String description){
    postsReference.document(widget.gCurrentUser.id).collection("userPosts").document(postID).setData({
      "postID":postID,
      "ownerID": widget.gCurrentUser.id,
      "likes":{},
    "username": widget.gCurrentUser.username,
      "timestamp":timestamp,
    "description":description,
    "location": location,
    "url":url,


    });
  }

  Future<String> uploadPhoto(mImageFile) async {
    StorageUploadTask mStorageUploadTask=storageRefrence.child("post_$postID.jpg").putFile(mImageFile);
    StorageTaskSnapshot storageTaskSnapshot=await mStorageUploadTask.onComplete;
    String downloadUrl=await storageTaskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }


  displayUploadFormScreen() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
          leading :IconButton(icon: Icon(Icons.arrow_back, color: Colors.white,), onPressed: clearPostInfo),
        title: Text("New Post", style: TextStyle(fontSize: 24.0, color: Colors.white, fontWeight: FontWeight.bold),),
        actions: <Widget>[
          GestureDetector(
            onTap: uploading?null: ()=> controlUploadAndSave(),
            child: Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Share",
                    style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 16.0),
                  ),
                ],
              ),
            ),

          )

          // ElevatedButton(
          //   onPressed: ()=> print("hello"),
          //   style: ButtonStyle(
          //     backgroundColor: MaterialStateProperty.resolveWith<Color>(
          //           (Set<MaterialState> states) {
          //         if (states.contains(MaterialState.pressed))
          //           return Colors.green;
          //         return Colors.green; // Use the component's default.
          //       },
          //     ),
          //   ),
          //     child: Container(
          //
          //
          //
          //       child: Text(
          //           "Share",
          //           style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16.0),
          //       ),
          //     ),
          //
          //
          //    // child: Text("Share", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16.0),),
          // ),
        ],
      ),
      body: ListView(
        children: <Widget>[
          uploading? LinearProgressIndicator():Text(""),
          Container(
            height: 230.0,
            width: MediaQuery.of(context).size.width*0.8,
            child: Center(
              child: AspectRatio(
                aspectRatio: 16/9,
                child: Container(
                  decoration: BoxDecoration(image: DecorationImage(image: FileImage(file), fit: BoxFit.cover,)),
                ),
              ),
            ),

          ),
          Padding(padding: EdgeInsets.only(top: 12.0),),
          ListTile(
            leading: CircleAvatar(backgroundImage: CachedNetworkImageProvider(widget.gCurrentUser.url),),
            title: Container(
              width: 250.0,
              child: TextField(
                style: TextStyle(color: Colors.white),
                controller: descriptionTextEditingController,
                decoration: InputDecoration(
                  hintText: "Give a description",
                  hintStyle: TextStyle(color:Colors.white),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.person_pin, color: Colors.white,size: 36.0,),
            title: Container(
              width: 250.0,
              child: TextField(
                style: TextStyle(color: Colors.white),
                controller: locationTextEditingController,
                decoration: InputDecoration(
                    hintText: "Give a location",
                    hintStyle: TextStyle(color:Colors.white),
                    border: InputBorder.none,
                ),
              ),
            ),
          ),
          Container(
            width: 220.0,
            height: 110.0,
            alignment: Alignment.center,
            child:ElevatedButton.icon(
                onPressed: getUserCurrentLocation,
                icon: Icon(Icons.location_on_outlined,color: Colors.white,),
                label: Text(
                  "Get Current Location",
                  style: TextStyle(color: Colors.white),
                )
            ),
          )


        ],
      ),
    );
  }

  bool get wantKeepAlive=>true;
  @override
  Widget build(BuildContext context) {
    return file==null ?displayUploadScreen(): displayUploadFormScreen();
  }
}
