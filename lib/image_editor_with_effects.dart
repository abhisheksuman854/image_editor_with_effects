import 'dart:async';
import 'dart:math' as math;
import 'package:colorfilter_generator/colorfilter_generator.dart';
import 'package:colorfilter_generator/presets.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hand_signature/signature.dart';
import 'package:image/image.dart' as img;
import 'package:image_editor_with_effects/data/image_item.dart';
import 'package:image_editor_with_effects/data/layer.dart';
import 'package:image_editor_with_effects/data/overlay_layer.dart';
import 'package:image_editor_with_effects/layers_viewer.dart';
import 'package:image_editor_with_effects/loading_screen.dart';
import 'package:image_editor_with_effects/modules/all_emojies.dart';
import 'package:image_editor_with_effects/modules/enhanced_text_module.dart';
import 'package:image_editor_with_effects/modules/layers_overlay.dart';
import 'package:image_editor_with_effects/modules/link.dart';
import 'package:image_editor_with_effects/modules/overlay.dart';
import 'package:image_editor_with_effects/options.dart' as o;
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screenshot/screenshot.dart';

import 'modules/colors_picker.dart';

late Size viewportSize;
double viewportRatio = 1;

List<Layer> layers = [], undoLayers = [], removedLayers = [];
Map<String, String> _translations = {};

String i18n(String sourceString) =>
    _translations[sourceString.toLowerCase()] ?? sourceString;

/// Single endpoint for MultiImageEditor & SingleImageEditor
class ImageEditor extends StatelessWidget {
  final dynamic image;
  final List? images;
  final String? savePath;
  final o.OutputFormat outputFormat;

  final o.ImagePickerOption imagePickerOption;
  final o.CropOption? cropOption;
  final o.BlurOption? blurOption;
  final o.BrushOption? brushOption;
  final o.EmojiOption? emojiOption;
  final o.FiltersOption? filtersOption;
  final o.FlipOption? flipOption;
  final o.RotateOption? rotateOption;
  final o.TextOption? textOption;
  final o.OverlayOption? overlayOption;

  const ImageEditor({
    super.key,
    this.image,
    this.images,
    this.savePath,
    this.imagePickerOption = const o.ImagePickerOption(),
    this.outputFormat = o.OutputFormat.jpeg,
    this.cropOption = const o.CropOption(),
    this.blurOption = const o.BlurOption(),
    this.brushOption = const o.BrushOption(),
    this.emojiOption = const o.EmojiOption(),
    this.filtersOption = const o.FiltersOption(),
    this.flipOption = const o.FlipOption(),
    this.rotateOption = const o.RotateOption(),
    this.textOption = const o.TextOption(),
    this.overlayOption = const o.OverlayOption(),
  });

  @override
  Widget build(BuildContext context) {
    if (image == null &&
        images == null &&
        !imagePickerOption.captureFromCamera &&
        !imagePickerOption.pickFromGallery) {
      throw Exception(
        'No image to work with, provide an image or allow the image picker.',
      );
    }

    if (image != null) {
      return SingleImageEditor(
        image: image,
        savePath: savePath,
        imagePickerOption: imagePickerOption,
        outputFormat: outputFormat,
        cropOption: cropOption,
        blurOption: blurOption,
        brushOption: brushOption,
        emojiOption: emojiOption,
        filtersOption: filtersOption,
        flipOption: flipOption,
        rotateOption: rotateOption,
        textOption: textOption,
        overlayOption: overlayOption,
      );
    } else {
      return MultiImageEditor(
        images: images ?? [],
        savePath: savePath,
        imagePickerOption: imagePickerOption,
        outputFormat: outputFormat,
        cropOption: cropOption,
        blurOption: blurOption,
        brushOption: brushOption,
        emojiOption: emojiOption,
        filtersOption: filtersOption,
        flipOption: flipOption,
        rotateOption: rotateOption,
        textOption: textOption,
        overlayOption: overlayOption,
      );
    }
  }

  static void setI18n(Map<String, String> translations) {
    translations.forEach((key, value) {
      _translations[key.toLowerCase()] = value;
    });
  }

  /// Set custom theme properties default is dark theme with white text
  static ThemeData theme = ThemeData(
    scaffoldBackgroundColor: Colors.black,
    colorScheme: const ColorScheme.dark(surface: Colors.black),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.black87,
      iconTheme: IconThemeData(color: Colors.white),
      systemOverlayStyle: SystemUiOverlayStyle.light,
      toolbarTextStyle: TextStyle(color: Colors.white),
      titleTextStyle: TextStyle(color: Colors.white),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.black,
    ),
    iconTheme: const IconThemeData(color: Colors.white),
    textTheme: const TextTheme(bodyMedium: TextStyle(color: Colors.white)),
  );
}

/// Show multiple image carousel to edit multple images at one and allow more images to be added
class MultiImageEditor extends StatefulWidget {
  final List images;
  final String? savePath;
  final o.OutputFormat outputFormat;

  final o.ImagePickerOption imagePickerOption;
  final o.CropOption? cropOption;
  final o.BlurOption? blurOption;
  final o.BrushOption? brushOption;
  final o.EmojiOption? emojiOption;
  final o.FiltersOption? filtersOption;
  final o.FlipOption? flipOption;
  final o.RotateOption? rotateOption;
  final o.TextOption? textOption;
  final o.OverlayOption? overlayOption;

