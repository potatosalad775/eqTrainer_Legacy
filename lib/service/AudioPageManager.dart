import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:eqtrainer/service/FileService.dart';

class AudioPageManager {
  late AudioFileIndex selectedAudioIndex;
  late AudioPlayer audioPlayer;


  //
  // this will notify progress bar with new values
  final progressNotifier = ValueNotifier<ProgressBarState>(
    ProgressBarState(
      current: Duration.zero,
      buffered: Duration.zero,
      total: Duration.zero,
    ),
  );
  //
  // this will notify play,pause button with new value
  final buttonNotifier = ValueNotifier<ButtonState>(ButtonState.paused);
  // this will listen whether startPoint/endPoint got changed or not.
  final startPointNotifier = ValueNotifier<Duration>(Duration.zero);
  final endPointNotifier = ValueNotifier<Duration>(const Duration(days: 1));

  AudioPageManager() {
    _init();
  }

  //
  // Initialize Preview Page
  void _init() async {
    audioPlayer = AudioPlayer();
    _listenPlayerState();
    _listenPlayerPosition();
    _listenBufferedPosition();
    _listenTotalDuration();
  }

  //
  // listening play,pause button state
  void _listenPlayerState() {
    audioPlayer.playerStateStream.listen((playerState) {
      final isPlaying = playerState.playing;
      final processingState = playerState.processingState;
      // buffering song
      if (processingState == ProcessingState.loading ||
          processingState == ProcessingState.buffering) {
        buttonNotifier.value = ButtonState.loading;
      }
      // song is not playing
      else if (!isPlaying) {
        buttonNotifier.value = ButtonState.paused;
      }
      // song is playing, but not completed
      else if (processingState != ProcessingState.completed){
        buttonNotifier.value = ButtonState.playing;
      }
      // song played til end
      else {
        audioPlayer.seek(Duration.zero);
        audioPlayer.pause();
      }
    });
  }

  //
  // listening current position state
  void _listenPlayerPosition() {
    audioPlayer.positionStream.listen((position) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: position,
        buffered: oldState.buffered,
        total: oldState.total,
      );
    });
  }

  //
  // listening buffered position state
  void _listenBufferedPosition() {
    audioPlayer.bufferedPositionStream.listen((bufferedPosition) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: oldState.current,
        buffered: bufferedPosition,
        total: oldState.total,
      );
    });
  }

  //
  // listening duration state
  void _listenTotalDuration() {
    audioPlayer.durationStream.listen((totalDuration) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: oldState.current,
        buffered: oldState.buffered,
        total: totalDuration ?? Duration.zero,
      );
    });
  }
}

//
//
class ProgressBarState {
  Duration current;
  Duration buffered;
  Duration total;

  ProgressBarState({
    required this.current,
    required this.buffered,
    required this.total,
  });
}

enum ButtonState {
  loading, paused, playing
}