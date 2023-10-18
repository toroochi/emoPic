import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:glassmorphism_widgets/glassmorphism_widgets.dart';
import 'picture_share.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'firebase_options.dart';
import 'package:firebase_database/firebase_database.dart';

import 'package:flutter_radar_chart/flutter_radar_chart.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, //firebaseの初期化
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'あなたのエモ写を定量化',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Scrolling Fade Image'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool showRadarChart = false;
  DatabaseReference ref = FirebaseDatabase.instance.ref();
  final a = FirebaseDatabase.instance.ref();

  int i = 0;
  final _auth = FirebaseAuth.instance;
  Uint8List? imageData;

  ScrollController _controller = ScrollController();
  double _opacity = 1.0; // 初期の不透明度
  double _scrollThreshold = 500.0; // フェードアウトの閾値

  bool useSides = false;
  double numberOfFeatures = 6;

  void uploadPicture() async {
    try {
      Uint8List? uint8list =
          await ImagePickerWeb.getImageAsBytes(); //画像をバイトとしてロード
      if (uint8list != null) {
        var metadata = SettableMetadata(
          contentType: "image/jpeg",
        );
        FirebaseStorage.instance
            .ref("image/sample" + i.toString())
            .putData(uint8list, metadata);
        i++;
        updateRadarChartData();
        // アップロード後、ダウンロードして画像を表示
        var imageURL =
            await FirebaseStorage.instance.ref("image/sample").getDownloadURL();
        setState(() {
          imageData = uint8list;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  void updateRadarChartData() {
    // データを適切に更新するロジックをここで実装
    // 例: Firebase Realtime Databaseからデータを取得し、chartDataを更新

    // 更新が完了したら、画面を再ビルド
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    _controller.addListener(() {
      // スクロール位置に応じて不透明度を計算
      double offset = _controller.offset;

      if (offset < _scrollThreshold) {
        double opacity = 1.0 - (offset / _scrollThreshold);
        if (opacity < 0.0) {
          opacity = 0.0;
        }
        setState(() {
          _opacity = opacity;
        });
      } else {
        setState(() {
          _opacity = 0.0; // 閾値を超えたら不透明度を0に設定
        });
      }
    });
  }

  var ticks = [0, 2, 4, 6, 8, 10];
  late List<List<num>> data = [
    [5, 5, 5, 5, 5, 5]
  ];
  @override
  Widget build(BuildContext context) {
    var features = [
      "emotional",
      "happy",
      "sad",
      "angry",
      "anxious",
      "surprised"
    ];
    features = features.sublist(0, numberOfFeatures.floor());

    return Scaffold(
      appBar: GlassAppBar(
        blur: 500,
        title: Text(
          'あなたのエモ写を定量化。',
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
                Navigator.pop(context);
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
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AllPicPage()),
                );
              },
            )
          ],
        ),
      ),
      body: Stack(
        children: <Widget>[
          SingleChildScrollView(
            controller: _controller,
            child: Column(
              children: <Widget>[
                AnimatedOpacity(
                  duration: Duration(milliseconds: 500),
                  opacity: _opacity,
                  child: Image.asset(
                    'images/sky_00184.jpeg',
                  ),
                ),
                Text(
                  '''あなたの写真のエモさを、
                      CLIPを用いたモデルで数値として可視化します.''',
                  style: TextStyle(
                    fontFamily: 'eri',
                    color: Colors.blue,
                    fontSize: 40,
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  heightFactor: 2,
                  child: SizedBox(
                    width: 200,
                    height: 200,
                    child: ElevatedButton(
                      child: const Text(
                        '''   画像を
                        アップロード''',
                        style: TextStyle(
                            color: Colors.blue,
                            fontSize: 25,
                            fontFamily: 'eri'),
                      ),
                      style: ElevatedButton.styleFrom(
                        primary: Colors.white,
                        onPrimary: Colors.lightBlueAccent,
                        shape: const CircleBorder(
                          side: BorderSide(
                            color: Colors.lightBlue,
                            width: 1,
                            style: BorderStyle.solid,
                          ),
                        ),
                      ),
                      onPressed: () async {
                        uploadPicture();
                        Uri url = Uri.parse(
                            "http://127.0.0.1:8000/items/sample" +
                                i.toString());
                        try {
                          setState(() {
                            showRadarChart = true;
                          });
                          //リクエストを投げる
                          var res = await http.get(url);
                          //リクエスト結果をコンソール出力
                          Map<String, dynamic> map2 = jsonDecode(res.body);

                          data[0][0] = (map2["emotional"] ?? -1);
                          data[0][1] = (map2["happy"] ?? -1);
                          data[0][2] = (map2["sad"] ?? -1);
                          data[0][3] = (map2["angry"] ?? -1);
                          data[0][4] = (map2["anxious"] ?? -1);
                          data[0][5] = (map2["surprised"] ?? -1);
                          for (var i = 0; i < 6; i++) {
                            data[0][i] *= 10;
                          }

                          data = data
                              .map((graph) =>
                                  graph.sublist(0, numberOfFeatures.floor()))
                              .toList();

                          debugPrint(res.body);
                          setState(() {
                            showRadarChart = true;
                          });
                        } catch (e) {
                          //リクエストに失敗した場合は"error"と表示
                          debugPrint("error");
                        }
                        await ref.set(i);
                      },
                    ),
                  ),
                ),
                SizedBox(
                  height: 200,
                ),
                Row(children: [
                  if (imageData != null)
                    Image.memory(
                      //image.memoryデータを画像に変換
                      imageData!,
                      width: 300, // 画像の幅を調整
                    ),
                  if (showRadarChart)
                    Container(
                      height: 300,
                      width: 300,
                      child: RadarChart.light(
                        ticks: ticks,
                        features: features,
                        data: data,
                        reverseAxis: false,
                        useSides: useSides,
                      ),
                    ),
                ])
              ],
            ),
          ),
          AnimatedOpacity(
            duration: Duration(milliseconds: 500),
            opacity: _opacity,
            child: IgnorePointer(
              ignoring: true,
              child: Align(
                alignment: Alignment.center,
                child: GlassContainer(
                  width: 1000,
                  height: 500,
                  blur: 10,
                  borderGradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.1),
                      Colors.white.withOpacity(0.1),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(25),
                    child: Text(
                      '''#あなたのエモ写を教えて。
                    #エモさの可視化''',
                      style: TextStyle(
                        fontFamily: 'eri',
                        color: Colors.white,
                        fontSize: 120,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
