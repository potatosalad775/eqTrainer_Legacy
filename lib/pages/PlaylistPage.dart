import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:eqtrainer/globals.dart' as globals;
import 'package:eqtrainer/service/AudioPreview.dart';
import 'package:eqtrainer/service/AudioPageManager.dart';

// Main Playlist Section page
class PlaylistPage extends StatefulWidget {
  const PlaylistPage({Key? key}) : super(key: key);

  @override
  State<PlaylistPage> createState() => _PlaylistPageState();
}
class _PlaylistPageState extends State<PlaylistPage> {

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
        valueListenable: globals.fileLoadNotifier,
        builder: (_, value, __) {
          // playlistFile Data initialized
          if(value == 1) {
            return SingleChildScrollView(
              physics: const ScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Headline
                  Padding(
                    padding: const EdgeInsets.fromLTRB(15, 20, 0, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "HEADLINE_PLAYLIST_PAGE_UPPER",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontWeight: FontWeight.w300,
                            fontSize: 30,
                            color: Theme.of(context).colorScheme.onBackground,
                          ),
                        ).tr(),
                        const SizedBox(height: 3,),
                        Text(
                          "HEADLINE_PLAYLIST_PAGE_LOWER",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 30,
                            color: Theme.of(context).colorScheme.onBackground,
                          ),
                        ).tr(),
                      ],
                    ),
                  ),
                  // Playlist Section
                  // if playlist is not empty...
                  globals.playlistData.isNotEmpty
                  ? ReorderableListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                      buildDefaultDragHandles: false,
                      itemCount: globals.playlistData.length,
                      itemBuilder: (context, index) {
                        return PlaylistCard(key: ValueKey(index), index: index);
                      },
                      onReorder: (oldIndex, newIndex) {
                        setState(() {
                          if(newIndex > oldIndex) {
                            newIndex = newIndex - 1;
                          }
                          final element = globals.playlistData.removeAt(oldIndex);
                          globals.playlistData.insert(newIndex, element);
                        });
                        globals.savePlaylist();
                      }
                  )
                  // if playlist is empty...
                  : Padding(
                    padding: const EdgeInsets.fromLTRB(15, 0, 0, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "BODYTEXT_PLAYLIST_PAGE_EMPTY_UPPER",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ).tr(),
                        const SizedBox(height: 5,),
                        const Text(
                          "BODYTEXT_PLAYLIST_PAGE_EMPTY_LOWER",
                          style: TextStyle(
                            fontSize: 13,
                          ),
                        ).tr(),
                      ],
                    ),
                  ),
                  // add audio file button
                  Padding(
                    padding: const EdgeInsets.fromLTRB(13, 5, 13, 20),
                    child: ElevatedButton.icon(
                      icon: const Icon(
                        Icons.add,
                        size: 35,
                      ),
                      label: const Text(
                        "BUTTON_ADD_AUDIO_CLIP",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ).tr(),
                      style: ElevatedButton.styleFrom(
                          primary: Theme.of(context).colorScheme.tertiaryContainer,
                          onPrimary: Theme.of(context).colorScheme.onTertiaryContainer,
                          minimumSize: const Size(double.maxFinite, 73),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)
                          )
                      ),
                      onPressed: () {
                        showModalBottomSheet(
                          backgroundColor: Colors.transparent,
                          context: context,
                          isScrollControlled: true,
                          enableDrag: false,
                          builder: (context) {
                            return const AudioPreview();
                          }
                        ).then((value) => setState(() {}));
                      },
                    ),
                  )
                ],
              ),
            );
          }
          // Circle Indicator for initializing playlistFile Data
          else if(value == 0) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          // It shouldn't happen, but Just in case...
          else {
            return AlertDialog(
              content: const Text("ALERT_ERROR_PLAYLIST_PAGE_TITLE").tr(),
              actions: <Widget>[
                TextButton(
                  child: const Text("ALERT_ERROR_PLAYLIST_PAGE_DISMISS").tr(),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                )
              ],
            );
          }
        }
      );
  }
}

class PlaylistCard extends StatefulWidget {
  final int index;

  const PlaylistCard({Key? key, required this.index}) : super(key: key);

  @override
  _PlaylistCardState createState() => _PlaylistCardState();
}
class _PlaylistCardState extends State<PlaylistCard> {

  // is Audio Clip enabled?
  late bool isEnabled;

