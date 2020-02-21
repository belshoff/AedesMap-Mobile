import 'dart:io';
import 'dart:async';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:simple_animations/simple_animations/controlled_animation.dart';
import 'package:simple_animations/simple_animations/multi_track_tween.dart';

class SendScreen extends StatefulWidget {
  @override
  _SendScreenState createState() => _SendScreenState();
}

class _SendScreenState extends State<SendScreen> {
  File image;
  Position currentPosition;
  int _currentIndex = 0;
  bool uploaded = false;
  bool uploading = false;

  final tween = MultiTrackTween(
    [
      Track("size").add(Duration(seconds: 2), Tween(begin: 500.0, end: 0.0)),
      Track("rotation").add(Duration(seconds: 2), ConstantTween(0.0))
    ],
  );

  /// Pegar Geolocalização do dispositivo.
  _getPosition() async {
    var location = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      currentPosition = location;
    });
  }

  _resetData() {
    print("_resetData");
    setState(() {
      uploading = false;
      uploaded = false;
      image = null;
    });
  }

  /// Enviar imagem para o Storage..
  _sendImage() async {
    setState(() {
      uploading = true;
    });

    String filename = path.basename(image.path);
    final StorageReference store =
        FirebaseStorage.instance.ref().child(filename);
    final StorageUploadTask task = store.putFile(image);
    final StorageTaskSnapshot downloadUrl = (await task.onComplete);
    final String url = (await downloadUrl.ref.getDownloadURL());
    print("Enviado $url");

    await postImage("$url").then((_) => _resetData());
  }

  Future<int> postImage(String url) async {
    var body = {
      "urlImage": url,
      "latitude": "${currentPosition.latitude}",
      "longitude": "${currentPosition.longitude}"
    };

    var response = await http.post(
        Uri.encodeFull("https://aedesmapapi.herokuapp.com/location"),
        headers: {"Accept": "application/json"},
        body: body);

    return response.statusCode;
  }

  /// Receber uma imagem do dispositivo.
  _getImage(ImageSource source) async {
    _getPosition();
    var photo = await ImagePicker.pickImage(source: source);
    photo != null
        ? setState(() {
            image = photo;
          })
        : setState(() {});
  }

  _setIndex(int index) {
    List<ImageSource> sources = [ImageSource.camera, ImageSource.gallery];
    _getImage(sources[index]);
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  Widget buildAnimation() {
    return ControlledAnimation(
      playback: Playback.MIRROR,
      duration: tween.duration,
      tween: tween,
      builder: (context, animation) {
        return Transform.rotate(
            angle: animation["rotation"],
            child: Column(
              children: <Widget>[
                Image.file(image,
                    height: animation["size"], width: animation["size"]),
              ],
            ));
      },
    );
  }

  // Botões de Ação da imagem.
  Widget sendButton() {
    return Align(
      alignment: Alignment(1.0, 0.8),
      child: FloatingActionButton(
        onPressed: () {
          _sendImage();
        },
        child: uploading
            ? CircularProgressIndicator()
            : Icon(Icons.send, color: Colors.teal),
        backgroundColor: Colors.white,
      ),
    );
  }

  Widget cancelButton() {
    return Align(
      alignment: Alignment(1.0, 1.0),
      child: uploading
          ? null
          : FloatingActionButton(
              onPressed: () {
                _resetData();
              },
              child: Icon(Icons.cancel, color: Colors.red),
              backgroundColor: Colors.white,
            ),
    );
  }

  Widget getImage(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final Color mainColor = Colors.grey;
    if (image == null) {
      return Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Spacer(),
            InkWell(
              child: Image.asset('assets/launcher/logo.png', height: height * 0.30)
              // Image(image: AssetImage('../assets/launcher/logo.png', height: height * 0.75)),
            ),
            Spacer(),
            InkWell(
              onTap: () { _getImage(ImageSource.camera); },
              child: DottedBorder(
                color: mainColor,
                strokeWidth: 2,
                padding: EdgeInsets.all(4),
                dashPattern: [9, 5],
                child: Container(
                  margin: EdgeInsets.only(top: 20.0, bottom: 20.0),
                  // margin: EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        margin: const EdgeInsets.only( right: 25.0 ),
                        child: Icon(
                          Icons.camera_alt,
                          size: 25,
                          color: mainColor
                        ),
                      ),
                      Container(
                        child: Text("Câmera",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 30,
                            color: mainColor
                          )
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Spacer(),
            InkWell(
              onTap: () { _getImage(ImageSource.gallery); },
              child: DottedBorder(
                color: mainColor,
                strokeWidth: 2,
                padding: EdgeInsets.all(4),
                dashPattern: [9, 5],
                child: Container(
                  // margin: EdgeInsets.all(20),
                  margin: EdgeInsets.only(top: 20.0, bottom: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        margin: const EdgeInsets.only(right: 25.0),
                        child: Icon(
                          Icons.image,
                          size: 25,
                          color: mainColor
                        ),
                      ),
                      Container(
                        child: Text("Galeria",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 30,
                            color: mainColor
                          )
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Spacer(),
          ],
        ),
      );
      // return ;
    } else if (uploaded) {
      return buildAnimation();
    } else {
      return Container(
          alignment: Alignment.topCenter,
          child: Column(
            children: <Widget>[
              Image.file(image, height: height * 0.75),
              currentPosition != null
                  ? Text(
                      "$currentPosition",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    )
                  : Text("Can't GET position.")
            ],
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Aedes Map',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          centerTitle: true,
          backgroundColor: Colors.blue,
        ),
        body: Container(
          padding: const EdgeInsets.all(8),
          child: getImage(context),
          alignment: Alignment.topCenter,
        ),
        floatingActionButton: Stack(
          children: image != null && currentPosition != null
              ? <Widget>[
                  sendButton(),
                  cancelButton(),
                ]
              : <Widget>[],
        ),
        // bottomNavigationBar: BottomNavigationBar(
        //   items: <BottomNavigationBarItem>[
        //     BottomNavigationBarItem(
        //       icon: Icon(Icons.camera_alt),
        //       title: Text("Camera"),
        //     ),
        //     BottomNavigationBarItem(
        //       icon: Icon(Icons.image),
        //       title: Text("Galeria"),
        //     )
        //   ],
        //   selectedItemColor: Colors.white,
        //   unselectedItemColor: Colors.white,
        //   backgroundColor: Colors.blue,
        //   currentIndex: _currentIndex,
        //   onTap: _setIndex,
        // )
    );
  }
}
