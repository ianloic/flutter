// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import 'basic.dart';
import 'binding.dart';
import 'framework.dart';
import 'overlay.dart';

typedef bool DragTargetWillAccept<T>(T data);
typedef void DragTargetAccept<T>(T data);
typedef Widget DragTargetBuilder<T>(BuildContext context, List<T> candidateData, List<dynamic> rejectedData);

/// Called when a [Draggable] is dropped without being accepted by a [DragTarget].
typedef void OnDraggableCanceled(Velocity velocity, Offset offset);

/// Where the [Draggable] should be anchored during a drag.
enum DragAnchor {
  /// Display the feedback anchored at the position of the original child. If
  /// feedback is identical to the child, then this means the feedback will
  /// exactly overlap the original child when the drag starts.
  child,

  /// Display the feedback anchored at the position of the touch that started
  /// the drag. If feedback is identical to the child, then this means the top
  /// left of the feedback will be under the finger when the drag starts. This
  /// will likely not exactly overlap the original child, e.g. if the child is
  /// big and the touch was not centered. This mode is useful when the feedback
  /// is transformed so as to move the feedback to the left by half its width,
  /// and up by half its width plus the height of the finger, since then it
  /// appears as if putting the finger down makes the touch feedback appear
  /// above the finger. (It feels weird for it to appear offset from the
  /// original child if it's anchored to the child and not the finger.)
  pointer,
}

/// Subclass this widget to customize the gesture used to start a drag.
abstract class DraggableBase<T> extends StatefulWidget {
  DraggableBase({
    Key key,
    this.data,
    this.child,
    this.childWhenDragging,
    this.feedback,
    this.feedbackOffset: Offset.zero,
    this.dragAnchor: DragAnchor.child,
    this.maxSimultaneousDrags,
    this.onDraggableCanceled
  }) : super(key: key) {
    assert(child != null);
    assert(feedback != null);
    assert(maxSimultaneousDrags == null || maxSimultaneousDrags > 0);
  }

  final T data;

  /// The widget below this widget in the tree.
  final Widget child;

  /// The widget to show instead of [child] when a drag is under way.
  ///
  /// If this is null, then [child] will be used instead (and so the
  /// drag source representation will change while a drag is under
  /// way).
  final Widget childWhenDragging;

  /// The widget to show under the pointer when a drag is under way.
  final Widget feedback;

  /// The feedbackOffset can be used to set the hit test target point for the
  /// purposes of finding a drag target. It is especially useful if the feedback
  /// is transformed compared to the child.
  final Offset feedbackOffset;

  /// Where this widget should be anchored during a drag.
  final DragAnchor dragAnchor;

  /// How many simultaneous drags to support. When null, no limit is applied.
  /// Set this to 1 if you want to only allow the drag source to have one item
  /// dragged at a time.
  final int maxSimultaneousDrags;

  /// Called when the draggable is dropped without being accepted by a [DragTarget].
  final OnDraggableCanceled onDraggableCanceled;

  /// Should return a new MultiDragGestureRecognizer instance
  /// constructed with the given arguments.
  MultiDragGestureRecognizer<MultiDragPointerState> createRecognizer(GestureMultiDragStartCallback onStart);

  @override
  _DraggableState<T> createState() => new _DraggableState<T>();
}

/// Makes its child draggable starting from tap down.
class Draggable<T> extends DraggableBase<T> {
  Draggable({
    Key key,
    T data,
    Widget child,
    Widget childWhenDragging,
    Widget feedback,
    Offset feedbackOffset: Offset.zero,
    DragAnchor dragAnchor: DragAnchor.child,
    int maxSimultaneousDrags,
    OnDraggableCanceled onDraggableCanceled
  }) : super(
    key: key,
    data: data,
    child: child,
    childWhenDragging: childWhenDragging,
    feedback: feedback,
    feedbackOffset: feedbackOffset,
    dragAnchor: dragAnchor,
    maxSimultaneousDrags: maxSimultaneousDrags,
    onDraggableCanceled: onDraggableCanceled
  );

