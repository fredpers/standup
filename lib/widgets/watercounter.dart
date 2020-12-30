import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math' as math;

class WaterCountdown extends StatefulWidget {
  WaterCountdown({Key key, this.duration, this.onComplete}) : super(key: key);

  final Duration duration;
  final Function onComplete;
  _WaterCountdownState state;

  void startCountdown() {
    state.startCountdown();
  }

  @override
  _WaterCountdownState createState() {
    state = _WaterCountdownState(duration, onComplete);
    return state;
  }
}

class _WaterCountdownState extends State<WaterCountdown>
    with SingleTickerProviderStateMixin {
  AutomatedAnimator automatedAnimator;

  _WaterCountdownState(Duration duration, Function onComplete) {
    automatedAnimator = AutomatedAnimator(
      animateToggle: false,
      doRepeatAnimation: false,
      duration: duration,
      onComplete: onComplete,
      buildWidget: (double animationPosition) {
        return WaveLoadingBubble(
          foregroundWaveColor: Color(0xFF6AA0E1),
          backgroundWaveColor: Color(0xFF4D90DF),
          loadingWheelColor: Color(0xFF77AAEE),
          period: animationPosition,
          backgroundWaveVerticalOffset: -140 + animationPosition * 280,
          foregroundWaveVerticalOffset: -140 +
              reversingSplitParameters(
                position: animationPosition,
                numberBreaks: 6,
                parameterBase: 8.0,
                parameterVariation: 8.0,
                reversalPoint: 0.75,
              ) +
              animationPosition * 280,
          waveHeight: 6,
          duration: widget.duration,
        );
      },
    );
  }

  void startCountdown() {
    automatedAnimator.startAnimation();
  }

  @override
  Widget build(BuildContext context) {
    return automatedAnimator;
  }
}

class AutomatedAnimator extends StatefulWidget {
  AutomatedAnimator({
    @required this.buildWidget,
    @required this.animateToggle,
    this.duration = const Duration(milliseconds: 900),
    this.doRepeatAnimation = false,
    this.onComplete,
    Key key,
  }) : super(key: key);

  final Widget Function(double animationValue) buildWidget;
  final Duration duration;
  bool animateToggle;
  final bool doRepeatAnimation;
  final Function onComplete;

  _AutomatedAnimatorState animatorState;

  void startAnimation(){
    animatorState.startAnimation();
  }

  @override
  _AutomatedAnimatorState createState() {
    animatorState = _AutomatedAnimatorState();
    return animatorState;
  }
}

class _AutomatedAnimatorState extends State<AutomatedAnimator>
    with SingleTickerProviderStateMixin {
  _AutomatedAnimatorState();

  AnimationController controller;

  void startAnimation() {
    controller.forward();
  }

  @override
  void initState() {
    super.initState();
    controller = AnimationController(vsync: this, duration: widget.duration)
      ..addListener(() => setState(() {}))
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          controller.reverseDuration = Duration(seconds: 1);
          controller.reverse().then((value) => widget.onComplete());
          widget.animateToggle = false;
        }
      });
    if (widget.animateToggle == true) controller.forward();
    if (widget.doRepeatAnimation == true) controller.repeat();
  }

  @override
  void didUpdateWidget(AutomatedAnimator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animateToggle == true) {
      controller.forward();
      return;
    }
    controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.animateToggle == true) {
      controller.forward();
    }
    return widget.buildWidget(controller.value);
  }
}

//*======================================================================
//* Additional functions to allow custom periodicity of animations
//*======================================================================

//*======================================================================
//* varies (parameterVariation) a parameter (parameterBase) based on an
//* animation position (position), broken into a number of parts
//* (numberBreaks).
//* the animation reverses at the halfway point (0.5)
//*
//* returns a value of 0.0 - 1.0
//*======================================================================

double reversingSplitParameters({
  @required double position,
  @required double numberBreaks,
  @required double parameterBase,
  @required double parameterVariation,
  @required double reversalPoint,
}) {
  assert(reversalPoint <= 1.0 && reversalPoint >= 0.0,
  "reversalPoint must be a number between 0.0 and 1.0");
  final double finalAnimationPosition =
  breakAnimationPosition(position, numberBreaks);

  if (finalAnimationPosition <= 0.5) {
    return parameterBase - (finalAnimationPosition * 2 * parameterVariation);
  } else {
    return parameterBase -
        ((1 - finalAnimationPosition) * 2 * parameterVariation);
  }
}

//*======================================================================
//* Breaks down a long animation controller value into a number of
//* smaller animations,
//* used for creating a single looping animation with multiple
//* sub animations with different periodicites that are able to
//* maintain a consistent unbroken loop
//*
//* Returns a value of 0.0 - 1.0 based on a given animationPosition
//* split into a discrete number of breaks (numberBreaks)
//*======================================================================

