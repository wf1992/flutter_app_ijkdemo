
import 'media_model.dart';

class AudioModel extends MediaModel {
  String? audioName;

  AudioModel.fromJson(Map<String, dynamic> json) {
    audioName = json['audioName'] ?? '';
    mediaUrl = json['mediaUrl'] ?? '';

  }
}

