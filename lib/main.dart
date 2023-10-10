import 'package:flutter/material.dart';
import 'package:glassmorphism_widgets/glassmorphism_widgets.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
  ScrollController _controller = ScrollController();
  double _opacity = 1.0; // 初期の不透明度
  double _scrollThreshold = 500.0; // フェードアウトの閾値

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


  @override
  Widget build(BuildContext context) {
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
              onTap: () {},
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
              onTap: () {},
            )
          ],
        ),
      ),
      backgroundColor: Colors.white,
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
                  child: OutlinedButton(
                    onPressed: () {
                      // 画像のアップロード時の処理を書く
                    },
                    child: Text(
                      '画像をアップロード',
                      style: TextStyle(
                        fontFamily: 'eri',
                        fontSize: 30,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 580,
                ),
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
