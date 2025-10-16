import 'package:flutter/material.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:image_editor_with_effects/data/overlay_layer.dart';

class OverlayEditorImage extends StatefulWidget {
  const OverlayEditorImage({super.key});

  @override
  State<OverlayEditorImage> createState() => _OverlayEditorImageState();
}

class _OverlayEditorImageState extends State<OverlayEditorImage> {
  Color selectedColor = Colors.white;
  double opacity = 0.5;
  double size = 100.0;
  OverlayShape currentShape = OverlayShape.rectangle;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black87,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Add Overlay', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.white),
            onPressed: () {
              final overlay = OverlayLayerData(
                color: selectedColor,
                opacityValue: opacity,
                shape: currentShape,
                size: size,
              );
              Navigator.pop(context, overlay);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    int nextIndex =
                        (currentShape.index + 1) % OverlayShape.values.length;
                    currentShape = OverlayShape.values[nextIndex];
                  });
                },
                child: SizedBox(
                  width: size,
                  height: size,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        size: Size(size, size),
                        painter: OverlayShapePainter(
                          color: selectedColor.withOpacity(opacity),
                          shape: currentShape,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Tap to change shape',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Container(
            color: Colors.black87,
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Shape indicator
                Text(
                  _getShapeName(currentShape),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                // Color picker
                const Text(
                  'Color',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 40,
                  child: ColorPicker(
                    color: selectedColor,
                    onColorChanged: (Color color) {
                      setState(() {
                        selectedColor = color;
                      });
                    },
                    width: 35,
                    height: 35,
                    borderRadius: 20,
                    spacing: 5,
                    runSpacing: 5,
                    wheelDiameter: 155,
                    heading: const SizedBox.shrink(),
                    subheading: const SizedBox.shrink(),
                    wheelSubheading: const SizedBox.shrink(),
                    showMaterialName: false,
                    showColorName: false,
                    showColorCode: false,
                    copyPasteBehavior: const ColorPickerCopyPasteBehavior(
                      longPressMenu: false,
                    ),
                    materialNameTextStyle: const TextStyle(fontSize: 0),
                    colorNameTextStyle: const TextStyle(fontSize: 0),
                    colorCodeTextStyle: const TextStyle(fontSize: 0),
                    pickersEnabled: const <ColorPickerType, bool>{
                      ColorPickerType.both: false,
                      ColorPickerType.primary: true,
                      ColorPickerType.accent: false,
                      ColorPickerType.bw: false,
                      ColorPickerType.custom: false,
                      ColorPickerType.wheel: false,
                    },
                  ),
                ),
                const SizedBox(height: 20),

                // Opacity slider
                const Text(
                  'Opacity',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Slider(
                        value: opacity,
                        min: 0.0,
                        max: 1.0,
                        activeColor: Colors.white,
                        inactiveColor: Colors.grey,
                        onChanged: (value) {
                          setState(() {
                            opacity = value;
                          });
                        },
                      ),
                    ),
                    SizedBox(
                      width: 45,
                      child: Text(
                        '${(opacity * 100).toInt()}%',
                        style: const TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Size slider
                const Text(
                  'Size',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Slider(
                        value: size,
                        min: 50.0,
                        max: 300.0,
                        activeColor: Colors.white,
                        inactiveColor: Colors.grey,
                        onChanged: (value) {
                          setState(() {
                            size = value;
                          });
                        },
                      ),
                    ),
                    SizedBox(
                      width: 45,
                      child: Text(
                        '${size.toInt()}',
                        style: const TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getShapeName(OverlayShape shape) {
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
