#version 460 core
#include <flutter/runtime_effect.glsl>

// The tab bar's liquid glass: one capsule of thick glass laid over whatever
// the page shows underneath. Runs as a backdrop image filter — the engine
// hands us the pixels behind the bar (uTex) and we hand back what the glass
// makes of them.
//
// What the engine actually provides (measured, not documented): uTex is the
// WHOLE backdrop — the screen — and FlutterFragCoord() is in its pixels; the
// widget's clip only limits which pixels we are asked for. So the capsule is
// described by its screen rect (uRect), and the lens and the shadow may read
// past the capsule's edge freely.
//
// Uniform order is the contract: the engine writes the texture size into the
// first vec2, and nav_glass.dart addresses everything else by float index.

uniform vec2 uSize;        // 0-1   texture size (px) — engine-set
uniform vec4 uRect;        // 2-5   capsule x, y, w, h in texture px
uniform float uRadius;     // 6     corner radius (px)
uniform float uRim;        // 7     width of the lensing rim (px)
uniform float uCurve;      // 8     how steeply the rim's surface tilts
uniform float uDepth;      // 9     refraction displacement at the rim (px)
uniform float uDisp;       // 10    chromatic dispersion, as a fraction
uniform float uBlur;       // 11    frost radius (px); 0 = clear glass
uniform float uSat;        // 12    saturation multiplier
uniform vec4 uTint;        // 13-16 straight-alpha tint over the sampled page
uniform float uSpec;       // 17    rim light strength
uniform vec2 uLight;       // 18-19 light direction in the texture's xy
uniform float uEdgeDark;   // 20    rim shade on the side facing away
uniform float uShadow;     // 21    drop shadow alpha; 0 = none
uniform float uShadowBlur; // 22    shadow softness (px)
uniform vec2 uShadowOff;   // 23-24 shadow offset (px)

uniform sampler2D uTex;

out vec4 fragColor;

// Signed distance to a rounded box centred on the origin; negative inside.
float sdBox(vec2 p, vec2 hs, float r) {
  vec2 d = abs(p) - (hs - vec2(r));
  return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0) - r;
}

// Outward in-plane normal of that box at p.
vec2 boxNormal(vec2 p, vec2 hs, float r) {
  vec2 d = abs(p) - (hs - vec2(r));
  vec2 m = max(d, 0.0);
  vec2 g = (m.x > 0.0 || m.y > 0.0)
      ? m / max(length(m), 1e-4)
      : ((d.x > d.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0));
  vec2 s = vec2(p.x < 0.0 ? -1.0 : 1.0, p.y < 0.0 ? -1.0 : 1.0);
  return g * s;
}

vec3 tap(vec2 px) {
  vec2 uv = clamp(px / uSize, vec2(0.0), vec2(1.0));
#ifdef IMPELLER_TARGET_OPENGLES
  uv.y = 1.0 - uv.y;
#endif
  return texture(uTex, uv).rgb;
}

// The frost: three rings of taps around the centre, rotated per pixel so the
// ring pattern dissolves into fine grain instead of banding.
//
// Cost matters here — this runs for every pixel under the bar, every frame
// the page beneath it changes. So the per-pixel jitter is ONE rotation
// (a single sin/cos pair), and each tap steps around its ring by a constant
// matrix: four multiply-adds instead of a sin and a cos per tap. Same taps,
// same picture, a fraction of the ALU.
const mat2 kStep8 = mat2(0.70710678, 0.70710678, -0.70710678, 0.70710678); // 45°
const mat2 kStep12 = mat2(0.86602540, 0.5, -0.5, 0.86602540);              // 30°
const mat2 kStep16 = mat2(0.92387953, 0.38268343, -0.38268343, 0.92387953); // 22.5°

vec3 frost(vec2 c) {
  if (uBlur < 0.5) return tap(c);
  float a0 = fract(sin(dot(c, vec2(12.9898, 78.233))) * 43758.5453) * 6.2831853;
  float ca = cos(a0);
  float sa = sin(a0);
  mat2 jitter = mat2(ca, sa, -sa, ca);
  vec3 acc = tap(c);
  float w = 1.0;
  // Ring 1: 8 taps from a0, 45° apart.
  vec2 d = jitter * vec2(uBlur * 0.35, 0.0);
  for (int i = 0; i < 8; i++) {
    acc += tap(c + d) * 0.85;
    d = kStep8 * d;
  }
  // Ring 2: 12 taps from a0 + 15°, 30° apart.
  d = jitter * (vec2(0.96592583, 0.25881905) * (uBlur * 0.7));
  for (int i = 0; i < 12; i++) {
    acc += tap(c + d) * 0.55;
    d = kStep12 * d;
  }
  // Ring 3: 16 taps from a0 + 11.25°, 22.5° apart.
  d = jitter * (vec2(0.98078528, 0.19509032) * uBlur);
  for (int i = 0; i < 16; i++) {
    acc += tap(c + d) * 0.3;
    d = kStep16 * d;
  }
  w += 8.0 * 0.85 + 12.0 * 0.55 + 16.0 * 0.3;
  return acc / w;
}

float shadowAt(vec2 q, vec2 hs, float r) {
  if (uShadow <= 0.0) return 0.0;
  float sd = sdBox(q - uShadowOff, hs, r);
  return uShadow * (1.0 - smoothstep(-uShadowBlur * 0.4, uShadowBlur, sd));
}

