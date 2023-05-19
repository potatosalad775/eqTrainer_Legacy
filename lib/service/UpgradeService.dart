import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_checker/store_checker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

bool isUpdateAvailable = false;

// TODO: Update Version Info for every Release Update
int versionMAJOR = 1;
int versionMINOR = 1;
int versionPATCH = 1;

// Version Fetched from Github API
late int latestVersionMajor;
late int latestVersionMinor;
late int latestVersionPatch;

late bool isPlayStore;

class UpgradeService {
  Future<bool> isFromPlayStore() async {
    Source installationSource = await StoreChecker.getSource;
    if(installationSource == Source.IS_INSTALLED_FROM_PLAY_STORE) {
      return true;
    } else {
      return false;
    }
  }

  Future<VersionFromAPI> fetchData() async {
    final response = await http.get(Uri.parse('https://api.github.com/repos/potatosalad775/eqTrainer/releases/latest'));

    if(response.statusCode == 200) {
      return VersionFromAPI.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to get Version Info.');
    }
  }

  Future<void> checkUpgrade() async {
    isPlayStore = await isFromPlayStore();
    VersionFromAPI apiData = await fetchData();
    String version = apiData.tag_name;
    // extracting integers of version from github api tag data.
    // since tag has prefix 'v', we are searching from index 1.
    int subStringIndex = 1;
    for(int stringIndex = 1; stringIndex < version.length; ++stringIndex) {
      if(version[stringIndex] == '.') {
        if(subStringIndex == 1) {
          latestVersionMajor = int.parse(version.substring(subStringIndex, stringIndex));
          subStringIndex = stringIndex + 1;
        }
        else {
          latestVersionMinor = int.parse(version.substring(subStringIndex, stringIndex));
          subStringIndex = stringIndex + 1;
        }
      }
    }
    latestVersionPatch = int.parse(version.substring(subStringIndex, version.length));

    // if user downloaded this from external source (not play store), app will send update notice
    //
    if(!isPlayStore) {
      if(latestVersionMajor > versionMAJOR) {
        isUpdateAvailable = true;
        Get.dialog(const UpdateAlertWidget());
      } else if(latestVersionMajor == versionMAJOR) {
        if(latestVersionMinor > versionMINOR) {
          isUpdateAvailable = true;
          Get.dialog(const UpdateAlertWidget());
        } else if(latestVersionMinor == versionMINOR) {
          if(latestVersionPatch > versionPATCH) {
            isUpdateAvailable = true;
            Get.dialog(const UpdateAlertWidget());
          }
        }
      }
    }
  }
}

class VersionFromAPI {
  final String tag_name;

  VersionFromAPI({required this.tag_name});

  factory VersionFromAPI.fromJson(Map<String, dynamic> json) {
    return VersionFromAPI(
      tag_name: json["tag_name"],
    );
  }
}

class UpdateAlertWidget extends StatelessWidget {
  const UpdateAlertWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("ALERT_UPDATE_FOUND_TITLE").tr(),
      content: const Text("ALERT_UPDATE_FOUND_CONTENT").tr(),
      actions: <Widget>[
        TextButton(
          child: const Text("ALERT_UPDATE_FOUND_SKIP").tr(),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text("ALERT_UPDATE_FOUND_DOWNLOAD").tr(),
          onPressed: () {
            _launchURL;
          },
        ),
      ],
    );
  }

  Future<void> _launchURL() async {
    if(!await launchUrl(Uri.parse("https://github.com/potatosalad775/eqTrainer/releases/latest/"))) {
      throw Exception('Could not launch URL');
    }
  }
}
