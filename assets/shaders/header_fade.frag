#version 460 core
#include <flutter/runtime_effect.glsl>

// One strip of the header's scroll-edge ladder, second half. The engine has
// ALREADY blurred the backdrop with its own two-pass Gaussian (this shader is
// the outer half of an ImageFilter.compose whose inner half is that blur), so
// what arrives in uTex is the smooth, blurred page. All that is left is the
// window: nothing above uStart, opaque from there to uFade, fading to nothing
// at uEnd, nothing below — so the strip shows its own zone and crossfades out
// across the zone beneath it into the next strip's level. Where the alpha is
// 0 the page shows through untouched.
//
// The window sits well inside the strip's box on purpose: a blur composed
// this way pads a thin box with transparent black rather than clamping, and
// the rows within a few sigma of the box's edges come out dark — so the box
// is padded by three sigma each side and those rows are masked to nothing.
//
// FlutterFragCoord() is in SCREEN pixels, as it is for a plain backdrop
// shader (measured — see nav_glass.frag), and the input is the blurred screen
// padded by the blur's reach past its far edges (measured: uSize is the
// screen plus about two sigma, the origin the screen's own).

uniform vec2 uSize;     // 0-1  input texture size (px) — engine-set
uniform vec2 uScreen;   // 2-3  the screen in the same px
uniform vec4 uRect;     // 4-7  box x, y, w, h in screen px
uniform float uStart;   // 8    top of the opaque window, 0..1 down the box
uniform float uFade;    // 9    where the fade begins
uniform float uEnd;     // 10   where it is gone

uniform sampler2D uTex;

out vec4 fragColor;

void main() {
  vec2 p = FlutterFragCoord().xy;
  float t = (p.y - uRect.y) / uRect.w;
  float f = step(uStart, t) * (1.0 - smoothstep(uFade, uEnd, t));

  // The padding lies past the screen's far edges, not around it: the
  // texture's origin is the screen's (measured — a symmetric guess put a dark
  // wedge of padding down the right edge).
  vec2 uv = clamp(p / uSize, vec2(0.0), vec2(1.0));
#ifdef IMPELLER_TARGET_OPENGLES
  uv.y = 1.0 - uv.y;
#endif
  // Unpremultiply: at the screen's edges the blur has mixed in transparent
  // black, darkening the colour in step with the alpha it lost; dividing it
  // back out leaves the blur of the page alone.
  vec4 smp = texture(uTex, uv);
  vec3 col = smp.rgb / max(smp.a, 0.001);
  // Premultiplied, like every Flutter shader (measured: the engine
  // composites a filter's output as premultiplied source-over).
  fragColor = vec4(col * f, f);
}
