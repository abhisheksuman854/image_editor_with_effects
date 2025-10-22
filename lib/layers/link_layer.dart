import 'package:flutter/material.dart';
import 'package:image_editor_with_effects/data/layer.dart';
import 'package:image_editor_with_effects/image_editor_with_effects.dart';
import 'package:image_editor_with_effects/modules/link_layer_overlay.dart';


/// Link layer
class LinkLayer extends StatefulWidget {
  final LinkLayerData layerData;
  final VoidCallback? onUpdate;
  final bool editable;

  const LinkLayer({
    super.key,
    required this.layerData,
    this.editable = false,
    this.onUpdate,
  });

  @override
  _TextViewState createState() => _TextViewState();
}

class _TextViewState extends State<LinkLayer> {
  double initialSize = 0;
  double initialRotation = 0;
  Offset initialFocalPoint = Offset.zero;

  @override
  Widget build(BuildContext context) {
    // Get screen/canvas dimensions
    final screenSize = MediaQuery.of(context).size;
    final maxWidth = screenSize.width;
    final maxHeight = screenSize.height;

    return Positioned(
      left: widget.layerData.offset.dx,
      top: widget.layerData.offset.dy,
      child: GestureDetector(
        onTap: widget.editable
            ? () {
                showModalBottomSheet(
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(10),
                      topLeft: Radius.circular(10),
                    ),
                  ),
                  context: context,
                  backgroundColor: Colors.transparent,
                  builder: (context) {
                    return LinkLayerOverlay(
                      index: layers.indexOf(widget.layerData),
                      layer: widget.layerData,
                      onUpdate: () {
                        if (widget.onUpdate != null) widget.onUpdate!();
                        setState(() {});
                      },
                    );
                  },
                );
              }
            : null,
        onScaleStart: widget.editable
            ? (details) {
                initialSize = widget.layerData.size;
                initialRotation = widget.layerData.rotation;
                initialFocalPoint = details.focalPoint;
              }
            : null,
        onScaleUpdate: widget.editable
            ? (detail) {
                if (detail.pointerCount == 1) {
                  // Move with boundary constraints
                  double newX =
                      widget.layerData.offset.dx + detail.focalPointDelta.dx;
                  double newY =
                      widget.layerData.offset.dy + detail.focalPointDelta.dy;

                  // Constrain within bounds (with some padding for the layer size)
                  final padding =
                      widget.layerData.size + 64; // 64 is the container padding
                  newX = newX.clamp(-padding, maxWidth - padding);
                  newY = newY.clamp(-padding, maxHeight - padding);

                  widget.layerData.offset = Offset(newX, newY);
                } else if (detail.pointerCount == 2) {
                  // Scale (smooth zoom)
                  widget.layerData.size = (initialSize * detail.scale).clamp(
                    10.0,
                    200.0,
                  );

                  // Rotate (smooth rotation)
                  widget.layerData.rotation = initialRotation + detail.rotation;
                }

                if (widget.onUpdate != null) widget.onUpdate!();
                setState(() {});
              }
            : null,
        child: Transform.rotate(
          angle: widget.layerData.rotation,
          alignment: Alignment.center,
          child: Container(
            padding: const EdgeInsets.all(64),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: widget.layerData.background.withOpacity(
                  widget.layerData.backgroundOpacity,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Transform.rotate(
                    angle: -0.4,
                    child: Icon(
                      Icons.link,
                      color: widget.layerData.color,
                      size: widget.layerData.size,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.layerData.text.toString(),
                    textAlign: widget.layerData.align,
                    style: TextStyle(
                      color: widget.layerData.color,
                      fontSize: widget.layerData.size,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
