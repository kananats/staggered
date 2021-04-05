import 'dart:math';

import 'package:flutter/material.dart';

class GridViewAnimatorController {
  void Function() _replay;

  void replay() {
    assert(_replay != null,
        "Please ensure this is attached to `GridViewAnimator`");
    _replay();
  }
}

class GridViewAnimator extends StatefulWidget {
  final GridViewAnimatorController controller;

  final GridView child;

  final Widget Function(BuildContext context, Widget child, Animation animation)
      builder;

  final Duration Function(int index) duration;
  final Duration Function(int index) delay;

  final Curve curve;

  GridViewAnimator({
    Key key,
    this.controller,
    @required this.child,
    Widget Function(BuildContext context, Widget child, Animation animation)
        builder,
    Duration Function(int index) duration,
    Duration Function(int index) delay,
    this.curve = Curves.fastOutSlowIn,
  })  : builder = builder ??
            ((context, child, animation) {
              return FadeTransition(
                opacity: Tween<double>(
                  begin: 0,
                  end: 1,
                ).animate(animation),
                child: ScaleTransition(
                  scale: Tween<double>(
                    begin: 0,
                    end: 1,
                  ).animate(animation),
                  child: child,
                ),
              );
            }),
        duration = duration ?? ((_) => Duration(milliseconds: 325)),
        delay = delay ??
            ((index) => Duration(milliseconds: 125) * pow(index, 0.75)),
        super(key: key);

  @override
  _GridViewAnimatorState createState() =>
      _GridViewAnimatorState(controller: controller);
}

class _GridViewAnimatorState extends State<GridViewAnimator>
    with TickerProviderStateMixin {
  AnimationController _animationController;

  _GridViewAnimatorState({
    GridViewAnimatorController controller,
  }) {
    controller?._replay = _replay;
  }

  @override
  void initState() {
    super.initState();

    _animationController =
        AnimationController(vsync: this, duration: _totalDuration);

    _replay();
  }

  @override
  Widget build(BuildContext context) {
    final child = widget.child;

    return GridView.custom(
      gridDelegate: child.gridDelegate,
      childrenDelegate: _makeChildDelegate(child.childrenDelegate),
    );
  }

  SliverChildDelegate _makeChildDelegate(SliverChildDelegate delegate) {
    if (delegate is SliverChildListDelegate) {
      var index = 0;
      return SliverChildListDelegate(
        delegate.children.map((child) {
          if (index >= (delegate.estimatedChildCount ?? 20)) return child;
          return widget.builder(
            context,
            child,
            _curvedAnimation(index++, _totalDuration),
          );
        }).toList(),
      );
    } else if (delegate is SliverChildBuilderDelegate) {
      return SliverChildBuilderDelegate(
        (context, index) {
          if (index >= (delegate.estimatedChildCount ?? 20))
            return delegate.builder(context, index);
          return widget.builder(
            context,
            delegate.builder(context, index),
            _curvedAnimation(index, _totalDuration),
          );
        },
        childCount: delegate.childCount,
      );
    }
    return delegate;
  }

  Duration get _totalDuration {
    final listViewDelegate = widget.child.childrenDelegate;
    final childCount = listViewDelegate.estimatedChildCount ?? 20;
    return widget.duration(childCount - 1) + widget.delay(childCount - 1);
  }

  CurvedAnimation _curvedAnimation(int index, Duration totalDuration) {
    return CurvedAnimation(
      curve: Interval(
        widget.delay(index).inMicroseconds / _totalDuration.inMicroseconds,
        (widget.duration(index) + widget.delay(index)).inMicroseconds /
            _totalDuration.inMicroseconds,
        curve: widget.curve,
      ),
      parent: _animationController,
    );
  }

  void _replay() {
    _animationController.reset();
    _animationController.forward();
  }
}
