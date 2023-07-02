// specify the version of GLSL to use.
#version 460 core

// specify the name of the fragment shader.
precision mediump float;

// include the Flutter-provided "FlutterFragCoord" function.
// this function returns the fragment's position in logical pixels in both in skia and impeller
#include <flutter/runtime_effect.glsl>

// declare the uniform inputs.
uniform vec2 uSize;
uniform sampler2D tTexture;


out vec4 fragColor;

const float blurSize = 1.0/3500.0;
const float intensity = 0.35;


vec4 fragment(vec2 uv, vec2 pos, inout vec4 color) {

    vec4 sum = vec4(0);
    vec2 texcoord = uv;
    int j;
    int i;

    for (i = -18; i < 18; i++){
        float factor = (mod(i, 18) / 10.0 ) * 0.008;
        sum += texture(tTexture, vec2(texcoord.x + i * blurSize, texcoord.y * 40)) * factor ;
        sum += texture(tTexture, vec2(texcoord.x, texcoord.y + i * blurSize * 40)) * factor ;
    }

    color = sum+ texture(tTexture, texcoord);

    return color;
}

float getLuma(vec3 color) {
    vec3 weights = vec3(0.299, 0.587, 0.114);
    return dot(color, weights);
}


// the main function
void main() {
    vec2 pos = FlutterFragCoord().xy;
    vec2 uv = pos / uSize;
    vec4 color;

//    fragColor = texture(tTexture, uv);
//    return;
//


    fragment(uv, pos, color);


    fragColor = color;
}
