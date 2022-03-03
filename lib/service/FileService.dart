import 'dart:io';
import 'package:duration/duration.dart';
import 'package:ffmpeg_kit_flutter_audio/ffmpeg_kit.dart';
import 'package:eqtrainer/globals.dart' as globals;

class FileService {
  // complete directory of clipped audio file
  late String clipDir;
  // clipped audio file's directory AFTER document directory.
  // we are NOT saving full directory since iOS Devices constantly change application directory upon update or installation.
  late String clipDirAfterDocumentDir;
  // time stamps required for clipping audio with ffmpeg_flutter.
  late String clipStartMSec;
  late String clipDurationMSec;

  // this function will clip audio and copy it into app's document directory.
  Future<void> clipAudio(String fileName, String fileDirectory, Duration startPoint, Duration endPoint) async {
    // this will create /audio directory in app document directory, if this does not exist.
    Directory newDirectory = await Directory(globals.appDocumentDirectory.path + '/original').create(recursive: true);
    // complete directory of clipped original audio file - ex) documentDir/original/filename.mp3
    clipDirAfterDocumentDir = '/original/${startPoint.inMilliseconds}_${endPoint.inMilliseconds}_$fileName';
    clipDir = newDirectory.path + '/${startPoint.inMilliseconds}_${endPoint.inMilliseconds}_$fileName';

    // ffmpeg will clip & copy audio file into application's document directory.
    clipStartMSec = '${startPoint.inMilliseconds}ms';
    clipDurationMSec = '${endPoint.inMilliseconds}ms';

    bool isOriginalClipExist = await File(clipDir).exists();
    if(!isOriginalClipExist) {
      // separated arguments for splitting original audio file into audio clip
      // -y : force overwrite temp files
      // -ss clipStartSec ~ -to clipDurationSec : cutting audio into clip, starting from clipStartSec with duration of clipDurationSec
      var arguments1 = ["-y", "-i", fileDirectory, "-vn", "-ss", clipStartMSec, "-to", clipDurationMSec, clipDir];
      // clipping original audio
      FFmpegKit.executeWithArguments(arguments1);
    }

    // update globals.playlistData
    globals.playlistData.add(AudioFileIndex(true, fileName, clipDirAfterDocumentDir, startPoint, endPoint));
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