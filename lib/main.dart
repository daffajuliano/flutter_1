import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http_parser/http_parser.dart';
import 'package:http/http.dart' as http;
import 'package:toast/toast.dart';
import 'package:mime/mime.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Image Picker Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  //final ImagePicker _imagePicker = ImagePickerChannel();

  File _imageFile;
  String address;
  double lat;
  double long;

  // mengambil gambar dari kamera atau galeri
  Future<void> captureImage(ImageSource imageSource, String type) async {
    try {
      File imageFile;
      if(type == "camera"){
        imageFile = await ImagePicker.pickImage(source: imageSource)
        .then((File recordedImage){
          if (recordedImage != null && recordedImage.path != null) {
            GallerySaver.saveImage(recordedImage.path).then((String) {
              setState(() {
                _imageFile = recordedImage;
              });
            });
          }
        });
      }else {
        imageFile = await ImagePicker.pickImage(source: imageSource);
      }

      setState(() {
        _imageFile = imageFile;
      });
    } catch (e) {
      print(e);
    }
  }

  // mengambil lokasi
  Future<void> getLoc() async {
    try {
      Position pos = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      double cLat = pos.latitude;
      double cLong = pos.longitude;
      List<Placemark> getAddress = await Geolocator().placemarkFromCoordinates(cLat, cLong);

      // urutkan address
      Placemark placemark = getAddress[0];
      String name = placemark.name;
      String administrativeArea = placemark.administrativeArea;
      String postalCode = placemark.postalCode;
      String subAdministrativeArea = placemark.subAdministrativeArea;

      setState(() {
        if(getAddress.isNotEmpty) {
          address = "$name $subAdministrativeArea $administrativeArea $postalCode";
          lat = cLat;
          long = cLong;
        }
      });
    } catch (e) {
      print(e);
    }
  }

  // mengecek gambar berhasil diambil atau tidak
  Widget _buildImage() {
    if (_imageFile != null) {
      return Image.file(_imageFile);
    } else {
      return Text('Take an image to start', style: TextStyle(fontSize: 18.0));
    }
  }

  uploadData() async{
    // cek ketersediaan gambar dan alamat
    if(_imageFile == null || address == null) {
      Toast.show("Belum ada gambar / lokasi", context, duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    } else {
      var uri = Uri.parse("http://05a0d01a.ngrok.io/api/saveUsers");
      // String image = base64Encode(_imageFile.readAsBytesSync());
      // String fileName = _imageFile.path.split("/").last;

      // var request = http.post(uri, body: {
      //   "location" : address, 
      //   "image" : image,
      //   "file_name" : fileName,
      // });
      final mimeDataType = lookupMimeType(_imageFile.path, headerBytes: [0xFF, 0xD8]).split('/');
      var request = http.MultipartRequest("POST", uri);
      request.fields['latitude'] = lat.toString();
      request.fields['longitude'] = long.toString();
      request.fields['location'] = address;
      request.files.add(
        await http.MultipartFile.fromPath("image", _imageFile.path,
          contentType: MediaType(mimeDataType[0], mimeDataType[1])
        )
      );

      request.send().then((response){
        if(response.statusCode == 200) {
          print("berhasil");
          Toast.show("Berhasil kirim gambar", context, duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        } else {
          print("gagal");
        }
      });
    }
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Expanded(child: Center(child: _buildImage())),
          Container(
            margin: EdgeInsets.only(top: 12, bottom: 0, left: 12, right: 12),
            child: address != null ? Text(address) : Text("Belum ada lokasi"),
          ),
          Container(
            margin: EdgeInsets.all(12),
            child: RaisedButton(
              color: Colors.blue,
              textColor: Colors.white,
              child: Text("lokasi"),
              onPressed: () => getLoc(),
            ),
          ),
          _buildButtons(),
        ],
      ),
    );
  }

  Widget _buildButtons() {
    return ConstrainedBox(
        constraints: BoxConstraints.expand(height: 80.0),
        child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              _buildActionButton(
                key: Key('retake'),
                icons: Icons.image,
                onPressed: () => captureImage(ImageSource.gallery, "gallery"),
              ),
              _buildActionButton(
                key: Key('send'),
                icons: Icons.send,
                onPressed: () => uploadData(),
              ),
              _buildActionButton(
                key: Key('upload'),
                icons: Icons.camera,
                onPressed: () => captureImage(ImageSource.camera, "camera"),
              ),
            ]));
  }

  Widget _buildActionButton({Key key, IconData icons, Function onPressed}) {
    return Expanded(
      child: FlatButton(
          key: key,
          child: Icon(icons),
          shape: RoundedRectangleBorder(),
          color: Colors.blueAccent,
          textColor: Colors.white,
          onPressed: onPressed),
    );
  }
}