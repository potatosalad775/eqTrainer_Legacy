import 'package:flutter/material.dart';
import 'package:eqtrainer/globals.dart' as globals;
import 'package:eqtrainer/pages/HelpPage.dart';
import 'package:easy_localization/easy_localization.dart';

class SessionPage extends StatefulWidget {
  const SessionPage({Key? key}) : super(key: key);

  @override
  State<SessionPage> createState() => _SessionPageState();
}

class _SessionPageState extends State<SessionPage> {

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const ScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Headline
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 20, 0, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "HEADLINE_SESSION_PAGE_UPPER",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontWeight: FontWeight.w300,
                    fontSize: 30,
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                ).tr(),
                const SizedBox(height: 3,),
                Text(
                  "HEADLINE_SESSION_PAGE_LOWER",
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
          // Session Configurations list
          ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
            itemCount: 5,
            itemBuilder: (context, index) {
              return SessionSelectorCard(index: index);
            },
          ),
          // Buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(13, 5, 13, 20),
            child: Row(
              children: <Widget>[
                Ink(
                  width: 73, height: 73,
                  decoration: ShapeDecoration(
                    color: Theme.of(context).colorScheme.tertiaryContainer,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)
                    )
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.help_outline,
                      size: 30,
                    ),
                    color: Theme.of(context).colorScheme.onTertiaryContainer,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) => const HelpPage(),
                        )
                      );
                    },
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(
                      Icons.play_arrow,
                      size: 35,
                    ),
                    label: const Text(
                      "BUTTON_SESSION_START",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ).tr(),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(73, 73),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                      )
                    ),
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/sessionService',
                      );
                    },
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

class SessionSelectorCard extends StatefulWidget {
  final int index;
  const SessionSelectorCard({Key? key, required this.index}) : super(key: key);

  @override
  _SessionSelectorCardState createState() => _SessionSelectorCardState();
}
class _SessionSelectorCardState extends State<SessionSelectorCard> {

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
      child: Card(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)
          ),
          color: Theme.of(context).colorScheme.surfaceVariant,
          child: ListTile(
            title: Text(
              // Starting Band
              (widget.index == 0) ? "SSC_NAME_STARTING_POINT".tr()
              // Gain (dB)
              : (widget.index == 1) ? "SSC_NAME_GAIN".tr()
              // Q Factor
              : (widget.index == 2) ? "SSC_NAME_QFACTOR".tr()
              // Filter
              : (widget.index == 3) ? "SSC_NAME_FILTER".tr()
              // Session Point - related to the result of session and it will change the number of bands
              : "SSC_NAME_POINTLIMIT".tr(),
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface
              ),
            ),
            subtitle: Text(
              // Starting Band
              (widget.index == 0) ? "SSC_DESC_STARTING_POINT".tr()
              // Gain (dB)
              : (widget.index == 1) ? "SSC_DESC_GAIN".tr()
              // Q Factor
              : (widget.index == 2) ? "SSC_DESC_QFACTOR".tr()
              // Filter
              : (widget.index == 3) ? "SSC_DESC_FILTER".tr()
              // Session Point - related to the result of session and it will change the number of bands
              : "SSC_DESC_POINTLIMIT".tr(),
              style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.onSurfaceVariant
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            // DropDownMenu
            trailing:
              // Starting Band
              (widget.index == 0) ? const DDBStartingBand()
              // Gain (dB)
              : (widget.index == 1) ? const DDBGain()
              // Q Factor
              : (widget.index == 2) ? const DDBQFactor()
              // Filter
              : (widget.index == 3) ? const DDBFilter()
              // Session Point - related to the result of session and it will change the number of bands
              : const DDBSessionPoint(),
            contentPadding: const EdgeInsets.fromLTRB(17, 0, 12, 0),
          )
      ),
    );
  }
}

class DDBStartingBand extends StatefulWidget {
  const DDBStartingBand({Key? key}) : super(key: key);

  @override
  _DDBStartingBandState createState() => _DDBStartingBandState();
}
class _DDBStartingBandState extends State<DDBStartingBand> {
  @override
  Widget build(BuildContext context) {
    return DropdownButton(
      alignment: Alignment.centerRight,
      isDense: true,
      value: globals.sessionStartingBand,
      menuMaxHeight: 400,
      items: globals.sessionStartingBandList.map<DropdownMenuItem<int>>((int value) {
        return DropdownMenuItem<int>(
          value: value,
          child: Text('$value'),
        );
      }).toList(),
      onChanged: (selectedVal) {
        setState(() {
          globals.sessionStartingBand = selectedVal as int;
        });
      },
      underline: Container(
        color: Colors.transparent,
      ),
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurface,
        fontSize: 17,
        fontWeight: FontWeight.bold
      ),
      icon: const Padding(
        padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
        child: Icon(Icons.arrow_drop_down),
      ),
    );
  }
}