void main() {
  vec2 p = FlutterFragCoord().xy;
  vec2 hs = uRect.zw * 0.5;
  vec2 q = p - (uRect.xy + hs);
  float r = min(uRadius, min(hs.x, hs.y));
  float sd = sdBox(q, hs, r);

  // Outside the capsule the page is left exactly as it was: the output is
  // transparent, so compositing changes nothing — except the shadow, which is
  // black at its own alpha. (Premultiplied, like every Flutter shader.)
  float shadow = shadowAt(q, hs, r);
  if (sd > 1.0) {
    fragColor = vec4(0.0, 0.0, 0.0, shadow);
    return;
  }

  // Rim profile: a quarter circle from the edge (x = 0) to flat glass (x = 1).
  float x = clamp(-sd / uRim, 0.0, 1.0);
  float h = sqrt(1.0 - (1.0 - x) * (1.0 - x));
  float tilt = (1.0 - x) / max(h, 0.08);
  vec2 g = boxNormal(q, hs, r);
  vec3 n = normalize(vec3(g * tilt * uCurve, 1.0));

  // Light entering the glass bends toward the normal: the rim shows the page
  // from a little further in, which reads as the edge magnifying it.
  vec3 t = refract(vec3(0.0, 0.0, -1.0), n, 1.0 / 1.5);
  vec2 off = t.xy / max(-t.z, 0.3) * uDepth;

  vec3 col = frost(p + off);
  float rimW = 1.0 - h;
  // Dispersion: glass bends blue more than red, so the rim shows the page's
  // red from a little nearer the edge and its blue from a little further in.
  // uDisp is that spread as a fraction of the bend — a whisper at rest, and
  // on the lens opened wide while a finger drags it, so the glyphs and labels
  // it slides across split into a warm copy and a cool one at its edge: the
  // fringe a soap bubble shows in the sun.
  if (uDisp > 0.0 && rimW > 0.01) {
    col.r = mix(col.r, tap(p + off * (1.0 - uDisp)).r, rimW);
    col.b = mix(col.b, tap(p + off * (1.0 + uDisp)).b, rimW);
  }

  float l = dot(col, vec3(0.2126, 0.7152, 0.0722));
  col = mix(vec3(l), col, uSat);
  col = mix(col, uTint.rgb, uTint.a);

  vec3 L = normalize(vec3(uLight, 0.75));
  vec3 H = normalize(L + vec3(0.0, 0.0, 1.0));
  float facing = dot(g, normalize(uLight));
  float toward = smoothstep(-0.25, 0.7, facing);
  float away = smoothstep(-0.25, 0.7, -facing);

  // Thin film: while the lens disperses, a band of colour lies across the
  // outer rim — warm at the very edge, magenta, then blue a little way in —
  // the way a soap film bands where it thins, strongest where the light
  // falls. Multiplied in so it reads as a pastel on a white page, with a
  // touch added on top so it still shows over ink. Nothing at rest: the
  // lens's resting dispersion sits below the threshold, and so does the
  // bar's.
  float film = smoothstep(0.25, 0.8, uDisp) * smoothstep(0.0, 0.04, x) *
      (1.0 - smoothstep(0.1, 0.4, x)) * (0.6 + 0.4 * toward) * 0.7;
  if (film > 0.001) {
    float u = clamp(x / 0.3, 0.0, 1.0);
    vec3 warm = vec3(1.0, 0.72, 0.4);
    vec3 magenta = vec3(1.0, 0.55, 0.9);
    vec3 blue = vec3(0.5, 0.75, 1.0);
    vec3 tone = u < 0.5 ? mix(warm, magenta, u * 2.0)
                        : mix(magenta, blue, u * 2.0 - 1.0);
    col = mix(col, col * mix(vec3(1.0), tone, 0.6) + tone * 0.1, film);
  }

  // Lighting: a Blinn highlight where the rim faces the light, a whisper of
  // shade where it faces away, and a hairline of light along the lit edge.
  float spec = pow(max(dot(n, H), 0.0), 20.0) * rimW * toward * uSpec;
  // The hairline of light along the lit edge. Dispersing, it splits the way
  // the page does — red held to the very edge, blue trailing just inside it —
  // so the rim carries a thread of colour even over a plain page.
  float d = -sd;
  float hairG = 1.0 - smoothstep(0.0, 2.5, d);
  vec3 hair = vec3(hairG);
  if (uDisp > 0.0) {
    float s = max(uDisp * uDepth * 0.35, 0.01);
    float hairR = 1.0 - smoothstep(0.0, 2.5, d + s * 0.5);
    float hairB = smoothstep(0.0, s, d) * (1.0 - smoothstep(0.0, 2.5, d - s));
    hair = vec3(hairR, hairG, hairB);
  }
  vec3 line = hair * (toward * uSpec * 0.6);
  col = col * (1.0 - uEdgeDark * rimW * away) + vec3(spec) + line;

  // Anti-aliased edge: the glass fades to the shadow underneath it.
  float aa = 1.0 - smoothstep(-1.0, 1.0, sd);
  float a = aa + shadow * (1.0 - aa);
  fragColor = vec4(col * aa, a);
}
