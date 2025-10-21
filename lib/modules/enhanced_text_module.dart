// ============================================
// File: lib/modules/enhanced_text_module.dart
// Complete enhanced text editor implementation
// ============================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_editor_with_effects/data/layer.dart';
import 'package:image_editor_with_effects/image_editor_with_effects.dart';

// ============ Enhanced Text Layer Data ============
class EnhancedTextLayerData extends Layer {
  String text;
  Color color;
  double size;
  TextAlign align;
  Color background;
  double backgroundOpacity;
  Offset offset;
  double rotation;
  String fontFamily;
  Gradient? textGradient;
  Gradient? backgroundGradient;
  String? animation;
  double animationDuration;
  FontWeight fontWeight;
  bool isItalic;
  
  EnhancedTextLayerData({
    required this.text,
    this.color = Colors.white,
    this.size = 32.0,
    this.align = TextAlign.center,
    this.background = Colors.transparent,
    this.backgroundOpacity = 0.0,
    this.offset = Offset.zero,
    this.rotation = 0.0,
    this.fontFamily = 'Roboto',
    this.textGradient,
    this.backgroundGradient,
    this.animation,
    this.animationDuration = 1.0,
    this.fontWeight = FontWeight.normal,
    this.isItalic = false,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'enhanced_text',
      'text': text,
      'color': color.value,
      'size': size,
      'align': align.index,
      'background': background.value,
      'backgroundOpacity': backgroundOpacity,
      'offset': {'dx': offset.dx, 'dy': offset.dy},
      'rotation': rotation,
      'fontFamily': fontFamily,
      'animation': animation,
      'animationDuration': animationDuration,
      'fontWeight': fontWeight.index,
      'isItalic': isItalic,
    };
  }
}

// ============ Enhanced Text Editor Screen ============
class EnhancedTextEditor extends StatefulWidget {
  final List<String> fontFamilies;
  final List<Color> textColors;
  final List<Gradient> textGradients;
  final List<Gradient> backgroundGradients;

  const EnhancedTextEditor({
    super.key,
    this.fontFamilies = const [
      'Roboto',
      'Pacifico',
      'Dancing Script',
      'Bebas Neue',
      'Lobster',
      'Anton',
      'Indie Flower',
      'Permanent Marker',
    ],
    this.textColors = const [
      Colors.white,
      Colors.black,
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.purple,
      Colors.orange,
    ],
    this.textGradients = const [],
    this.backgroundGradients = const [],
  });

  @override
  createState() => _EnhancedTextEditorState();
}

