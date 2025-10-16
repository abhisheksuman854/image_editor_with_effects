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
            // Single tap to change shape
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
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Stack(
                        children: [
                          Opacity(
                            opacity: widget.layerData.opacity,
                            child: Image.memory(
                              widget.layerData.overlayImage!.bytes,
                              fit: BoxFit.cover,
                              width: widget.layerData.size,
                              height: widget.layerData.size,
                            ),
                          ),
                          if (widget.editable)
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.5),
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                        ],
                      ),
                    )
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
}