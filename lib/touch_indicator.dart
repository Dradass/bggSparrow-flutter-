library touch_indicator;


import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Adds touch indicators to the screen whenever a touch occurs
///
/// This can be useful when recording videos of an app where you want to show
/// where the user has tapped. Can also be useful when running integration
/// tests or when giving demos with a screencast.
class TouchIndicator extends StatefulWidget {
  /// The child on which to show indicators
  final Widget child;

  /// The size of the indicator
  final double indicatorSize;

  /// The color of the indicator
  final Color indicatorColor;

  /// Overrides the default indicator.
  ///
  /// Make sure to set the proper [indicatorSize] to align the widget properly
  final Widget? indicator;

  /// If set to true, shows indicators in release mode as well
  final bool forceInReleaseMode;

  /// If set to false, disables the indicators from showing
  final bool enabled;

  /// Creates a touch indicator canvas
  ///
  /// Touch indicators are shown on the child whenever a touch occurs
  const TouchIndicator({
    Key? key,
    required this.child,
    this.indicator,
    this.indicatorSize = 60.0,
    this.indicatorColor = Colors.blueGrey,
    this.forceInReleaseMode = false,
    this.enabled = true,
  }) : super(key: key);

  @override
  _TouchIndicatorState createState() => _TouchIndicatorState();
}

class _TouchIndicatorState extends State<TouchIndicator> {
  Map<int, Offset> touchPositions = <int, Offset>{};
  List<Widget> children = [];
  int? randomPlayer;

  Iterable<Widget> buildTouchIndicators() sync* {
    if (touchPositions.isNotEmpty) {
      for (var touchPosition in touchPositions.values) {
        yield Positioned.directional(
          start: touchPosition.dx - widget.indicatorSize / 2,
          top: touchPosition.dy - widget.indicatorSize / 2,
          textDirection: TextDirection.ltr,
          child: widget.indicator != null
              ? widget.indicator!
              : Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.indicatorColor.withOpacity(0.3),
                  ),
                  child: Icon(
                    Icons.fingerprint,
                    size: widget.indicatorSize,
                    color: widget.indicatorColor.withOpacity(0.9),
                  ),
                ),
        );
      }
    }
  }

  void savePointerPosition(int index, Offset position) {
    setState(() {
      touchPositions[index] = position;
    });
  }

  void clearPointerPosition(int index) {
    setState(() {
      touchPositions.remove(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    if ((kReleaseMode && !widget.forceInReleaseMode) || !widget.enabled) {
      return widget.child;
    }

    children = [
      widget.child,
      ...buildTouchIndicators(),
    ];

    return Listener(
      onPointerDown: (opm) {
        savePointerPosition(opm.pointer, opm.position);
        checkTouchPositions(touchPositions.length);
      },
      // onPointerMove: (opm) {
      //   print('savePointerPosition');
      //   savePointerPosition(opm.pointer, opm.position);
      //   print(touchPositions);
      // },
      onPointerCancel: (opc) {
        clearPointerPosition(opc.pointer);
        print('onPointerCancel');
      },
      onPointerUp: (opc) {
        print('onPointerUp');
        clearPointerPosition(opc.pointer);
      },
      child: Stack(children: children),
    );
  }

  void checkTouchPositions(int firstPositionsCount) async {
    await Future.delayed(const Duration(seconds: 3));
    if (touchPositions.length == firstPositionsCount) {
      if (touchPositions.length > 1) {
        randomPlayer = ((touchPositions.keys).toList()..shuffle()).first;
        for (var position in (touchPositions.keys).toList()..shuffle()) {
          if (position != randomPlayer) {
            touchPositions[position] = const Offset(-100, -100);
            savePointerPosition(position, touchPositions[position]!);
          }
        }
      }
    }
  }
}