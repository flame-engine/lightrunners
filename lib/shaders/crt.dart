import 'dart:ui' as ui;

import 'package:vector_math/vector_math.dart' hide Colors;

import 'package:flutter/material.dart';
import 'package:flutter_shaders/flutter_shaders.dart';

class CRTShader extends StatelessWidget {
  const CRTShader({
    super.key,
    required this.enabled,
    required this.child,
  });

  final bool enabled;
  final Widget child;

  @override
  Widget build(BuildContext context) {


    if(!enabled) return child;

    return ColoredBox(
      color: Colors.black,
      child: ImageBuilder(
        assetImageProvider: const AssetImage('assets/images/liltex_3.jpg'),
        (context, pixelTexture) {
          return ShaderBuilder(
            assetKey: 'shaders/super_crt.glsl',
            child: child,
            (context, shader, child) {
              return AnimatedSampler(
                (image, size, canvas) {
                  shader
                    ..setFloatUniforms((value) {
                      value
                        ..setSize(size)
                        ..setFloat(1)
                        ..setVector(Vector2(2, 5));
                    })
                    ..setImageSampler(0, pixelTexture)
                    ..setImageSampler(1, image);

                  canvas.drawRect(
                    Offset.zero & size,
                    Paint()..shader = shader,
                  );
                },
                child: child!,
              );
            },
          );
        },
      ),
    );
  }
}

class ImageBuilder extends StatefulWidget {
  const ImageBuilder(
    this.builder, {
    super.key,
    required this.assetImageProvider,
  });

  final Widget Function(BuildContext context, ui.Image image) builder;
  final ImageProvider assetImageProvider;

  @override
  State<ImageBuilder> createState() => _ImageBuilderState();
}

class _ImageBuilderState extends State<ImageBuilder> {
  ui.Image? image;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    getImage();
  }

  Future<void> getImage() async {
    widget.assetImageProvider.resolve(ImageConfiguration.empty).addListener(
      ImageStreamListener((info, synchronousCall) {
        setState(() {
          image = info.image;
        });
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final image = this.image;

    if (image == null) {
      return const SizedBox.shrink();
    }

    return widget.builder(context, image);
  }
}
