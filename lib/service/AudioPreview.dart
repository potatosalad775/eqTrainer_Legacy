import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:just_audio/just_audio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';

import 'package:eqtrainer/globals.dart' as globals;
import 'package:eqtrainer/service/FileService.dart';
import 'package:eqtrainer/service/AudioPageManager.dart';

class AudioPreview extends StatefulWidget {

  const AudioPreview({Key? key}) : super(key: key);

  @override
  _AudioPreviewState createState() => _AudioPreviewState();
}
class _AudioPreviewState extends State<AudioPreview> {

  late AudioPageManager previewPage;
  late AudioPlayer audioPlayer;
  late int durationSec;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    previewPage.audioPlayer.dispose();
    audioPlayer.dispose();
  }

  //
  // opens file picker page, will return true after user picked file
  // ..or false when user cancel picking file or error occurs.
  Future<bool> openFilePage() async {
    previewPage = AudioPageManager();
    audioPlayer = previewPage.audioPlayer;

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'wav',
        'aiff',
        'alac',
        'flac',
        'mp3',
        'aac',
        'wma',
        'ogg',
        'm4a'
      ],
      allowMultiple: false,
    );
    if(result != null) {
      try {
        var duration = await audioPlayer.setFilePath(result.files.single.path.toString());
        // updating index cache with selected Audio file's index
        previewPage.selectedAudioIndex = AudioFileIndex(
          true,
          result.files.single.name.toString(),
          result.files.single.path.toString(),
          const Duration(seconds: 0),
          duration as Duration,
          // File Format, Not Available for now : just a placeholder for previewing clip.
          // when user actually finish editing and save it, FileService will fill out actual value
        );
        durationSec = previewPage.selectedAudioIndex.endPoint.inSeconds;
        previewPage.endPointNotifier.value = previewPage.selectedAudioIndex.endPoint;
        return true;
      }
      catch (e) {
        return false;
      }
    }
    else {
      // file selection cancelled
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(20),
            )
          ),
          child: FutureBuilder<bool>(
            future: openFilePage(),
            builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
              // Data Returned
              if(snapshot.data == true) {
                return Column(
                  children: <Widget>[
                    // Music Slider
                    WidgetAudioSlider(previewPage: previewPage, durationSec: durationSec),
                    // Play/Pause, go to Start point / End point
                    WidgetControlButton(previewPage: previewPage),
                    // startPoint/endPoint selector & Save Button
                    Padding(
                      padding: const EdgeInsets.all(15),
                      child: Row(
                        children: [
                          WidgetStartPointSetter(previewPage: previewPage),
                          const SizedBox(width: 15,),
                          WidgetEndPointSetter(previewPage: previewPage),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
                      child: ElevatedButton.icon(
                        icon: const Icon(
                          Icons.save,
                          size: 25,
                        ),
                        label: const Text(
                          "BUTTON_AUDIO_CLIP_SAVE",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ).tr(),
                        style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.maxFinite, 50),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)
                            )
                        ),
                        onPressed: () {
                          completeAudioPreview(previewPage).whenComplete(() => null);
                        },
                      ),
                    )
                  ],
                );
              }
              // Data not returned yet
              else if (snapshot.hasData == false) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              // error occurred
              else {
                return AlertDialog(
                  title: const Text("ALERT_AUDIO_FILESELECTION_CANCELED_TITLE").tr(),
                  actions: <Widget>[
                    TextButton(
                      child: const Text("ALERT_AUDIO_FILESELECTION_CANCELED_DISMISS").tr(),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    )
                  ],
                );
              }
            },
          ),
        ),
      ],
    );
  }

  Future<void> completeAudioPreview(AudioPageManager previewPage) async {
    previewPage.audioPlayer.dispose();
    // clip selected audio and copy to app's document directory
    FileService _fs = FileService();
    await _fs.clipAudio(
        previewPage.selectedAudioIndex.name,
        previewPage.selectedAudioIndex.directory,
        previewPage.selectedAudioIndex.startPoint,
        previewPage.selectedAudioIndex.endPoint
    );
    // save playlist
    globals.savePlaylist();
    Navigator.pop(context);
  }
}

