import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_ijkdemo/pages/fijk_video_page.dart';
import 'package:flutter_app_ijkdemo/pages/fijk_audio_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  //限制横屏
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

/*
*   fijkplayer 中出现的异常情况都以异步的形式出现，并且作为 FijkValue 的字段在值发生变化时通知订阅者。
*   在 fijkplayer 中，目前没有引入 FijkException 之外的任何异常。并且 FijkException 是不会抛出的。所以不需要异常处理函数 app 也不会因为 fijkplayer 而导致崩溃。
但是一旦出现 FijkException 意味着播放器处于 error 状态，你应该显出错误信息，或者关闭播放器。
*
*   音频Audio Focus： only for android  默认0：不产生作用 ， 1：会在播放器进入 started 状态后调用系统 requestAudioFocus 接口。
*   await player.setOption(FijkOption.hostCategory, "request-audio-focus", 1);

*
*   设置常亮：默认0：不产生作用 ， 1：常亮
*   await player.setOption(FijkOption.hostCategory, "request-screen-on", 1);
*
*   首帧UI：
*   推荐： 在 FijkView 中，使用 FijkView cover参数设置，抑或自定义panelBuilder UI，自己设置
*   不推荐：  使用setDataSource 中的showCover 参数，会产生额外的性能消耗。
*
* */

class _MyHomePageState extends State<MyHomePage> {

  List<String> _sliverDataSource = ["视频测试","音频测试"];

  @override
  void initState() {
    super.initState();
    //设置单页面的竖屏
//    SystemChrome.setPreferredOrientations([
//      DeviceOrientation.portraitUp
//    ]);
  }

   _getSliverListBuilder(){
    return SliverChildBuilderDelegate((context, index){
      return GestureDetector(
        onTap: (){
          _tapSliverIndexToGoNextPage(index);
        },
        child: Column(
          children: [
            Container(
              height: 80,
              color: Colors.white,
              alignment: Alignment.centerLeft,
              child: Text(
                _sliverDataSource[index],
              ),
            ),

            Container(
              height: 1,
              color: Colors.grey,
            )
          ],
        ),
      );
    },
      childCount: _sliverDataSource.length,
    );
  }
  
  _tapSliverIndexToGoNextPage(int index) {
    switch(index) {
      case 0:
        _goVideoPage();
        break;
      case 1:
        _goVoicePage();
        break;
      default:
        break;
    }
  }

  //  跳转视频page
  _goVideoPage(){
    Navigator.of(context).push(new MaterialPageRoute(
        builder: (context) =>
        new FijkVideoPage()));
  }

  //  跳转音频page
  _goVoicePage(){
    Navigator.of(context).push(new MaterialPageRoute(
        builder: (context) =>
        new FijkAudioPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Demo"),
      ),
      body: CustomScrollView(
        slivers: [
          SliverList(
            delegate: _getSliverListBuilder(),
          )
        ],
      ),
    );
  }
}
