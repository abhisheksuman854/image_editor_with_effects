import 'dart:math' as math;

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
  OverlayShape imageShape = OverlayShape.rectangle;
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
          TextButton(
            onPressed: () {
              if (overlayType == OverlayType.image && selectedImage == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please select an image first'),
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 2),
                  ),
                );
                return;
              }
              final overlay = OverlayLayerData(
                color: selectedColor,
                opacityValue: opacity,
                shape: overlayType == OverlayType.shape
                    ? currentShape
                    : imageShape,
                size: size,
                overlayType: overlayType,
                overlayImage: selectedImage,
              );
              Navigator.pop(context, overlay);
            },
            child: const Text(
              'Done',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Type selector tabs
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: _buildTypeTab(
                      'Shape',
                      OverlayType.shape,
                      Icons.category_outlined,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTypeTab(
                      'Image',
                      OverlayType.image,
                      Icons.image_outlined,
                    ),
                  ),
                ],
              ),
            ),

            // Preview area - takes remaining space
            Expanded(
              flex: 3,
              child: Center(
                child: overlayType == OverlayType.shape
                    ? _buildShapePreview()
                    : _buildImagePreview(),
              ),
            ),

            // Controls area - scrollable with adaptive height
            Expanded(
              flex: 2,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: overlayType == OverlayType.shape
                      ? _buildShapeControls()
                      : _buildImageControls(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeTab(String label, OverlayType type, IconData icon) {
    final isSelected = overlayType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          overlayType = type;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.grey[700]!,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.black : Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.black : Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShapePreview() {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                SizedBox(
                  width: size,
                  height: size,
                  child: CustomPaint(
                    size: Size(size, size),
                    painter: OverlayShapePainter(
                      color: selectedColor.withOpacity(opacity),
                      shape: currentShape,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _getShapeName(currentShape),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          selectedImage == null
              ? GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_photo_alternate_outlined,
                          color: Colors.white.withOpacity(0.7),
                          size: 48,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap to select',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : SizedBox(
                  width: size,
                  height: size,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      ClipPath(
                        clipper: _getShapeClipper(imageShape),
                        child: Opacity(
                          opacity: opacity,
                          child: Image.memory(
                            selectedImage!.bytes,
                            fit: BoxFit.cover,
                            width: size,
                            height: size,
                          ),
                        ),
                      ),
                      ClipPath(
                        clipper: _getShapeClipper(imageShape),
                        child: Container(
                          width: size,
                          height: size,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.white.withOpacity(0.5),
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 20,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 36,
                              minHeight: 36,
                            ),
                            onPressed: _pickImage,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
          const SizedBox(height: 20),
          if (selectedImage == null)
            OutlinedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.photo_library_outlined, size: 20),
              label: const Text('Choose from Gallery'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white, width: 1.5),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final imageItem = ImageItem(image);
      await imageItem.loader.future;
      setState(() {
        selectedImage = imageItem;
      });
    }
  }

  Widget _buildShapeControls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Customize Shape',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        // Shape selector grid
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: OverlayShape.values.map((shape) {
              final isSelected = currentShape == shape;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    currentShape = shape;
                  });
                },
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withOpacity(0.2)
                        : Colors.transparent,
                    border: Border.all(
                      color: isSelected
                          ? Colors.white
                          : Colors.white.withOpacity(0.3),
                      width: isSelected ? 3 : 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: SizedBox(
                      width: 35,
                      height: 35,
                      child: CustomPaint(
                        size: const Size(35, 35),
                        painter: OverlayShapePainter(
                          color: Colors.white,
                          shape: shape,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 24),
        const Text(
          'Color',
          style: TextStyle(color: Colors.white70, fontSize: 15),
        ),
        const SizedBox(height: 12),
        ColorPicker(
          color: selectedColor,
          onColorChanged: (Color color) {
            setState(() {
              selectedColor = color;
            });
          },
          width: 44,
          height: 44,
          borderRadius: 22,
          spacing: 8,
          runSpacing: 8,
          wheelDiameter: 155,
          enableShadesSelection: false,
          heading: const SizedBox.shrink(),
          subheading: const SizedBox.shrink(),
          wheelSubheading: const SizedBox.shrink(),
          showMaterialName: false,
          showColorName: false,
          showColorCode: false,
          copyPasteBehavior: const ColorPickerCopyPasteBehavior(
            longPressMenu: false,
          ),
          pickersEnabled: const <ColorPickerType, bool>{
            ColorPickerType.both: false,
            ColorPickerType.primary: true,
            ColorPickerType.accent: false,
            ColorPickerType.bw: false,
            ColorPickerType.custom: false,
            ColorPickerType.wheel: false,
          },
        ),
        const SizedBox(height: 24),
        _buildSlider(
          'Opacity',
          opacity,
          0.0,
          1.0,
          (value) => setState(() => opacity = value),
          '${(opacity * 100).toInt()}%',
        ),
        const SizedBox(height: 16),
        _buildSlider(
          'Size',
          size,
          50.0,
          300.0,
          (value) => setState(() => size = value),
          '${size.toInt()}',
        ),
      ],
    );
  }

  Widget _buildImageControls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Customize Image',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),
        // Shape selector for image
        const Text(
          'Shape',
          style: TextStyle(color: Colors.white70, fontSize: 15),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: OverlayShape.values.map((shape) {
            final isSelected = imageShape == shape;
            return GestureDetector(
              onTap: () {
                setState(() {
                  imageShape = shape;
                });
              },
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withOpacity(0.2)
                      : Colors.transparent,
                  border: Border.all(
                    color: isSelected
                        ? Colors.white
                        : Colors.white.withOpacity(0.3),
                    width: isSelected ? 2.5 : 1,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: SizedBox(
                    width: 28,
                    height: 28,
                    child: CustomPaint(
                      size: const Size(28, 28),
                      painter: OverlayShapePainter(
                        color: Colors.white,
                        shape: shape,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        _buildSlider(
          'Opacity',
          opacity,
          0.0,
          1.0,
          (value) => setState(() => opacity = value),
          '${(opacity * 100).toInt()}%',
        ),
        const SizedBox(height: 16),
        _buildSlider(
          'Size',
          size,
          50.0,
          300.0,
          (value) => setState(() => size = value),
          '${size.toInt()}',
        ),
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                displayValue,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: Colors.white,
            inactiveTrackColor: Colors.white.withOpacity(0.2),
            thumbColor: Colors.white,
            overlayColor: Colors.white.withOpacity(0.2),
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
          ),
          child: Slider(value: value, min: min, max: max, onChanged: onChanged),
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

class _RectangleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class _CircleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()..addOval(Rect.fromLTWH(0, 0, size.width, size.height));
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class _RoundedRectangleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()..addRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Radius.circular(size.width * 0.15),
      ),
    );
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class _TriangleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(size.width / 2, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
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
    const points = 5;

    for (int i = 0; i < points * 2; i++) {
      final angle = (i * math.pi / points) - (math.pi / 2);
      final radius = i.isEven ? outerRadius : innerRadius;
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
    final w = size.width;
    final h = size.height;

    path.moveTo(w / 2, h * 0.35);
    path.cubicTo(w / 2, h * 0.25, w * 0.4, h * 0.15, w * 0.25, h * 0.15);
    path.cubicTo(0, h * 0.15, 0, h * 0.35, 0, h * 0.35);
    path.cubicTo(0, h * 0.55, w / 2, h * 0.85, w / 2, h);
    path.cubicTo(w / 2, h * 0.85, w, h * 0.55, w, h * 0.35);
    path.cubicTo(w, h * 0.35, w, h * 0.15, w * 0.75, h * 0.15);
    path.cubicTo(w * 0.6, h * 0.15, w / 2, h * 0.25, w / 2, h * 0.35);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
