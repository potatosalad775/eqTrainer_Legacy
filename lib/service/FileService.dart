import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:duration/duration.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ffmpeg_kit_flutter_audio/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_audio/return_code.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:eqtrainer/globals.dart' as globals;

class FileService {
  // document Directory of eq_trainer application.
  // this will be used to store audio clip.
  late Directory documentDir;
  // complete directory of clipped audio file
  late String clipDir;
  // time stamps required for clipping audio with ffmpeg_flutter.
  late String clipStartMSec;
  late String clipDurationMSec;

  // this function will clip audio and copy it into app's document directory.
  Future<void> clipAudio(String fileName, String fileDirectory, Duration startPoint, Duration endPoint) async {
    // fetching application's document directory
    documentDir = await getApplicationDocumentsDirectory();
    // this will create /audio directory in app document directory, if this does not exist.
    Directory newDirectory = await Directory(documentDir.path + '/audio').create(recursive: true);
    // complete directory of clipped audio file - ex) documentDir/audio/temp0.mp3
    clipDir = newDirectory.path + '/' + fileName;

    // ffmpeg will clip & copy audio file into application's document directory.
    clipStartMSec = '${startPoint.inMilliseconds}ms';
    clipDurationMSec = '${endPoint.inMilliseconds}ms';

    // separated arguments for splitting original audio file into audio clip
    // -y : force overwrite temp files
    // -ss clipStartSec ~ -to clipDurationSec : cutting audio into clip, starting from clipStartSec with duration of clipDurationSec
    var arguments1 = ["-y", "-i", fileDirectory, "-vn", "-ss", clipStartMSec, "-to", clipDurationMSec, clipDir];
    // clipping original audio
    FFmpegKit.executeWithArgumentsAsync((arguments1), (session) async {
      final returnCode = await session.getReturnCode();
      // if it's canceled or error occurred
      if(!ReturnCode.isSuccess(returnCode)) {
        GetSnackBar(
          icon: const Icon(Icons.error),
          title: tr("SNACKBAR_ERROR_FFMPEG_TITLE"),
          message: tr("SNACKBAR_ERROR_FFMPEG_MESSAGE"),
          duration: const Duration(seconds: 2),
          snackPosition: SnackPosition.TOP,
        );
      }
      print(session.getOutput);
    });

    // update globals.playlistData
    globals.playlistData.add(AudioFileIndex(true, fileName, clipDir, startPoint, endPoint));
  }
}

// this class manages Index of every AudioFile inside AudioFileList.
class AudioFileIndex {
  // contains whether this clip is enabled for session or not
  // 0 = false / 1 = true
  bool enabled;
  // these are self-explanatory
  String name;
  String directory;
  // this includes startPoint and endPoint of audio file's timeline,
  // ... so it automatically play certain section of audio file during session.
  Duration startPoint;
  Duration endPoint;

  AudioFileIndex(
    this.enabled,
    this.name,
    this.directory,
    this.startPoint,
    this.endPoint,
  );

  factory AudioFileIndex.fromJson(Map<String, dynamic> parsedJson){
    return AudioFileIndex(
      parsedJson["enabled"] == 'true',
      parsedJson["name"],
      parsedJson["directory"],
      parseTime(parsedJson["startPoint"]),
      parseTime(parsedJson["endPoint"]),
    );
  }

  Map<String, dynamic> toJson() => {
    'enabled': enabled.toString(),
    'name': name,
    'directory': directory,
    'startPoint': startPoint.toString(),
    'endPoint': endPoint.toString(),
  };
}