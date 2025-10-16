import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_editor_with_effects/data/overlay_layer.dart';

class OverlayLayerOverlay extends StatefulWidget {
  final int index;
  final OverlayLayerData layerData;
  final Function onUpdate;

  const OverlayLayerOverlay({
    super.key,
    required this.index,
    required this.layerData,
    required this.onUpdate,
  });

  @override
  State<OverlayLayerOverlay> createState() => _OverlayLayerOverlayState();
}

class _OverlayLayerOverlayState extends State<OverlayLayerOverlay> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(10),
          topLeft: Radius.circular(10),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Text(
                'OVERLAY SETTINGS',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Shape selector (for both shape and image overlays)
            const Text(
              'Shape',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: OverlayShape.values.map((shape) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        widget.layerData.shape = shape;
                      });
                      widget.onUpdate();
                    },
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: widget.layerData.shape == shape
                            ? Colors.white24
                            : Colors.white10,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: widget.layerData.shape == shape
                              ? Colors.white
                              : Colors.white30,
                          width: 2,
                        ),
                      ),
                      child: CustomPaint(
                        painter: OverlayShapePainter(
                          color: Colors.white,
                          shape: shape,
                          editable: false,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              
              // Color picker (only for shape overlays)
              if (widget.layerData.overlayType == OverlayType.shape) ...[
              const Text(
                'Color',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: Colors.black87,
                      title: const Text(
                        'Pick a color',
                        style: TextStyle(color: Colors.white),
                      ),
                      content: SingleChildScrollView(
                        child: ColorPicker(
                          color: widget.layerData.color,
                          onColorChanged: (color) {
                            setState(() {
                              widget.layerData.color = color;
                            });
                            widget.onUpdate();
                          },
                          pickersEnabled: const {
                            ColorPickerType.wheel: true,
                            ColorPickerType.primary: true,
                            ColorPickerType.accent: false,
                          },
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Done'),
                        ),
                      ],
                    ),
                  );
                },
                child: Container(
                  height: 50,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: widget.layerData.color,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Center(
                    child: Text(
                      'Tap to change color',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
            
            // Opacity slider
            const Text(
              'Opacity',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: widget.layerData.opacity,
                    min: 0.0,
                    max: 1.0,
                    divisions: 100,
                    activeColor: Colors.white,
                    inactiveColor: Colors.grey,
                    onChanged: (value) {
                      setState(() {
                        widget.layerData.opacityValue = value;
                      });
                      widget.onUpdate();
                    },
                  ),
                ),
                SizedBox(
                  width: 50,
                  child: Text(
                    '${(widget.layerData.opacity * 100).toInt()}%',
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            
            // Size slider
            const Text(
              'Size',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: widget.layerData.size,
                    min: 50.0,
                    max: 400.0,
                    divisions: 70,
                    activeColor: Colors.white,
                    inactiveColor: Colors.grey,
                    onChanged: (value) {
                      setState(() {
                        widget.layerData.size = value;
                      });
                      widget.onUpdate();
                    },
                  ),
                ),
                SizedBox(
                  width: 50,
                  child: Text(
                    '${widget.layerData.size.toInt()}',
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Instructions
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Gestures:',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• Tap to change shape',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  Text(
                    '• Drag with 1 finger to move',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  Text(
                    '• Pinch with 2 fingers to scale',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  Text(
                    '• Rotate with 2 fingers',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}