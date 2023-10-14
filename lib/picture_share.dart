import 'package:flutter/material.dart';
import 'package:glassmorphism_widgets/glassmorphism_widgets.dart';
import 'main.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:typed_data';

class AllPicPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'あなたのエモ写を定量化',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AllPicHomePage(title: 'みんなの写真広場'), // 新しいページに遷移
    );
  }
}

class AllPicHomePage extends StatefulWidget {
  const AllPicHomePage({super.key, required this.title});

  final String title;

  @override
  State<AllPicHomePage> createState() => AllPicHomePageState();
}

class AllPicHomePageState extends State<AllPicHomePage> {
  List<Uint8List> images = [];

  @override
  void initState() {
    super.initState();
    // Firebase Storageから画像をダウンロード
    downloadImages();
  }

  void downloadImages() async {
    final storage = FirebaseStorage.instance;
    // 画像へのパス（必要に応じて変更）
    final imagePaths = ['image/sample0', 'image/sample1', 'image/sample2'];

    for (var path in imagePaths) {
      try {
        final image = await storage.ref(path).getData();
        if (image != null) {
          setState(() {
            images.add(image);
          });
        }
      } catch (e) {
        print('Error downloading image: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GlassAppBar(
        blur: 500,
        title: Text(
          'みんなの写真広場',
          style: TextStyle(
            fontFamily: 'eri',
            color: Colors.blue,
            fontSize: 30,
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            ListTile(
              title: Text(
                '#エモさ定量化',
                style: TextStyle(
                  fontFamily: 'eri',
                  fontSize: 30,
                  color: Colors.blue,
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MyApp()), // メインページに遷移
                );
              },
            ),
            ListTile(
              title: Text(
                '#みんなの写真広場',
                style: TextStyle(
                  fontFamily: 'eri',
                  fontSize: 30,
                  color: Colors.blue,
                ),
              ),
              onTap: () {
                Navigator.pop(context); // このページに留まる
              },
            )
          ],
        ),
      ),
      // 他のウィジェットやコンテンツをここに追加
      body: Center(
      child: CarouselSlider(
      options: CarouselOptions(
      height: 400.0,
      ),
        items: images.map((imageData) {
          return Builder(
            builder: (BuildContext context) {
              return Container(
                width: MediaQuery.of(context).size.width,
                margin: const EdgeInsets.symmetric(horizontal: 5.0),
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: MemoryImage(imageData),
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          );
        }).toList(),
      ),
      ),
    );
  }
}
