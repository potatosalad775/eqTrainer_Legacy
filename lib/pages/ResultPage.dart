import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:eqtrainer/globals.dart' as globals;

class ResultPage extends StatefulWidget {
  const ResultPage({Key? key}) : super(key: key);

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {

  double resultGraphBarWidth = 5;
  int totalCorrectScore = 0;
  int totalIncorrectScore = 0;

  void calculateTotalScore() {
    for(int index = 0; index < 7; ++index) {
      totalCorrectScore += globals.sessionResult[index].correctScore;
      totalIncorrectScore += globals.sessionResult[index].incorrectScore;
    }
  }

  @override
  void initState() {
    calculateTotalScore();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: AppBar(
          leading: const BackButton(),
          title: const Text("HEADLINE_RESULT_PAGE").tr(),
          titleSpacing: 0,
          backgroundColor: Theme.of(context).colorScheme.background,
          foregroundColor: Theme.of(context).colorScheme.onBackground,
          elevation: 1,
        ),
        body: Column(
          children: <Widget>[
            // Card with Score per Frequency Range
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                itemCount: 7,
                itemBuilder: (BuildContext context, int index) {
                  return ResultPerFreqCard(
                    index: index,
                  );
                },
              ),
            ),
            // Card with Total Score
            Container(
              padding: const EdgeInsets.all(20),
              color: Theme.of(context).colorScheme.secondary,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    "BOTTOM_BAR_RESULT_TOTAL",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSecondary,
                    ),
                  ).tr(),
                  (totalCorrectScore + totalIncorrectScore != 0)
                  // if user completed at least one round
                  ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        '${totalCorrectScore * 100 ~/ (totalCorrectScore + totalIncorrectScore)}%',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSecondary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        tr(
                          "BOTTOM_BAR_RESULT_SCORELIST",
                          namedArgs: {
                            'correctScore': totalCorrectScore.toString(),
                            'incorrectScore': totalIncorrectScore.toString(),
                            'totalScore': (totalCorrectScore + totalIncorrectScore).toString(),
                          },
                        ),
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSecondary,
                        ),
                      )
                    ],
                  )
                  // ...else
                  : Text(
                    "BOTTOM_BAR_RESULT_NOTTESTED",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSecondary,
                    ),
                  ).tr()
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}


class ResultPerFreqCard extends StatelessWidget {
  final int index;
  const ResultPerFreqCard({Key? key, required this.index}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
      color: Theme.of(context).colorScheme.surfaceVariant,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10)
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
        horizontalTitleGap: 0,
        // Name and Description of Frequency Range
        leading: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              globals.sessionResult[index].rangeName,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              globals.sessionResult[index].rangeDescription,
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.outline,
              ),
            )
          ],
        ),
        // Session Score
        // If certain range of frequency was tested during session before...
        trailing: (globals.sessionResult[index].correctScore + globals.sessionResult[index].incorrectScore != 0)
          // show percentage and the number of user's answers.
          ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(
                '${(globals.sessionResult[index].correctScore * 100) ~/ (globals.sessionResult[index].correctScore + globals.sessionResult[index].incorrectScore)}%',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                tr(
                  "BOTTOM_BAR_RESULT_SCORELIST",
                  namedArgs: {
                    'correctScore': globals.sessionResult[index].correctScore.toString(),
                    'incorrectScore': globals.sessionResult[index].incorrectScore.toString(),
                    'totalScore': (globals.sessionResult[index].correctScore + globals.sessionResult[index].incorrectScore).toString(),
                  },
                ),
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.outline,
                ),
              )
            ],
          )
          // ... else, show - it was not tested
          : Text(
          "BOTTOM_BAR_RESULT_NOTTESTED",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ).tr()
      ),
    );
  }
}