  const MultiImageEditor({
    super.key,
    this.images = const [],
    this.savePath,
    this.imagePickerOption = const o.ImagePickerOption(),
    this.outputFormat = o.OutputFormat.jpeg,
    this.cropOption = const o.CropOption(),
    this.blurOption = const o.BlurOption(),
    this.brushOption = const o.BrushOption(),
    this.emojiOption = const o.EmojiOption(),
    this.filtersOption = const o.FiltersOption(),
    this.flipOption = const o.FlipOption(),
    this.rotateOption = const o.RotateOption(),
    this.textOption = const o.TextOption(),
    this.overlayOption = const o.OverlayOption(),
  });

  @override
  State<MultiImageEditor> createState() => _MultiImageEditorState();
}

class _MultiImageEditorState extends State<MultiImageEditor> {
  List<ImageItem> images = [];
  PermissionStatus galleryPermission = PermissionStatus.permanentlyDenied,
      cameraPermission = PermissionStatus.permanentlyDenied;

  Future<void> checkPermissions() async {
    if (widget.imagePickerOption.pickFromGallery) {
      galleryPermission = await Permission.photos.status;
    }

    if (widget.imagePickerOption.captureFromCamera) {
      cameraPermission = await Permission.camera.status;
    }

    setState(() {});
  }

