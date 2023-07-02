// specify the version of GLSL to use.
#version 460 core

// specify the name of the fragment shader.
precision mediump float;

// include the Flutter-provided "FlutterFragCoord" function.
// this function returns the fragment's position in logical pixels in both in skia and impeller
#include <flutter/runtime_effect.glsl>


// declare the uniform inputs.
uniform vec2 uSize;
uniform float uPixelRatio;
uniform vec2 brickSize;

uniform sampler2D tPixelTexture;
uniform sampler2D tTexture;

// declare the output variable.
out vec4 fragColor;


vec2 brickTile(vec2 st, float _zoom){
    st.y += step(1., mod(st.x, 2.0)) * 0.1;
    return fract(st);
}


// the shader core, implement effects here
void fragment(vec2 pos, inout vec4 color, float displacement) {
    pos.y += displacement;

    vec2 st = pos.xy;
    st /= uPixelRatio;
    st /= brickSize;



    float tiling = step(1., mod(st.x, 2.0)) * 0.5;
    float brickY;
    if (tiling!=0.0) {
        brickY = floor((pos.y + brickSize.y * 0.5) / brickSize.y) -1;
    } else {
        brickY = floor(pos.y / brickSize.y);
    }

    float brickX = floor(pos.x / brickSize.x);
    float bricksY = floor(uSize.y / brickSize.y  - tiling);
    float bricksXAmount = floor(uSize.x / brickSize.x);

    float bricksYAmount;
    if (tiling!=0.0) {
        bricksYAmount = floor(uSize.y / brickSize.y) -2;
    } else {
        bricksYAmount = floor(uSize.y / brickSize.y) -1;
    }

    if (tiling != 0.0) {
        if (brickY == bricksY || (brickY < 0.0)){
            color = vec4(0.0, 0.0, 0.0, 0.0);
            return;
        }
    } else if (brickY >= bricksY){
        color = vec4(0.0, 0.0, 0.0, 0.0);
        return;
    }

    st.y += tiling;

    // this is st within the tile
    st =  fract(st);


    float puvy = (brickY / bricksYAmount);
    float puvx = (brickX / bricksXAmount);


    // this is color of the tile
    vec4 tileColor = texture(tTexture, vec2(puvx, puvy));

    tileColor.rgb /= vec3(0.9);

    vec2 ssize = vec2(1.0, 1.0);
    vec2 bst = st / ssize;
    vec2 rst = (st - vec2((1.0 - ssize.x) / 2, 0.0)) / ssize;
    vec2 gst = (st - vec2((1.0 - ssize.x), 0.0)) / ssize;

    color = vec4(0.0, 0.0, 0.0, 1.0);

    vec3 sizer = tileColor.rgb * 4.0;

    //    sizer = vec3(2.0) * sizer;
    sizer= smoothstep(0.0, 1.0, sizer);
    //        sizer = vec3(1.0) ;


    rst = (rst / sizer.r);
    rst -= 1.0 - sizer.r;

    color.r = texture(tPixelTexture, rst).r * tileColor.r;

    gst = (gst / sizer.g);
    gst -= 1.0 - sizer.g;

    color.g = texture(tPixelTexture, gst).g * tileColor.g;


    bst.y =  (bst.y / sizer.b);
    bst.y -= 1.0 - sizer.b;

    color.b = texture(tPixelTexture, bst).b * tileColor.b;



    color.a = color.b + color.g + color.r;

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
    fragment(pos, color, 0.0);

    vec4 color2;
    fragment(pos + vec2(brickSize) / 2, color2, 0);

    float lumacolor2 = getLuma(color2.rgb);
    if(lumacolor2 > 0.4) {
        color.rgb = mix(color.rgb, color2.rgb, 0.5);
    }


    color.rgb *= 1.2;

    fragColor = color;
}
