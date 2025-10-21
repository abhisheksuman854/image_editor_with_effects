import 'package:flutter/material.dart';
import 'package:image_editor_with_effects/data/layer.dart';
import 'package:image_editor_with_effects/data/overlay_layer.dart';
import 'package:image_editor_with_effects/layers/background_blur_layer.dart';
import 'package:image_editor_with_effects/layers/background_layer.dart';
import 'package:image_editor_with_effects/layers/emoji_layer.dart';
import 'package:image_editor_with_effects/layers/image_layer.dart';
import 'package:image_editor_with_effects/layers/link_layer.dart';
import 'package:image_editor_with_effects/layers/overlay_layer.dart';
import 'package:image_editor_with_effects/modules/enhanced_text_module.dart';

/// View stacked layers (unbounded height, width)
class LayersViewer extends StatelessWidget {
  final List<Layer> layers;
  final Function()? onUpdate;
  final bool editable;

  const LayersViewer({
    super.key,
    required this.layers,
    required this.editable,
    this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: layers.map((layerItem) {
        // Background layer
        if (layerItem is BackgroundLayerData) {
          return BackgroundLayer(
            layerData: layerItem,
            onUpdate: onUpdate,
            editable: editable,
          );
        }

        // Image layer
        if (layerItem is ImageLayerData) {
          return ImageLayer(
            layerData: layerItem,
            onUpdate: onUpdate,
            editable: editable,
          );
        }

        // Background blur layer
        if (layerItem is BackgroundBlurLayerData && layerItem.radius > 0) {
          return BackgroundBlurLayer(
            layerData: layerItem,
            onUpdate: onUpdate,
            editable: editable,
          );
        }

        // Emoji layer
        if (layerItem is EmojiLayerData) {
          return EmojiLayer(
            layerData: layerItem,
            onUpdate: onUpdate,
            editable: editable,
          );
        }

        // Text layer
        if (layerItem is EnhancedTextLayerData) {
  return EnhancedTextLayer(
    key: ValueKey('enhanced_text_${layers.indexOf(layerItem)}'),
    layerData: layerItem,
    editable: editable,
    onUpdate: onUpdate,
  );
}

        // Link layer
        if (layerItem is LinkLayerData) {
          return LinkLayer(
            layerData: layerItem,
            onUpdate: onUpdate,
            editable: editable,
          );
        }

        // Overlay layer
        if (layerItem is OverlayLayerData) {
          return OverlayLayer(
            layerData: layerItem,
            onUpdate: onUpdate,
            editable: editable,
          );
        } else if (layerItem is BrushLayerData) {
          // Render brush layer
          return CustomPaint(
            painter: BrushPainter(
              paths: layerItem.paths,
              color: layerItem.color,
              strokeWidth: layerItem.strokeWidth,
              maxWidth: layerItem.maxWidth,
            ),
            size: Size.infinite,
            child: Container(), // Empty container to provide size
          );
        }

        // Blank layer
        return Container();
      }).toList(),
    );
  }
}
