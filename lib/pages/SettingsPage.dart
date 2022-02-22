import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:eqtrainer/service/ThemeService.dart';
import 'package:eqtrainer/service/UpgradeService.dart';
import 'package:path_provider/path_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override

  Widget build(BuildContext context) {
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
                    'eqTrainer',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontWeight: FontWeight.w300,
                      fontSize: 30,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                  ),
                  const SizedBox(height: 3,),
                  Text(
                    "HEADLINE_SETTINGS_PAGE",
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
            // Setting Section
            ListView(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              children: const <Widget>[
                SettingCardDarkMode(),
                SettingCardLanguage(),
                DonationCard(),
                ContactDevCard(),
                WipeCacheCard(),
                UpdateCard(),
                OpenSourceLicenseCard()
              ],
            ),
            // About eqTrainer
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 0, 0, 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Project eqTrainer',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                  ),
                  const SizedBox(height: 3,),
                  Text(
                    'Powered by Flutter & Open-source Community',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
  }
}

class SettingCardDarkMode extends StatefulWidget {
  const SettingCardDarkMode({Key? key}) : super(key: key);
  @override
  State<SettingCardDarkMode> createState() => _SettingCardDarkModeState();
}
class _SettingCardDarkModeState extends State<SettingCardDarkMode> {
  // initial menu item
  String dropDownMenu = ThemeService().themeString;
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
            leading: Icon(
              Icons.dark_mode,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            title: Text(
              "SETTINGS_DARKMODE",
              style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurface
              ),
            ).tr(),
            // DropDownMenu
            trailing: DropdownButton(
              alignment: Alignment.centerRight,
              isDense: true,
              value: dropDownMenu,
              menuMaxHeight: 400,
              items: <String>['DARKMODE_LIGHT', 'DARKMODE_DARK', 'DARKMODE_SYSTEM']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: (value == 'DARKMODE_LIGHT') ? const Text('DARKMODE_LIGHT').tr()
                      : (value == 'DARKMODE_DARK') ? const Text('DARKMODE_DARK').tr()
                      : const Text('DARKMODE_SYSTEM').tr()
                );
              }).toList(),
              onChanged: (String? selectedVal) {
                setState(() {
                  dropDownMenu = selectedVal!;
                  if(dropDownMenu == 'DARKMODE_LIGHT') {
                    ThemeService().switchTheme(ThemeMode.light);
                  } else if(dropDownMenu == 'DARKMODE_DARK') {
                    ThemeService().switchTheme(ThemeMode.dark);
                  } else {
                    ThemeService().switchTheme(ThemeMode.system);
                  }
                });
              },
              underline: Container(
                color: Colors.transparent,
              ),
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 16,
              ),
              icon: const Padding(
                padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
                child: Icon(Icons.arrow_drop_down),
              ),
            ),
            contentPadding: const EdgeInsets.fromLTRB(17, 0, 12, 0),
            horizontalTitleGap: 0,
          )
      ),
    );
  }
}

class SettingCardLanguage extends StatefulWidget {
  const SettingCardLanguage({Key? key}) : super(key: key);

  @override
  _SettingCardLanguageState createState() => _SettingCardLanguageState();
}
class _SettingCardLanguageState extends State<SettingCardLanguage> {
  // initial menu item
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
            leading: Icon(
              Icons.language,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            title: Text(
              "SETTINGS_LANGUAGE",
              style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurface
              ),
            ).tr(),
            // DropDownMenu
            trailing: DropdownButton(
              alignment: Alignment.centerRight,
              isDense: true,
              value: context.locale.toStringWithSeparator(),
              menuMaxHeight: 400,
              items: <String>['en_US', 'ko_KR']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                    value: value,
                    child: (value == 'en_US') ? const Text("LANG_ENGLISH").tr()
                        : (value == 'ko_KR') ? const Text("LANG_KOREAN").tr()
                        : const Text('')
                );
              }).toList(),
              onChanged: (String? selectedVal) {
                context.setLocale(selectedVal!.toLocale());
                Get.updateLocale(selectedVal.toLocale());
              },
              underline: Container(
                color: Colors.transparent,
              ),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 16,
              ),
              icon: const Padding(
                padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
                child: Icon(Icons.arrow_drop_down),
              ),
            ),
            contentPadding: const EdgeInsets.fromLTRB(17, 0, 12, 0),
            horizontalTitleGap: 0,
          )
      ),
    );
  }
}

