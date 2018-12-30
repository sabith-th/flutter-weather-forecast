import 'dart:math';

import 'package:flutter/material.dart';
import 'package:weather_forecast_app/generic_widgets/radial_position.dart';

class RadialList extends StatelessWidget {
  final RadialListViewModel radialList;

  const RadialList({
    this.radialList,
  });

  Widget _radialListItem(
      RadialListItemViewModel viewModel, double angle, double screenHeight) {
    return Transform(
      transform: Matrix4.translationValues(
        40.0,
        screenHeight / 2,
        0.0,
      ),
      child: RadialPosition(
        angle: angle,
        radius: 140.0 + 75.0,
        child: RadialListItem(
          listItem: viewModel,
        ),
      ),
    );
  }

  List<Widget> _radialListItems(double screenHeight) {
    final double firstItemAngle = -pi / 3;
    final double lastItemAngle = pi / 3;
    final double angleDiffPerItem =
        (lastItemAngle - firstItemAngle) / (radialList.items.length - 1);
    double currentAngle = firstItemAngle;

    return radialList.items.map((RadialListItemViewModel viewModel) {
      final listItem = _radialListItem(viewModel, currentAngle, screenHeight);
      currentAngle += angleDiffPerItem;
      return listItem;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    return Stack(
      children: _radialListItems(screenHeight),
    );
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
