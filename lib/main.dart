import 'package:flutter/material.dart';
import 'package:weather_forecast_app/forecast/app_bar.dart';
import 'package:weather_forecast_app/forecast/forecast.dart';
import 'package:weather_forecast_app/forecast/forecast_list.dart';
import 'package:weather_forecast_app/forecast/week_drawer.dart';
import 'package:weather_forecast_app/generic_widgets/sliding_drawer.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  OpenableController openableController;
  String selectedDay = 'Tuesday, January 1';

  @override
  void initState() {
    super.initState();
    openableController = new OpenableController(
      vsync: this,
      openDuration: const Duration(milliseconds: 250),
    )..addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Forecast(
            radialList: forecastRadialList,
          ),
          Positioned(
            top: 0.0,
            left: 0.0,
            right: 0.0,
            child: ForecastAppBar(
              onDrawerArrowTap: openableController.open,
              selectedDay: selectedDay,
            ),
          ),
          SlidingDrawer(
            drawer: WeekDrawer(
              onDaySelected: (String title) {
                setState(() {
                  selectedDay = title.replaceAll('\n', ', ');
                });
                openableController.close();
              },
            ),
            openableController: openableController,
          ),
        ],
      ),
    );
  }
}
