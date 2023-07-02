import 'dart:ui' as ui;

import 'package:vector_math/vector_math.dart' hide Colors;

import 'package:flutter/material.dart';
import 'package:flutter_shaders/flutter_shaders.dart';

class BloomShader extends StatelessWidget {
  const BloomShader({
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
      child: ShaderBuilder(
        assetKey: 'shaders/bloom.glsl',
        child: child,
        (context, shader, child) {
          return AnimatedSampler(
            (image, size, canvas) {
              shader
                ..setFloatUniforms((value) {
                  value.setSize(size);
                })
                ..setImageSampler(0, image);

              canvas.drawRect(Offset.zero & size, Paint()..shader = shader);
            },
            child: child!,
          );
        },
      ),
    );
  }
}

