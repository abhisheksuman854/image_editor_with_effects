import 'package:flutter/material.dart';
import 'package:hand_signature/signature.dart';
import 'package:image_editor_with_effects/data/image_item.dart';
import 'package:image_editor_with_effects/data/overlay_layer.dart';

// Update the LayerType enum:
enum LayerType {
  background,
  image,
  text,
  emoji,
  link,
  overlay,
  brush, // Add this
  backgroundBlur,
}

/// Layer class with some common properties
class Layer {
  Offset offset;
  double rotation, scale, opacity;

  Layer({
    this.offset = const Offset(64, 64),
    this.opacity = 1,
    this.rotation = 0,
    this.scale = 1,
  });

  void copyFrom(Map json) {
    offset = Offset(json['offset'][0], json['offset'][1]);
    opacity = json['opacity'];
    rotation = json['rotation'];
    scale = json['scale'];
  }

  static Layer fromJson(Map json) {
    switch (json['type']) {
      case 'BackgroundLayer':
        return BackgroundLayerData.fromJson(json);
      case 'EmojiLayer':
        return EmojiLayerData.fromJson(json);
      case 'ImageLayer':
        return ImageLayerData.fromJson(json);
      case 'OverlayLayer':
        return OverlayLayerData.fromJson(json);
      case 'LinkLayer':
        return LinkLayerData.fromJson(json);
      case 'EnhancedTextLayer':
        return TextLayerData.fromJson(json);
      case 'BackgroundBlurLayer':
        return BackgroundBlurLayerData.fromJson(json);
      case 'BrushLayer':
        return BrushLayerData.fromJson(json);
      default:
        return Layer();
    }
  }

  Map toJson() {
    return {
      'offset': [offset.dx, offset.dy],
      'opacity': opacity,
      'rotation': rotation,
      'scale': scale,
    };
  }
}

/// Attributes used by [BackgroundLayer]
class BackgroundLayerData extends Layer {
  ImageItem image;

  BackgroundLayerData({required this.image});

  static BackgroundLayerData fromJson(Map json) {
    return BackgroundLayerData(image: ImageItem.fromJson(json['image']));
  }

  @override
  Map toJson() {
    return {'type': 'BackgroundLayer', 'image': image.toJson()};
  }
}

/// Attributes used by [EmojiLayer]
class EmojiLayerData extends Layer {
  String text;
  double size;

  EmojiLayerData({
    this.text = '',
    this.size = 64,
    super.offset,
    super.opacity,
    super.rotation,
    super.scale,
  });

  static EmojiLayerData fromJson(Map json) {
    var layer = EmojiLayerData(text: json['text'], size: json['size']);

    layer.copyFrom(json);
    return layer;
  }

  @override
  Map toJson() {
    return {
      'type': 'EmojiLayer',
      'text': text,
      'size': size,
      ...super.toJson(),
    };
  }
}

/// Attributes used by [ImageLayer]
class ImageLayerData extends Layer {
  ImageItem image;
  double size;

  ImageLayerData({
    required this.image,
    this.size = 64,
    super.offset,
    super.opacity,
    super.rotation,
    super.scale,
  });

  static ImageLayerData fromJson(Map json) {
    var layer = ImageLayerData(
      image: ImageItem.fromJson(json['image']),
      size: json['size'],
    );

    layer.copyFrom(json);
    return layer;
  }

  @override
  Map toJson() {
    return {
      'type': 'ImageLayer',
      'image': image.toJson(),
      'size': size,
      ...super.toJson(),
    };
  }
}

/// Attributes used by [EnhancedTextLayer]
class TextLayerData extends Layer {
  String text;
  double size;
  Color color, background;
  double backgroundOpacity;
  TextAlign align;

  TextLayerData({
    required this.text,
    this.size = 64,
    this.color = Colors.white,
    this.background = Colors.transparent,
    this.backgroundOpacity = 0,
    this.align = TextAlign.left,
    super.offset,
    super.opacity,
    super.rotation,
    super.scale,
  });

  static TextLayerData fromJson(Map json) {
    var layer = TextLayerData(
      text: json['text'],
      size: json['size'],
      color: Color(json['color']),
      background: Color(json['background']),
      backgroundOpacity: json['backgroundOpacity'],
      align: TextAlign.values.firstWhere((e) => e.name == json['align']),
    );

    layer.copyFrom(json);
    return layer;
  }

  @override
  Map toJson() {
    return {
      'type': 'EnhancedTextLayer',
      'text': text,
      'size': size,
      'color': color.toARGB32(),
      'background': background.toARGB32(),
      'backgroundOpacity': backgroundOpacity,
      'align': align.name,
      ...super.toJson(),
    };
  }
}

