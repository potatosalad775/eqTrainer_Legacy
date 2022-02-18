import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:numberpicker/numberpicker.dart';

import 'package:eqtrainer/globals.dart' as globals;
import 'package:eqtrainer/service/SessionPageManager.dart';

class SessionService extends StatefulWidget {
  const SessionService({Key? key}) : super(key: key);

  @override
  _SessionServiceState createState() => _SessionServiceState();
}
class _SessionServiceState extends State<SessionService> {

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            showDialog<void>(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text("ALERT_SESSION_EXIT_TITLE").tr(),
                  content: SingleChildScrollView(
                    child: const Text("ALERT_SESSION_EXIT_CONTENT").tr(),
                  ),
                  actions: <Widget>[
                    TextButton(
                      child: const Text("ALERT_SESSION_EXIT_CONTINUE").tr(),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    TextButton(
                      child: const Text("ALERT_SESSION_EXIT_EXIT").tr(),
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.popAndPushNamed(
                          context,
                          '/resultPage',
                        );
                      },
                    )
                  ],
                );
              }
            );
          },
        ),
        title: const Text("HEADLINE_SESSION_SERVICE").tr(),
        titleSpacing: 0,
        backgroundColor: Theme.of(context).colorScheme.background,
        foregroundColor: Theme.of(context).colorScheme.onBackground,
        elevation: 1,
      ),
      body: const ChartWidget(),
    );
  }
}

class ChartWidget extends StatefulWidget {
  const ChartWidget({Key? key}) : super(key: key);

  @override
  _ChartWidgetState createState() => _ChartWidgetState();
}
class _ChartWidgetState extends State<ChartWidget> {

  // Value for Graph Index Number
  int previousPickerValue = 1;
  int currentPickerValue = 1;
  Duration currentPosition = Duration.zero;

  // List of bool for tracking EQ Filter button selection state
  // 0 - Original(Filter not applied) button / 1 - EQ Filtered button
  List<bool> isSelected = [true, false];

  // Temporary Value containing Gain value for session.
  int tempGain = globals.sessionGain;

  // PageManager, related to audio Player for session
  late SessionPageManager sessionManager;

  Future<void> initFunc() async {
    sessionManager = SessionPageManager();
  }

  @override
  void initState() {
    initFunc();
    super.initState();
  }

