import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_picker/Picker.dart';
import 'widgets/watercounter.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // bool för att dölja/visa startknapp
  bool countDownStarted = false;
  ConfettiController _confettiController;

  @override
  void initState() {
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 1),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
  }

  WaterCountdown waterCountdown;

  _MyHomePageState() {
    waterCountdown = new WaterCountdown(
      // duration är hur lång nedräkningen ska vara. Går att speca t ex Duration(seconds: 10) för att testa en kort nedräkning
      duration: Duration(minutes: 15),
      // onComplete är funktionen som körs countdown har nått 00:00
      onComplete: () {
        countDownStarted = false;
        //Setstate bygger om appen, dvs laddar om state och uppdaterar guit
        setState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Skapar bubblan som räknar ner, bör läggas i en InkWell så att vi kan definera en onclick osv
            buildInkWell(),
            Visibility(
                visible: countDownStarted,
                // Konfettin kommer ifrån vart den här widgeten finns,
                // när det går att avbryta timern innan ska _confettiController.play(); köras
                child: ConfettiWidget(
                    confettiController: _confettiController,
                    blastDirectionality: BlastDirectionality.explosive,
                    maxBlastForce: 10,
                    gravity: 0.002,
                    emissionFrequency: 0.2,
                    colors: [
                      Colors.blueAccent,
                      Colors.black12,
                      Colors.blueGrey,
                      Colors.amberAccent
                    ],
                    child: waterCountdown),
            ),
          ],
        ),
      ),
      floatingActionButton: IconButton(
        onPressed: showSettingsDialog, //_showSettingsDialog,
        icon: Icon(
          Icons.settings,
          color: Colors.blueAccent,
        ),
      ),
    );
  }

  Widget buildInkWell() {
    // Visibility gör så man kan gömma en widget, så la in InkWell i en som är gömd när vi räknar ner
    return Visibility(
      visible: !countDownStarted,
      child: InkWell(
        onTap: () {
          // Bara för att testa att den fungerar, flyttas till function som körs när man avbryter nedräkningen
          _confettiController.play();
          countDownStarted = true;
          setState(() {
            /**
             * Due to waterCountdown being hidden until state is updated we need
             * to wait until it is visible until we try to start the countdown.
             * It's fucking hacky and will probably fail on slow devices.
             * I'll try to fix...
             */
            Future.delayed(Duration(milliseconds: 40), () {
              waterCountdown.startCountdown();
              setState(() {});
            });
          });
        },
        child: Container(
          child: Center(
            child: Text(
              "Start",
              style: TextStyle(color: Colors.white, fontSize: 38),
            ),
          ),
          width: 290,
          height: 290,
          decoration: BoxDecoration(
            color: Colors.blueAccent,
            border: Border.all(color: Colors.grey, width: 10),
            borderRadius: BorderRadius.all(Radius.circular(300)),
          ),
        ),
      ),
    );
  }

  void showSettingsDialog() {
    Picker(
      adapter: NumberPickerAdapter(data: <NumberPickerColumn>[
        const NumberPickerColumn(
            begin: 0, end: 59, suffix: Text(' m'), initValue: 15),
        const NumberPickerColumn(
            begin: 0, end: 59, suffix: Text(' s'), jump: 5, initValue: 0),
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
      confirmText: "OK",
      title: const Text('Select duration'),
      selectedTextStyle: TextStyle(color: Colors.blue),
      onConfirm: (Picker picker, List<int> value) {
        // Set the duration of the countdown
        Duration _duration = Duration(
            minutes: picker.getSelectedValues()[0],
            seconds: picker.getSelectedValues()[1]);
        waterCountdown.resetDuration(_duration);
      },
    ).showDialog(context);
  }
}
