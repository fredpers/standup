import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_picker/Picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:water_countdown/theme/colortheme.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() {
    return _SettingsScreenState();
  }
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
      floatingActionButton: FloatingActionButton(
        backgroundColor: ColorTheme.getPrimary(),
        onPressed: () => Navigator.pop(context),
        child: Icon(Icons.arrow_back),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(AppLocalizations.of(context).select_timer_duration,  style: TextStyle(color: ColorTheme.getSecondary(), fontSize: 30),),
            Container(height: 10,),
            IconButton(
              iconSize: 100,
              icon: Icon(
                Icons.timer_outlined,
                size: 100,
                color: ColorTheme.getPrimary(),
              ),
              onPressed: () {
                showSettingsDialog(context);
              },
            ),
            Container(height: 30,),
            Text(AppLocalizations.of(context).select_color_theme, style: TextStyle(color: ColorTheme.getSecondary(), fontSize: 30),),
            Container(height: 10,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                colorSelectionButton(ColorTheme.GREEN),
                colorSelectionButton(ColorTheme.BLUE),
                colorSelectionButton(ColorTheme.PINK)
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget colorSelectionButton(int theme) {
   return RaisedButton(
        color: ColorTheme.getPrimaryByChoice(theme),
        child: Container(width: 70, height: 70,),
        onPressed: () {
          ColorTheme.currentSelection = theme;
          SharedPreferences.getInstance().then((pref)=>pref.setInt('colorTheme', theme));
          setState(() {});
        },
        shape: CircleBorder(
            side: BorderSide(
                color: ColorTheme.currentSelection == theme
                    ? Colors.black26
                    : Colors.transparent,
                width: 5),),);
  }

  void showSettingsDialog(BuildContext context) {
    TextStyle style = new TextStyle(color: ColorTheme.getSecondary());
    Picker(
      adapter: NumberPickerAdapter(data: <NumberPickerColumn>[
        NumberPickerColumn(
            begin: 0,
            end: 59,
            suffix: Text(AppLocalizations.of(context).minutes),
            initValue: 15),
        NumberPickerColumn(
            begin: 0,
            end: 59,
            suffix: Text(AppLocalizations.of(context).seconds),
            jump: 5,
            initValue: 0),
      ]),
      delimiter: <PickerDelimiter>[
        PickerDelimiter(
          child: Container(
            width: 30.0,
            alignment: Alignment.center,
            child: Icon(Icons.more_vert),
          ),
        )
      ],
      hideHeader: true,
      confirmTextStyle: style,
      cancelTextStyle: style,
      confirmText: AppLocalizations.of(context).ok,
      cancelText: AppLocalizations.of(context).cancel,
      title: Text(AppLocalizations.of(context).select_duration),
      selectedTextStyle: TextStyle(color: ColorTheme.getSecondary()),
      onConfirm: (Picker picker, List<int> value) async {
        // Set the duration of the countdown
        Duration _duration = Duration(
            minutes: picker.getSelectedValues()[0],
            seconds: picker.getSelectedValues()[1]);
        if (_duration.inSeconds != 0) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setInt('timeLimit', _duration.inSeconds);
        }
      },
    ).showDialog(context);
  }
}
