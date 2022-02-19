import 'dart:io';
import 'dart:math';
import 'package:ffmpeg_kit_flutter_audio/return_code.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:ffmpeg_kit_flutter_audio/ffmpeg_kit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:eqtrainer/globals.dart' as globals;

class SessionPageManager {

  // approximate list of values for EQ Filter graphs.
  // it DOES NOT accurately resemble Constant-Q Filter graph.
  // it utilizes Gaussian Function to draw graphs.
  // see updateGraph Function for more info.
  late List<LineChartBarData> graphData;

  // list of x axis value of graph's vertexes.
  late List<int> graphVertexData;
  // center frequency list. it matches with each graph's vertex x axis value
  late List<int> vertexFrequencyData;

  // each separated audioPlayer will have separated audio source
  late AudioPlayer originalPlayer;
  late AudioPlayer filteredPlayer;
  late ConcatenatingAudioSource originalAudioSource;
  late ConcatenatingAudioSource filteredAudioSource;
  // this will notify play,pause button with new value
  final playButtonNotifier = ValueNotifier<ButtonState>(ButtonState.paused);

  // Flag to notify sessionPage that data is updating
  final updateFlag = ValueNotifier<bool>(true);

  // this contains index of selected audio clip from list of AudioFileIndex.
  final selectedAudioIndex = ValueNotifier<int>(0);

  SessionPageManager() {
    _init();
  }

  Future<void> _init() async {
    updateFlag.value = true;

    originalPlayer = AudioPlayer();
    filteredPlayer = AudioPlayer();
    originalPlayer.setLoopMode(LoopMode.all);
    filteredPlayer.setLoopMode(LoopMode.all);
    originalPlayer.setVolume(1);
    filteredPlayer.setVolume(0);

    // update the number of graphs
    updateGraphNum();

    // originalPlayer and filteredPlayer ALWAYS works together. (play, pause, seek...)
    // turning filter on/off will actually manipulate each player's volume.
    // this will only listen OriginalPlayer's state for reason above.
    _listenOriginalPlayerState();

    // reset session result
    globals.resetSessionResult();

    // choosing which graph will be answer for each session
    // this will choose the index number of graph, which will represent the eq filter applied to audio
    randomIndexSetter();
    // print(answerIndex.value);

    // updating materials required for session page.
    // ...will search x axis value for each graph's vertex,
    await searchGraphVertex();
    // ...update list of value required to draw graphs,
    await updateGraph();
    // ...and convert graph vertex's x axis value to frequency value. this will be center frequency for graph.
    await convertToFrequency();

    // setting audio source for each players (player for original audio, and filtered audio)
    // setFilteredAudioSource function includes creating filtered audio from original audio.
    await setOriginalAudioSource();

    tempDir = await getTemporaryDirectory();

    await setFilteredAudioSource();

    updateFlag.value = false;
  }

  Future<void> nextRound() async {
    updateFlag.value = true;
    originalPlayer.stop();
    filteredPlayer.stop();
    originalPlayer.setVolume(1);
    filteredPlayer.setVolume(0);

    // boolean flag - containing whether the number of band is changed or not
    bool bandChanged = false;
    // if sessionPoint reaches sessionPointLimit...
    // increasing the number of bands
    if(globals.sessionPoint >= globals.sessionPointLimit) {
      if(globals.sessionStartingBand < 25) {
        globals.sessionStartingBand++;
      }
      bandChanged = true;
    }
    // decreasing the number of bands
    else if(globals.sessionPoint <= (0 - globals.sessionPointLimit)) {
      if(globals.sessionStartingBand > 2) {
        globals.sessionStartingBand--;
      }
      bandChanged = true;
    }

    // choosing which graph will be answer for each session
    // this will choose the index number of graph, which will represent the eq filter applied to audio
    randomIndexSetter();
    // print(answerIndex.value);

    // if the number of bands was changed...
    if(bandChanged) {
      // it needs to recalculate entire graph and center frequency.
      await searchGraphVertex();
      await updateGraph();
      await convertToFrequency();

      // update the number of graphs
      updateGraphNum();
      // reset sessionPoint
      globals.sessionPoint = 0;
    }
    // reapply filters with new center frequency chosen by randomIndexSetter function.
    originalPlayer.setAudioSource(originalAudioSource);
    await setFilteredAudioSource();

    updateFlag.value = false;
  }

