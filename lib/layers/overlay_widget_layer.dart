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
  Offset baseOffset = Offset.zero;

  @override
  void initState() {
    super.initState();
    baseOffset = widget.layerData.offset;
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.layerData.offset.dx,
      top: widget.layerData.offset.dy,
      child: GestureDetector(
        onTap: widget.editable
            ? () {
                setState(() {
                  widget.layerData.nextShape();
                });
                widget.onUpdate?.call();
              }
            : null,
        onScaleStart: widget.editable
            ? (details) {
                baseScaleFactor = widget.layerData.scale;
                baseAngle = widget.layerData.rotation;
              }
            : null,
        onScaleUpdate: widget.editable
            ? (details) {
                setState(() {
                  widget.layerData.scale = baseScaleFactor * details.scale;
                  widget.layerData.rotation = baseAngle + details.rotation;
                });
                widget.onUpdate?.call();
              }
            : null,
        onPanUpdate: widget.editable
            ? (details) {
                setState(() {
                  widget.layerData.offset = Offset(
                    widget.layerData.offset.dx + details.delta.dx,
                    widget.layerData.offset.dy + details.delta.dy,
                  );
                });
                widget.onUpdate?.call();
              }
            : null,
        child: Transform.scale(
          scale: widget.layerData.scale,
          child: Transform.rotate(
            angle: widget.layerData.rotation,
            child: SizedBox(
              width: widget.layerData.size,
              height: widget.layerData.size,
              child: CustomPaint(
                painter: OverlayShapePainter(
                  color: widget.layerData.color.withOpacity(widget.layerData.opacity),
                  shape: widget.layerData.shape,
                  // editable: widget.editable,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}