/// Attributes used by [TextLayer]
class LinkLayerData extends Layer {
  String text;
  double size;
  Color color, background;
  double backgroundOpacity;
  TextAlign align;

  LinkLayerData({
    required this.text,
    this.size = 64,
    this.color = Colors.white,
    this.background = Colors.transparent,
    this.backgroundOpacity = 0,
    this.align = TextAlign.left,
    super.offset,
    super.opacity,
    super.rotation,
    super.scale,
  });

  static LinkLayerData fromJson(Map json) {
    var layer = LinkLayerData(
      text: json['text'],
      size: json['size'],
      color: Color(json['color']),
      background: Color(json['background']),
      backgroundOpacity: json['backgroundOpacity'],
      align: TextAlign.values.firstWhere((e) => e.name == json['align']),
    );

    layer.copyFrom(json);
    return layer;
  }

  @override
  Map toJson() {
    return {
      'type': 'LinkLayer',
      'text': text,
      'size': size,
      'color': color.toARGB32(),
      'background': background.toARGB32(),
      'backgroundOpacity': backgroundOpacity,
      'align': align.name,
      ...super.toJson(),
    };
  }
}

/// Attributes used by [BackgroundBlurLayer]
class BackgroundBlurLayerData extends Layer {
  Color color;
  double radius;

  BackgroundBlurLayerData({
    required this.color,
    required this.radius,
    super.offset,
    super.opacity,
    super.rotation,
    super.scale,
  });

  static BackgroundBlurLayerData fromJson(Map json) {
    var layer = BackgroundBlurLayerData(
      color: Color(json['color']),
      radius: json['radius'],
    );

    layer.copyFrom(json);
    return layer;
  }

  @override
  Map toJson() {
    return {
      'type': 'BackgroundBlurLayer',
      'color': color.toARGB32(),
      'radius': radius,
      ...super.toJson(),
    };
  }
}

/// Attributes used by [BrushLayer]
class BrushLayerData extends Layer {
  List<CubicPath> paths;
  Color color;
  double strokeWidth;
  double maxWidth;

  BrushLayerData({
    this.paths = const [],
    this.color = Colors.white,
    this.strokeWidth = 1.0,
    this.maxWidth = 7.0,
    super.offset,
    super.rotation,
    super.scale,
    super.opacity,
  });

  static BrushLayerData fromJson(Map json) {
    var layer = BrushLayerData(
      color: Color(json['color']),
      strokeWidth: json['strokeWidth'],
      maxWidth: json['maxWidth'],
    );
    layer.copyFrom(json);
    return layer;
  }

  @override
  Map toJson() {
    return {
      'type': 'BrushLayer',
      'color': color.value,
      'strokeWidth': strokeWidth,
      'maxWidth': maxWidth,
      'offset': [offset.dx, offset.dy],
      'opacity': opacity,
      'rotation': rotation,
      'scale': scale,
    };
  }
}

/// Custom painter for brush strokes
class BrushPainter extends CustomPainter {
  final List<CubicPath> paths;
  final Color color;
  final double strokeWidth;
  final double maxWidth;

  BrushPainter({
    required this.paths,
    required this.color,
    required this.strokeWidth,
    required this.maxWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (var cubicPath in paths) {
      if (cubicPath.points.isEmpty) continue;

      final paint = Paint()
        ..color = color
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      final points = cubicPath.points;

      for (int i = 0; i < points.length - 1; i++) {
        final point = points[i];
        final nextPoint = points[i + 1];

        // OffsetPoint has dx, dy, and timestamp (int, not DateTime)
        final currentOffset = Offset(point.dx, point.dy);
        final nextOffset = Offset(nextPoint.dx, nextPoint.dy);

        // Calculate stroke width based on distance
        final distance = (nextOffset - currentOffset).distance;

        // Timestamp is in milliseconds as int
        final timeDiff = (nextPoint.timestamp - point.timestamp).abs().clamp(
          1,
          1000,
        );
        final velocity = distance / timeDiff;

        // Normalize velocity and calculate width
        final normalizedVelocity = (velocity / 2.0).clamp(0.0, 1.0);
        final width =
            strokeWidth + (maxWidth - strokeWidth) * (1 - normalizedVelocity);

        paint.strokeWidth = width.clamp(strokeWidth, maxWidth);

        canvas.drawLine(currentOffset, nextOffset, paint);
      }
    }
  }

  @override
  bool shouldRepaint(BrushPainter oldDelegate) {
    return oldDelegate.paths != paths ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.maxWidth != maxWidth;
  }
}