  // answerIndex contains index value of graph that EQ Filter will be applied
  // minimum 1 to maximum - the number of graphs
  final answerIndex = ValueNotifier<int>(0);
  int previousAnswer = 0;

  // this function will choose random index from list of graphs.
  // ...so it can apply eq filter to specific frequency
  // - which eventually will be used as 'correct answer' for training session
  void randomIndexSetter() {
    int min = 1;
    int max;
    Random rnd = Random();

    if(globals.sessionFilter == 'Peak & Dip') {
      max = globals.sessionStartingBand * 2;
    } else {
      max = globals.sessionStartingBand;
    }
    answerIndex.value = min + rnd.nextInt(max - min);

    if(previousAnswer == answerIndex.value) {
      randomIndexSetter();
    } else {
      previousAnswer = answerIndex.value;
    }
  }

  int graphNumber = 2;
  void updateGraphNum() {
    graphNumber = globals.sessionFilter == 'Peak & Dip'
    // if SessionFilter == 'Peak & Dip'
        ? globals.sessionStartingBand * 2
    // if SessionFilter != 'Peak & Dip'
        : globals.sessionStartingBand;
  }

  // Graph Vertex Search Function
  // this function will search each graph's vertex
  // and return List of Graph Vertex's X axis value.
  Future<void> searchGraphVertex() async {
    // this will contain vertex of graphs.
    List<int> requestedGraphVertex = [];

    // divTemp is half of the distance between top points of graphs.
    // this will be used to record graph's middle point x axis.
    double divTemp = ((650 - 59) / (globals.sessionStartingBand * 2));

    // graphCenterPoint collects graph's middle x axis point.
    for(int i = 1; i <= globals.sessionStartingBand; i++) {
      double diff = ((2 * i) - 1) * divTemp;
      requestedGraphVertex.add(59 + diff.toInt());
    }

    graphVertexData = requestedGraphVertex;
  }

  // Graph Updater
  // graphs center points will be evenly divided through 20Hz to 20kHz by X axis value
  // currently we have 20Hz at x:59, and 20kHz at x:650.
  // as a result, this function will return List of LineChartBarData.
  Future<void> updateGraph() async {
    // spots required to draw graph
    List<FlSpot> spots = [];
    // LineChartBarData that this function will return
    List<LineChartBarData> requestedLCBD = [];
    // this is the Q Factor just for the graph, not EQ Filter
    // ...since graphs are way too overlapping each other as Starting Band increases.
    double graphQFactor = (86 - (3 * globals.sessionStartingBand)).toDouble();

    // Starting with each graph's middle x axis value,
    // We are drawing Graphs from now on.
    // the formula for the graph below is Gaussian Function.
    // ... so it's not really accurate graph for EQ filter.
    // I believe it should be Constant-C function or something,
    // but I couldn't get accurate information about the graph formula...
    // which harman's How to Listen program is using.
    // but their graphs were not accurate either, it doesn't change with altered gain or q Factor value.
    // it looked like some kind of image or something.
    for(int index = 0; index < globals.sessionStartingBand; ++index) {
      // Drawing Peak Graph
      if (globals.sessionFilter != 'Dip') {
        // drawing graph with spots every 5 pixels
        for(int i = 0; i <= 650; i += 5) {
          // calculating y axis value with Gaussian Function
          num temp = (0 - ((pow((i - graphVertexData[index]), 2)) / (pow(graphQFactor, 2))));
          // to get y, we are using 2 to multiply with temp above, instead of actual gain value.
          // this is because we are setting Graph's Max,Min Point's Y axis value as 2.
          num y = 2 * (pow(e, temp));
          double tempX = i.toDouble();
          double tempY = y.toDouble();
          spots.add(FlSpot(tempX, tempY));
        }
        // adding graph to LineChartBarData List
        requestedLCBD.add(
            LineChartBarData(
                isCurved: true,
                colors: [Colors.redAccent],
                barWidth: 5,
                isStrokeCapRound: true,
                dotData: FlDotData(show: false),
                belowBarData: BarAreaData(show: false),
                spots: spots
            )
        );
        spots = [];
      }
      // Drawing Dip Graph
      if (globals.sessionFilter != 'Peak') {
        // drawing graph with spots every 10 pixels
        for(int i = 0; i <= 650; i += 5) {
          num temp = (0 - ((pow((i - graphVertexData[index]), 2)) / (pow(graphQFactor, 2))));
          num y = 2 * (pow(e, temp));
          double tempX = i.toDouble();
          double tempY = 0 - y.toDouble();
          spots.add(FlSpot(tempX, tempY));
        }
        // adding graph to LineChartBarData List

        requestedLCBD.add(
            LineChartBarData(
                isCurved: true,
                colors: [Colors.redAccent],
                barWidth: 5,
                isStrokeCapRound: true,
                dotData: FlDotData(show: false),
                belowBarData: BarAreaData(show: false),
                spots: spots
            )
        );
        spots = [];
      }
    }
    // changing color of first graph, from red to blue. (since graph selector is initialized with 1)
    requestedLCBD[0] = requestedLCBD[0].copyWith(colors: [Colors.blueAccent]);
    graphData = requestedLCBD;
  }

