import 'package:flutter/material.dart';

class BackgroundWithRings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        Image.asset(
          'assets/weather-bk_enlarged.png',
          fit: BoxFit.cover,
        ),
        ClipOval(
          clipper: CircleClipper(
            radius: 140.0,
            offset: const Offset(40.0, 0.0),
          ),
          child: Image.asset(
            'assets/weather-bk.png',
            fit: BoxFit.cover,
          ),
        ),
        CustomPaint(
          painter: WhiteCircleCutoutPainter(
            centerOffset: const Offset(40.0, 0.0),
            circles: [
              Circle(radius: 140.0, alpha: 0x10),
              Circle(radius: 140.0 + 15.0, alpha: 0x28),
              Circle(radius: 140.0 + 30.0, alpha: 0x38),
              Circle(radius: 140.0 + 75.0, alpha: 0x50),
            ],
          ),
          child: Container(),
        ),
      ],
    );
  }
}

class CircleClipper extends CustomClipper<Rect> {
  final double radius;
  final Offset offset;

  CircleClipper({
    this.radius,
    this.offset = const Offset(0.0, 0.0),
  });

  @override
  Rect getClip(Size size) {
    return new Rect.fromCircle(
      center: Offset(0.0, size.height / 2) + offset,
      radius: radius,
    );
  }

  @override
  bool shouldReclip(CustomClipper<Rect> oldClipper) {
    return true;
  }
}

class Circle {
  final double radius;
  final int alpha;

  Circle({
    this.radius,
    this.alpha = 0xFF,
  });
}

class WhiteCircleCutoutPainter extends CustomPainter {
  final Color overlayColor = const Color(0xFFAA88AA);

  final List<Circle> circles;
  final Offset centerOffset;
  final Paint whitePaint;
  final Paint borderPaint;

  WhiteCircleCutoutPainter({
    this.circles = const [],
    this.centerOffset = const Offset(0.0, 0.0),
  })  : whitePaint = new Paint(),
        borderPaint = new Paint() {
    borderPaint
      ..color = const Color(0x10FFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 1; i < circles.length; i++) {
      _maskCircle(canvas, size, circles[i - 1].radius);
      whitePaint.color = overlayColor.withAlpha(circles[i - 1].alpha);
      // Draw circle
      canvas.drawCircle(
        new Offset(0.0, size.height / 2) + centerOffset,
        circles[i].radius,
        whitePaint,
      );
      // Draw circle bevel
      canvas.drawCircle(
        new Offset(0.0, size.height / 2) + centerOffset,
        circles[i - 1].radius,
        borderPaint,
      );
    }
    // Mask the area of the final circle
    _maskCircle(canvas, size, circles.last.radius);
    // Draw an overlay that fills the rest of the screen
    whitePaint.color = overlayColor.withAlpha(circles.last.alpha);
    canvas.drawRect(
      new Rect.fromLTWH(0.0, 0.0, size.width, size.height),
      whitePaint,
    );
    // Draw the bevel for the final circle
    canvas.drawCircle(
      new Offset(0.0, size.height / 2) + centerOffset,
      circles.last.radius,
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }

  _maskCircle(Canvas canvas, Size size, double radius) {
    Path clipperCircle = new Path();
    clipperCircle.fillType = PathFillType.evenOdd;
    clipperCircle.addRect(new Rect.fromLTWH(0.0, 0.0, size.width, size.height));
    clipperCircle.addOval(
      new Rect.fromCircle(
        center: new Offset(0.0, size.height / 2) + centerOffset,
        radius: radius,
      ),
    );
    canvas.clipPath(clipperCircle);
  }
}
