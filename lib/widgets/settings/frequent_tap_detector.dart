import 'dart:async';

import 'package:flutter/material.dart';

class FrequentTapDetector extends StatefulWidget {
  final int threshold;
  final VoidCallback? onTapCountReachedCallback;
  final Widget child;

  const FrequentTapDetector({
    super.key,
    required this.child,
    this.onTapCountReachedCallback,
    this.threshold = 5,
  });

  @override
  State<FrequentTapDetector> createState() => _FrequentTapDetectorState();
}

class _FrequentTapDetectorState extends State<FrequentTapDetector> {
  int tapCount = 0;
  late Timer tapTimer;

  @override
  void initState() {
    super.initState();

    tapTimer = Timer(Duration.zero, () {});
  }

  void onResetTapCount() {
    tapCount = 0;
    print('Reset tap count');
  }

  void startResetDelay() {
    tapTimer.cancel();
    tapTimer = Timer(
      const Duration(milliseconds: 1000),
      onResetTapCount,
    );
  }

  @override
  void dispose() {
    tapTimer.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: widget.child,
      onTap: () {
        tapCount += 1;
        print('Tap Count: $tapCount');
        if (tapCount >= widget.threshold) {
          widget.onTapCountReachedCallback?.call();
          tapCount = 0;
        } else {
          startResetDelay();
        }
      },
    );
  }
}
