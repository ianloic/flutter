// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:test/test.dart';

void main() {

  testWidgets('Can animate position data', (WidgetTester tester) {

    final RelativeRectTween rect = new RelativeRectTween(
      begin: new RelativeRect.fromRect(
        new Rect.fromLTRB(10.0, 20.0, 20.0, 30.0),
        new Rect.fromLTRB(0.0, 10.0, 100.0, 110.0)
      ),
      end: new RelativeRect.fromRect(
        new Rect.fromLTRB(80.0, 90.0, 90.0, 100.0),
        new Rect.fromLTRB(0.0, 10.0, 100.0, 110.0)
      )
    );
    final AnimationController controller = new AnimationController(
      duration: const Duration(seconds: 10)
    );
    final List<Size> sizes = <Size>[];
    final List<Offset> positions = <Offset>[];
    final GlobalKey key = new GlobalKey();

    void recordMetrics() {
      RenderBox box = key.currentContext.findRenderObject();
      BoxParentData boxParentData = box.parentData;
      sizes.add(box.size);
      positions.add(boxParentData.offset);
    }

    tester.pumpWidget(
      new Center(
        child: new Container(
          height: 100.0,
          width: 100.0,
          child: new Stack(
            children: <Widget>[
              new PositionedTransition(
                rect: rect.animate(controller),
                child: new Container(
                  key: key
                )
              )
            ]
          )
        )
      )
    ); // t=0
    recordMetrics();
    controller.forward();
    tester.pump(); // t=0 again
    recordMetrics();
    tester.pump(const Duration(seconds: 1)); // t=1
    recordMetrics();
    tester.pump(const Duration(seconds: 1)); // t=2
    recordMetrics();
    tester.pump(const Duration(seconds: 3)); // t=5
    recordMetrics();
    tester.pump(const Duration(seconds: 5)); // t=10
    recordMetrics();

    expect(sizes, equals([const Size(10.0, 10.0), const Size(10.0, 10.0), const Size(10.0, 10.0), const Size(10.0, 10.0), const Size(10.0, 10.0), const Size(10.0, 10.0)]));
    expect(positions, equals([const Offset(10.0, 10.0), const Offset(10.0, 10.0), const Offset(17.0, 17.0), const Offset(24.0, 24.0), const Offset(45.0, 45.0), const Offset(80.0, 80.0)]));

    controller.stop();
  });

}
