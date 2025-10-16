import 'package:flutter/material.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:image_editor_with_effects/data/overlay_layer.dart';
import 'package:image_editor_with_effects/data/image_item.dart';
import 'package:image_picker/image_picker.dart';

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
  OverlayType overlayType = OverlayType.shape;
  ImageItem? selectedImage;

  final ImagePicker _picker = ImagePicker();

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
                overlayType: overlayType,
                overlayImage: selectedImage,
              );
              Navigator.pop(context, overlay);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Type selector tabs
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTypeTab('Shape', OverlayType.shape),
                const SizedBox(width: 20),
                _buildTypeTab('Image', OverlayType.image),
              ],
            ),
          ),

          Expanded(
            child: Center(
              child: overlayType == OverlayType.shape
                  ? _buildShapePreview()
                  : _buildImagePreview(),
            ),
          ),

          Container(
            color: Colors.black87,
            padding: const EdgeInsets.all(20),
            child: overlayType == OverlayType.shape
                ? _buildShapeControls()
                : _buildImageControls(),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeTab(String label, OverlayType type) {
    final isSelected = overlayType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          overlayType = type;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildShapePreview() {
    return GestureDetector(
      onTap: () {
        setState(() {
          int nextIndex = (currentShape.index + 1) % OverlayShape.values.length;
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
    );
  }

  Widget _buildImagePreview() {
    return GestureDetector(
      onTap: () async {
        final XFile? image = await _picker.pickImage(
          source: ImageSource.gallery,
        );

        if (image != null) {
          final imageItem = ImageItem(image);
          await imageItem.loader.future;
          setState(() {
            selectedImage = imageItem;
          });
        }
      },
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: selectedImage == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.add_photo_alternate,
                    color: Colors.white,
                    size: 48,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tap to select image',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Opacity(
                  opacity: opacity,
                  child: Image.memory(selectedImage!.bytes, fit: BoxFit.cover),
                ),
              ),
      ),
    );
  }

  Widget _buildShapeControls() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _getShapeName(currentShape),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
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
        _buildSlider('Opacity', opacity, 0.0, 1.0, (value) {
          setState(() => opacity = value);
        }, '${(opacity * 100).toInt()}%'),
        const SizedBox(height: 10),
        _buildSlider('Size', size, 50.0, 300.0, (value) {
          setState(() => size = value);
        }, '${size.toInt()}'),
      ],
    );
  }

  Widget _buildImageControls() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton.icon(
          onPressed: () async {
            final XFile? image = await _picker.pickImage(
              source: ImageSource.gallery,
            );

            if (image != null) {
              final imageItem = ImageItem(image);
              await imageItem.loader.future;
              setState(() {
                selectedImage = imageItem;
              });
            }
          },
          icon: const Icon(Icons.photo_library),
          label: Text(selectedImage == null ? 'Select Image' : 'Change Image'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
          ),
        ),
        const SizedBox(height: 20),
        _buildSlider('Opacity', opacity, 0.0, 1.0, (value) {
          setState(() => opacity = value);
        }, '${(opacity * 100).toInt()}%'),
        const SizedBox(height: 10),
        _buildSlider('Size', size, 50.0, 300.0, (value) {
          setState(() => size = value);
        }, '${size.toInt()}'),
      ],
    );
  }

  Widget _buildSlider(
    String label,
    double value,
    double min,
    double max,
    Function(double) onChanged,
    String displayValue,
  ) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: value,
                min: min,
                max: max,
                activeColor: Colors.white,
                inactiveColor: Colors.grey,
                onChanged: onChanged,
              ),
            ),
            SizedBox(
              width: 45,
              child: Text(
                displayValue,
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ],
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
