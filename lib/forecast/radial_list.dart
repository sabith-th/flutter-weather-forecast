import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:weather_forecast_app/generic_widgets/radial_position.dart';

class SlidingRadialList extends StatelessWidget {
  final RadialListViewModel radialList;
  final SlidingRadialListController controller;

  const SlidingRadialList({
    this.radialList,
    this.controller,
  });

  Widget _radialListItem(RadialListItemViewModel viewModel, double angle,
      double opacity, double screenHeight) {
    return Transform(
      transform: Matrix4.translationValues(
        40.0,
        screenHeight / 2,
        0.0,
      ),
      child: RadialPosition(
        angle: angle,
        radius: 140.0 + 75.0,
        child: Opacity(
          opacity: opacity,
          child: RadialListItem(
            listItem: viewModel,
          ),
        ),
      ),
    );
  }

  List<Widget> _radialListItems(double screenHeight) {
    int index = 0;
    return radialList.items.map((RadialListItemViewModel viewModel) {
      final listItem = _radialListItem(
        viewModel,
        controller.getItemAngle(index),
        controller.getItemOpacity(),
        screenHeight,
      );
      ++index;
      return listItem;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    return AnimatedBuilder(
      animation: controller,
      builder: (BuildContext buildContext, Widget child) {
        return Stack(
          children: _radialListItems(screenHeight),
        );
      },
    );
  }
}

enum RadialListState {
  closed,
  open,
  slidingOpen,
  fadingOut,
}

class SlidingRadialListController extends ChangeNotifier {
  final double firstItemAngle = -pi / 3;
  final double lastItemAngle = pi / 3;
  final double startSlidingAngle = 3 * pi / 4;

  final int itemCount;
  final AnimationController _slideController;
  final AnimationController _fadeController;
  final List<Animation<double>> _slidePositions;

  RadialListState _state = RadialListState.closed;
  Completer<Null>onOpenedCompleter;
  Completer<Null> onClosedCompleter;

  SlidingRadialListController({
    this.itemCount,
    vsync,
  })  : _slideController = new AnimationController(
          duration: const Duration(milliseconds: 1500),
          vsync: vsync,
        ),
        _fadeController = new AnimationController(
          duration: const Duration(milliseconds: 150),
          vsync: vsync,
        ),
        _slidePositions = [] {
    _slideController
      ..addListener(notifyListeners)
      ..addStatusListener((AnimationStatus status) {
        switch (status) {
          case AnimationStatus.forward:
            _state = RadialListState.slidingOpen;
            notifyListeners();
            break;
          case AnimationStatus.completed:
            _state = RadialListState.open;
            notifyListeners();
            onOpenedCompleter.complete();
            break;
          case AnimationStatus.reverse:
          case AnimationStatus.dismissed:
            break;
        }
      });

    _fadeController
      ..addListener(notifyListeners)
      ..addStatusListener((AnimationStatus status) {
        switch (status) {
          case AnimationStatus.forward:
            _state = RadialListState.fadingOut;
            notifyListeners();
            break;
          case AnimationStatus.completed:
            _state = RadialListState.closed;
            _slideController.value = 0.0;
            _fadeController.value = 0.0;
            notifyListeners();
            onClosedCompleter.complete();
            break;
          case AnimationStatus.reverse:
          case AnimationStatus.dismissed:
            break;
        }
      });

    final delayInterval = 0.1;
    final slideInterval = 0.5;
    final angleDeltaPerItem =
        (lastItemAngle - firstItemAngle) / (itemCount - 1);

    for (var i = 0; i < itemCount; i++) {
      final start = delayInterval * i;
      final end = start + slideInterval;
      final endSlidingAngle = firstItemAngle + (angleDeltaPerItem * i);
      _slidePositions.add(
        new Tween(
          begin: startSlidingAngle,
          end: endSlidingAngle,
        ).animate(
          new CurvedAnimation(
            parent: _slideController,
            curve: new Interval(
              start,
              end,
              curve: Curves.easeInOut,
            ),
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  double getItemAngle(int index) {
    return _slidePositions[index].value;
  }

  double getItemOpacity() {
    switch (_state) {
      case RadialListState.closed:
        return 0.0;
        break;
      case RadialListState.slidingOpen:
      case RadialListState.open:
        return 1.0;
        break;
      case RadialListState.fadingOut:
        return (1.0 - _fadeController.value);
      default:
        return 1.0;
    }
  }

  Future<Null> open() {
    if (_state == RadialListState.closed) {
      _slideController.forward();
      onOpenedCompleter = new Completer();
      return onOpenedCompleter.future;
    }
    return null;
  }

  Future<Null> close() {
    if (_state == RadialListState.open) {
      _fadeController.forward();
      onClosedCompleter = new Completer();
      return onClosedCompleter.future;
    }
    return null;
  }
}

class RadialListItem extends StatelessWidget {
  final RadialListItemViewModel listItem;

  RadialListItem({
    this.listItem,
  });

  @override
  Widget build(BuildContext context) {
    final circleDecoration = listItem.isSelected
        ? BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          )
        : BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.transparent,
            border: Border.all(
              color: Colors.white,
              width: 2.0,
            ),
          );

    return Transform(
      transform: Matrix4.translationValues(-30.0, -30.0, 0.0),
      child: Row(
        children: <Widget>[
          Container(
            width: 60.0,
            height: 60.0,
            decoration: circleDecoration,
            child: Padding(
              padding: const EdgeInsets.all(7.0),
              child: Image(
                image: listItem.icon,
                color: listItem.isSelected ? Color(0xFF6688CC) : Colors.white,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 5.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  listItem.title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                  ),
                ),
                Text(
                  listItem.subtitle,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RadialListItemViewModel {
  final ImageProvider icon;
  final String title;
  final String subtitle;
  final bool isSelected;

  RadialListItemViewModel({
    this.icon,
    this.title = '',
    this.subtitle = '',
    this.isSelected = false,
  });
}

class RadialListViewModel {
  final List<RadialListItemViewModel> items;

  RadialListViewModel({
    this.items = const [],
  });
}
