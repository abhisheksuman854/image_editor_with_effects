import 'package:flutter/material.dart';
import 'package:image_editor_with_effects/data/layer.dart';
import 'package:image_editor_with_effects/data/overlay_layer.dart';
import 'package:image_editor_with_effects/layers/background_blur_layer.dart';
import 'package:image_editor_with_effects/layers/background_layer.dart';
import 'package:image_editor_with_effects/layers/emoji_layer.dart';
import 'package:image_editor_with_effects/layers/image_layer.dart';
import 'package:image_editor_with_effects/layers/link_layer.dart';
import 'package:image_editor_with_effects/layers/overlay_widget_layer.dart';
import 'package:image_editor_with_effects/layers/text_layer.dart';

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
        if (layerItem is TextLayerData) {
          return TextLayer(
            layerData: layerItem,
            onUpdate: onUpdate,
            editable: editable,
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
            // editable: editable,
          );
        }

        // Blank layer
        return Container();
      }).toList(),
    );
  }
}