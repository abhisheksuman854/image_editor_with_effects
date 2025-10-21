import 'package:colorfilter_generator/colorfilter_generator.dart';
import 'package:flutter/material.dart';

enum OutputFormat {
  /// merge all layers and return jpeg encoded bytes
  jpeg,

  /// convert all layers into json and return the list
  json,

  /// merge all layers and return png encoded bytes
  png,
}

class AspectRatio {
  final String title;
  final double? ratio;

  const AspectRatio({required this.title, this.ratio});
}

class CropOption {
  final bool reversible;

  /// List of availble ratios
  final List<AspectRatio> ratios;

  const CropOption({
    this.reversible = true,
    this.ratios = const [
      AspectRatio(title: 'Freeform'),
      AspectRatio(title: '1:1', ratio: 1),
      AspectRatio(title: '4:3', ratio: 4 / 3),
      AspectRatio(title: '5:4', ratio: 5 / 4),
      AspectRatio(title: '7:5', ratio: 7 / 5),
      AspectRatio(title: '16:9', ratio: 16 / 9),
    ],
  });
}

class BlurOption {
  const BlurOption();
}

class BrushOption {
  /// show background image on draw screen
  final bool showBackground;

  /// User will able to move, zoom drawn image
  /// Note: Layer may not be placed precisely
  final bool translatable;
  final List<BrushColor> colors;

  const BrushOption({
    this.showBackground = true,
    this.translatable = false,
    this.colors = const [
      BrushColor(color: Colors.black, background: Colors.white),
      BrushColor(color: Colors.white),
      BrushColor(color: Colors.blue),
      BrushColor(color: Colors.green),
      BrushColor(color: Colors.pink),
      BrushColor(color: Colors.purple),
      BrushColor(color: Colors.brown),
      BrushColor(color: Colors.indigo),
    ],
  });
}

class BrushColor {
  /// Color of brush
  final Color color;

  /// Background color while brush is active only be used when showBackground is false
  final Color background;

  const BrushColor({required this.color, this.background = Colors.black});
}

class EmojiOption {
  const EmojiOption();
}

class FiltersOption {
  final List<ColorFilterGenerator>? filters;
  const FiltersOption({this.filters});
}

class FlipOption {
  const FlipOption();
}

class RotateOption {
  const RotateOption();
}

class TextOption {
  /// List of available font families
  final List<String> fontFamilies;

  /// List of available text colors
  final List<Color> textColors;

  /// List of available gradient presets for text
  final List<Gradient> textGradients;

  /// List of available gradient presets for text background
  final List<Gradient> backgroundGradients;

  /// Available text animations
  final List<TextAnimation> animations;

  /// Enable font family selection
  final bool enableFontFamily;

  /// Enable text gradient
  final bool enableTextGradient;

  /// Enable background gradient
  final bool enableBackgroundGradient;

  /// Enable text animations
  final bool enableAnimations;

  const TextOption({
    this.fontFamilies = const [
      'Roboto',
      'Arial',
      'Times New Roman',
      'Courier',
      'Georgia',
      'Verdana',
      'Helvetica',
    ],
    this.textColors = const [
      Colors.white,
      Colors.black,
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.purple,
      Colors.orange,
      Colors.pink,
      Colors.teal,
      Colors.indigo,
      Colors.cyan,
    ],
    this.textGradients = const [
      LinearGradient(
        colors: [Colors.purple, Colors.blue],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      LinearGradient(
        colors: [Colors.orange, Colors.pink],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      LinearGradient(
        colors: [Colors.green, Colors.teal],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      LinearGradient(
        colors: [Colors.red, Colors.yellow],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      LinearGradient(
        colors: [Colors.indigo, Colors.cyan],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
    ],
    this.backgroundGradients = const [
      LinearGradient(
        colors: [Colors.black54, Colors.transparent],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ),
      LinearGradient(
        colors: [Colors.purple, Colors.blue],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      LinearGradient(
        colors: [Colors.orange, Colors.pink],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      RadialGradient(
        colors: [Colors.yellow, Colors.red],
        center: Alignment.center,
        radius: 0.8,
      ),
      LinearGradient(
        colors: [Colors.green, Colors.teal],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ],
    this.animations = const [
      TextAnimation.fade,
      TextAnimation.slide,
      TextAnimation.bounce,
      TextAnimation.rotate,
      TextAnimation.scale,
      TextAnimation.pulse,
    ],
    this.enableFontFamily = true,
    this.enableTextGradient = true,
    this.enableBackgroundGradient = true,
    this.enableAnimations = true,
  });
}

/// Available text animation types
enum TextAnimation { none, fade, slide, bounce, rotate, scale, pulse }

extension TextAnimationExtension on TextAnimation {
  String get name {
    switch (this) {
      case TextAnimation.none:
        return 'None';
      case TextAnimation.fade:
        return 'Fade';
      case TextAnimation.slide:
        return 'Slide';
      case TextAnimation.bounce:
        return 'Bounce';
      case TextAnimation.rotate:
        return 'Rotate';
      case TextAnimation.scale:
        return 'Scale';
      case TextAnimation.pulse:
        return 'Pulse';
    }
  }
}

class ImagePickerOption {
  final bool pickFromGallery, captureFromCamera;
  final int maxLength;

  const ImagePickerOption({
    this.pickFromGallery = false,
    this.captureFromCamera = false,
    this.maxLength = 99,
  });
}

class OverlayOption {
  final bool enabled;

  const OverlayOption({this.enabled = true});
}
