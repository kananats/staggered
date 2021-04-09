import 'dart:math';

import 'package:flutter/material.dart';

class ListViewAnimatorController {
  late void Function() _replay;

  void replay() {
    _replay();
  }
}

class ListViewAnimator extends StatefulWidget {
  final ListViewAnimatorController? controller;

  final ListView child;

  final Widget Function(
      BuildContext context, Widget? child, Animation<double> animation) builder;

  final Duration Function(int index) duration;
  final Duration Function(int index) delay;

  final Curve curve;

  ListViewAnimator({
    Key? key,
    this.controller,
    required this.child,
    Widget Function(
            BuildContext context, Widget? child, Animation<double> animation)?
        builder,
    Duration Function(int index)? duration,
    Duration Function(int index)? delay,
    this.curve = Curves.fastOutSlowIn,
  })  : builder = builder ??
            ((context, child, animation) {
              return FadeTransition(
                opacity: Tween<double>(
                  begin: 0,
                  end: 1,
                ).animate(animation),
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: Offset(0.55, 0),
                    end: Offset(0, 0),
                  ).animate(animation),
                  child: child,
                ),
              );
            }),
        duration = duration ?? ((_) => Duration(milliseconds: 425)),
        delay =
            delay ?? ((index) => Duration(milliseconds: 125) * pow(index, 0.8)),
        super(key: key);

  @override
  _ListViewAnimatorState createState() =>
      _ListViewAnimatorState(controller: controller);
}

class _ListViewAnimatorState extends State<ListViewAnimator>
    with TickerProviderStateMixin {
  late AnimationController _animationController;

  _ListViewAnimatorState({
    ListViewAnimatorController? controller,
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

    return ListView.custom(
      key: child.key,
      scrollDirection: child.scrollDirection,
      reverse: child.reverse,
      controller: child.controller,
      primary: child.primary,
      physics: child.physics,
      shrinkWrap: child.shrinkWrap,
      padding: child.padding,
      itemExtent: child.itemExtent,
      childrenDelegate: _makeChildDelegate(child.childrenDelegate),
      cacheExtent: child.cacheExtent,
      semanticChildCount: child.semanticChildCount,
      dragStartBehavior: child.dragStartBehavior,
      keyboardDismissBehavior: child.keyboardDismissBehavior,
      restorationId: child.restorationId,
      clipBehavior: child.clipBehavior,
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

    if (childCount <= 0) return Duration.zero;

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