  // Axis value to Frequency Converter
  // converts list of Graph Vertex X axis value into list of approximate Frequency
  Future<void> convertToFrequency() async {
    // clearing Freq data list
    vertexFrequencyData = [];

    // converting x axis value to nearest frequency.
    for(int gVindex = 0; gVindex < graphVertexData.length; ++gVindex) {
      // x axis value
      int xPoint = graphVertexData[gVindex];
      // converted frequency value
      int frequencyVal;

      // xPoint has Graph vertex's x axis value
      // we are converting that into frequency value.

      // 20hz - 30hz
      // in here, x axis 59 = 20hz, 93 = 30hz.
      // EQFreqVal = 20(hz) + (((xPoint(x axis) - [20hz x axis value]) * [30hz - 20hz]) / [30hz x axis - 20hz x axis])
      if(59 <= xPoint && xPoint < 93) {
        frequencyVal = 20 + (((xPoint - 59) * 10) ~/ 34);
      }
      // 30hz - 40hz
      else if(93 <= xPoint && xPoint < 118) {
        frequencyVal = 30 + (((xPoint - 93) * 10) ~/ 25);
      }
      // 40hz - 50hz
      else if(118 <= xPoint && xPoint < 137) {
        frequencyVal = 40 + (((xPoint - 118) * 10) ~/ 19);
      }
      // 50hz - 60hz
      else if(137 <= xPoint && xPoint < 153) {
        frequencyVal = 50 + (((xPoint - 137) * 10) ~/ 16);
      }
      // 60hz - 70hz
      else if(153 <= xPoint && xPoint < 166) {
        frequencyVal = 60 + (((xPoint - 153) * 10) ~/ 13);
      }
      // 70hz - 80hz
      else if(166 <= xPoint && xPoint < 177) {
        frequencyVal = 70 + (((xPoint - 166) * 10) ~/ 11);
      }
      // 80hz - 90hz
      else if(177 <= xPoint && xPoint < 187) {
        frequencyVal = 80 + (((xPoint - 177) * 10) ~/ 10);
      }
      // 90hz - 100hz
      else if(187 <= xPoint && xPoint < 197) {
        frequencyVal = 90 + (((xPoint - 187) * 10) ~/ 10);
      }
      // 100 hz - 200 hz
      else if(197 <= xPoint && xPoint < 256) {
        frequencyVal = 100 + (((xPoint - 197) * 100) ~/ 59);
      }
      // 200 hz - 300 hz
      else if(256 <= xPoint && xPoint < 291) {
        frequencyVal = 200 + (((xPoint - 256) * 100) ~/ 35);
      }
      // 300 hz - 400 hz
      else if(291 <= xPoint && xPoint < 315) {
        frequencyVal = 300 + (((xPoint - 291) * 100) ~/ 24);
      }
      // 400 hz - 500 hz
      else if(315 <= xPoint && xPoint < 335) {
        frequencyVal = 400 + (((xPoint - 315) * 100) ~/ 20);
      }
      // 500 hz - 600 hz
      else if(335 <= xPoint && xPoint < 350) {
        frequencyVal = 500 + (((xPoint - 335) * 100) ~/ 15);
      }
      // 600 hz - 700 hz
      else if(350 <= xPoint && xPoint < 363) {
        frequencyVal = 600 + (((xPoint - 350) * 100) ~/ 13);
      }
      // 700 hz - 800 hz
      else if(363 <= xPoint && xPoint < 375) {
        frequencyVal = 700 + (((xPoint - 363) * 100) ~/ 12);
      }
      // 800 hz - 900 hz
      else if(375 <= xPoint && xPoint < 385) {
        frequencyVal = 800 + (((xPoint - 375) * 100) ~/ 10);
      }
      // 900 hz - 1000 hz
      else if(385 <= xPoint && xPoint < 394) {
        frequencyVal = 900 + (((xPoint - 385) * 100) ~/ 9);
      }
      // 1000 hz - 2000 hz
      else if(394 <= xPoint && xPoint < 452) {
        frequencyVal = 1000 + (((xPoint - 394) * 1000) ~/ 58);
      }
      // 2000 hz - 3000 hz
      else if(452 <= xPoint && xPoint < 487) {
        frequencyVal = 2000 + (((xPoint - 452) * 1000) ~/ 35);
      }
      // 3000 hz - 4000 hz
      else if(487 <= xPoint && xPoint < 512) {
        frequencyVal = 3000 + (((xPoint - 487) * 1000) ~/ 25);
      }
      // 4000 hz - 5000 hz
      else if(512 <= xPoint && xPoint < 531) {
        frequencyVal = 4000 + (((xPoint - 512) * 1000) ~/ 19);
      }
      // 5000 hz - 6000 hz
      else if(531 <= xPoint && xPoint < 546) {
        frequencyVal = 5000 + (((xPoint - 531) * 1000) ~/ 15);
      }
      // 6000 hz - 7000 hz
      else if(546 <= xPoint && xPoint < 559) {
        frequencyVal = 6000 + (((xPoint - 546) * 1000) ~/ 13);
      }
      // 7000 hz - 8000 hz
      else if(559 <= xPoint && xPoint < 571) {
        frequencyVal = 7000 + (((xPoint - 559) * 1000) ~/ 12);
      }
      // 8000 hz - 9000 hz
      else if(571 <= xPoint && xPoint < 581) {
        frequencyVal = 8000 + (((xPoint - 571) * 1000) ~/ 10);
      }
      // 9000 hz - 10000 hz
      else if(581 <= xPoint && xPoint < 590) {
        frequencyVal = 9000 + (((xPoint - 581) * 1000) ~/ 9);
      }
      // 10000 hz - 20000 hz
      else {
        frequencyVal = 10000 + (((xPoint - 590) * 10000) ~/ 60);
      }

      vertexFrequencyData.add(frequencyVal.toInt());
    }
  }