  @override
  void initState() {
    images = widget.images.map((e) => ImageItem(e)).toList();
    checkPermissions();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    viewportSize = MediaQuery.of(context).size;

    return Theme(
      data: ImageEditor.theme,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          actions: [
            const BackButton(),
            const Spacer(),
            if (images.length < widget.imagePickerOption.maxLength &&
                widget.imagePickerOption.pickFromGallery)
              Opacity(
                opacity: galleryPermission.isPermanentlyDenied ? 0.5 : 1,
                child: IconButton(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  icon: const Icon(Icons.photo),
                  onPressed: () async {
                    if (await Permission.photos.isPermanentlyDenied) {
                      await openAppSettings();
                    }

                    var selected = await imagePicker.pickMultiImage(
                      requestFullMetadata: false,
                    );

                    images.addAll(selected.map((e) => ImageItem(e)).toList());
                    setState(() {});
                  },
                ),
              ),
            if (images.length < widget.imagePickerOption.maxLength &&
                widget.imagePickerOption.captureFromCamera)
              Opacity(
                opacity: cameraPermission.isPermanentlyDenied ? 0.5 : 1,
                child: IconButton(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  icon: const Icon(Icons.camera_alt),
                  onPressed: () async {
                    if (await Permission.camera.isPermanentlyDenied) {
                      await openAppSettings();
                    }

                    var selected = await imagePicker.pickImage(
                      source: ImageSource.camera,
                    );

                    if (selected == null) return;

                    images.add(ImageItem(selected));
                    setState(() {});
                  },
                ),
              ),
            IconButton(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              icon: const Icon(Icons.check),
              onPressed: () async {
                Navigator.pop(context, images);
              },
            ),
          ],
        ),
        body: Column(
          children: [
            SizedBox(
              height: 332,
              width: double.infinity,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    const SizedBox(width: 32),
                    for (var image in images)
                      Stack(
                        children: [
                          GestureDetector(
                            onTap: () async {
                              var img = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SingleImageEditor(
                                    image: image,
                                    outputFormat: o.OutputFormat.jpeg,
                                    overlayOption: widget.overlayOption,
                                  ),
                                ),
                              );

                              if (img != null) {
                                image.load(img);
                                setState(() {});
                              }
                            },
                            child: Container(
                              margin: const EdgeInsets.only(
                                top: 32,
                                right: 32,
                                bottom: 32,
                              ),
                              width: 200,
                              height: 300,
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                border: Border.all(
                                  color: Colors.white.withAlpha(80),
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: Image.memory(
                                  image.bytes,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 36,
                            right: 36,
                            child: Container(
                              height: 32,
                              width: 32,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.black.withAlpha(60),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: IconButton(
                                iconSize: 20,
                                padding: const EdgeInsets.all(0),
                                onPressed: () {
                                  images.remove(image);
                                  setState(() {});
                                },
                                icon: const Icon(Icons.clear_outlined),
                              ),
                            ),
                          ),
                          if (widget.filtersOption != null)
                            Positioned(
                              bottom: 32,
                              left: 0,
                              child: Container(
                                height: 38,
                                width: 38,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Colors.black.withAlpha(100),
                                  borderRadius: const BorderRadius.only(
                                    topRight: Radius.circular(19),
                                  ),
                                ),
                                child: IconButton(
                                  iconSize: 20,
                                  padding: const EdgeInsets.all(0),
                                  onPressed: () async {
                                    Uint8List? editedImage =
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ImageFilters(
                                              image: image.bytes,
                                              options: widget.filtersOption,
                                            ),
                                          ),
                                        );

                                    if (editedImage != null) {
                                      image.load(editedImage);
                                    }

                                    setState(() {});
                                  },
                                  icon: const Icon(Icons.photo_filter_sharp),
                                ),
                              ),
                            ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  final imagePicker = ImagePicker();
}

/// Image editor with all option available
class SingleImageEditor extends StatefulWidget {
  final dynamic image;
  final String? savePath;
  final o.OutputFormat outputFormat;

  final o.ImagePickerOption imagePickerOption;
  final o.CropOption? cropOption;
  final o.BlurOption? blurOption;
  final o.BrushOption? brushOption;
  final o.EmojiOption? emojiOption;
  final o.FiltersOption? filtersOption;
  final o.FlipOption? flipOption;
  final o.RotateOption? rotateOption;
  final o.TextOption? textOption;
  final o.OverlayOption? overlayOption;

  const SingleImageEditor({
    super.key,
    this.image,
    this.savePath,
    this.imagePickerOption = const o.ImagePickerOption(),
    this.outputFormat = o.OutputFormat.jpeg,
    this.cropOption = const o.CropOption(),
    this.blurOption = const o.BlurOption(),
    this.brushOption = const o.BrushOption(),
    this.emojiOption = const o.EmojiOption(),
    this.filtersOption = const o.FiltersOption(),
    this.flipOption = const o.FlipOption(),
    this.rotateOption = const o.RotateOption(),
    this.textOption = const o.TextOption(),
    this.overlayOption = const o.OverlayOption(),
  });

  @override
  State<SingleImageEditor> createState() => _SingleImageEditorState();
}

class _SingleImageEditorState extends State<SingleImageEditor> {
  ImageItem currentImage = ImageItem();

  ScreenshotController screenshotController = ScreenshotController();

  PermissionStatus galleryPermission = PermissionStatus.permanentlyDenied,
      cameraPermission = PermissionStatus.permanentlyDenied;

  Future<void> checkPermissions() async {
    if (widget.imagePickerOption.pickFromGallery) {
      galleryPermission = await Permission.photos.status;
    }

    if (widget.imagePickerOption.captureFromCamera) {
      cameraPermission = await Permission.camera.status;
    }

    if (widget.imagePickerOption.pickFromGallery ||
        widget.imagePickerOption.captureFromCamera) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    // Don't clear global layers here
    // They might be needed by other instances
    super.dispose();
  }

  List<Widget> get filterActions {
    return [
      const BackButton(),
      SizedBox(
        width: MediaQuery.of(context).size.width - 48,
        child: SingleChildScrollView(
          reverse: true,
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              IconButton(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                icon: Icon(
                  Icons.undo,
                  color:
                      layers.any(
                        (element) => element.runtimeType != BackgroundLayerData,
                      )
                      ? Colors.white
                      : Colors.grey,
                ),
                onPressed:
                    layers.any(
                      (element) => element.runtimeType != BackgroundLayerData,
                    )
                    ? () {
                        if (removedLayers.isNotEmpty) {
                          layers.add(removedLayers.removeLast());
                          setState(() {});
                          return;
                        }

                        undoLayers.add(layers.removeLast());
                        setState(() {});
                      }
                    : null,
              ),
              IconButton(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                icon: Icon(
                  Icons.redo,
                  color: undoLayers.isNotEmpty ? Colors.white : Colors.grey,
                ),
                onPressed: () {
                  if (undoLayers.isEmpty) return;

                  layers.add(undoLayers.removeLast());

                  setState(() {});
                },
              ),
              if (widget.imagePickerOption.pickFromGallery)
                Opacity(
                  opacity: galleryPermission.isPermanentlyDenied ? 0.5 : 1,
                  child: IconButton(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    icon: const Icon(Icons.photo),
                    onPressed: () async {
                      if (await Permission.photos.isPermanentlyDenied) {
                        await openAppSettings();
                        return;
                      }

                      var image = await picker.pickImage(
                        source: ImageSource.gallery,
                      );

                      if (!mounted || image == null) return;

                      var imageItem = ImageItem(image);
                      await imageItem.loader.future;

                      if (!mounted) return;

                      layers.add(ImageLayerData(image: imageItem));
                      setState(() {});
                    },
                  ),
                ),
              if (widget.imagePickerOption.captureFromCamera)
                Opacity(
                  opacity: cameraPermission.isPermanentlyDenied ? 0.5 : 1,
                  child: IconButton(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    icon: const Icon(Icons.camera_alt),
                    onPressed: () async {
                      if (await Permission.camera.isPermanentlyDenied) {
                        await openAppSettings();
                      }

                      var image = await picker.pickImage(
                        source: ImageSource.camera,
                      );

                      if (image == null) return;

                      var imageItem = ImageItem(image);
                      await imageItem.loader.future;

                      if (!mounted) return;

                      layers.add(ImageLayerData(image: imageItem));
                      setState(() {});
                    },
                  ),
                ),
              IconButton(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                icon: const Icon(Icons.check),
                onPressed: () async {
                  resetTransformation();

                  // Verify we have content
                  if (layers.isEmpty || currentImage.bytes.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('No image to save')),
                    );
                    return;
                  }

                  setState(() {});
                  var loadingScreen = showLoadingScreen(context);

                  try {
                    if (widget.outputFormat == o.OutputFormat.json) {
                      var json = layers.map((e) => e.toJson()).toList();
                      loadingScreen.hide();
                      if (mounted) Navigator.pop(context, json);
                    } else {
                      var editedImageBytes = await getMergedImage(
                        widget.outputFormat,
                      );
                      loadingScreen.hide();

                      if (mounted && editedImageBytes != null) {
                        Navigator.pop(context, editedImageBytes);
                      } else {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Failed to process image'),
                            ),
                          );
                        }
                      }
                    }
                  } catch (e) {
                    loadingScreen.hide();
                    if (mounted) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('Error: $e')));
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    ];
  }

  @override
  void initState() {
    super.initState();

    // Initialize layers if empty
    if (layers.isEmpty) {
      layers = [];
      undoLayers = [];
      removedLayers = [];
    }

    if (widget.image != null) {
      loadImage(widget.image!);
    }

    checkPermissions();
  }

  void ensureBackgroundLayer() {
    // Check if there's a background layer
    bool hasBackground = layers.any((layer) => layer is BackgroundLayerData);

    // If no background and we have an image, create one
    if (!hasBackground && currentImage.bytes.isNotEmpty) {
      layers.insert(0, BackgroundLayerData(image: currentImage));
      if (mounted) {
        setState(() {});
      }
    }
  }

  double flipValue = 0;
  int rotateValue = 0;

  double x = 0;
  double y = 0;
  double z = 0;

  double lastScaleFactor = 1, scaleFactor = 1;
  double widthRatio = 1, heightRatio = 1, pixelRatio = 1;

  void resetTransformation() {
    scaleFactor = 1;
    x = 0;
    y = 0;
    setState(() {});
  }

  Future<Uint8List?> getMergedImage([
    o.OutputFormat format = o.OutputFormat.png,
  ]) async {
    Uint8List? image;

    // Check if we have layers
    if (layers.isEmpty) {
      // Fallback to current image
      return currentImage.bytes.isNotEmpty ? currentImage.bytes : null;
    }

    // If only background layer and no transformations, return original
    if (flipValue == 0 && rotateValue == 0 && layers.length == 1) {
      if (layers.first is BackgroundLayerData) {
        image = (layers.first as BackgroundLayerData).image.bytes;
      } else if (layers.first is ImageLayerData) {
        image = (layers.first as ImageLayerData).image.bytes;
      }
    } else {
      // Capture screenshot for multiple layers or transformations
      try {
        image = await screenshotController.capture(pixelRatio: pixelRatio);
      } catch (e) {
        // Fallback to background layer
        if (layers.isNotEmpty && layers.first is BackgroundLayerData) {
          image = (layers.first as BackgroundLayerData).image.bytes;
        } else {
          image = currentImage.bytes;
        }
      }
    }

    // Convert to JPEG if needed
    if (image != null && format == o.OutputFormat.jpeg) {
      var decodedImage = img.decodeImage(image);
      if (decodedImage == null) {
        throw Exception('Unable to decode image for conversion.');
      }
      return img.encodeJpg(decodedImage);
    }

    return image;
  }

  @override
  Widget build(BuildContext context) {
    viewportSize = MediaQuery.of(context).size;
    pixelRatio = MediaQuery.of(context).devicePixelRatio;
    // CRITICAL: Ensure background layer always exists
    ensureBackgroundLayer();
    return Theme(
      data: ImageEditor.theme,
      child: Scaffold(
        body: Stack(
          children: [
            GestureDetector(
              onScaleUpdate: (details) {
                if (details.pointerCount == 1) {
                  x += details.focalPointDelta.dx;
                  y += details.focalPointDelta.dy;
                  setState(() {});
                }

                if (details.pointerCount == 2) {
                  if (details.horizontalScale != 1) {
                    scaleFactor =
                        lastScaleFactor *
                        math.min(
                          details.horizontalScale,
                          details.verticalScale,
                        );
                    setState(() {});
                  }
                }
              },
              onScaleEnd: (details) {
                lastScaleFactor = scaleFactor;
              },
              child: Center(
                child: SizedBox(
                  height: currentImage.height / pixelRatio,
                  width: currentImage.width / pixelRatio,
                  child: Screenshot(
                    controller: screenshotController,
                    child: RotatedBox(
                      quarterTurns: rotateValue,
                      child: Transform(
                        transform: Matrix4(
                          1,
                          0,
                          0,
                          0,
                          0,
                          1,
                          0,
                          0,
                          0,
                          0,
                          1,
                          0,
                          x,
                          y,
                          0,
                          1 / scaleFactor,
                        )..rotateY(flipValue),
                        alignment: FractionalOffset.center,
                        child: LayersViewer(
                          layers: layers,
                          onUpdate: () {
                            setState(() {});
                          },
                          editable: true,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.25),
                ),
                child: SafeArea(child: Row(children: filterActions)),
              ),
            ),
            if (layers.length > 1)
              Positioned(
                bottom: 64,
                left: 0,
                child: SafeArea(
                  child: Container(
                    height: 48,
                    width: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(100),
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(19),
                        bottomRight: Radius.circular(19),
                      ),
                    ),
                    child: IconButton(
                      iconSize: 20,
                      padding: const EdgeInsets.all(0),
                      onPressed: () {
                        showModalBottomSheet(
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(10),
                              topLeft: Radius.circular(10),
                            ),
                          ),
                          context: context,
                          backgroundColor: Colors.transparent,
                          builder: (context) => SafeArea(
                            child: ManageLayersOverlay(
                              layers: layers,
                              onUpdate: () => setState(() {}),
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.layers),
                    ),
                  ),
                ),
              ),
            Positioned(
              bottom: 64,
              right: 0,
              child: SafeArea(
                child: Container(
                  height: 48,
                  width: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(100),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(19),
                      bottomLeft: Radius.circular(19),
                    ),
                  ),
                  child: IconButton(
                    iconSize: 20,
                    padding: const EdgeInsets.all(0),
                    onPressed: () {
                      resetTransformation();
                    },
                    icon: Icon(
                      scaleFactor > 1 ? Icons.zoom_in_map : Icons.zoom_out_map,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: Container(
          alignment: Alignment.bottomCenter,
          height: 86 + MediaQuery.of(context).padding.bottom,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: const BoxDecoration(
            color: Colors.black87,
            shape: BoxShape.rectangle,
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  if (widget.cropOption != null)
                    BottomButton(
                      icon: Icons.crop,
                      text: i18n('Crop'),
                      onTap: () async {
                        resetTransformation();
                        if (!mounted) return;

                        var loadingScreen = showLoadingScreen(context);
                        var mergedImage = await getMergedImage();

                        if (!mounted) {
                          loadingScreen.hide();
                          return;
                        }

                        loadingScreen.hide();

                        Uint8List? croppedImage = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ImageCropper(
                              image: mergedImage!,
                              reversible: widget.cropOption!.reversible,
                              availableRatios: widget.cropOption!.ratios,
                            ),
                          ),
                        );

                        if (!mounted || croppedImage == null) return;

                        flipValue = 0;
                        rotateValue = 0;

                        await currentImage.load(croppedImage);

                        if (mounted) {
                          setState(() {});
                        }
                      },
                    ),
                  if (widget.brushOption != null)
                    BottomButton(
                      icon: Icons.edit,
                      text: i18n('Brush'),
                      onTap: () async {
                        if (!mounted) return;

                        BrushLayerData? brushLayer = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ImageEditorDrawing(
                              image: currentImage,
                              options: widget.brushOption!,
                            ),
                          ),
                        );

                        if (!mounted || brushLayer == null) return;

                        undoLayers.clear();
                        removedLayers.clear();

                        layers.add(brushLayer);
                        setState(() {});
                      },
                    ),
                  if (widget.textOption != null)
                    BottomButton(
                      icon: Icons.text_fields,
                      text: i18n('Text'),
                      onTap: () async {
                        if (!mounted) return;

                        EnhancedTextLayerData? layer = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EnhancedTextEditor(
                              fontFamilies: widget.textOption!.fontFamilies,
                              textColors: widget.textOption!.textColors,
                              textGradients: widget.textOption!.textGradients,
                              backgroundGradients:
                                  widget.textOption!.backgroundGradients,
                            ),
                          ),
                        );

                        if (!mounted || layer == null) return;

                        undoLayers.clear();
                        removedLayers.clear();

                        layers.add(layer);

                        setState(() {});
                      },
                    ),
                  if (widget.textOption != null)
                    BottomButton(
                      icon: Icons.link,
                      text: i18n('Link'),
                      onTap: () async {
                        LinkLayerData? layer = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LinkEditorImage(),
                          ),
                        );

                        if (layer == null) return;

                        undoLayers.clear();
                        removedLayers.clear();

                        layers.add(layer);

                        setState(() {});
                      },
                    ),
                  if (widget.flipOption != null)
                    BottomButton(
                      icon: Icons.flip,
                      text: i18n('Flip'),
                      onTap: () {
                        setState(() {
                          flipValue = flipValue == 0 ? math.pi : 0;
                        });
                      },
                    ),
                  if (widget.rotateOption != null)
                    BottomButton(
                      icon: Icons.rotate_left,
                      text: i18n('Rotate left'),
                      onTap: () {
                        var t = currentImage.width;
                        currentImage.width = currentImage.height;
                        currentImage.height = t;

                        rotateValue--;
                        setState(() {});
                      },
                    ),
                  if (widget.rotateOption != null)
                    BottomButton(
                      icon: Icons.rotate_right,
                      text: i18n('Rotate right'),
                      onTap: () {
                        var t = currentImage.width;
                        currentImage.width = currentImage.height;
                        currentImage.height = t;

                        rotateValue++;
                        setState(() {});
                      },
                    ),
                  if (widget.blurOption != null)
                    BottomButton(
                      icon: Icons.blur_on,
                      text: i18n('Blur'),
                      onTap: () {
                        var blurLayer = BackgroundBlurLayerData(
                          color: Colors.transparent,
                          radius: 0.0,
                          opacity: 0.0,
                        );

                        undoLayers.clear();
                        removedLayers.clear();
                        layers.add(blurLayer);
                        setState(() {});

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
                            return StatefulBuilder(
                              builder: (context, setS) {
                                return SingleChildScrollView(
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: Colors.black87,
                                      borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(10),
                                        topLeft: Radius.circular(10),
                                      ),
                                    ),
                                    padding: const EdgeInsets.all(20),
                                    height: 400,
                                    child: Column(
                                      children: [
                                        Center(
                                          child: Text(
                                            i18n(
                                              'Slider Filter Color',
                                            ).toUpperCase(),
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 20.0),
                                        Text(
                                          i18n('Slider Color'),
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: BarColorPicker(
                                                width: 300,
                                                thumbColor: Colors.white,
                                                cornerRadius: 10,
                                                pickMode: PickMode.color,
                                                colorListener: (int value) {
                                                  setS(() {
                                                    setState(() {
                                                      blurLayer.color = Color(
                                                        value,
                                                      );
                                                    });
                                                  });
                                                },
                                              ),
                                            ),
                                            TextButton(
                                              child: Text(i18n('Reset')),
                                              onPressed: () {
                                                setState(() {
                                                  setS(() {
                                                    blurLayer.color =
                                                        Colors.transparent;
                                                  });
                                                });
                                              },
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 5.0),
                                        Text(
                                          i18n('Blur Radius'),
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 10.0),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Slider(
                                                activeColor: Colors.white,
                                                inactiveColor: Colors.grey,
                                                value: blurLayer.radius,
                                                min: 0.0,
                                                max: 10.0,
                                                onChanged: (v) {
                                                  setS(() {
                                                    setState(() {
                                                      blurLayer.radius = v;
                                                    });
                                                  });
                                                },
                                              ),
                                            ),
                                            TextButton(
                                              child: Text(i18n('Reset')),
                                              onPressed: () {
                                                setS(() {
                                                  setState(() {
                                                    blurLayer.color =
                                                        Colors.white;
                                                  });
                                                });
                                              },
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 5.0),
                                        Text(
                                          i18n('Color Opacity'),
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 10.0),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Slider(
                                                activeColor: Colors.white,
                                                inactiveColor: Colors.grey,
                                                value: blurLayer.opacity,
                                                min: 0.00,
                                                max: 1.0,
                                                onChanged: (v) {
                                                  setS(() {
                                                    setState(() {
                                                      blurLayer.opacity = v;
                                                    });
                                                  });
                                                },
                                              ),
                                            ),
                                            TextButton(
                                              child: Text(i18n('Reset')),
                                              onPressed: () {
                                                setS(() {
                                                  setState(() {
                                                    blurLayer.opacity = 0.0;
                                                  });
                                                });
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  if (widget.filtersOption != null)
                    BottomButton(
                      icon: Icons.color_lens,
                      text: i18n('Filter'),
                      onTap: () async {
                        resetTransformation();
                        if (!mounted) return;

                        var loadingScreen = showLoadingScreen(context);
                        var mergedImage = await getMergedImage();

                        if (!mounted) {
                          loadingScreen.hide();
                          return;
                        }

                        loadingScreen.hide();

                        Uint8List? filterAppliedImage = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ImageFilters(
                              image: mergedImage!,
                              options: widget.filtersOption,
                            ),
                          ),
                        );

                        if (!mounted || filterAppliedImage == null) return;

                        removedLayers.clear();
                        undoLayers.clear();

                        var layer = BackgroundLayerData(
                          image: ImageItem(filterAppliedImage),
                        );

                        layers.add(layer);
                        await layer.image.loader.future;

                        if (mounted) {
                          setState(() {});
                        }
                      },
                    ),
                  if (widget.emojiOption != null)
                    BottomButton(
                      icon: FontAwesomeIcons.faceSmile,
                      text: i18n('Emoji'),
                      onTap: () async {
                        EmojiLayerData? layer = await showModalBottomSheet(
                          context: context,
                          backgroundColor: Colors.black,
                          builder: (BuildContext context) {
                            return const Emojies();
                          },
                        );

                        if (layer == null) return;

                        undoLayers.clear();
                        removedLayers.clear();
                        layers.add(layer);

                        setState(() {});
                      },
                    ),
                  if (widget.overlayOption != null)
                    BottomButton(
                      icon: Icons.category,
                      text: i18n('Overlay'),
                      onTap: () async {
                        OverlayLayerData? layer = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const OverlayEditorImage(),
                          ),
                        );

                        if (layer == null) return;

                        undoLayers.clear();
                        removedLayers.clear();

                        layers.add(layer);

                        setState(() {});
                      },
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  final picker = ImagePicker();

  Future<void> loadImage(dynamic imageFile) async {
    // Clear existing layers FIRST
    layers.clear();
    undoLayers.clear();
    removedLayers.clear();

    // Load the image
    await currentImage.load(imageFile);

    // CRITICAL: Always create background layer immediately
    layers.add(BackgroundLayerData(image: currentImage));

    // Force UI update
    if (mounted) {
      setState(() {});
    }
  }
}

/// Button used in bottomNavigationBar in ImageEditor
class BottomButton extends StatelessWidget {
  final VoidCallback? onTap, onLongPress;
  final IconData icon;
  final String text;

  const BottomButton({
    super.key,
    this.onTap,
    this.onLongPress,
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(height: 8),
            Text(i18n(text)),
          ],
        ),
      ),
    );
  }
}

/// Crop given image with various aspect ratios
class ImageCropper extends StatefulWidget {
  final Uint8List image;
  final List<o.AspectRatio> availableRatios;
  final bool reversible;

  const ImageCropper({
    super.key,
    required this.image,
    this.reversible = true,
    this.availableRatios = const [
      o.AspectRatio(title: 'Freeform'),
      o.AspectRatio(title: '1:1', ratio: 1),
      o.AspectRatio(title: '4:3', ratio: 4 / 3),
      o.AspectRatio(title: '5:4', ratio: 5 / 4),
      o.AspectRatio(title: '7:5', ratio: 7 / 5),
      o.AspectRatio(title: '16:9', ratio: 16 / 9),
    ],
  });

  @override
  State<ImageCropper> createState() => _ImageCropperState();
}

class _ImageCropperState extends State<ImageCropper> {
  final _controller = GlobalKey<ExtendedImageEditorState>();

  double? currentRatio;
  bool get isLandscape => currentRatio != null && currentRatio! > 1;
  int rotateAngle = 0;

  @override
  void initState() {
    if (widget.availableRatios.isNotEmpty) {
      currentRatio = widget.availableRatios.first.ratio;
    }
    _controller.currentState?.rotate(degree: 90);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller.currentState != null) {
      // _controller.currentState?.
    }

    return Theme(
      data: ImageEditor.theme,
      child: Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              icon: const Icon(Icons.check),
              onPressed: () async {
                var state = _controller.currentState;

                if (state == null || state.getCropRect() == null) {
                  Navigator.pop(context);
                }

                var data = await cropImageWithThread(
                  imageBytes: state!.rawImageData,
                  rect: state.getCropRect()!,
                );

                if (mounted) Navigator.pop(context, data);
              },
            ),
          ],
        ),
        body: Container(
          color: Colors.black,
          child: ExtendedImage.memory(
            widget.image,
            cacheRawData: true,
            fit: BoxFit.contain,
            extendedImageEditorKey: _controller,
            mode: ExtendedImageMode.editor,
            initEditorConfigHandler: (state) {
              return EditorConfig(cropAspectRatio: currentRatio);
            },
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: SizedBox(
            height: 80,
            child: Column(
              children: [
                Container(
                  height: 80,
                  decoration: const BoxDecoration(
                    boxShadow: [BoxShadow(color: Colors.black, blurRadius: 10)],
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        if (widget.reversible &&
                            currentRatio != null &&
                            currentRatio != 1)
                          IconButton(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            icon: Icon(
                              Icons.portrait,
                              color: isLandscape ? Colors.grey : Colors.white,
                            ),
                            onPressed: () {
                              currentRatio = 1 / currentRatio!;

                              setState(() {});
                            },
                          ),
                        if (widget.reversible &&
                            currentRatio != null &&
                            currentRatio != 1)
                          IconButton(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            icon: Icon(
                              Icons.landscape,
                              color: isLandscape ? Colors.white : Colors.grey,
                            ),
                            onPressed: () {
                              currentRatio = 1 / currentRatio!;

                              setState(() {});
                            },
                          ),
                        for (var ratio in widget.availableRatios)
                          TextButton(
                            onPressed: () {
                              currentRatio = ratio.ratio;

                              setState(() {});
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              child: Text(
                                i18n(ratio.title),
                                style: TextStyle(
                                  color: currentRatio == ratio.ratio
                                      ? Colors.white
                                      : Colors.grey,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<Uint8List?> cropImageWithThread({
    required Uint8List imageBytes,
    required Rect rect,
  }) async {
    img.Command cropTask = img.Command();
    cropTask.decodeImage(imageBytes);

    cropTask.copyCrop(
      x: rect.topLeft.dx.ceil(),
      y: rect.topLeft.dy.ceil(),
      height: rect.height.ceil(),
      width: rect.width.ceil(),
    );

    img.Command encodeTask = img.Command();
    encodeTask.subCommand = cropTask;
    encodeTask.encodeJpg();

    return encodeTask.getBytesThread();
  }
}

/// Return filter applied Uint8List image
class ImageFilters extends StatefulWidget {
  final Uint8List image;

  /// apply each filter to given image in background and cache it to improve UX
  final bool useCache;
  final o.FiltersOption? options;

  const ImageFilters({
    super.key,
    required this.image,
    this.useCache = true,
    this.options,
  });

  @override
  State<ImageFilters> createState() => _ImageFiltersState();
}

class _ImageFiltersState extends State<ImageFilters> {
  late img.Image decodedImage;
  ColorFilterGenerator selectedFilter = PresetFilters.none;
  Uint8List resizedImage = Uint8List.fromList([]);
  double filterOpacity = 1;
  Uint8List? filterAppliedImage;
  ScreenshotController screenshotController = ScreenshotController();
  late List<ColorFilterGenerator> filters;

  @override
  void initState() {
    filters = [
      PresetFilters.none,
      ...(widget.options?.filters ?? presetFiltersList.sublist(1)),
    ];

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ImageEditor.theme,
      child: Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              icon: const Icon(Icons.check),
              onPressed: () async {
                var loadingScreen = showLoadingScreen(context);
                var data = await screenshotController.capture();
                loadingScreen.hide();

                if (mounted) Navigator.pop(context, data);
              },
            ),
          ],
        ),
        body: Center(
          child: Screenshot(
            controller: screenshotController,
            child: Stack(
              children: [
                Image.memory(widget.image, fit: BoxFit.cover),
                FilterAppliedImage(
                  key: Key('selectedFilter:${selectedFilter.name}'),
                  image: widget.image,
                  filter: selectedFilter,
                  fit: BoxFit.cover,
                  opacity: filterOpacity,
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: SizedBox(
            height: 160,
            child: Column(
              children: [
                SizedBox(
                  height: 40,
                  child: selectedFilter == PresetFilters.none
                      ? Container()
                      : selectedFilter.build(
                          Slider(
                            min: 0,
                            max: 1,
                            divisions: 100,
                            value: filterOpacity,
                            onChanged: (value) {
                              filterOpacity = value;
                              setState(() {});
                            },
                          ),
                        ),
                ),
                SizedBox(
                  height: 120,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      for (var filter in filters)
                        GestureDetector(
                          onTap: () {
                            selectedFilter = filter;
                            setState(() {});
                          },
                          child: Column(
                            children: [
                              Container(
                                height: 64,
                                width: 64,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(48),
                                  border: Border.all(
                                    color: selectedFilter == filter
                                        ? Colors.white
                                        : Colors.black,
                                    width: 2,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(48),
                                  child: FilterAppliedImage(
                                    key: Key(
                                      'filterPreviewButton:${filter.name}',
                                    ),
                                    image: widget.image,
                                    filter: filter,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Text(
                                i18n(filter.name),
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FilterAppliedImage extends StatefulWidget {
  final Uint8List image;
  final ColorFilterGenerator filter;
  final BoxFit? fit;
  final Function(Uint8List)? onProcess;
  final double opacity;

  const FilterAppliedImage({
    super.key,
    required this.image,
    required this.filter,
    this.fit,
    this.onProcess,
    this.opacity = 1,
  });

  @override
  State<FilterAppliedImage> createState() => _FilterAppliedImageState();
}

class _FilterAppliedImageState extends State<FilterAppliedImage> {
  @override
  void initState() {
    super.initState();

    if (widget.onProcess != null) {
      if (widget.filter.filters.isEmpty) {
        widget.onProcess!(widget.image);
        return;
      }

      var filterTask = img.Command();
      filterTask.decodeImage(widget.image);

      var matrix = widget.filter.matrix;

      filterTask.filter((image) {
        for (final pixel in image) {
          pixel.r =
              matrix[0] * pixel.r +
              matrix[1] * pixel.g +
              matrix[2] * pixel.b +
              matrix[3] * pixel.a +
              matrix[4];

          pixel.g =
              matrix[5] * pixel.r +
              matrix[6] * pixel.g +
              matrix[7] * pixel.b +
              matrix[8] * pixel.a +
              matrix[9];

          pixel.b =
              matrix[10] * pixel.r +
              matrix[11] * pixel.g +
              matrix[12] * pixel.b +
              matrix[13] * pixel.a +
              matrix[14];

          pixel.a =
              matrix[15] * pixel.r +
              matrix[16] * pixel.g +
              matrix[17] * pixel.b +
              matrix[18] * pixel.a +
              matrix[19];
        }

        return image;
      });

      filterTask
          .getBytesThread()
          .then((result) {
            if (widget.onProcess != null && result != null) {
              widget.onProcess!(result);
            }
          })
          .catchError((err, stack) {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.filter.filters.isEmpty) {
      return Image.memory(widget.image, fit: widget.fit);
    }

    return Opacity(
      opacity: widget.opacity,
      child: widget.filter.build(Image.memory(widget.image, fit: widget.fit)),
    );
  }
}

/// Show image drawing surface over image
class ImageEditorDrawing extends StatefulWidget {
  final ImageItem image;
  final o.BrushOption options;

  const ImageEditorDrawing({
    super.key,
    required this.image,
    this.options = const o.BrushOption(
      showBackground: true,
      translatable: true,
    ),
  });

  @override
  State<ImageEditorDrawing> createState() => _ImageEditorDrawingState();
}

class _ImageEditorDrawingState extends State<ImageEditorDrawing> {
  Color currentColor = Colors.white;
  Color currentBackgroundColor = Colors.black;

  final control = HandSignatureControl(
    initialSetup: const SignaturePathSetup(
      threshold: 3.0,
      smoothRatio: 0.65,
      velocityRange: 2.0,
    ),
  );

  List<CubicPath> undoList = [];
  bool skipNextEvent = false;

  void changeColor(o.BrushColor color) {
    currentColor = color.color;
    currentBackgroundColor = color.background;
    setState(() {});
  }

  @override
  void initState() {
    control.addListener(() {
      if (control.hasActivePath) return;

      if (skipNextEvent) {
        skipNextEvent = false;
        return;
      }

      undoList = [];
      if (mounted) {
        setState(() {});
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    control.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ImageEditor.theme,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              icon: const Icon(Icons.clear),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            const Spacer(),
            IconButton(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              icon: Icon(
                Icons.undo,
                color: control.paths.isNotEmpty
                    ? Colors.white
                    : Colors.white.withAlpha(80),
              ),
              onPressed: () {
                if (control.paths.isEmpty) return;
                skipNextEvent = true;
                undoList.add(control.paths.last);
                control.stepBack();
                if (mounted) {
                  setState(() {});
                }
              },
            ),
            IconButton(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              icon: Icon(
                Icons.redo,
                color: undoList.isNotEmpty
                    ? Colors.white
                    : Colors.white.withAlpha(80),
              ),
              onPressed: () {
                if (undoList.isEmpty) return;
                control.paths.add(undoList.removeLast());
                if (mounted) {
                  setState(() {});
                }
              },
            ),
            IconButton(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              icon: const Icon(Icons.check),
              onPressed: () {
                // If no drawing, just go back
                if (control.paths.isEmpty) {
                  Navigator.pop(context);
                  return;
                }

                // Create a brush layer with the current paths
                final brushLayer = BrushLayerData(
                  paths: List.from(control.paths),
                  color: currentColor,
                  strokeWidth: 1.0,
                  maxWidth: 7.0,
                  offset: Offset.zero,
                );

                Navigator.pop(context, brushLayer);
              },
            ),
          ],
        ),
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: widget.options.showBackground
                ? null
                : currentBackgroundColor,
            image: widget.options.showBackground
                ? DecorationImage(
                    image: Image.memory(widget.image.bytes).image,
                    fit: BoxFit.contain,
                  )
                : null,
          ),
          child: HandSignature(
            control: control,
            drawer: ShapeSignatureDrawer(
              color: currentColor,
              width: 1.0,
              maxWidth: 7.0,
            ),
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Container(
            height: 80,
            decoration: const BoxDecoration(
              boxShadow: [BoxShadow(blurRadius: 2)],
            ),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: <Widget>[
                ColorButton(
                  color: Colors.yellow,
                  onTap: (color) {
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
                        return Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(
                                MediaQuery.of(context).size.width / 2,
                              ),
                              topRight: Radius.circular(
                                MediaQuery.of(context).size.width / 2,
                              ),
                            ),
                          ),
                          child: SingleChildScrollView(
                            child: ColorPicker(
                              wheelDiameter:
                                  MediaQuery.of(context).size.width - 64,
                              color: currentColor,
                              pickersEnabled: const {
                                ColorPickerType.both: false,
                                ColorPickerType.primary: false,
                                ColorPickerType.accent: false,
                                ColorPickerType.bw: false,
                                ColorPickerType.custom: false,
                                ColorPickerType.customSecondary: false,
                                ColorPickerType.wheel: true,
                              },
                              enableShadesSelection: false,
                              onColorChanged: (color) {
                                currentColor = color;
                                if (mounted) {
                                  setState(() {});
                                }
                              },
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
                for (var color in widget.options.colors)
                  ColorButton(
                    color: color.color,
                    onTap: (color) {
                      currentColor = color;
                      if (mounted) {
                        setState(() {});
                      }
                    },
                    isSelected: color.color == currentColor,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Button used in bottomNavigationBar in ImageEditorDrawing
class ColorButton extends StatelessWidget {
  final Color color;
  final Function(Color) onTap;
  final bool isSelected;

  const ColorButton({
    super.key,
    required this.color,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onTap(color);
      },
      child: Container(
        height: 34,
        width: 34,
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 23),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.white54,
            width: isSelected ? 3 : 1,
          ),
        ),
      ),
    );
  }
}
