import 'dart:io';

import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';

class SendScreen extends StatefulWidget {
  @override
  _SendScreenState createState() => _SendScreenState();
}

class _SendScreenState extends State<SendScreen> {

  File image;
  Position currentPosition;
  int _currentIndex = 0;

  _getPosition() async {
    print("GET LOCATION");
    var location = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      currentPosition = location;
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

  _getImage(ImageSource source) async {
    _getPosition();
    var photo = await ImagePicker.pickImage(source: source);
    photo != null ? setState(() { image = photo; }) : setState(() { }) ;
  }

  void _setIndex ( int index ) {
    List<ImageSource> sources = [ImageSource.camera, ImageSource.gallery];
    _getImage(sources[index]);
    setState(() {
      _currentIndex = index;
    });
  }

  Widget getImage () {
    if ( image == null ) {
      return Text("No Image", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24));
    } else {
      // return Image.file(image, height: 500);
      return Container(
        alignment: Alignment.topCenter,
        child: Column(
          children: <Widget>[
            Image.file(image, height: 500),
            currentPosition != null ? Text("$currentPosition", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),) : Text("Can't GET position.")
          ],
        )
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aedes Map', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Container(
        padding: const EdgeInsets.all(8),
        child: getImage(),
        alignment: Alignment.topCenter,
      ),
      floatingActionButton: Stack(
        children: image != null && currentPosition != null ? <Widget>[
          Align(
            alignment: Alignment(1.0, 0.8),
            child: FloatingActionButton(
              onPressed: () { print("Um dia vai enviar."); },
              child: Icon(Icons.send, color: Colors.teal),
              backgroundColor: Colors.white,
            ),
          ),
          Align(
            alignment: Alignment(1.0, 1.0),
            child: FloatingActionButton(
              onPressed: () {
                setState(() { image = null; });
              },
              child: Icon(Icons.cancel, color: Colors.red),
              backgroundColor: Colors.white,
            ),
          ),
        ] : <Widget>[] ,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt),
            title: Text("Camera"),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.image),
            title: Text("Galeria"),
          )
        ],
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white,
        backgroundColor: Colors.blue,
        currentIndex: _currentIndex,
        onTap: _setIndex,
      )
    );
  }
}