  @override
  void dispose() {
    sessionManager.originalPlayer.dispose();
    sessionManager.filteredPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: sessionManager.updateFlag,
      builder: (_, value, __) {
        if(value == false) {
          return Column(
            children: [
              // Graph Widget
              Expanded(
                child: Container(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  padding: const EdgeInsets.fromLTRB(0, 20, 20, 0),
                  child: LineChart(
                      LineChartData(
                          lineTouchData: LineTouchData(enabled: false),
                          // Grid Line
                          gridData: FlGridData(show: false),
                          // Vertical Line
                          extraLinesData: ExtraLinesData(
                            extraLinesOnTop: false,
                            horizontalLines: [
                              HorizontalLine(
                                y: -3,
                                strokeWidth: 4,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                              HorizontalLine(
                                y: -2,
                                strokeWidth: 0.5,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                              HorizontalLine(
                                y: 2,
                                strokeWidth: 0.5,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                              HorizontalLine(
                                y: 3,
                                strokeWidth: 4,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ],
                            verticalLines: [
                              VerticalLine( // 20hz
                                x: 0,
                                strokeWidth: 4,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                              VerticalLine( // 20hz
                                x: 59,
                                strokeWidth: 1,
                                color: Theme.of(context).colorScheme.outline,
                              ),
                              VerticalLine( // 50hz
                                x: 137,
                                strokeWidth: 0.5,
                                color: Theme.of(context).colorScheme.outline,
                              ),
                              VerticalLine( // 100hz
                                x: 197,
                                strokeWidth: 0.5,
                                color: Theme.of(context).colorScheme.outline,
                              ),
                              VerticalLine( // 200hz
                                x: 256,
                                strokeWidth: 1,
                                color: Theme.of(context).colorScheme.outline,
                              ),
                              VerticalLine( // 500hz
                                x: 335,
                                strokeWidth: 0.5,
                                color: Theme.of(context).colorScheme.outline,
                              ),
                              VerticalLine( // 1khz
                                x: 394,
                                strokeWidth: 0.5,
                                color: Theme.of(context).colorScheme.outline,
                              ),
                              VerticalLine( // 2khz
                                x: 452,
                                strokeWidth: 1,
                                color: Theme.of(context).colorScheme.outline,
                              ),
                              VerticalLine( // 5khz
                                x: 531,
                                strokeWidth: 0.5,
                                color: Theme.of(context).colorScheme.outline,
                              ),
                              VerticalLine( // 10khz
                                x: 590,
                                strokeWidth: 0.5,
                                color: Theme.of(context).colorScheme.outline,
                              ),
                              VerticalLine( // 20hz
                                x: 650,
                                strokeWidth: 4,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ],
                          ),
                          // Graph Border
                          borderData: FlBorderData(show: false),
                          // Axis Titles
                          titlesData: FlTitlesData(
                            show: true,
                            rightTitles: SideTitles(showTitles: false),
                            topTitles: SideTitles(showTitles: false),
                            leftTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 20,
                                textAlign: TextAlign.center,
                                rotateAngle: -90,
                                getTitles: (value) {
                                  // we aren't using actual gain value to calculate y axis value of graph.
                                  // each graph's vertex's y axis value is fixed to 2 or -2.
                                  if(value.abs() == 2 && value < 0) {
                                    return '${0 - tempGain}';
                                  }
                                  if(value.abs() == 0) {
                                    return '0';
                                  }
                                  if(value.abs() == 2 && value > 0) {
                                    return '$tempGain';
                                  }
                                  else {
                                    return '';
                                  }
                                },
                                getTextStyles: (context, value) {
                                  return TextStyle(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  );
                                }
                            ),
                            bottomTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 20,
                                interval: 1,
                                textAlign: TextAlign.center,
                                margin: 3,
                                getTitles: (value) {
                                  // i know it's stupid, but the value below here are
                                  // calculated from pixel width of H2L program's graph
                                  switch (value.toInt()) {
                                    case 59:
                                      return '20';
                                    case 137:
                                      return '50';
                                    case 197:
                                      return '100';
                                    case 256:
                                      return '200';
                                    case 335:
                                      return '500';
                                    case 394:
                                      return '1k';
                                    case 452:
                                      return '2k';
                                    case 531:
                                      return '5k';
                                    case 590:
                                      return '10k';
                                    case 650:
                                      return '20k';
                                  }
                                  return '';
                                },
                                getTextStyles: (context, value) {
                                  return TextStyle(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  );
                                }
                            ),
                          ),
                          // Actual Graph
                          lineBarsData: sessionManager.graphData,
                          minX: 0, maxX: 650, minY: -3, maxY: 3,
                          clipData: FlClipData.all()
                      )
                  ),
                ),
              ),
              // Graph Selector
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // decrease currentPickerValue, which represents index of selected graph
                  IconButton(
                    icon: Icon(
                      Icons.remove,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                    iconSize: (MediaQuery.of(context).size.width) * 0.1,
                    onPressed: () {
                      setState(() {
                        final newValue = currentPickerValue - 1;
                        currentPickerValue = newValue.clamp(1, sessionManager.graphNumber);
                      });
                    },
                  ),
                  // horizontal scrollable number picker for currentPickerValue
                  NumberPicker(
                    value: currentPickerValue,
                    minValue: 1,
                    maxValue: sessionManager.graphNumber,
                    step: 1,
                    axis: Axis.horizontal,
                    itemWidth: (MediaQuery.of(context).size.width) * 0.2,
                    selectedTextStyle: TextStyle(
                      color: Theme.of(context).colorScheme.tertiary,
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                    ),
                    textStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onBackground,
                      fontSize: 15,
                    ),
                    onChanged: (value) {
                      setState(() {
                        sessionManager.graphData[previousPickerValue - 1] = sessionManager.graphData[previousPickerValue - 1].copyWith(colors: [Colors.redAccent]);
                        currentPickerValue = value;
                        sessionManager.graphData[currentPickerValue - 1] = sessionManager.graphData[currentPickerValue - 1].copyWith(colors: [Colors.blueAccent]);
                        previousPickerValue = value;
                      });
                    },
                  ),
                  // increase currentPickerValue, which represents index of selected graph
                  IconButton(
                    icon: Icon(
                      Icons.add,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                    iconSize: (MediaQuery.of(context).size.width) * 0.1,
                    onPressed: () {
                      setState(() {
                        final newValue = currentPickerValue + 1;
                        currentPickerValue = newValue.clamp(1, sessionManager.graphNumber);
                      });
                    },
                  ),
                ],
              ),
              // Clip Controller
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Previous Button
                  IconButton(
                    icon: Icon(
                      Icons.skip_previous,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                    iconSize: (MediaQuery.of(context).size.width) * 0.2,
                    onPressed: () {
                      sessionManager.seekToPrevious();
                    },
                  ),
                  // Play, Pause Button
                  ValueListenableBuilder(
                    valueListenable: sessionManager.playButtonNotifier,
                    builder: (_, value, __) {
                      switch (value) {
                      // on Paused
                        case ButtonState.paused:
                          return IconButton(
                            icon: Icon(
                              Icons.play_arrow,
                              color: Theme.of(context).colorScheme.onBackground,
                            ),
                            iconSize: (MediaQuery.of(context).size.width) * 0.3,
                            onPressed: () {
                              sessionManager.play();
                            },
                          );
                      // on Playing
                        case ButtonState.playing:
                          return IconButton(
                            icon: Icon(
                              Icons.pause,
                              color: Theme.of(context).colorScheme.onBackground,
                            ),
                            iconSize: (MediaQuery.of(context).size.width) * 0.3,
                            onPressed: () {
                              sessionManager.pause();
                            },
                          );
                        case ButtonState.loading:
                          return Container(
                            margin: const EdgeInsets.all(10),
                            width: (MediaQuery.of(context).size.width) * 0.3,
                            height: (MediaQuery.of(context).size.width) * 0.3,
                            child: const CircularProgressIndicator(),
                          );
                      } return const Icon(Icons.error);
                    },
                  ),
                  // Next Button
                  IconButton(
                    icon: Icon(
                      Icons.skip_next,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                    iconSize: (MediaQuery.of(context).size.width) * 0.2,
                    onPressed: () {
                      sessionManager.seekToNext();
                    },
                  ),
                ],
              ),
              // Filter Selector
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    // Filter Button
                    ToggleButtons(
                      constraints: BoxConstraints(
                          minWidth: (MediaQuery.of(context).size.width) * 0.35,
                          minHeight: 48
                      ),
                      children: <Widget>[
                        const Text("BUTTON_EQ_OFF").tr(),
                        const Text("BUTTON_EQ_ON").tr(),
                      ],
                      fillColor: Theme.of(context).colorScheme.primary,
                      selectedColor: Theme.of(context).colorScheme.onPrimary,
                      color: Theme.of(context).colorScheme.outline,
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold
                      ),
                      onPressed: (int index) {
                        setState(() {
                          // Original Pressed
                          if(index == 0) {
                            // if user is switching filtered audio to original audio
                            if(isSelected[1]) {
                              sessionManager.filteredPlayer.setVolume(0);
                              sessionManager.originalPlayer.setVolume(1);
                            }
                            isSelected[0] = true;
                            isSelected[1] = false;
                          }
                          // EQ Filtered pressed
                          else {
                            // if user is switching original audio to filtered audio
                            if(isSelected[0]) {
                              sessionManager.originalPlayer.setVolume(0);
                              sessionManager.filteredPlayer.setVolume(1);
                            }
                            isSelected[0] = false;
                            isSelected[1] = true;
                          }
                        });
                      },
                      isSelected: isSelected,
                    ),
                    // Submit Answer
                    Ink(
                      decoration: ShapeDecoration(
                          color: Theme.of(context).colorScheme.tertiary,
                          shape: const CircleBorder()
                      ),
                      child: IconButton(
                        color: Theme.of(context).colorScheme.tertiary,
                        icon: Icon(
                          Icons.next_plan_outlined,
                          color: Theme.of(context).colorScheme.onTertiary,
                        ),
                        onPressed: () {
                          // converting index of graph into index of center frequency.
                          late int freqIndex;
                          if(globals.sessionFilter == 'Peak & Dip') {
                            freqIndex = (sessionManager.answerIndex.value - 1) ~/ 2;
                          }
                          else {
                            freqIndex = sessionManager.answerIndex.value - 1;
                          }
                          // evaluate whether user's answer was correct or not
                          // calculating answer's frequency will happen on globals.updateSessionResult function.
                          if(currentPickerValue == sessionManager.answerIndex.value) {
                            globals.sessionPoint++;
                            globals.updateSessionResult(true, sessionManager.vertexFrequencyData[freqIndex]);
                            Get.showSnackbar(
                                GetSnackBar(
                                  icon: const Icon(Icons.check_circle),
                                  title: tr("SNACKBAR_FEEDBACK_CORRECT"),
                                  message: tr(
                                    "SNACKBAR_FEEDBACK_ANSWER",
                                    namedArgs: {"ANSWER_INDEX": sessionManager.answerIndex.value.toString()}
                                  ),
                                  duration: const Duration(seconds: 2),
                                  snackPosition: SnackPosition.TOP,
                                )
                            );
                          }
                          else {
                            globals.sessionPoint--;
                            globals.updateSessionResult(false, sessionManager.vertexFrequencyData[freqIndex]);
                            Get.showSnackbar(
                                GetSnackBar(
                                  icon: const Icon(Icons.cancel),
                                  title: tr("SNACKBAR_FEEDBACK_INCORRECT"),
                                  message: tr(
                                      "SNACKBAR_FEEDBACK_ANSWER",
                                      namedArgs: {"ANSWER_INDEX": sessionManager.answerIndex.value.toString()}
                                  ),
                                  duration: const Duration(seconds: 2),
                                  snackPosition: SnackPosition.TOP,
                                )
                            );
                          }
                          // reset filter selection toggle button
                          isSelected[0] = true;
                          isSelected[1] = false;
                          // reset graph with blue accent
                          sessionManager.graphData[currentPickerValue - 1] = sessionManager.graphData[currentPickerValue - 1].copyWith(colors: [Colors.redAccent]);
                          sessionManager.graphData[0] = sessionManager.graphData[0].copyWith(colors: [Colors.blueAccent]);
                          // reset picker value
                          currentPickerValue = 1;
                          previousPickerValue = 1;
                          // collection of functions to start next round
                          sessionManager.nextRound();
                        },
                      ),
                    )
                  ],
                ),
              ),
            ],
          );
        }
        else {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  "PROGRESS_INDICATOR_PAGE_SESSION_UPPER",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                ).tr(),
                Text(
                  "PROGRESS_INDICATOR_PAGE_SESSION_LOWER",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                ).tr(),
                const SizedBox(
                  height: 15,
                ),
                const CircularProgressIndicator(),
              ],
            ),
          );
        }
      }
    );
  }
}