class _EnhancedTextEditorState extends State<EnhancedTextEditor> {
  final TextEditingController _controller = TextEditingController();
  Color currentColor = Colors.white;
  Color currentBackgroundColor = Colors.transparent;
  double currentSize = 32.0;
  TextAlign currentAlign = TextAlign.center;
  String currentFont = 'Roboto';
  Gradient? currentTextGradient;
  Gradient? currentBackgroundGradient;
  FontWeight currentWeight = FontWeight.normal;
  bool isItalic = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  TextStyle _getTextStyle() {
    TextStyle baseStyle;
    
    try {
      baseStyle = GoogleFonts.getFont(
        currentFont,
        fontSize: currentSize,
        color: currentTextGradient != null ? Colors.white : currentColor,
        fontWeight: currentWeight,
        fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
      );
    } catch (e) {
      baseStyle = TextStyle(
        fontFamily: currentFont,
        fontSize: currentSize,
        color: currentTextGradient != null ? Colors.white : currentColor,
        fontWeight: currentWeight,
        fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
      );
    }
    
    return baseStyle;
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark(),
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black87,
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('Add Text'),
          actions: [
            // Text Alignment
            IconButton(
              icon: const Icon(Icons.format_align_left),
              color: currentAlign == TextAlign.left ? Colors.white : Colors.grey,
              onPressed: () => setState(() => currentAlign = TextAlign.left),
            ),
            IconButton(
              icon: const Icon(Icons.format_align_center),
              color: currentAlign == TextAlign.center ? Colors.white : Colors.grey,
              onPressed: () => setState(() => currentAlign = TextAlign.center),
            ),
            IconButton(
              icon: const Icon(Icons.format_align_right),
              color: currentAlign == TextAlign.right ? Colors.white : Colors.grey,
              onPressed: () => setState(() => currentAlign = TextAlign.right),
            ),
            const SizedBox(width: 8),
            // Bold
            IconButton(
              icon: const Icon(Icons.format_bold),
              color: currentWeight == FontWeight.bold ? Colors.white : Colors.grey,
              onPressed: () => setState(() {
                currentWeight = currentWeight == FontWeight.bold
                    ? FontWeight.normal
                    : FontWeight.bold;
              }),
            ),
            // Italic
            IconButton(
              icon: const Icon(Icons.format_italic),
              color: isItalic ? Colors.white : Colors.grey,
              onPressed: () => setState(() => isItalic = !isItalic),
            ),
            const SizedBox(width: 8),
            // Done
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: () {
                if (_controller.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter some text')),
                  );
                  return;
                }
                
                Navigator.pop(
                  context,
                  EnhancedTextLayerData(
                    text: _controller.text,
                    color: currentColor,
                    size: currentSize,
                    align: currentAlign,
                    background: currentBackgroundColor,
                    backgroundOpacity: currentBackgroundColor != Colors.transparent ? 0.7 : 0.0,
                    fontFamily: currentFont,
                    textGradient: currentTextGradient,
                    backgroundGradient: currentBackgroundGradient,
                    fontWeight: currentWeight,
                    isItalic: isItalic,
                    offset: Offset(viewportSize.width / 4, viewportSize.height / 3),
                  ),
                );
              },
            ),
          ],
        ),
        body: Column(
          children: [
            // Text Preview
            Expanded(
              flex: 2,
              child: Container(
                color: Colors.black,
                alignment: Alignment.center,
                padding: const EdgeInsets.all(24),
                child: _controller.text.isEmpty
                    ? Text(
                        'Type your text...',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 24,
                        ),
                      )
                    : Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: currentBackgroundGradient == null
                              ? currentBackgroundColor.withOpacity(
                                  currentBackgroundColor != Colors.transparent ? 0.7 : 0.0,
                                )
                              : null,
                          gradient: currentBackgroundGradient,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: currentTextGradient != null
                            ? ShaderMask(
                                shaderCallback: (bounds) =>
                                    currentTextGradient!.createShader(bounds),
                                child: Text(
                                  _controller.text,
                                  textAlign: currentAlign,
                                  style: _getTextStyle(),
                                ),
                              )
                            : Text(
                                _controller.text,
                                textAlign: currentAlign,
                                style: _getTextStyle(),
                              ),
                      ),
              ),
            ),
            
            // Text Input
            Container(
              color: Colors.grey[900],
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _controller,
                style: const TextStyle(color: Colors.white, fontSize: 18),
                decoration: InputDecoration(
                  hintText: 'Enter your text here...',
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  border: InputBorder.none,
                ),
                maxLines: 3,
                autofocus: true,
                onChanged: (value) => setState(() {}),
              ),
            ),
            
            // Options Panel
            Expanded(
              flex: 3,
              child: Container(
                color: Colors.black87,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Font Size
                      _buildSection(
                        'Size',
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              Expanded(
                                child: Slider(
                                  value: currentSize,
                                  min: 16,
                                  max: 120,
                                  activeColor: Colors.white,
                                  onChanged: (value) =>
                                      setState(() => currentSize = value),
                                ),
                              ),
                              SizedBox(
                                width: 50,
                                child: Text(
                                  '${currentSize.round()}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      // Font Family
                      _buildSection(
                        'Font',
                        SizedBox(
                          height: 60,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: widget.fontFamilies.length,
                            itemBuilder: (context, index) {
                              final font = widget.fontFamilies[index];
                              final isSelected = currentFont == font;
                              return GestureDetector(
                                onTap: () => setState(() => currentFont = font),
                                child: Container(
                                  margin: const EdgeInsets.only(right: 12),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.grey[800],
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.transparent,
                                      width: 2,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      font,
                                      style: GoogleFonts.getFont(
                                        font,
                                        color: isSelected
                                            ? Colors.black
                                            : Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      
                      // Text Color
                      _buildSection(
                        'Text Color',
                        SizedBox(
                          height: 60,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: widget.textColors.length,
                            itemBuilder: (context, index) {
                              final color = widget.textColors[index];
                              final isSelected = currentColor == color &&
                                  currentTextGradient == null;
                              return GestureDetector(
                                onTap: () => setState(() {
                                  currentColor = color;
                                  currentTextGradient = null;
                                }),
                                child: Container(
                                  width: 50,
                                  height: 50,
                                  margin: const EdgeInsets.only(right: 12),
                                  decoration: BoxDecoration(
                                    color: color,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.grey[700]!,
                                      width: isSelected ? 3 : 1,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      
                      // Text Gradient
                      if (widget.textGradients.isNotEmpty)
                        _buildSection(
                          'Text Gradient',
                          SizedBox(
                            height: 60,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: widget.textGradients.length + 1,
                              itemBuilder: (context, index) {
                                if (index == 0) {
                                  return GestureDetector(
                                    onTap: () =>
                                        setState(() => currentTextGradient = null),
                                    child: Container(
                                      width: 70,
                                      margin: const EdgeInsets.only(right: 12),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[800],
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: currentTextGradient == null
                                              ? Colors.white
                                              : Colors.transparent,
                                          width: 2,
                                        ),
                                      ),
                                      child: const Center(
                                        child: Text(
                                          'None',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  );
                                }
                                final gradient = widget.textGradients[index - 1];
                                final isSelected = currentTextGradient == gradient;
                                return GestureDetector(
                                  onTap: () =>
                                      setState(() => currentTextGradient = gradient),
                                  child: Container(
                                    width: 70,
                                    margin: const EdgeInsets.only(right: 12),
                                    decoration: BoxDecoration(
                                      gradient: gradient,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.transparent,
                                        width: 3,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      
                      // Background
                      _buildSection(
                        'Background',
                        SizedBox(
                          height: 60,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: widget.textColors.length,
                            itemBuilder: (context, index) {
                              final color = widget.textColors[index];
                              final isSelected = currentBackgroundColor == color &&
                                  currentBackgroundGradient == null;
                              return GestureDetector(
                                onTap: () => setState(() {
                                  currentBackgroundColor = color;
                                  currentBackgroundGradient = null;
                                }),
                                child: Container(
                                  width: 50,
                                  height: 50,
                                  margin: const EdgeInsets.only(right: 12),
                                  decoration: BoxDecoration(
                                    color: color,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.grey[700]!,
                                      width: isSelected ? 3 : 1,
                                    ),
                                  ),
                                  child: color == Colors.transparent
                                      ? const Icon(
                                          Icons.block,
                                          color: Colors.red,
                                          size: 24,
                                        )
                                      : null,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      
                      // Background Gradient
                      if (widget.backgroundGradients.isNotEmpty)
                        _buildSection(
                          'Background Gradient',
                          SizedBox(
                            height: 60,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: widget.backgroundGradients.length + 1,
                              itemBuilder: (context, index) {
                                if (index == 0) {
                                  return GestureDetector(
                                    onTap: () => setState(() {
                                      currentBackgroundGradient = null;
                                      currentBackgroundColor = Colors.transparent;
                                    }),
                                    child: Container(
                                      width: 70,
                                      margin: const EdgeInsets.only(right: 12),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[800],
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: currentBackgroundGradient == null
                                              ? Colors.white
                                              : Colors.transparent,
                                          width: 2,
                                        ),
                                      ),
                                      child: const Center(
                                        child: Text(
                                          'None',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  );
                                }
                                final gradient = widget.backgroundGradients[index - 1];
                                final isSelected = currentBackgroundGradient == gradient;
                                return GestureDetector(
                                  onTap: () => setState(() {
                                    currentBackgroundGradient = gradient;
                                    currentBackgroundColor = Colors.white;
                                  }),
                                  child: Container(
                                    width: 70,
                                    margin: const EdgeInsets.only(right: 12),
                                    decoration: BoxDecoration(
                                      gradient: gradient,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.transparent,
                                        width: 3,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, Widget child) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 12),
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

// ============ Enhanced Text Layer Widget (for rendering) ============
class EnhancedTextLayer extends StatefulWidget {
  final EnhancedTextLayerData layerData;
  final VoidCallback? onUpdate;
  final bool editable;

  const EnhancedTextLayer({
    super.key,
    required this.layerData,
    this.onUpdate,
    this.editable = false,
  });

  @override
  createState() => _EnhancedTextLayerWidgetState();
}

class _EnhancedTextLayerWidgetState extends State<EnhancedTextLayer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  double initialSize = 0;

  @override
  void initState() {
    super.initState();
    initialSize = widget.layerData.size;
    
    _animController = AnimationController(
      duration: Duration(
        milliseconds: (widget.layerData.animationDuration * 1000).toInt(),
      ),
      vsync: this,
    );
    
    if (widget.layerData.animation != null) {
      _animController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  TextStyle _getTextStyle() {
    try {
      return GoogleFonts.getFont(
        widget.layerData.fontFamily,
        fontSize: widget.layerData.size,
        color: widget.layerData.textGradient != null
            ? Colors.white
            : widget.layerData.color,
        fontWeight: widget.layerData.fontWeight,
        fontStyle: widget.layerData.isItalic
            ? FontStyle.italic
            : FontStyle.normal,
      );
    } catch (e) {
      return TextStyle(
        fontFamily: widget.layerData.fontFamily,
        fontSize: widget.layerData.size,
        color: widget.layerData.textGradient != null
            ? Colors.white
            : widget.layerData.color,
        fontWeight: widget.layerData.fontWeight,
        fontStyle: widget.layerData.isItalic
            ? FontStyle.italic
            : FontStyle.normal,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget textWidget = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: widget.layerData.backgroundGradient == null
            ? widget.layerData.background.withOpacity(
                widget.layerData.backgroundOpacity,
              )
            : null,
        gradient: widget.layerData.backgroundGradient,
        borderRadius: BorderRadius.circular(8),
      ),
      child: widget.layerData.textGradient != null
          ? ShaderMask(
              shaderCallback: (bounds) =>
                  widget.layerData.textGradient!.createShader(bounds),
              child: Text(
                widget.layerData.text,
                textAlign: widget.layerData.align,
                style: _getTextStyle(),
              ),
            )
          : Text(
              widget.layerData.text,
              textAlign: widget.layerData.align,
              style: _getTextStyle(),
            ),
    );

    // Apply animation
    if (widget.layerData.animation != null) {
      final animation = CurvedAnimation(
        parent: _animController,
        curve: Curves.easeInOut,
      );
      
      switch (widget.layerData.animation) {
        case 'fade':
          textWidget = FadeTransition(opacity: animation, child: textWidget);
          break;
        case 'scale':
          textWidget = ScaleTransition(
            scale: Tween<double>(begin: 0.95, end: 1.05).animate(animation),
            child: textWidget,
          );
          break;
        case 'bounce':
          textWidget = SlideTransition(
            position: Tween<Offset>(
              begin: Offset.zero,
              end: const Offset(0, -0.05),
            ).animate(animation),
            child: textWidget,
          );
          break;
        case 'rotate':
          textWidget = RotationTransition(
            turns: Tween<double>(begin: -0.02, end: 0.02).animate(animation),
            child: textWidget,
          );
          break;
      }
    }

    return Positioned(
      left: widget.layerData.offset.dx,
      top: widget.layerData.offset.dy,
      child: GestureDetector(
        onTap: widget.editable
            ? () {
                showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.transparent,
                  isScrollControlled: true,
                  builder: (context) => EnhancedTextLayerOverlay(
                    layer: widget.layerData,
                    onUpdate: () {
                      if (widget.onUpdate != null) widget.onUpdate!();
                      setState(() {});
                    },
                  ),
                );
              }
            : null,
        onScaleUpdate: widget.editable
            ? (details) {
                if (details.pointerCount == 1) {
                  widget.layerData.offset = Offset(
                    widget.layerData.offset.dx + details.focalPointDelta.dx,
                    widget.layerData.offset.dy + details.focalPointDelta.dy,
                  );
                } else if (details.pointerCount == 2) {
                  widget.layerData.size = 
                      (initialSize * details.scale).clamp(16.0, 120.0);
                  widget.layerData.rotation = details.rotation;
                }
                setState(() {});
              }
            : null,
        onScaleEnd: widget.editable
            ? (details) {
                initialSize = widget.layerData.size;
              }
            : null,
        child: Transform.rotate(
          angle: widget.layerData.rotation,
          child: Container(
            padding: const EdgeInsets.all(32),
            child: textWidget,
          ),
        ),
      ),
    );
  }
}

// ============ Text Layer Overlay (Edit options) ============
class EnhancedTextLayerOverlay extends StatefulWidget {
  final EnhancedTextLayerData layer;
  final VoidCallback onUpdate;

  const EnhancedTextLayerOverlay({
    super.key,
    required this.layer,
    required this.onUpdate,
  });

  @override
  createState() => _EnhancedTextLayerOverlayState();
}

class _EnhancedTextLayerOverlayState extends State<EnhancedTextLayerOverlay> {
  final List<String> animations = ['None', 'Fade', 'Scale', 'Bounce', 'Rotate'];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[600],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Edit Text',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Size slider
                  const Text(
                    'Size',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  Slider(
                    value: widget.layer.size,
                    min: 16,
                    max: 120,
                    activeColor: Colors.white,
                    onChanged: (value) {
                      setState(() {
                        widget.layer.size = value;
                        widget.onUpdate();
                      });
                    },
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Animation selector
                  const Text(
                    'Animation',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 50,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: animations.length,
                      itemBuilder: (context, index) {
                        final animName = animations[index];
                        final animValue = animName == 'None' 
                            ? null 
                            : animName.toLowerCase();
                        final isSelected = widget.layer.animation == animValue;
                        
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              widget.layer.animation = animValue;
                              widget.onUpdate();
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 12),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.white : Colors.grey[800],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                animName,
                                style: TextStyle(
                                  color: isSelected ? Colors.black : Colors.white,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
          
          // Action buttons
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _actionButton(
                  icon: Icons.edit,
                  label: 'Edit',
                  onTap: () async {
                    Navigator.pop(context);
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EnhancedTextEditor(),
                      ),
                    );
                    if (result != null && result is EnhancedTextLayerData) {
                      widget.layer.text = result.text;
                      widget.layer.color = result.color;
                      widget.layer.size = result.size;
                      widget.layer.fontFamily = result.fontFamily;
                      widget.layer.textGradient = result.textGradient;
                      widget.layer.backgroundGradient = result.backgroundGradient;
                      widget.layer.align = result.align;
                      widget.layer.fontWeight = result.fontWeight;
                      widget.layer.isItalic = result.isItalic;
                      widget.onUpdate();
                    }
                  },
                ),
                _actionButton(
                  icon: Icons.copy,
                  label: 'Duplicate',
                  onTap: () {
                    final newLayer = EnhancedTextLayerData(
                      text: widget.layer.text,
                      color: widget.layer.color,
                      size: widget.layer.size,
                      fontFamily: widget.layer.fontFamily,
                      textGradient: widget.layer.textGradient,
                      backgroundGradient: widget.layer.backgroundGradient,
                      offset: widget.layer.offset + const Offset(20, 20),
                      align: widget.layer.align,
                      fontWeight: widget.layer.fontWeight,
                      isItalic: widget.layer.isItalic,
                      animation: widget.layer.animation,
                    );
                    layers.add(newLayer);
                    Navigator.pop(context);
                    widget.onUpdate();
                  },
                ),
                _actionButton(
                  icon: Icons.delete,
                  label: 'Delete',
                  color: Colors.red,
                  onTap: () {
                    final index = layers.indexOf(widget.layer);
                    if (index != -1) {
                      removedLayers.add(layers.removeAt(index));
                      Navigator.pop(context);
                      widget.onUpdate();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color ?? Colors.grey[800],
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }
}