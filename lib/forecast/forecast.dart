import 'package:flutter/material.dart';
import 'package:weather_forecast_app/forecast/background/background_with_rings.dart';
import 'package:weather_forecast_app/forecast/background/rain.dart';
import 'package:weather_forecast_app/forecast/radial_list.dart';

class Forecast extends StatelessWidget {
  final RadialListViewModel radialList;
  final SlidingRadialListController slidingListController;

  Forecast({
    @required this.radialList,
    @required this.slidingListController,
  });

  Widget _temperatureText() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(
          top: 150.0,
          left: 10.0,
        ),
        child: Text(
          '68˚',
          style: TextStyle(
            color: Colors.white,
            fontSize: 80.0,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        BackgroundWithRings(),
        _temperatureText(),
        SlidingRadialList(
          radialList: radialList,
          controller: slidingListController,
        ),
        Rain(),
      ],
    );
  }
}
