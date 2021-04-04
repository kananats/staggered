import 'dart:math';

import 'package:flutter/material.dart';

class ListViewAnimatorController {
  final void Function() _reset;

  ListViewAnimatorController(void Function() reset) : _reset = reset;

  void reset() => _reset();
}

class ListViewAnimator extends StatefulWidget {
  final ListViewAnimatorController controller;

  final Widget child;

  final Widget Function(BuildContext context, Widget child, Animation animation)
      builder;

  final Duration Function(int index) duration;
  final Duration Function(int index) delay;

  final Curve curve;

  ListViewAnimator({
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
  _ListViewAnimatorState createState() => _ListViewAnimatorState();
}

class _ListViewAnimatorState extends State<ListViewAnimator>
    with TickerProviderStateMixin {
  AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    _animationController =
        AnimationController(vsync: this, duration: _totalDuration);

    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.child is ListView) {
      return ListView.builder(
        itemCount: _listViewDelegate.childCount,
        itemBuilder: (context, index) {
          return widget.builder(
            context,
            _listViewDelegate.builder(context, index),
            _curvedAnimation(index),
          );
        },
      );
    }

    return widget.child;
  }

  ListView get _listView {
    return widget.child as ListView;
  }

  SliverChildBuilderDelegate get _listViewDelegate {
    return _listView.childrenDelegate as SliverChildBuilderDelegate;
  }

  Duration get _totalDuration {
    return widget.duration(_listViewDelegate.childCount - 1) +
        widget.delay(_listViewDelegate.childCount - 1);
  }

  CurvedAnimation _curvedAnimation(int index) {
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
}