class DDBGain extends StatefulWidget {
  const DDBGain({Key? key}) : super(key: key);

  @override
  _DDBGainState createState() => _DDBGainState();
}
class _DDBGainState extends State<DDBGain> {
  @override
  Widget build(BuildContext context) {
    return DropdownButton(
      alignment: Alignment.centerRight,
      isDense: true,
      value: globals.sessionGain,
      menuMaxHeight: 400,
      items: globals.sessionGainList.map<DropdownMenuItem<int>>((int value) {
        return DropdownMenuItem<int>(
          value: value,
          child: Text('$value'),
        );
      }).toList(),
      onChanged: (selectedVal) {
        setState(() {
          globals.sessionGain = selectedVal as int;
        });
      },
      underline: Container(
        color: Colors.transparent,
      ),
      style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontSize: 17,
          fontWeight: FontWeight.bold
      ),
      icon: const Padding(
        padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
        child: Icon(Icons.arrow_drop_down),
      ),
    );
  }
}

class DDBQFactor extends StatefulWidget {
  const DDBQFactor({Key? key}) : super(key: key);

  @override
  _DDBQFactorState createState() => _DDBQFactorState();
}
class _DDBQFactorState extends State<DDBQFactor> {
  @override
  Widget build(BuildContext context) {
    return DropdownButton(
      alignment: Alignment.centerRight,
      isDense: true,
      value: globals.sessionQFactor,
      menuMaxHeight: 400,
      items: globals.sessionQFactorList.map<DropdownMenuItem<double>>((double value) {
        return DropdownMenuItem<double>(
          value: value,
          child: Text('$value'),
        );
      }).toList(),
      onChanged: (selectedVal) {
        setState(() {
          globals.sessionQFactor = selectedVal as double;
        });
      },
      underline: Container(
        color: Colors.transparent,
      ),
      style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontSize: 17,
          fontWeight: FontWeight.bold
      ),
      icon: const Padding(
        padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
        child: Icon(Icons.arrow_drop_down),
      ),
    );
  }
}

class DDBFilter extends StatefulWidget {
  const DDBFilter({Key? key}) : super(key: key);

  @override
  _DDBFilterState createState() => _DDBFilterState();
}
class _DDBFilterState extends State<DDBFilter> {
  @override
  Widget build(BuildContext context) {
    return DropdownButton(
      alignment: Alignment.centerRight,
      isDense: true,
      value: globals.sessionFilter,
      menuMaxHeight: 400,
      items: globals.sessionFilterList.map((String value) {
        return DropdownMenuItem(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (selectedVal) {
        setState(() {
          globals.sessionFilter = selectedVal as String;
        });
      },
      underline: Container(
        color: Colors.transparent,
      ),
      style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontSize: 17,
          fontWeight: FontWeight.bold
      ),
      icon: const Padding(
        padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
        child: Icon(Icons.arrow_drop_down),
      ),
    );
  }
}

class DDBSessionPoint extends StatefulWidget {
  const DDBSessionPoint({Key? key}) : super(key: key);
  @override
  _DDBSessionPointState createState() => _DDBSessionPointState();
}
class _DDBSessionPointState extends State<DDBSessionPoint> {
  @override
  Widget build(BuildContext context) {
    return DropdownButton(
      alignment: Alignment.centerRight,
      isDense: true,
      value: globals.sessionPointLimit,
      menuMaxHeight: 400,
      items: globals.sessionPointLimitList.map<DropdownMenuItem<int>>((int value) {
        return DropdownMenuItem<int>(
          value: value,
          child: Text('$value'),
        );
      }).toList(),
      onChanged: (selectedVal) {
        setState(() {
          globals.sessionPointLimit = selectedVal as int;
        });
      },
      underline: Container(
        color: Colors.transparent,
      ),
      style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontSize: 17,
          fontWeight: FontWeight.bold
      ),
      icon: const Padding(
        padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
        child: Icon(Icons.arrow_drop_down),
      ),
    );
  }
}