  @override
  ImmediateMultiDragGestureRecognizer createRecognizer(GestureMultiDragStartCallback onStart) {
    return new ImmediateMultiDragGestureRecognizer()..onStart = onStart;
  }
}

/// Makes its child draggable. When competing with other gestures,
/// this will only start the drag horizontally.
class HorizontalDraggable<T> extends DraggableBase<T> {
  HorizontalDraggable({
    Key key,
    T data,
    Widget child,
    Widget childWhenDragging,
    Widget feedback,
    Offset feedbackOffset: Offset.zero,
    DragAnchor dragAnchor: DragAnchor.child,
    int maxSimultaneousDrags,
    OnDraggableCanceled onDraggableCanceled
  }) : super(
    key: key,
    data: data,
    child: child,
    childWhenDragging: childWhenDragging,
    feedback: feedback,
    feedbackOffset: feedbackOffset,
    dragAnchor: dragAnchor,
    maxSimultaneousDrags: maxSimultaneousDrags,
    onDraggableCanceled: onDraggableCanceled
  );

  @override
  HorizontalMultiDragGestureRecognizer createRecognizer(GestureMultiDragStartCallback onStart) {
    return new HorizontalMultiDragGestureRecognizer()..onStart = onStart;
  }
}

/// Makes its child draggable. When competing with other gestures,
/// this will only start the drag vertically.
class VerticalDraggable<T> extends DraggableBase<T> {
  VerticalDraggable({
    Key key,
    T data,
    Widget child,
    Widget childWhenDragging,
    Widget feedback,
    Offset feedbackOffset: Offset.zero,
    DragAnchor dragAnchor: DragAnchor.child,
    int maxSimultaneousDrags,
    OnDraggableCanceled onDraggableCanceled
  }) : super(
    key: key,
    data: data,
    child: child,
    childWhenDragging: childWhenDragging,
    feedback: feedback,
    feedbackOffset: feedbackOffset,
    dragAnchor: dragAnchor,
    maxSimultaneousDrags: maxSimultaneousDrags,
    onDraggableCanceled: onDraggableCanceled
  );

  @override
  VerticalMultiDragGestureRecognizer createRecognizer(GestureMultiDragStartCallback onStart) {
    return new VerticalMultiDragGestureRecognizer()..onStart = onStart;
  }
}

/// Makes its child draggable starting from long press.
class LongPressDraggable<T> extends DraggableBase<T> {
  LongPressDraggable({
    Key key,
    T data,
    Widget child,
    Widget childWhenDragging,
    Widget feedback,
    Offset feedbackOffset: Offset.zero,
    DragAnchor dragAnchor: DragAnchor.child,
    int maxSimultaneousDrags,
    OnDraggableCanceled onDraggableCanceled
  }) : super(
    key: key,
    data: data,
    child: child,
    childWhenDragging: childWhenDragging,
    feedback: feedback,
    feedbackOffset: feedbackOffset,
    dragAnchor: dragAnchor,
    maxSimultaneousDrags: maxSimultaneousDrags,
    onDraggableCanceled: onDraggableCanceled
  );

  @override
  DelayedMultiDragGestureRecognizer createRecognizer(GestureMultiDragStartCallback onStart) {
    return new DelayedMultiDragGestureRecognizer()
      ..onStart = (Point position) {
        Drag result = onStart(position);
        if (result != null)
          HapticFeedback.vibrate();
        return result;
      };
  }
}

class _DraggableState<T> extends State<DraggableBase<T>> {

  @override
  void initState() {
    super.initState();
    _recognizer = config.createRecognizer(_startDrag);
  }

  GestureRecognizer _recognizer;
  int _activeCount = 0;

  void _routePointer(PointerEvent event) {
    if (config.maxSimultaneousDrags != null && _activeCount >= config.maxSimultaneousDrags)
      return;
    _recognizer.addPointer(event);
  }

