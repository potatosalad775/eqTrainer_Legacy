import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Theme.of(context).colorScheme.background,
        foregroundColor: Theme.of(context).colorScheme.onBackground,
        leading: const BackButton(),
        titleSpacing: 0,
        title: const Text('Help'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(15),
        children: <Widget>[
          const Image(
            image: AssetImage('assets/sessionGraph.png'),
          ),
          const SizedBox(height: 15,),
          Text(
            'HELP_STARTING_BAND',
            style: TextStyle(color: Theme.of(context).colorScheme.onBackground,),
            textAlign: TextAlign.start,
          ).tr(),
          const SizedBox(height: 15,),
          Text(
            'HELP_GAIN',
            style: TextStyle(color: Theme.of(context).colorScheme.onBackground,),
            textAlign: TextAlign.start,
          ).tr(),
          const SizedBox(height: 15,),
          Text(
            'HELP_QFACTOR',
            style: TextStyle(color: Theme.of(context).colorScheme.onBackground,),
            textAlign: TextAlign.start,
          ).tr(),
          const SizedBox(height: 15,),
          Text(
            'HELP_FILTER',
            style: TextStyle(color: Theme.of(context).colorScheme.onBackground,),
            textAlign: TextAlign.start,
          ).tr(),
          const SizedBox(height: 15,),
          Text(
            'HELP_POINTLIMIT',
            style: TextStyle(color: Theme.of(context).colorScheme.onBackground,),
            textAlign: TextAlign.start,
          ).tr(),
          const SizedBox(height: 15,),
          Text(
            'HELP_DISCLAIMER_SESSION',
            style: TextStyle(color: Theme.of(context).colorScheme.onBackground,),
            textAlign: TextAlign.start,
          ).tr(),
          const SizedBox(height: 15,),
          Text(
            'HELP_DISCLAIMER_GAIN',
            style: TextStyle(color: Theme.of(context).colorScheme.onBackground,),
            textAlign: TextAlign.start,
          ).tr(),
          const SizedBox(height: 15,),
          Text(
            'HELP_DISCLAIMER_PLAYLIST',
            style: TextStyle(color: Theme.of(context).colorScheme.onBackground,),
            textAlign: TextAlign.start,
          ).tr(),
        ],
      ),
    );
  }
}
