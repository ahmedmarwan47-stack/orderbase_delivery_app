#version 460 core
#include <flutter/runtime_effect.glsl>

// The header's scroll edge, second half. The engine has ALREADY blurred the
// backdrop with its own two-pass Gaussian (this shader is the outer half of an
// ImageFilter.compose whose inner half is that blur), so what arrives in uTex
// is the smooth, blurred page. All that is left to do is let it thin out: full
// down to the fade, then gone at the band's bottom, with the page ground washed
// over at the same rate. Where the output alpha is 0 the sharp page shows
// through untouched, so the band ends without a seam — the way a gradient-
// masked UIVisualEffectView ends.
//
// FlutterFragCoord() is in SCREEN pixels, as it is for a plain backdrop
// shader (measured — see nav_glass.frag). The input, though, is the blur's
// own output, which the engine pads by the blur's reach; the padding is taken
// as symmetric, so a screen pixel sits (uSize - uScreen) / 2 further into the
// texture than its screen coordinate says.

uniform vec2 uSize;     // 0-1  input texture size (px) — engine-set
uniform vec2 uScreen;   // 2-3  the screen in the same px
uniform vec4 uRect;     // 4-7  band x, y, w, h in screen px
uniform float uFade;    // 8    where the fade begins, 0..1 down the band
uniform vec4 uTint;     // 9-12 straight-alpha wash over the blurred page

uniform sampler2D uTex;

out vec4 fragColor;

void main() {
  vec2 p = FlutterFragCoord().xy;
  float t = (p.y - uRect.y) / uRect.w;
  float f = 1.0 - smoothstep(uFade, 1.0, clamp(t, 0.0, 1.0));

  vec2 pad = (uSize - uScreen) * 0.5;
  vec2 uv = clamp((p + pad) / uSize, vec2(0.0), vec2(1.0));
#ifdef IMPELLER_TARGET_OPENGLES
  uv.y = 1.0 - uv.y;
#endif
  vec3 col = texture(uTex, uv).rgb;
  col = mix(col, uTint.rgb, uTint.a * f);
  // Premultiplied, like every Flutter shader.
  fragColor = vec4(col * f, f);
}
