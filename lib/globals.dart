library eq_trainer.globals;

import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:path_provider/path_provider.dart';

import 'package:eqtrainer/service/FileService.dart';

// path to playlist data json
late File playlistDataPath;

// Notifies whether json file is loaded or not.
// -1 == error occurred / 0 == not loaded or loading / 1 == loaded
final fileLoadNotifier = ValueNotifier<int>(0);

// Load playlist json file at initial launch.
Future<void> initFile() async {
  final directory = await getApplicationDocumentsDirectory();
  final jsonPath = directory.path;
  playlistDataPath = File('$jsonPath/assets/playlist.json');

  // json file does exist
  if(await playlistDataPath.exists()) {
    // Trying to read json file
    try {
      final jsonString = await playlistDataPath.readAsString();
      if(jsonString.isNotEmpty) {
        // Trying to parse playlist json file.
        try {
          await loadPlaylist();
          fileLoadNotifier.value = 1;
        }
        // parse Failed
        catch(e) {
          fileLoadNotifier.value = -1;
        }
      }
      // if json has no data but json file does exist
      else {
        fileLoadNotifier.value = 1;
      }
    }
    // Could not read json file
    catch (e) {
      fileLoadNotifier.value = -1;
    }
  }
  // json file dose not exist
  else {
    // try creating json file
    try {
      await playlistDataPath.create(recursive: true);
      fileLoadNotifier.value = 1;
    }
    // json file creation failed
    catch(e1) {
      fileLoadNotifier.value = -1;
    }
  }
}

// Data list containing playlist json file data
List<AudioFileIndex> playlistData = [];

// this will load json file and pass it to playlistData
Future<void> loadPlaylist() async {
  try {
    final jsonString = await playlistDataPath.readAsString();
    final playlistMap = jsonDecode(jsonString);
    final List<AudioFileIndex> tempList = List<AudioFileIndex>.from(playlistMap.map((i)=>AudioFileIndex.fromJson(i)).toList());
    playlistData = tempList;
  }
  catch(e) {
    print(e);
  }
}

// this will serialize playlistData and save it to playlist.json file.
Future<void> savePlaylist() async {
  try {
    String jsonString = jsonEncode(playlistData);
    await playlistDataPath.writeAsString(jsonString);
  } catch (e) {
    // print(e);
    GetSnackBar(
      title: tr("SNACKBAR_PLAYLIST_SAVE_FAILED_TITLE"),
      message: tr("SNACKBAR_PLAYLIST_SAVE_FAILED_MESSAGE"),
      duration: const Duration(seconds: 2),
      snackPosition: SnackPosition.TOP,
    );
  }
}

// variables for initializing session
int sessionStartingBand = 2;
List<int> sessionStartingBandList = [2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25];
int sessionGain = 6;
List<int> sessionGainList = [1,2,3,4,5,6,8,10,13,15,20];
double sessionQFactor = 1;
List<double> sessionQFactorList = [0.1, 0.25, 0.5, 0.75, 1, 2, 5, 10, 15, 20, 25, 30, 50];
String sessionFilter = 'Peak & Dip';
List<String> sessionFilterList = ['Peak', 'Dip', 'Peak & Dip'];
int sessionPointLimit = 3;
List<int> sessionPointLimitList = [1,3,5,7,10,10000];

// a single session is consisted with several rounds.
// completedRound contains the number of rounds that user completed
int completedRound = 0;
// sessionPoint will increase or decrease depending user has correct answer or not.
// hitting certain amount of point will increase or decrease number of bands (center frequencies)
int sessionPoint = 0;
// variables for result of round, separated by frequencies
// sessionResult List contains each frequency range's name and description, and two types of score points.
// when user choose right graph, third variable (frequencyRangeProperties.correctScore) will be incremented.
// otherwise, fourth variable (frequencyRangeProperties.incorrectScore) will be incremented.
List<frequencyRangeProperties> sessionResult = [
  frequencyRangeProperties(tr("FR_SUB_BASS"), tr("FR_SUB_BASS_DESC"), 0, 0),
  frequencyRangeProperties(tr("FR_MID_BASS"), tr("FR_MID_BASS_DESC"), 0, 0),
  frequencyRangeProperties(tr("FR_LOWER_MIDRANGE"), tr("FR_LOWER_MIDRANGE_DESC"), 0, 0),
  frequencyRangeProperties(tr("FR_CENTER_MIDRANGE"), tr("FR_CENTER_MIDRANGE_DESC"), 0, 0),
  frequencyRangeProperties(tr("FR_UPPER_MIDRANGE"), tr("FR_UPPER_MIDRANGE_DESC"), 0, 0),
  frequencyRangeProperties(tr("FR_TREBLE"), tr("FR_TREBLE_DESC"), 0, 0),
  frequencyRangeProperties(tr("FR_UPPER_TREBLE"), tr("FR_UPPER_TREBLE_DESC"), 0, 0),
];

void resetSessionResult() {
  completedRound = 0;
  sessionPoint = 0;
  for(int index = 0; index < 7; ++index) {
    sessionResult[index].correctScore = 0;
    sessionResult[index].incorrectScore = 0;
  }
}

void updateSessionResult(bool isCorrect, int answerFreq) {
  completedRound++;
  // classify answerFreq into appropriate frequency Range.
  int index;
  if(20 <= answerFreq && answerFreq < 80) {
    index = 0;
  } else if(80 <= answerFreq && answerFreq < 200) {
    index = 1;
  } else if(200 <= answerFreq && answerFreq < 800) {
    index = 2;
  } else if(800 <= answerFreq && answerFreq < 1500) {
    index = 3;
  } else if(1500 <= answerFreq && answerFreq < 5000) {
    index = 4;
  } else if(5000 <= answerFreq && answerFreq < 10000) {
    index = 5;
  } else {
    index = 6;
  }

  if(isCorrect) {
    sessionResult[index].correctScore++;
  } else {
    sessionResult[index].incorrectScore++;
  }
}

class frequencyRangeProperties {
  String rangeName;
  String rangeDescription;
  int correctScore;
  int incorrectScore;

  frequencyRangeProperties(
    this.rangeName,
    this.rangeDescription,
    this.correctScore,
    this.incorrectScore
  );
}