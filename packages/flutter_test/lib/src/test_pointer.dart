// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/gestures.dart';

export 'dart:ui' show Point;

/// A class for generating coherent artificial pointer events.
///
/// You can use this to manually simulate individual events, but the
/// simplest way to generate coherent gestures is to use [TestGesture].
class TestPointer {
  /// Creates a [TestPointer]. By default, the pointer identifier used is 1, however
  /// this can be overridden by providing an argument to the constructor.
  TestPointer([ this.pointer = 1 ]);

  /// The pointer identifier used for events generated by this object.
  ///
  /// Set when the object is constructed. Defaults to 1.
  final int pointer;

  /// Whether the pointer simulated by this object is currently down.
  ///
  /// A pointer is released (goes up) by calling [up] or [cancel].
  ///
  /// Once a pointer is released, it can no longer generate events.
  bool get isDown => _isDown;
  bool _isDown = false;

  /// The position of the last event sent by this object.
  ///
  /// If no event has ever been sent by this object, returns null.
  Point get location => _location;
  Point _location;

  /// Create a [PointerDownEvent] at the given location.
  ///
  /// By default, the time stamp on the event is [Duration.ZERO]. You
  /// can give a specific time stamp by passing the `timeStamp`
  /// argument.
  PointerDownEvent down(Point newLocation, { Duration timeStamp: Duration.ZERO }) {
    assert(!isDown);
    _isDown = true;
    _location = newLocation;
    return new PointerDownEvent(
      timeStamp: timeStamp,
      pointer: pointer,
      position: location
    );
  }

  /// Create a [PointerMoveEvent] to the given location.
  ///
  /// By default, the time stamp on the event is [Duration.ZERO]. You
  /// can give a specific time stamp by passing the `timeStamp`
  /// argument.
  PointerMoveEvent move(Point newLocation, { Duration timeStamp: Duration.ZERO }) {
    assert(isDown);
    Offset delta = newLocation - location;
    _location = newLocation;
    return new PointerMoveEvent(
      timeStamp: timeStamp,
      pointer: pointer,
      position: newLocation,
      delta: delta
    );
  }

  /// Create a [PointerUpEvent].
  ///
  /// By default, the time stamp on the event is [Duration.ZERO]. You
  /// can give a specific time stamp by passing the `timeStamp`
  /// argument.
  ///
  /// The object is no longer usable after this method has been called.
  PointerUpEvent up({ Duration timeStamp: Duration.ZERO }) {
    assert(isDown);
    _isDown = false;
    return new PointerUpEvent(
      timeStamp: timeStamp,
      pointer: pointer,
      position: location
    );
  }

  /// Create a [PointerCancelEvent].
  ///
  /// By default, the time stamp on the event is [Duration.ZERO]. You
  /// can give a specific time stamp by passing the `timeStamp`
  /// argument.
  ///
  /// The object is no longer usable after this method has been called.
  PointerCancelEvent cancel({ Duration timeStamp: Duration.ZERO }) {
    assert(isDown);
    _isDown = false;
    return new PointerCancelEvent(
      timeStamp: timeStamp,
      pointer: pointer,
      position: location
    );
  }
}

/// A class for performing gestures in tests.
///
/// The simplest way to create a [TestGesture] is to call
/// [WidgetTester.startGesture].
class TestGesture {
  /// Create a [TestGesture] by starting with a pointerDown at the
  /// given point.
  ///
  /// By default, the pointer ID used is 1. This can be overridden by
  /// providing the `pointer` argument.
  ///
  /// By default, the global binding is used both for hit testing and
  /// for dispatching of events. The object to use for hit testing can
  /// be overridden by providing `hitTestTarget`, and the object to
  /// use for dispatching events can be overridden by providing an
  /// `dispatcher`.
  factory TestGesture(Point downLocation, {
    int pointer: 1,
    HitTestable target,
    HitTestDispatcher dispatcher
  }) {
    // hit test
    final HitTestResult result = new HitTestResult();
    target ??= GestureBinding.instance;
    assert(target != null);
    target.hitTest(result, downLocation);

    // dispatch down event
    final TestPointer testPointer = new TestPointer(pointer);
    dispatcher ??= GestureBinding.instance;
    assert(dispatcher != null);
    dispatcher.dispatchEvent(testPointer.down(downLocation), result);

    // create a TestGesture
    return new TestGesture._(dispatcher, result, testPointer);
  }

  const TestGesture._(this._dispatcher, this._result, this._pointer);

  final HitTestDispatcher _dispatcher;
  final HitTestResult _result;
  final TestPointer _pointer;

  /// Send a move event moving the pointer by the given offset.
  void moveBy(Offset offset) {
    assert(_pointer._isDown);
    moveTo(_pointer.location + offset);
  }

  /// Send a move event moving the pointer to the given location.
  void moveTo(Point location) {
    assert(_pointer._isDown);
    _dispatcher.dispatchEvent(_pointer.move(location), _result);
  }

  /// End the gesture by releasing the pointer.
  ///
  /// The object is no longer usable after this method has been called.
  void up() {
    assert(_pointer._isDown);
    _dispatcher.dispatchEvent(_pointer.up(), _result);
    assert(!_pointer._isDown);
  }

  /// End the gesture by canceling the pointer (as would happen if the
  /// system showed a modal dialog on top of the Flutter application,
  /// for instance).
  ///
  /// The object is no longer usable after this method has been called.
  void cancel() {
    assert(_pointer._isDown);
    _dispatcher.dispatchEvent(_pointer.cancel(), _result);
    assert(!_pointer._isDown);
  }
}