  @override
  Widget build(BuildContext context) {
    isEnabled = globals.playlistData[widget.index].enabled;
    _PlaylistPageState? parent = context.findAncestorStateOfType<_PlaylistPageState>();
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
      child: Card(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)
        ),
        color: Theme.of(context).colorScheme.surfaceVariant,
        child: ListTile(
          horizontalTitleGap: 0,
          contentPadding: const EdgeInsets.fromLTRB(18, 0, 8, 0),
          title: Text(
            globals.playlistData[widget.index].name,
            style: TextStyle(
                fontSize: 18,
                color: Theme.of(context).colorScheme.onSurface
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            globals.playlistData[widget.index].startPoint.toString().substring(2, 10) + " ~ " + globals.playlistData[widget.index].endPoint.toString().substring(2, 10),
            style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurfaceVariant
            ),
          ),
          // Drag handle for reordering audio clips
          leading: ReorderableDragStartListener(
            index: widget.index,
            child: Container(
                alignment: Alignment.center,
                width: 20,
                child: const Icon(Icons.drag_handle)
            ),
          ),
          // Switch for enable/disabling Audio clip for session
          trailing: Switch(
            activeColor: Colors.deepPurple[500],
            activeTrackColor: Colors.deepPurple[100],
            value: isEnabled,
            onChanged: (bool newValue) {
              setState(() {
                isEnabled = newValue;
                globals.playlistData[widget.index].enabled = isEnabled;
              });
            },
          ),
          onLongPress: () {
            showModalBottomSheet(
              context: context,
              builder: (context) {
                return Wrap(
                  children: <Widget>[
                    ListTile(
                      horizontalTitleGap: 0,
                      leading: const Icon(Icons.play_arrow),
                      title: const Text("MENU_AUDIO_CLIP_PLAY").tr(),
                      onTap: () {
                        Navigator.pop(context);
                        showModalBottomSheet(context: context, builder: (context) {
                          return PopUpPlayer(index: widget.index);
                        });
                      },
                    ),
                    ListTile(
                      horizontalTitleGap: 0,
                      leading: const Icon(Icons.delete),
                      title: const Text("MENU_AUDIO_CLIP_DELETE").tr(),
                      onTap: () async {
                        // Delete Original File
                        File(globals.playlistData[widget.index].directory).delete();

                        // Update playlist Data file
                        parent?.setState(() {
                          globals.playlistData.removeAt(widget.index);
                        });
                        globals.savePlaylist();
                        Navigator.pop(context);
                        SnackBar(
                          content: const Text("ALERT_AUDIO_CLIP_DELETED").tr(),
                        );

                        // Search and Delete Cache related to Original File
                        // basic Directory variables
                        Directory documentDir = await getApplicationDocumentsDirectory();
                        // this will create /adjusted directory in app document directory, if this does not exist.
                        Directory adjustedFolderDir = await Directory(documentDir.path + '/adjusted').create(recursive: true);
                        // this will create /filtered directory in app temporary directory, if this does not exist.
                        Directory filteredFolderDir = await Directory(documentDir.path + '/filtered').create(recursive: true);
                        // fetch file list from directories
                        final List<FileSystemEntity> adjustedFolderEntities = await adjustedFolderDir.list().toList();
                        final List<FileSystemEntity> filteredFolderEntities = await filteredFolderDir.list().toList();
                        // search and delete cache
                        if(adjustedFolderEntities.isNotEmpty) {
                          for(int index = 0; index < adjustedFolderEntities.length; ++index) {
                            if(adjustedFolderEntities[index].path.substring(adjustedFolderEntities[index].path.length - globals.playlistData[widget.index].name.length, adjustedFolderEntities[index].path.length) == globals.playlistData[widget.index].name) {
                              adjustedFolderEntities[index].deleteSync();
                            }
                          }
                        }
                        if(filteredFolderEntities.isNotEmpty) {
                          for(int index = 0; index < filteredFolderEntities.length; ++index) {
                            if(filteredFolderEntities[index].path.substring(filteredFolderEntities[index].path.length - globals.playlistData[widget.index].name.length, filteredFolderEntities[index].path.length) == globals.playlistData[widget.index].name) {
                              filteredFolderEntities[index].deleteSync();
                            }
                          }
                        }
                      },
                    ),
                  ],
                );
              }
            );
          },
        ),
      ),
    );
  }
}

class PopUpPlayer extends StatefulWidget {
  final int index;

  const PopUpPlayer({Key? key, required this.index}) : super(key: key);

  @override
  _PopUpPlayerState createState() => _PopUpPlayerState();
}
class _PopUpPlayerState extends State<PopUpPlayer> {
  late AudioPageManager popupPlayerPage;
  late AudioPlayer audioPlayer;

  @override
  void initState() {
    popupPlayerPage = AudioPageManager();
    audioPlayer = popupPlayerPage.audioPlayer;
    audioPlayer.setFilePath(globals.appDocumentDirectory.path + globals.playlistData[widget.index].directory);
    print(globals.playlistData[widget.index].directory);
    super.initState();
  }
  
  @override
  void dispose() {
    popupPlayerPage.audioPlayer.dispose();
    audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: <Widget>[
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(25,20,25,0),
              child: ValueListenableBuilder<ProgressBarState>(
                valueListenable: popupPlayerPage.progressNotifier,
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
                    onSeek: popupPlayerPage.audioPlayer.seek,
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Previous Button
                ValueListenableBuilder(
                    valueListenable: popupPlayerPage.startPointNotifier,
                    builder: (_, value, __) {
                      return IconButton(
                        icon: const Icon(Icons.skip_previous),
                        iconSize: 70,
                        onPressed: () {
                          popupPlayerPage.audioPlayer.seek(popupPlayerPage.startPointNotifier.value);
                        },
                      );
                    }
                ),
                // Play, Pause Button
                ValueListenableBuilder(
                  valueListenable: popupPlayerPage.buttonNotifier,
                  builder: (_, value, __) {
                    switch (value) {
                    // on Paused
                      case ButtonState.paused:
                        return IconButton(
                          icon: const Icon(Icons.play_arrow),
                          iconSize: 70,
                          onPressed: () {
                            popupPlayerPage.audioPlayer.play();
                          },
                        );
                    // on Playing
                      case ButtonState.playing:
                        return IconButton(
                          icon: const Icon(Icons.pause),
                          iconSize: 70,
                          onPressed: () {
                            popupPlayerPage.audioPlayer.pause();
                          },
                        );
                      case ButtonState.loading:
                        return Container(
                          margin: const EdgeInsets.all(10),
                          width: 70,
                          height: 70,
                          child: const CircularProgressIndicator(),
                        );
                    } return const Icon(Icons.error);
                  },
                ),
                // Exit Button
                IconButton(
                  icon: const Icon(Icons.close),
                  iconSize: 70,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                )
              ],
            ),
          ],
        ),
      ]
    );
  }
}
