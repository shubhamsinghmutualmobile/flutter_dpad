import 'package:flutter/material.dart';

const containerSize = 70.0;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  double speed = 0;
  double angle = 0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Current speed is: ${speed.toStringAsPrecision(4)} m/s",
              style: Theme.of(context).textTheme.headline5,
            ),
            Text(
              "Current angle is: ${angle.toStringAsPrecision(4)} deg",
              style: Theme.of(context).textTheme.headline5,
            ),
            AspectRatio(
              aspectRatio: 1,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: Stack(children: [
                    Container(
                      decoration: const BoxDecoration(
                        color: Colors.black26,
                      ),
                      child: GestureDetectedItem(
                        updatePanValue: (panValue) {
                          setState(() {
                            speed += panValue;
                          });
                        },
                        updateAngleValue: (angleValue) {
                          angle += angleValue;
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: RotatedBox(
                          quarterTurns: 3,
                          child: Text(
                            "<--- Speed --->",
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Text(
                          "<--- Angle --->",
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                    ),
                  ]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GestureDetectedItem extends StatefulWidget {
  final Function(double panValue) updatePanValue;
  final Function(double panValue) updateAngleValue;

  const GestureDetectedItem(
      {Key? key, required this.updatePanValue, required this.updateAngleValue})
      : super(key: key);

  @override
  State<GestureDetectedItem> createState() => _GestureDetectedItemState();
}

class _GestureDetectedItemState extends State<GestureDetectedItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<Offset> _animation;
  Offset elementOffset = Offset.zero;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    )..addListener(() {
        setState(() {
          if (_animController.isCompleted) {
            elementOffset = Offset.zero;
            _animController.reverse();
          }
        });
      });
    _animation = Tween<Offset>(begin: elementOffset, end: Offset.zero)
        .animate(_animController);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _animation = Tween<Offset>(begin: elementOffset, end: Offset.zero)
        .animate(_animController);
    return Center(
      child: Transform.translate(
        offset: _animation.value,
        child: GestureDetector(
          child: Container(
            width: containerSize,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              shape: BoxShape.circle,
            ),
          ),
          onPanUpdate: (DragUpdateDetails dragUpdateDetails) {
            setState(() {
              elementOffset += dragUpdateDetails.delta;
              widget.updatePanValue(dragUpdateDetails.delta.dy);
              widget.updateAngleValue(dragUpdateDetails.delta.dx);
            });
          },
          onPanEnd: (_) {
            setState(() {
              _animController.forward();
            });
          },
        ),
      ),
    );
  }
}