double breakAnimationPosition(double position, double numberBreaks) {
  double finalAnimationPosition = 0;
  final double breakPoint = 1.0 / numberBreaks;

  for (var i = 0; i < numberBreaks; i++) {
    if (position <= breakPoint * (i + 1)) {
      finalAnimationPosition = (position - i * breakPoint) * numberBreaks;
      break;
    }
  }

  return finalAnimationPosition;
}

class WaveLoadingBubble extends StatelessWidget {
  const WaveLoadingBubble({
    this.bubbleDiameter = 300.0,
    this.loadingCircleWidth = 10.0,
    this.waveInsetWidth = 5.0,
    this.waveHeight = 5.0,
    this.foregroundWaveColor = Colors.lightBlue,
    this.backgroundWaveColor = Colors.blue,
    this.loadingWheelColor = Colors.white,
    this.foregroundWaveVerticalOffset = 5.0,
    this.backgroundWaveVerticalOffset = 0.0,
    this.period = 0.0,
    this.duration,
    Key key,
  }) : super(key: key);

  final double bubbleDiameter;
  final double loadingCircleWidth;
  final double waveInsetWidth;
  final double waveHeight;
  final Color foregroundWaveColor;
  final Color backgroundWaveColor;
  final Color loadingWheelColor;
  final double foregroundWaveVerticalOffset;
  final double backgroundWaveVerticalOffset;
  final double period;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: WaveLoadingBubblePainter(
          bubbleDiameter: bubbleDiameter,
          loadingCircleWidth: loadingCircleWidth,
          waveInsetWidth: waveInsetWidth,
          waveHeight: waveHeight,
          foregroundWaveColor: foregroundWaveColor,
          backgroundWaveColor: backgroundWaveColor,
          loadingWheelColor: loadingWheelColor,
          foregroundWaveVerticalOffset: foregroundWaveVerticalOffset,
          backgroundWaveVerticalOffset: backgroundWaveVerticalOffset,
          period: period,
          duration: duration),
    );
  }
}

class WaveLoadingBubblePainter extends CustomPainter {
  WaveLoadingBubblePainter({this.bubbleDiameter,
    this.loadingCircleWidth,
    this.waveInsetWidth,
    this.waveHeight,
    this.foregroundWaveColor,
    this.backgroundWaveColor,
    this.loadingWheelColor,
    this.foregroundWaveVerticalOffset,
    this.backgroundWaveVerticalOffset,
    this.period,
    this.duration})
      : foregroundWavePaint = Paint()
    ..color = foregroundWaveColor,
        backgroundWavePaint = Paint()
          ..color = backgroundWaveColor,
        loadingCirclePaint = Paint()
          ..shader = SweepGradient(
            colors: [
              Colors.transparent,
              loadingWheelColor,
              Colors.transparent,
            ],
            stops: [0.0, 0.9, 1.0],
            startAngle: 0,
            endAngle: math.pi * 1,
            transform: GradientRotation(period * math.pi * 2 * 5),
          ).createShader(Rect.fromCircle(
            center: Offset(0.0, 0.0),
            radius: bubbleDiameter / 2,
          ));

  final double bubbleDiameter;
  final double loadingCircleWidth;
  final double waveInsetWidth;
  final double waveHeight;
  final Paint foregroundWavePaint;
  final Paint backgroundWavePaint;
  final Paint loadingCirclePaint;
  final Color foregroundWaveColor;
  final Color backgroundWaveColor;
  final Color loadingWheelColor;
  final double foregroundWaveVerticalOffset;
  final double backgroundWaveVerticalOffset;
  final double period;
  final Duration duration;

