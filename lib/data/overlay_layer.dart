import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:image_editor_with_effects/data/layer.dart';
import 'package:image_editor_with_effects/data/image_item.dart';

/// Enum for different overlay shapes
enum OverlayShape { rectangle, circle, roundedRectangle, triangle, star, heart }

/// Enum for overlay types
enum OverlayType { shape, image }

/// Overlay Layer Data
class OverlayLayerData extends Layer {
  Color color;
  double opacityValue;
  OverlayShape shape;
  double size;
  OverlayType overlayType;
  ImageItem? overlayImage;

  OverlayLayerData({
    this.color = Colors.white,
    this.opacityValue = 0.5,
    this.shape = OverlayShape.rectangle,
    this.size = 100.0,
    this.overlayType = OverlayType.shape,
    this.overlayImage,
    super.offset,
    super.rotation,
    super.scale,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'overlay',
      'overlayType': overlayType.index,
      'color': color.value,
      'opacity': opacity,
      'shape': shape.index,
      'size': size,
      'offset': {'dx': offset.dx, 'dy': offset.dy},
      'rotation': rotation,
      'scale': scale,
      'hasImage': overlayImage != null,
    };
  }

  /// Cycle to the next shape (works for both shape and image overlays)
  void nextShape() {
    int nextIndex = (shape.index + 1) % OverlayShape.values.length;
    shape = OverlayShape.values[nextIndex];
  }

  /// Get shape name for display
  String get shapeName {
    if (overlayType == OverlayType.image) {
      return 'Image: ${_getShapeName()}';
    }
    return _getShapeName();
  }

  String _getShapeName() {
    switch (shape) {
      case OverlayShape.rectangle:
        return 'Rectangle';
      case OverlayShape.circle:
        return 'Circle';
      case OverlayShape.roundedRectangle:
        return 'Rounded Rectangle';
      case OverlayShape.triangle:
        return 'Triangle';
      case OverlayShape.star:
        return 'Star';
      case OverlayShape.heart:
        return 'Heart';
    }
  }
}

/// Widget to render overlay shapes
class OverlayWidget extends StatelessWidget {
  final OverlayLayerData overlay;
  final VoidCallback? onTap;
  final bool editable;

  const OverlayWidget({
    super.key,
    required this.overlay,
    this.onTap,
    this.editable = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: editable ? onTap : null,
      child: SizedBox(
        width: overlay.size,
        height: overlay.size,
        child:
            overlay.overlayType == OverlayType.image &&
                overlay.overlayImage != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Opacity(
                  opacity: overlay.opacity,
                  child: Image.memory(
                    overlay.overlayImage!.bytes,
                    fit: BoxFit.cover,
                  ),
                ),
              )
            : CustomPaint(
                painter: OverlayShapePainter(
                  color: overlay.color.withOpacity(overlay.opacity),
                  shape: overlay.shape,
                  editable: editable,
                ),
              ),
      ),
    );
  }
}

/// Custom painter for overlay shapes
class OverlayShapePainter extends CustomPainter {
  final Color color;
  final OverlayShape shape;
  final bool editable;

  OverlayShapePainter({
    required this.color,
    required this.shape,
    this.editable = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = Colors.white.withOpacity(editable ? 0.5 : 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    switch (shape) {
      case OverlayShape.rectangle:
        _drawRectangle(canvas, size, paint, strokePaint);
        break;
      case OverlayShape.circle:
        _drawCircle(canvas, size, paint, strokePaint);
        break;
      case OverlayShape.roundedRectangle:
        _drawRoundedRectangle(canvas, size, paint, strokePaint);
        break;
      case OverlayShape.triangle:
        _drawTriangle(canvas, size, paint, strokePaint);
        break;
      case OverlayShape.star:
        _drawStar(canvas, size, paint, strokePaint);
        break;
      case OverlayShape.heart:
        _drawHeart(canvas, size, paint, strokePaint);
        break;
    }
  }

  void _drawRectangle(
    Canvas canvas,
    Size size,
    Paint paint,
    Paint strokePaint,
  ) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(rect, paint);
    if (editable) canvas.drawRect(rect, strokePaint);
  }

  void _drawCircle(Canvas canvas, Size size, Paint paint, Paint strokePaint) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    canvas.drawCircle(center, radius, paint);
    if (editable) canvas.drawCircle(center, radius, strokePaint);
  }

  void _drawRoundedRectangle(
    Canvas canvas,
    Size size,
    Paint paint,
    Paint strokePaint,
  ) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final radius = Radius.circular(size.width * 0.2);
    canvas.drawRRect(RRect.fromRectAndRadius(rect, radius), paint);
    if (editable) {
      canvas.drawRRect(RRect.fromRectAndRadius(rect, radius), strokePaint);
    }
  }

  void _drawTriangle(Canvas canvas, Size size, Paint paint, Paint strokePaint) {
    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, paint);
    if (editable) canvas.drawPath(path, strokePaint);
  }

  void _drawStar(Canvas canvas, Size size, Paint paint, Paint strokePaint) {
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

    canvas.drawPath(path, paint);
    if (editable) canvas.drawPath(path, strokePaint);
  }

  void _drawHeart(Canvas canvas, Size size, Paint paint, Paint strokePaint) {
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

    canvas.drawPath(path, paint);
    if (editable) canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}