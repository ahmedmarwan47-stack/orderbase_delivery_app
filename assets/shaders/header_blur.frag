#version 460 core
#include <flutter/runtime_effect.glsl>

// The header's scroll edge: the page blurred under the bar and clearing again
// a little below it, with the page ground washed over the blur at the same
// rate so the title stays readable over whatever passes beneath. No line
// anywhere — the only edge is the one the fade draws, and it draws none.
//
// Runs as a backdrop image filter, under the same contract as
// nav_glass.frag: uTex is the WHOLE screen and FlutterFragCoord() is in its
// pixels, so the band describes itself in screen coordinates (uRect) and the
// widget's clip limits which pixels we are asked for.
//
// Uniform order is the contract: the engine writes the texture size into the
// first vec2, and header_blur.dart addresses everything else by float index.

uniform vec2 uSize;   // 0-1  texture size (px) — engine-set
uniform vec4 uRect;   // 2-5  band x, y, w, h in texture px
uniform float uFade;  // 6    y (px) where the blur starts thinning; gone at the band's bottom
uniform float uBlur;  // 7    frost radius at full strength (px)
uniform vec4 uTint;   // 8-11 straight-alpha wash over the blurred page

uniform sampler2D uTex;

out vec4 fragColor;

vec3 tap(vec2 px) {
  vec2 uv = clamp(px / uSize, vec2(0.0), vec2(1.0));
#ifdef IMPELLER_TARGET_OPENGLES
  uv.y = 1.0 - uv.y;
#endif
  return texture(uTex, uv).rgb;
}

// The same three-ring frost as nav_glass.frag — one jitter rotation per
// pixel, constant steps around each ring — with the radius handed in, since
// here it is a function of where the pixel sits in the fade.
const mat2 kStep8 = mat2(0.70710678, 0.70710678, -0.70710678, 0.70710678);
const mat2 kStep12 = mat2(0.86602540, 0.5, -0.5, 0.86602540);
const mat2 kStep16 = mat2(0.92387953, 0.38268343, -0.38268343, 0.92387953);

vec3 frost(vec2 c, float r) {
  if (r < 0.5) return tap(c);
  float a0 = fract(sin(dot(c, vec2(12.9898, 78.233))) * 43758.5453) * 6.2831853;
  float ca = cos(a0);
  float sa = sin(a0);
  mat2 jitter = mat2(ca, sa, -sa, ca);
  vec3 acc = tap(c);
  vec2 d = jitter * vec2(r * 0.35, 0.0);
  for (int i = 0; i < 8; i++) {
    acc += tap(c + d) * 0.85;
    d = kStep8 * d;
  }
  d = jitter * (vec2(0.96592583, 0.25881905) * (r * 0.7));
  for (int i = 0; i < 12; i++) {
    acc += tap(c + d) * 0.55;
    d = kStep12 * d;
  }
  d = jitter * (vec2(0.98078528, 0.19509032) * r);
  for (int i = 0; i < 16; i++) {
    acc += tap(c + d) * 0.3;
    d = kStep16 * d;
  }
  return acc / (1.0 + 8.0 * 0.85 + 12.0 * 0.55 + 16.0 * 0.3);
}

void main() {
  vec2 p = FlutterFragCoord().xy;
  float bottom = uRect.y + uRect.w;
  // Full above uFade, nothing at the band's bottom; the same curve drives
  // the frost and the wash so they thin out together.
  float f = 1.0 - smoothstep(uFade, bottom, p.y);
  vec3 col = frost(p, uBlur * f);
  col = mix(col, uTint.rgb, uTint.a * f);
  // Opaque: the blurred page replaces the page. Where f is 0 the frost is a
  // single tap of the page itself, so the band ends without a seam.
  fragColor = vec4(col, 1.0);
}