  @override
  void paint(Canvas canvas, Size size) {
    final double loadingBubbleRadius = (bubbleDiameter / 2);
    final double insetBubbleRadius = loadingBubbleRadius - waveInsetWidth;
    final double waveBubbleRadius = insetBubbleRadius - loadingCircleWidth;
    final double outerWaveBubbleRadius = waveBubbleRadius + 10;
    Path backgroundWavePath = WavePathHorizontal(
      amplitude: waveHeight,
      period: 1.0,
      startPoint:
      Offset(0.0 - waveBubbleRadius, 0.0 + backgroundWaveVerticalOffset),
      width: bubbleDiameter,
      crossAxisEndPoint: waveBubbleRadius,
      doClosePath: true,
      phaseShift: period * 2 * duration.inSeconds / 3,
    ).build();

    Path foregroundWavePath = WavePathHorizontal(
      amplitude: waveHeight,
      period: 1.0,
      startPoint:
      Offset(0.0 - waveBubbleRadius, 0.0 + foregroundWaveVerticalOffset),
      width: bubbleDiameter,
      crossAxisEndPoint: waveBubbleRadius,
      doClosePath: true,
      phaseShift: -period * 2 * duration.inSeconds / 3,
    ).build();

    Path circleClip = Path()
      ..addRRect(RRect.fromLTRBXY(
          -waveBubbleRadius,
          -waveBubbleRadius,
          waveBubbleRadius,
          waveBubbleRadius,
          waveBubbleRadius,
          waveBubbleRadius));
    Path outerCircleClip = Path()
      ..addRRect(RRect.fromLTRBXY(
          -outerWaveBubbleRadius,
          -outerWaveBubbleRadius,
          outerWaveBubbleRadius,
          outerWaveBubbleRadius,
          outerWaveBubbleRadius,
          outerWaveBubbleRadius));

    // Path insetCirclePath = Path()..addRRect(RRect.fromLTRBXY(-insetBubbleRadius, -insetBubbleRadius, insetBubbleRadius, insetBubbleRadius, insetBubbleRadius, insetBubbleRadius));
    Path loadingCirclePath = Path()
      ..addRRect(RRect.fromLTRBXY(
          -loadingBubbleRadius,
          -loadingBubbleRadius,
          loadingBubbleRadius,
          loadingBubbleRadius,
          loadingBubbleRadius,
          loadingBubbleRadius));
    Paint outerCirclePaint = Paint()
      ..color = Colors.black12;
    Paint innerContainer = Paint()
      ..color = Colors.white;
    canvas.drawPath(outerCircleClip, outerCirclePaint);
    canvas.drawPath(circleClip, innerContainer);
    canvas.clipPath(circleClip, doAntiAlias: true);
    canvas.drawPath(backgroundWavePath, backgroundWavePaint);
    canvas.drawPath(foregroundWavePath, foregroundWavePaint);
    drawClockTime(canvas, backgroundWavePath);
  }

  void drawClockTime(Canvas canvas, Path backgroundPath) {
    double secondsPassed = period * duration.inSeconds;
    Duration timeLeft = duration - Duration(seconds: secondsPassed.round());
    TextSpan span = new TextSpan(
        text: _printDuration(timeLeft), style: TextStyle(fontSize: 40));
    TextSpan blackSpan = new TextSpan(
        text: _printDuration(timeLeft),
        style: TextStyle(fontSize: 40, color: Colors.black));
    TextPainter tp = new TextPainter(
        text: span,
        textAlign: TextAlign.left,
        textDirection: TextDirection.ltr);
    tp.layout();
    TextPainter tp2 = new TextPainter(
        text: blackSpan,
        textAlign: TextAlign.left,
        textDirection: TextDirection.ltr);
    tp2.layout();
    canvas.save();
    tp2.paint(canvas, Offset(-55, -25));
    canvas.clipPath(backgroundPath, doAntiAlias: true);
    tp.paint(canvas, Offset(-55, -25));
    canvas.restore();
  }

  @override
  bool shouldRepaint(WaveLoadingBubblePainter oldDelegate) => true;

  @override
  bool shouldRebuildSemantics(WaveLoadingBubblePainter oldDelegate) => false;

  String _printDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }
}

class WavePathHorizontal {
  WavePathHorizontal({
    @required this.width,
    @required this.amplitude,
    @required this.period,
    @required this.startPoint,
    this.phaseShift = 0.0,
    this.doClosePath = false,
    this.crossAxisEndPoint = 10,
  }) : assert(crossAxisEndPoint != null || doClosePath == false,
  "if doClosePath is true you must provide an end point (crossAxisEndPoint)");

  final double width;
  final double amplitude;
  final double period;
  final Offset startPoint;
  final double crossAxisEndPoint; //*
  final double
  phaseShift; //* shift the starting value of the wave, in radians, repeats every 2 radians
  final bool doClosePath;

  Path build() {
    double startPointX = startPoint.dx;
    double startPointY = startPoint.dy;
    Path returnPath = new Path();
    returnPath.moveTo(startPointX, startPointY);

    for (double i = 0; i <= width; i++) {
      returnPath.lineTo(
        i + startPointX,
        startPointY +
            amplitude *
                math.sin(
                    (i * 2 * period * math.pi / width) + phaseShift * math.pi),
      );
    }
    if (doClosePath == true) {
      returnPath.lineTo(startPointX + width, crossAxisEndPoint);
      returnPath.lineTo(startPointX, crossAxisEndPoint);
      returnPath.close();
    }
    return returnPath;
  }
}
