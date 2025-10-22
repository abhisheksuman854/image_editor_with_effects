import 'package:flutter/material.dart';
import 'package:image_editor_with_effects/data/layer.dart';
import 'package:image_editor_with_effects/data/overlay_layer.dart';
import 'package:image_editor_with_effects/modules/emoji_layer_overlay.dart';
import 'package:image_editor_with_effects/modules/enhanced_text_module.dart';
import 'package:image_editor_with_effects/modules/image_layer_overlay.dart';
import 'package:image_editor_with_effects/modules/overlay_layer_overlay.dart';
import 'package:image_editor_with_effects/modules/text_layer_overlay.dart';
import 'package:reorderables/reorderables.dart';

class ManageLayersOverlay extends StatefulWidget {
  final List<Layer> layers;
  final Function onUpdate;

  const ManageLayersOverlay({
    super.key,
    required this.layers,
    required this.onUpdate,
  });

  @override
  State<ManageLayersOverlay> createState() => _ManageLayersOverlayState();
}

class _ManageLayersOverlayState extends State<ManageLayersOverlay> {
  var scrollController = ScrollController();

  // Helper method to build layer preview
  Widget _buildLayerPreview(Layer layer) {
    if (layer is LinkLayerData) {
      return const Icon(Icons.link, size: 32, color: Colors.white);
    } else if (layer is TextLayerData || layer is EnhancedTextLayerData) {
      return const Text(
        'T',
        style: TextStyle(
          fontSize: 32,
          color: Colors.white,
          fontWeight: FontWeight.w100,
        ),
      );
    } else if (layer is EmojiLayerData) {
      return Text(
        layer.text,
        style: const TextStyle(
          fontSize: 32,
          color: Colors.white,
          fontWeight: FontWeight.w100,
        ),
      );
    } else if (layer is ImageLayerData) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.memory(
          layer.image.bytes,
          fit: BoxFit.cover,
          width: 40,
          height: 40,
        ),
      );
    } else if (layer is BackgroundLayerData) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.memory(
          layer.image.bytes,
          fit: BoxFit.cover,
          width: 40,
          height: 40,
        ),
      );
    } else if (layer is OverlayLayerData) {
      if (layer.overlayImage != null &&
          layer.overlayType == OverlayType.image) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.memory(
            layer.overlayImage!.bytes,
            fit: BoxFit.cover,
            width: 40,
            height: 40,
          ),
        );
      } else {
        // Fallback icon if no image
        return const Icon(Icons.category, size: 32, color: Colors.white);
      }
    } else if (layer is BrushLayerData) {
      return const Icon(Icons.edit, size: 32, color: Colors.white);
    } else if (layer is BackgroundBlurLayerData) {
      return const Icon(Icons.blur_on, size: 32, color: Colors.white);
    } else {
      return const Text('', style: TextStyle(color: Colors.white));
    }
  }

  // Helper method to build layer title
  Widget _buildLayerTitle(Layer layer) {
    if (layer is LinkLayerData) {
      return Text(
        layer.text,
        style: const TextStyle(color: Colors.white),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    } else if (layer is TextLayerData) {
      return Text(
        layer.text,
        style: const TextStyle(color: Colors.white),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    } else if (layer is EmojiLayerData) {
      return Text(
        'Emoji: ${layer.text}',
        style: const TextStyle(color: Colors.white),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    } else if (layer is OverlayLayerData) {
      return const Text(
        'Overlay Layer',
        style: TextStyle(color: Colors.white),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    } else if (layer is BrushLayerData) {
      return const Text(
        'Brush Layer',
        style: TextStyle(color: Colors.white),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    } else if (layer is BackgroundBlurLayerData) {
      return const Text(
        'Blur Layer',
        style: TextStyle(color: Colors.white),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    } else {
      return Text(
        layer.runtimeType.toString(),
        style: const TextStyle(color: Colors.white),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 450,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: const BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(10),
          topLeft: Radius.circular(10),
        ),
      ),
      child: ReorderableColumn(
        onReorder: (oldIndex, newIndex) {
          var oi = widget.layers.length - 1 - oldIndex,
              ni = widget.layers.length - 1 - newIndex;

          // skip main layer
          if (oi == 0 || ni == 0) {
            return;
          }

          widget.layers.insert(ni, widget.layers.removeAt(oi));
          widget.onUpdate();
          setState(() {});
        },
        draggedItemBuilder: (context, index) {
          var layer = widget.layers[widget.layers.length - 1 - index];

          return Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xff111111),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 64,
                  height: 64,
                  child: Center(child: _buildLayerPreview(layer)),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width - 92 - 64,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [_buildLayerTitle(layer)],
                  ),
                ),
                if (layer is! BackgroundLayerData)
                  IconButton(
                    onPressed: () {
                      widget.layers.remove(layer);
                      widget.onUpdate();
                      setState(() {});
                    },
                    icon: const Icon(Icons.delete, size: 22, color: Colors.red),
                  ),
              ],
            ),
          );
        },
        children: [
          for (var layer in widget.layers.reversed)
            if (!(layer is BackgroundLayerData &&
                widget.layers.indexOf(layer) != 0))
              GestureDetector(
                key: Key(
                  '${widget.layers.indexOf(layer)}:${layer.runtimeType}',
                ),
                onTap: () {
                  if (layer is BackgroundLayerData || layer is BrushLayerData) {
                    return;
                  }

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
                      if (layer is EmojiLayerData) {
                        return EmojiLayerOverlay(
                          index: widget.layers.indexOf(layer),
                          layer: layer,
                          onUpdate: () {
                            widget.onUpdate();
                            setState(() {});
                          },
                        );
                      }

                      if (layer is ImageLayerData) {
                        return ImageLayerOverlay(
                          index: widget.layers.indexOf(layer),
                          layerData: layer,
                          onUpdate: () {
                            widget.onUpdate();
                            setState(() {});
                          },
                        );
                      }

                      if (layer is TextLayerData) {
                        return TextLayerOverlay(
                          index: widget.layers.indexOf(layer),
                          layer: layer,
                          onUpdate: () {
                            widget.onUpdate();
                            setState(() {});
                          },
                        );
                      }

                      // Add overlay layer editing if you have an overlay editor
                      if (layer is OverlayLayerData) {
                        return OverlayLayerOverlay(
                          index: widget.layers.indexOf(layer),
                          layerData: layer,
                          onUpdate: () {
                            widget.onUpdate();
                            setState(() {});
                          },
                        );
                      }

                      return Container();
                    },
                  );
                },
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 64,
                        height: 64,
                        child: Center(child: _buildLayerPreview(layer)),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width - 92 - 64,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [_buildLayerTitle(layer)],
                        ),
                      ),
                      if (layer is! BackgroundLayerData)
                        IconButton(
                          onPressed: () {
                            widget.layers.remove(layer);
                            widget.onUpdate();
                            setState(() {});
                          },
                          icon: const Icon(
                            Icons.delete,
                            size: 22,
                            color: Colors.red,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }
}