class DonationCard extends StatelessWidget {
  const DonationCard({Key? key}) : super(key: key);

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
            leading: Icon(
              Icons.favorite,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            title: Text(
              "SETTINGS_DONATE",
              style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurface
              ),
            ).tr(),
            // DropDownMenu
            trailing: Icon(
              Icons.open_in_new,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            onTap: () {
              (context.locale == const Locale('ko', 'KR'))
                  ? launch('https://toss.me/감자샐러드')
                  : launch('https://paypal.me/potatosalad775');
            },
            contentPadding: const EdgeInsets.fromLTRB(17, 0, 17, 0),
            horizontalTitleGap: 0,
          )
      ),
    );
  }
}

class ContactDevCard extends StatelessWidget {
  const ContactDevCard({Key? key}) : super(key: key);

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
            leading: Icon(
              Icons.person,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            title: Text(
              "SETTINGS_DEV",
              style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurface
              ),
            ).tr(),
            // DropDownMenu
            trailing: Wrap(
              children: [
                // twitter
                IconButton(
                  padding: const EdgeInsets.all(0),
                  icon: const FaIcon(FontAwesomeIcons.twitter),
                  color: Theme.of(context).colorScheme.onSurface,
                  onPressed: () {
                    launch('https://twitter.com/potatosalad775');
                  },
                ),
                // email
                IconButton(
                  padding: const EdgeInsets.all(0),
                  icon: const Icon(Icons.mail),
                  color: Theme.of(context).colorScheme.onSurface,
                  onPressed: () {
                    launch('mailto:transaction@kakao.com');
                  },
                ),
              ],
            ),
            contentPadding: const EdgeInsets.fromLTRB(17, 0, 5, 0),
            horizontalTitleGap: 0,
          )
      ),
    );
  }
}

class WipeCacheCard extends StatelessWidget {
  const WipeCacheCard({Key? key}) : super(key: key);

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
            leading: Icon(
              Icons.delete,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            title: Text(
              'SETTINGS_WIPE_CACHE',
              style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurface
              ),
            ).tr(),
            // DropDownMenu
            trailing: Icon(
              Icons.arrow_forward,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            onTap: () async {
              Directory documentDir = await getApplicationDocumentsDirectory();

              try {
                if(Directory(documentDir.path + "/adjusted").existsSync()) {
                  Directory(documentDir.path + "/adjusted").deleteSync(recursive: true);
                }
                if(Directory(documentDir.path + "/filtered").existsSync()) {
                  Directory(documentDir.path + "/filtered").deleteSync(recursive: true);
                }
                Get.showSnackbar(
                  GetSnackBar(
                    icon: const Icon(Icons.check_circle),
                    title: tr("SNACKBAR_CACHE_WIPED_TITLE"),
                    message: tr("SNACKBAR_CACHE_WIPED_MESSAGE"),
                    duration: const Duration(seconds: 2),
                    snackPosition: SnackPosition.TOP,
                  )
                );
              } catch(e) {
                Get.showSnackbar(
                  GetSnackBar(
                    icon: const Icon(Icons.cancel),
                    title: tr("SNACKBAR_CACHE_WIPE_FAILED_TITLE"),
                    message: e.toString(),
                    duration: const Duration(seconds: 2),
                    snackPosition: SnackPosition.TOP,
                  )
                );
              }
            },
            contentPadding: const EdgeInsets.fromLTRB(17, 0, 17, 0),
            horizontalTitleGap: 0,
          )
      ),
    );
  }
}

class OpenSourceLicenseCard extends StatelessWidget {
  const OpenSourceLicenseCard({Key? key}) : super(key: key);

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
            leading: Icon(
              Icons.list_alt,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            title: Text(
              'Open Source License',
              style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurface
              ),
            ),
            // DropDownMenu
            trailing: Icon(
              Icons.open_in_new,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LicensePage()));
            },
            contentPadding: const EdgeInsets.fromLTRB(17, 0, 17, 0),
            horizontalTitleGap: 0,
          )
      ),
    );
  }
}

class UpdateCard extends StatelessWidget {
  const UpdateCard({Key? key}) : super(key: key);

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
            leading: Icon(
              Icons.system_update,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            title: Text(
              "SETTINGS_UPDATE",
              style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurface
              ),
            ).tr(),
            // Version Info
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text(
                  "v$versionMAJOR.$versionMINOR.$versionPATCH",
                  style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onSurface
                  ),
                ),
                Text(
                  (isUpdateAvailable)
                      ? "SETTINGS_UPDATE_AVAILABLE"
                      : "SETTINGS_UPDATE_NOTFOUND",
                  style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurface
                  ),
                ).tr(),
              ],
            ),
            onTap: () {
              if(isUpdateAvailable) {
                launch("https://github.com/potatosalad775/eqTrainer/releases/latest");
              }
            },
            contentPadding: const EdgeInsets.fromLTRB(17, 0, 17, 0),
            horizontalTitleGap: 0,
          )
      ),
    );
  }
}