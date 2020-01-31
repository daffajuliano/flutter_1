// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:camera/camera.dart';

// List<CameraDescription> cameras;

// class SignIn extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: "Foto",
//       home: Scaffold(
//           appBar: AppBar(title: Text("Foto")),
//           body: SingleChildScrollView(
//             padding: EdgeInsets.all(12),
//             child: Column(children: [
//               Container(
//                 margin: EdgeInsets.only(bottom: 8),
//                 child: Image.asset('asset/image/gambar1.jpg'),
//               ),
//               Container(
//                 child: RaisedButton(
//                     color: Colors.blue,
//                     textColor: Colors.white,
//                     onPressed: () {
//                       CameraWidget();
//                     },
//                     child: Text("Take Picture")),
//               )
//             ]),
//           )),
//     );
//   }
// }

// class CameraWidget extends StatefulWidget {
//   @override
//   State<StatefulWidget> createState() => CameraState();
// }

// class CameraState extends State<CameraWidget> {
//   List<CameraDescription> cameras;
//   CameraController controller;
//   bool isReady = false;

//   @override
//   void initState() {
//     super.initState();

//   }

//   Future<void> setupCameras() async {
//     try {
//       cameras = await availableCameras();
//       controller = new CameraController(cameras[0], ResolutionPreset.medium);
//       await controller.initialize();
//     } on CameraException catch (_) {
//       setState(() {
//         isReady = false;
//       });
//     }
    
//     setState(() {
//       isReady = true;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     if(!isReady && !controller.value.isInitialized){
//       return Container();
//     }
//     return AspectRatio(
//       aspectRatio: controller.value.aspectRatio,
//       child: CameraPreview(controller),
//     );
//   }
// }
