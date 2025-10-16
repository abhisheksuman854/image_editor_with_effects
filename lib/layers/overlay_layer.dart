import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:image_editor_with_effects/data/overlay_layer.dart';

/// Overlay Layer Widget - handles interaction and rendering
class OverlayLayer extends StatefulWidget {
  final OverlayLayerData layerData;
  final Function()? onUpdate;
  final bool editable;

  const OverlayLayer({
    super.key,
    required this.layerData,
    this.onUpdate,
    this.editable = false,
  });

  @override
  State<OverlayLayer> createState() => _OverlayLayerState();
}

class _OverlayLayerState extends State<OverlayLayer> {
  double baseScaleFactor = 1;
  double baseAngle = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.layerData.offset.dx,
      top: widget.layerData.offset.dy,
      child: Transform.scale(
        scale: widget.layerData.scale,
        child: Transform.rotate(
          angle: widget.layerData.rotation,
          child: GestureDetector(
            // Single tap to change shape (works for both shape and image overlays)
            onTap: widget.editable
                ? () {
                    setState(() {
                      widget.layerData.nextShape();
                    });
                    widget.onUpdate?.call();
                  }
                : null,

            // Use only scale gesture recognizer for all interactions
            onScaleStart: widget.editable
                ? (details) {
                    baseScaleFactor = widget.layerData.scale;
                    baseAngle = widget.layerData.rotation;
                  }
                : null,
            onScaleUpdate: widget.editable
                ? (details) {
                    setState(() {
                      // Handle dragging (1 finger)
                      if (details.pointerCount == 1) {
                        widget.layerData.offset = Offset(
                          widget.layerData.offset.dx + details.focalPointDelta.dx,
                          widget.layerData.offset.dy + details.focalPointDelta.dy,
                        );
                      } else if (details.pointerCount == 2) {
                        // Handle scaling and rotation (2 fingers)
                        widget.layerData.scale =
                            baseScaleFactor * details.scale;
                        widget.layerData.rotation =
                            baseAngle + details.rotation;
                      }
                    });
                    widget.onUpdate?.call();
                  }
                : null,

            child: SizedBox(
              width: widget.layerData.size,
              height: widget.layerData.size,
              child:
                  widget.layerData.overlayType == OverlayType.image &&
                      widget.layerData.overlayImage != null
                  ? _buildImageWithShape()
                  : CustomPaint(
                      size: Size(widget.layerData.size, widget.layerData.size),
                      painter: OverlayShapePainter(
                        color: widget.layerData.color.withOpacity(
                          widget.layerData.opacity,
                        ),
                        shape: widget.layerData.shape,
                        editable: widget.editable,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageWithShape() {
    return Stack(
      children: [
        ClipPath(
          clipper: _getShapeClipper(widget.layerData.shape),
          child: Opacity(
            opacity: widget.layerData.opacity,
            child: Image.memory(
              widget.layerData.overlayImage!.bytes,
              fit: BoxFit.cover,
              width: widget.layerData.size,
              height: widget.layerData.size,
            ),
          ),
        ),
        if (widget.editable)
          ClipPath(
            clipper: _getShapeClipper(widget.layerData.shape),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white.withOpacity(0.5),
                  width: 2,
                ),
              ),
            ),
          ),
      ],
    );
  }

  CustomClipper<Path> _getShapeClipper(OverlayShape shape) {
    switch (shape) {
      case OverlayShape.rectangle:
        return _RectangleClipper();
      case OverlayShape.circle:
        return _CircleClipper();
      case OverlayShape.roundedRectangle:
        return _RoundedRectangleClipper();
      case OverlayShape.triangle:
        return _TriangleClipper();
      case OverlayShape.star:
        return _StarClipper();
      case OverlayShape.heart:
        return _HeartClipper();
    }
  }
}

// Custom clippers for each shape
class _RectangleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..close();
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class _CircleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()
      ..addOval(Rect.fromCircle(
        center: Offset(size.width / 2, size.height / 2),
        radius: size.width / 2,
      ))
      ..close();
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class _RoundedRectangleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Radius.circular(size.width * 0.2),
      ))
      ..close();
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class _TriangleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class _StarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final outerRadius = size.width / 2;
    final innerRadius = outerRadius * 0.4;
    final points = 5;

    for (int i = 0; i < points * 2; i++) {
      final radius = i.isEven ? outerRadius : innerRadius;
      final angle = (i * math.pi) / points - math.pi / 2;
      final x = centerX + radius * math.cos(angle);
      final y = centerY + radius * math.sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class _HeartClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final width = size.width;
    final height = size.height;

    path.moveTo(width / 2, height * 0.35);

    // Left side
    path.cubicTo(
      width * 0.2,
      height * 0.1,
      -width * 0.25,
      height * 0.4,
      width / 2,
      height,
    );

    // Right side
    path.moveTo(width / 2, height * 0.35);
    path.cubicTo(
      width * 0.8,
      height * 0.1,
      width * 1.25,
      height * 0.4,
      width / 2,
      height,
    );

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}