  _DragAvatar<T> _startDrag(Point position) {
    if (config.maxSimultaneousDrags != null && _activeCount >= config.maxSimultaneousDrags)
      return null;
    Point dragStartPoint;
    switch (config.dragAnchor) {
      case DragAnchor.child:
        final RenderBox renderObject = context.findRenderObject();
        dragStartPoint = renderObject.globalToLocal(position);
        break;
      case DragAnchor.pointer:
        dragStartPoint = Point.origin;
      break;
    }
    setState(() {
      _activeCount += 1;
    });
    return new _DragAvatar<T>(
      overlay: Overlay.of(context, debugRequiredFor: config),
      data: config.data,
      initialPosition: position,
      dragStartPoint: dragStartPoint,
      feedback: config.feedback,
      feedbackOffset: config.feedbackOffset,
      onDragEnd: (Velocity velocity, Offset offset, bool wasAccepted) {
        setState(() {
          _activeCount -= 1;
          if (!wasAccepted && config.onDraggableCanceled != null)
            config.onDraggableCanceled(velocity, offset);
        });
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    assert(Overlay.of(context, debugRequiredFor: config) != null);
    final bool canDrag = config.maxSimultaneousDrags == null ||
                         _activeCount < config.maxSimultaneousDrags;
    final bool showChild = _activeCount == 0 || config.childWhenDragging == null;
    return new Listener(
      onPointerDown: canDrag ? _routePointer : null,
      child: showChild ? config.child : config.childWhenDragging
    );
  }
}

/// Receives data when a [Draggable] widget is dropped.
class DragTarget<T> extends StatefulWidget {
  const DragTarget({
    Key key,
    this.builder,
    this.onWillAccept,
    this.onAccept
  }) : super(key: key);

  /// Called to build the contents of this widget.
  ///
  /// The builder can build different widgets depending on what is being dragged
  /// into this drag target.
  final DragTargetBuilder<T> builder;

  /// Called to determine whether this widget is interested in receiving a given
  /// piece of data being dragged over this drag target.
  final DragTargetWillAccept<T> onWillAccept;

  /// Called when an acceptable piece of data was dropped over this drag target.
  final DragTargetAccept<T> onAccept;

  @override
  _DragTargetState<T> createState() => new _DragTargetState<T>();
}

class _DragTargetState<T> extends State<DragTarget<T>> {
  final List<T> _candidateData = new List<T>();
  final List<dynamic> _rejectedData = new List<dynamic>();

  bool didEnter(dynamic data) {
    assert(!_candidateData.contains(data));
    assert(!_rejectedData.contains(data));
    if (data is T && (config.onWillAccept == null || config.onWillAccept(data))) {
      setState(() {
        _candidateData.add(data);
      });
      return true;
    }
    _rejectedData.add(data);
    return false;
  }

  void didLeave(dynamic data) {
    assert(_candidateData.contains(data) || _rejectedData.contains(data));
    setState(() {
      _candidateData.remove(data);
      _rejectedData.remove(data);
    });
  }

  void didDrop(dynamic data) {
    assert(_candidateData.contains(data));
    setState(() {
      _candidateData.remove(data);
    });
    if (config.onAccept != null)
      config.onAccept(data);
  }

  @override
  Widget build(BuildContext context) {
    assert(config.builder != null);
    return new MetaData(
      metaData: this,
      behavior: HitTestBehavior.translucent,
      child: config.builder(context, _candidateData, _rejectedData)
    );
  }
}


enum _DragEndKind { dropped, canceled }
typedef void _OnDragEnd(Velocity velocity, Offset offset, bool wasAccepted);

// The lifetime of this object is a little dubious right now. Specifically, it
// lives as long as the pointer is down. Arguably it should self-immolate if the
// overlay goes away, or maybe even if the Draggable that created goes away.
// This will probably need to be changed once we have more experience with using
// this widget.
class _DragAvatar<T> extends Drag {
  _DragAvatar({
    OverlayState overlay,
    this.data,
    Point initialPosition,
    this.dragStartPoint: Point.origin,
    this.feedback,
    this.feedbackOffset: Offset.zero,
    this.onDragEnd
  }) {
    assert(overlay != null);
    assert(dragStartPoint != null);
    assert(feedbackOffset != null);
    _entry = new OverlayEntry(builder: _build);
    overlay.insert(_entry);
    _position = initialPosition;
    update(initialPosition);
  }

  final T data;
  final Point dragStartPoint;
  final Widget feedback;
  final Offset feedbackOffset;
  final _OnDragEnd onDragEnd;

  _DragTargetState<T> _activeTarget;
  List<_DragTargetState<T>> _enteredTargets = <_DragTargetState<T>>[];
  Point _position;
  Offset _lastOffset;
  OverlayEntry _entry;

  // Drag API
  @override
  void move(Offset offset) {
    _position += offset;
    update(_position);
  }

  @override
  void end(Velocity velocity) {
    finish(_DragEndKind.dropped, velocity);
  }

  @override
  void cancel() {
    finish(_DragEndKind.canceled);
  }

  void update(Point globalPosition) {
    _lastOffset = globalPosition - dragStartPoint;
    _entry.markNeedsBuild();
    HitTestResult result = new HitTestResult();
    WidgetsBinding.instance.hitTest(result, globalPosition + feedbackOffset);

    List<_DragTargetState<T>> targets = _getDragTargets(result.path).toList();

    bool listsMatch = false;
    if (targets.length >= _enteredTargets.length && _enteredTargets.isNotEmpty) {
      listsMatch = true;
      Iterator<_DragTargetState<T>> iterator = targets.iterator;
      for (int i = 0; i < _enteredTargets.length; i += 1) {
        iterator.moveNext();
        if (iterator.current != _enteredTargets[i]) {
          listsMatch = false;
          break;
        }
      }
    }

    // If everything's the same, bail early.
    if (listsMatch)
      return;

    // Leave old targets.
    _leaveAllEntered();

    // Enter new targets.
    _DragTargetState<T> newTarget = targets.firstWhere((_DragTargetState<T> target) {
        _enteredTargets.add(target);
        return target.didEnter(data);
      },
      orElse: () => null
    );

    _activeTarget = newTarget;
  }

  Iterable<_DragTargetState<T>> _getDragTargets(List<HitTestEntry> path) sync* {
    // Look for the RenderBoxes that corresponds to the hit target (the hit target
    // widgets build RenderMetadata boxes for us for this purpose).
    for (HitTestEntry entry in path) {
      if (entry.target is RenderMetaData) {
        RenderMetaData renderMetaData = entry.target;
        if (renderMetaData.metaData is _DragTargetState<T>)
          yield renderMetaData.metaData;
      }
    }
  }

  void _leaveAllEntered() {
    for (int i = 0; i < _enteredTargets.length; i += 1)
      _enteredTargets[i].didLeave(data);
    _enteredTargets.clear();
  }

  void finish(_DragEndKind endKind, [Velocity velocity]) {
    bool wasAccepted = false;
    if (endKind == _DragEndKind.dropped && _activeTarget != null) {
      _activeTarget.didDrop(data);
      wasAccepted = true;
      _enteredTargets.remove(_activeTarget);
    }
    _leaveAllEntered();
    _activeTarget = null;
    _entry.remove();
    _entry = null;
    // TODO(ianh): consider passing _entry as well so the client can perform an animation.
    if (onDragEnd != null)
      onDragEnd(velocity ?? Velocity.zero, _lastOffset, wasAccepted);
  }

  Widget _build(BuildContext context) {
    return new Positioned(
      left: _lastOffset.dx,
      top: _lastOffset.dy,
      child: new IgnorePointer(
        child: feedback
      )
    );
  }
}
