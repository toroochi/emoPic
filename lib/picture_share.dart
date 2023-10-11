import 'package:flutter/material.dart';
import 'package:glassmorphism_widgets/glassmorphism_widgets.dart';
import 'main.dart';

class AllPicPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'あなたのエモ写を定量化',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}

class _AllPicPage extends StatefulWidget {
  const _AllPicPage({super.key, required this.title});

  final String title;

  @override
  State<_AllPicPage> createState() => _AllPicPageState();
}

class _AllPicPageState extends State<_AllPicPage>{

  @override
  Widget build(BuildContext context){
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
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MyApp()),
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
                Navigator.pop(
                  context
                );
              },
            )
          ],
        ),
      ),
    );
  }
}