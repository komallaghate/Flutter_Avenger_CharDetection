import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

class Home extends StatefulWidget {
  Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Future<File>? imageFile;
  File? _image;
  String result = '';
  ImagePicker? imagePicker;

  pickFromGallery() async {
    XFile? pickedFile =
        await imagePicker!.pickImage(source: ImageSource.gallery);
    _image = File(pickedFile!.path);
    setState(() {
      _image;
      doImageClassification();
    });
  }

  capturePhoto() async {
    XFile? pickedFile =
        await imagePicker!.pickImage(source: ImageSource.camera);
    _image = File(pickedFile!.path);
    _image == null
        ? Navigator.of(context).pop
        : setState(() {
            _image;
            doImageClassification();
          });
  }

  loadDataModelFiles() async {
    String? output = await Tflite.loadModel(
        model: 'assets/model_unquant.tflite',
        labels: 'assets/labels.txt',
        numThreads: 1,
        isAsset: true,
        useGpuDelegate: false);
    print(output);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    imagePicker = ImagePicker();
    loadDataModelFiles();
  }

  doImageClassification() async {
    var recognitions = await Tflite.runModelOnImage(
        path: _image!.path,
        imageMean: 0.0,
        imageStd: 255.0,
        numResults: 2, // 2 results per image prediction
        threshold: 0.1,
        asynch: true);
    print(recognitions!.length.toString());
    setState(() {
      result = '';
    });
    recognitions.forEach((element) {
      setState(() {
        print(element.toString());
        result += element['label'] + '\n\n';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/background-avengers-marvel.jpg'),
                  fit: BoxFit.cover)),
          child: Column(
            children: [
              const SizedBox(width: 100.0),
              Container(
                  margin: const EdgeInsets.only(top: 70.0),
                  child: Stack(
                    children: <Widget>[
                      Center(
                          child: TextButton(
                        onPressed: capturePhoto,
                        onLongPress: pickFromGallery,
                        child: Container(
                            margin: const EdgeInsets.only(
                                top: 50.0, right: 35.0, left: 35.0),
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: Colors.black, width: 1.5)),
                            child: _image != null
                                ? Image.file(
                                    _image!,
                                    height: 360.0,
                                    width: 400.0,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    width: 140.0,
                                    height: 190.0,
                                    child: const Icon(
                                      Icons.camera_alt_rounded,
                                      color: Colors.black,
                                    ))),
                      ))
                    ],
                  )),
              const SizedBox(height: 100.0),
              Container(
                  color: Colors.white.withOpacity(0.8),
                  // margin: const EdgeInsets.only(top: 20.0),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Center(
                      child: Text(
                        '$result',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 35.0,
                          color: Colors.black,
                          // backgroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ))
            ],
          )),
    );
  }
}