  // Original Audio Source Updater
  // This will convert list of clipped audio file, into list of AudioSource.
  // ...and apply it to ConcatenatingAudioSource list for originalPlayer.
  Future<void> setOriginalAudioSource() async {
    List<AudioSource> finalAudioSourceList = [];
    for(int index = 0; index < globals.playlistData.length; ++index) {
      // Creating list of AudioSource
      if(globals.playlistData[index].enabled) {
        finalAudioSourceList.add(AudioSource.uri(Uri.parse(globals.playlistData[index].directory)));
      }
    }
    originalAudioSource = ConcatenatingAudioSource(children: finalAudioSourceList);
    originalPlayer.setAudioSource(originalAudioSource);
  }

  // temp directory for filtered audio.
  // updated only once with setOriginalAudioSource.
  late Directory tempDir;
  // complete directory of clipped audio file & filtered audio clip
  late String filteredClipDir;
  // format / file extension of audio clip trying to filter.
  late String clipFormat;

  // Filtered Audio Source Updater
  // This will apply eq filter to each enabled audio clips from list of AudioFileIndex and make temp files.
  // those temp audio clips will be made into list of AudioSource,
  // and this will be applied to filteredPlayer's ConcatenatingAudioSource.
  Future<void> setFilteredAudioSource() async {
    List<AudioSource> finalAudioSourceList = [];
    for(int index = 0; index < globals.playlistData.length; ++index) {
      // Creating list of AudioSource
      if(globals.playlistData[index].enabled) {
        // updating temp values for eq filter
        late int centerFreq;
        late int gain;
        // Peak
        if(globals.sessionFilter == 'Peak') {
          centerFreq = vertexFrequencyData[answerIndex.value - 1];
          gain = globals.sessionGain;
        }
        // Dip
        else if(globals.sessionFilter == 'Dip') {
          centerFreq = vertexFrequencyData[answerIndex.value - 1];
          gain = 0 - globals.sessionGain;
        }
        // Peak & Dip
        else {
          // graph's index is numbered from left to right, and from peak to dip
          // using ((answerIndex.value - 1) / 2), we can combine peak graph, dip graph with same center frequency into single index
          centerFreq = vertexFrequencyData[(answerIndex.value - 1) ~/ 2];
          // after that, we can determine which graph is peak or dip by using % 2 function
          if(answerIndex.value % 2 == 1) {
            gain = globals.sessionGain;
          }
          else {
            gain = 0 - globals.sessionGain;
          }
        }

        // extracting file format from its directory
        for(int charIndex = globals.playlistData[index].directory.length - 1; charIndex >= 0; --charIndex) {
          if(globals.playlistData[index].directory[charIndex] == '.') {
            clipFormat = globals.playlistData[index].directory.substring(charIndex + 1, globals.playlistData[index].directory.length);
            break;
          }
        }

        // complete directory of filtered audio clip - ex) tempdir/filtered0.mp3
        filteredClipDir = tempDir.path + '/filtered' + index.toString() + '.' + clipFormat;

        // separated arguments for applying eq filter into clipped audio
        // -y : force overwrite temp files
        // -vn : skip inclusion of video stream, which might cause error with files such as m4a or more.
        var arguments2 = ["-y", "-i", globals.playlistData[index].directory, "-af", "equalizer=f=$centerFreq:t=q:w=${globals.sessionQFactor}:g=$gain", "-vn", filteredClipDir];
        // applying filter to clipped audio
        FFmpegKit.executeWithArgumentsAsync((arguments2), (session) async {
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
        // add filtered audio to finalAudioSourceList
        finalAudioSourceList.add(AudioSource.uri(Uri.parse(filteredClipDir)));
      }
    }
    filteredAudioSource = ConcatenatingAudioSource(children: finalAudioSourceList);
    filteredPlayer.setAudioSource(filteredAudioSource);
    //print("converted");
  }

  //
  // listening play,pause button state
  void _listenOriginalPlayerState() {
    originalPlayer.playerStateStream.listen((oPlayerState) {
      filteredPlayer.playerStateStream.listen((fPlayerState) {
        final isOriginalPlaying = oPlayerState.playing;
        final isFilteredPlaying = fPlayerState.playing;
        final oProcessingState = oPlayerState.processingState;
        final fProcessingState = fPlayerState.processingState;
        // buffering song
        if (oProcessingState == ProcessingState.loading ||
            oProcessingState == ProcessingState.buffering ||
            fProcessingState == ProcessingState.loading ||
            fProcessingState == ProcessingState.buffering) {
          playButtonNotifier.value = ButtonState.loading;
        }
        // song is not playing
        else if (!isOriginalPlaying && !isFilteredPlaying) {
          playButtonNotifier.value = ButtonState.paused;
        }
        // song is playing, but not completed
        else if (oProcessingState != ProcessingState.completed || fProcessingState != ProcessingState.completed){
          playButtonNotifier.value = ButtonState.playing;
        }
        // song played til end
        else {
          seekToPrevious();
        }
      });
    });
  }

  void play() {
    originalPlayer.play();
    filteredPlayer.play();
  }

  void pause() {
    originalPlayer.pause();
    filteredPlayer.pause();
  }

  void seekToNext() {
    originalPlayer.seekToNext();
    filteredPlayer.seekToNext();
  }

  void seekToPrevious() {
    originalPlayer.seekToPrevious();
    filteredPlayer.seekToPrevious();
  }
}

enum ButtonState {
  loading, paused, playing
}