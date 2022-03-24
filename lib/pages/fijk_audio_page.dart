import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:dio/dio.dart';
import 'package:fijkplayer_ijkfix/fijkplayer_ijkfix.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import '../panels/audio_bar_panel_widget.dart';
import 'package:flutter_app_ijkdemo/models/audio_model.dart';
import '';
class FijkAudioPage extends StatefulWidget {
  @override
  _FijkAudioPageState createState() => _FijkAudioPageState();
}

class _FijkAudioPageState extends State<FijkAudioPage> {
  final FijkPlayer player = FijkPlayer();


  List<Map<String,dynamic>> sourceMapList = [
    {"mediaUrl":"http://downsc.chinaz.net/Files/DownLoad/sound1/201906/11582.mp3","audioName":"line_音频Mp3-1"},
    {"mediaUrl":"http://downsc.chinaz.net/files/download/sound1/201206/1638.mp3","audioName":"line_音频Mp3-2"},
    {"mediaUrl":"asset:///filesource/mp3_1.mp3","audioName":"local_音频Mp3-1"},
    {"mediaUrl":"asset:///filesource/mp3_2.mp3","audioName":"local_音频Mp3-2"},
//    http://tworookie.com/wav_1.wav
    {"mediaUrl":"https://media.smgtech.net:8443/radio/original/2022/03/14/2117win6838cd2578aba21bd71aadfc6e28d6ae1647226193798.s48","audioName":"在线_音频s48_1"},

    {"mediaUrl":"https://media.smgtech.net:8443/radio/original/2022/03/16/2075win5c260f282c059061ddd059a926299c5e1647389232996.wav","audioName":"在线_音频wav_1"},
    {"mediaUrl":"asset:///filesource/wav_1.wav","audioName":"local_音频wav_1"},
    {"mediaUrl":"asset:///filesource/wav_2.wav","audioName":"local_音频wav_2"},
    {"mediaUrl":"asset:///filesource/s48_1.s48","audioName":"local_音频s48_1"},
    {"mediaUrl":"asset:///filesource/s48_2.s48","audioName":"local_音频s48_2"},
    {"mediaUrl":"asset:///filesource/m4a_1.m4a","audioName":"local_音频m4a_1"},
    {"mediaUrl":"","audioName":"documents_音频测试"},

  ];

  /*  自己服务器下载的文件地址：
  *   http://tworookie.com/wav_1.wav
  *   http://tworookie.com/wav_2.wav
  *   http://tworookie.com/s48_1.s48
  *   http://tworookie.com/s48_2.s48
  *   http://tworookie.com/m4a_1.m4a
  *
  *   s48文件，在上次的网站上下载下来，貌似在网站上也不能播放，所以这边还需要另测一次
  * */

  List<AudioModel> _audioSourceList = [];

  int _currentIndex = -1;
  String value = ''; // 每次input的值
  AudioPlayer audioPlayer = AudioPlayer();
  String downLoadSufixName = "wav_2.wav";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _audioSourceList = sourceMapList.map((e) {
      return AudioModel.fromJson(e);
    }).toList();
    downloadFile();
  }

  //test: 测试下载至本地，播放本地文件
  Future<void> downloadFile() async {
    Dio dio = Dio();
    try {
      var dir = await getApplicationDocumentsDirectory();
      print("path ${dir.path}");
      await dio.download('http://tworookie.com/$downLoadSufixName', "${dir.path}/$downLoadSufixName",
          onReceiveProgress: (rec, total) {
            print("Rec: $rec , Total: $total");


          });
    } catch (e) {
      print(e);
    }
    print("Download completed");
  }

  @override
  void dispose() {
    print("Audio ~~ dispose  to release palyer and setPreferredOrientations!!!");
    player.dispose();
    super.dispose();
  }

  _changePlayerSource(int index) async {
    if(index == _audioSourceList.length - 1){
      var dir = await getApplicationDocumentsDirectory();
      await player.reset().then((value) {
        player.setDataSource("${dir.path}/$downLoadSufixName",autoPlay: true);
      });
      return;
    }
    await player.reset().then((value) {
      player.setDataSource( _audioSourceList[index].mediaUrl,autoPlay: true);
    });
  }

  _getSliverChildDelegate() {
    return SliverChildBuilderDelegate((context, index) {
      return GestureDetector(
        onTap: (){
          setState(() {
            _currentIndex = index;
            _changePlayerSource(index);
          });
        },
        child: Column(
          children: [
            Container(
              height: 60,
              color: Colors.white,
              alignment: Alignment.centerLeft,
              //  在此要注意看我的AudioModel 中的audioName，是可空类型，所以在此需要强制取值或者不确定是否有值，需要用三目运算判断去给默认值
              //  类比AudioModel的父类MediaModel，mediaUrl是非空类型，所以可以直接取值
              child: Text(_audioSourceList[index].audioName!),
            ),
            _currentIndex!=index
                ?Container()
                :Container(
              height: 60,
              color: Colors.lightBlue,
              child: FijkView(
                color: Colors.white,
                fit: FijkFit.cover,
                player: player,
                panelBuilder: (
                    FijkPlayer player,
                    FijkData data,
                    BuildContext context,
                    Size viewSize,
                    Rect texturePos,
                    ) {
                  /// 使用自定义的布局
                  return AudioBarPanelWidget(
                    player: player,
                    // 传递 context 用于左上角返回箭头关闭当前页面，不要传递错误 context，
                    // 如果要点击箭头关闭当前的页面，那必须传递当前组件的根 context
                    buildContext: context,
                    viewSize: viewSize,
                    texturePos: texturePos,

                  );
                },

              ),
            )
          ],
        ),
      );
    },
    childCount: _audioSourceList.length);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("FijkAudio Page"),
        elevation: 0,
        leading: IconButton(
            icon: BackButtonIcon(),
            onPressed: () {
              _back();
            }),
        centerTitle: true,
      ),
      body: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverList(delegate: _getSliverChildDelegate()),
            ],
          )
      ),
      floatingActionButton: FloatingActionButton(onPressed: (){
        play();
      },
      child: Text('audioPlayer'),),
    );
  }

  _back()async{
    if(player.state == FijkState.idle || player.state == FijkState.error
        || player.state == FijkState.completed || player.state == FijkState.end ){
      Navigator.of(context).pop();
      return;
    }
    await player.pause().then((value){
      print('pause success~~~');
      Navigator.of(context).pop();
    });


  }

  ///audioPlayer 播放
  play() async {
    var dir = await getApplicationDocumentsDirectory();
    int result = await audioPlayer.setUrl("${dir.path}/$downLoadSufixName");
    await audioPlayer.resume();
    if (result == 1) {
      audioPlayer.onAudioPositionChanged.listen((event) {

      });
    } else {
      print('play failed');
    }
  }

}