class WidgetAudioSlider extends StatelessWidget {
  const WidgetAudioSlider({Key? key, required this.previewPage, required this.durationSec}) : super(key: key);

  final AudioPageManager previewPage;
  final int durationSec;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 15, 10, 0),
      child: Stack(
        children: <Widget>[
          // point notifier down arrow
          SizedBox(
            width: double.maxFinite,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: <Widget>[
                ValueListenableBuilder(
                  valueListenable: previewPage.startPointNotifier,
                  builder: (_, value, __) {
                    return Align(
                      alignment: Alignment(
                        (2 * previewPage.startPointNotifier.value.inSeconds / durationSec) - 1,
                        1
                      ),
                      child: Icon(
                        Icons.arrow_downward,
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                    );
                  }
                ),
                ValueListenableBuilder(
                    valueListenable: previewPage.endPointNotifier,
                    builder: (_, value, __) {
                      return Align(
                        alignment: Alignment(
                          (2 * previewPage.endPointNotifier.value.inSeconds / durationSec) - 1,
                          1
                        ),
                        child: Icon(
                          Icons.arrow_downward,
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                      );
                    }
                ),
              ],
            ),
          ),
          // audio slider
          Padding(
            padding: const EdgeInsets.fromLTRB(10,15,10,0),
            child: ValueListenableBuilder<ProgressBarState>(
              valueListenable: previewPage.progressNotifier,
              builder: (_, value, __) {
                return ProgressBar(
                  baseBarColor: Colors.deepPurple[50],
                  bufferedBarColor: Colors.deepPurple[100],
                  progressBarColor: Colors.deepPurple[300],
                  thumbColor: Colors.deepPurple[500],
                  thumbGlowColor: Colors.deepPurple[50],
                  progress: value.current,
                  buffered: value.buffered,
                  total: value.total,
                  onSeek: previewPage.audioPlayer.seek,
                  timeLabelTextStyle: TextStyle(
                    fontSize: 18,
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                );
              },
            ),
          ),
        ]
      ),
    );
  }
}

class WidgetControlButton extends StatelessWidget {
  const WidgetControlButton({Key? key, required this.previewPage}) : super(key: key);

  final AudioPageManager previewPage;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Previous Button
        ValueListenableBuilder(
            valueListenable: previewPage.startPointNotifier,
            builder: (_, value, __) {
              return IconButton(
                icon: Icon(
                  Icons.skip_previous,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
                iconSize: 70,
                onPressed: () {
                  previewPage.audioPlayer.seek(previewPage.startPointNotifier.value);
                },
              );
            }
        ),
        // Play, Pause Button
        ValueListenableBuilder(
          valueListenable: previewPage.buttonNotifier,
          builder: (_, value, __) {
            switch (value) {
            // on Paused
              case ButtonState.paused:
                return IconButton(
                  icon: Icon(
                    Icons.play_arrow,
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                  iconSize: 100,
                  onPressed: () {
                    previewPage.audioPlayer.play();
                  },
                );
            // on Playing
              case ButtonState.playing:
                return IconButton(
                  icon: Icon(
                    Icons.pause,
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                  iconSize: 100,
                  onPressed: () {
                    previewPage.audioPlayer.pause();
                  },
                );
              case ButtonState.loading:
                return Container(
                  margin: const EdgeInsets.all(10),
                  width: 100,
                  height: 100,
                  child: const CircularProgressIndicator(),
                );
            } return Icon(
              Icons.error,
              color: Theme.of(context).colorScheme.onBackground,
            );
          },
        ),
        // Next Button
        ValueListenableBuilder(
            valueListenable: previewPage.endPointNotifier,
            builder: (_, value, __) {
              return IconButton(
                icon: Icon(
                  Icons.skip_next,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
                iconSize: 70,
                onPressed: () {
                  previewPage.audioPlayer.seek(previewPage.endPointNotifier.value);
                },
              );
            }
        ),
      ],
    );
  }
}

class WidgetStartPointSetter extends StatelessWidget {
  const WidgetStartPointSetter({Key? key, required this.previewPage}) : super(key: key);

  final AudioPageManager previewPage;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ValueListenableBuilder(
        valueListenable: previewPage.startPointNotifier,
        builder: (_, value, __) {
          return ElevatedButton(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text(
                  "BUTTON_AUDIO_EDIT_PAGE_STARTPOINT",
                  style: TextStyle(
                    fontSize: 13,
                  ),
                  maxLines: 1,
                ).tr(),
                Text(
                  previewPage.startPointNotifier.value.toString().substring(2, 10),
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold
                  ),
                  maxLines: 1,
                ),
              ],
            ),
            style: ElevatedButton.styleFrom(
                primary: Theme.of(context).colorScheme.surfaceVariant,
                onPrimary: Theme.of(context).colorScheme.onSurfaceVariant,
                minimumSize: const Size(double.maxFinite, 50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)
                )
            ),
            onPressed: () {
              if(previewPage.selectedAudioIndex.endPoint <= previewPage.audioPlayer.position) {
                Get.showSnackbar(
                    GetSnackBar(
                      icon: const Icon(Icons.error),
                      title: tr("SNACKBAR_AUDIO_EDIT_START_AFTER_END_TITLE"),
                      message: tr("SNACKBAR_AUDIO_EDIT_START_AFTER_END_MESSAGE"),
                      duration: const Duration(seconds: 2),
                      snackPosition: SnackPosition.TOP,
                    )
                );
              }
              else {
                previewPage.startPointNotifier.value = previewPage.audioPlayer.position;
                previewPage.selectedAudioIndex.startPoint = previewPage.startPointNotifier.value;
              }
            },
          );
        },
      ),
    );
  }
}
class WidgetEndPointSetter extends StatelessWidget {
  const WidgetEndPointSetter({Key? key, required this.previewPage}) : super(key: key);

  final AudioPageManager previewPage;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ValueListenableBuilder(
          valueListenable: previewPage.endPointNotifier,
          builder: (_, value, __) {
            return ElevatedButton(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text(
                    "BUTTON_AUDIO_EDIT_PAGE_ENDPOINT",
                    style: TextStyle(
                      fontSize: 13,
                    ),
                    maxLines: 1,
                  ).tr(),
                  Text(
                    previewPage.endPointNotifier.value.toString().substring(2, 10),
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold
                    ),
                    maxLines: 1,
                  ),
                ],
              ),
              style: ElevatedButton.styleFrom(
                  primary: Theme.of(context).colorScheme.surfaceVariant,
                  onPrimary: Theme.of(context).colorScheme.onSurfaceVariant,
                  minimumSize: const Size(double.maxFinite, 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)
                  )
              ),
              onPressed: () {
                if(previewPage.selectedAudioIndex.startPoint >= previewPage.audioPlayer.position) {
                  Get.showSnackbar(
                      GetSnackBar(
                        icon: const Icon(Icons.error),
                        title: tr("SNACKBAR_AUDIO_EDIT_END_BEFORE_START_TITLE"),
                        message: tr("SNACKBAR_AUDIO_EDIT_END_BEFORE_START_MESSAGE"),
                        duration: const Duration(seconds: 2),
                        snackPosition: SnackPosition.TOP,
                      )
                  );
                }
                else {
                  previewPage.endPointNotifier.value = previewPage.audioPlayer.position;
                  previewPage.selectedAudioIndex.endPoint = previewPage.endPointNotifier.value;
                }
              },
            );
          }
      ),
    );
  }
}