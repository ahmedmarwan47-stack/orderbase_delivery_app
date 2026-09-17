#version 460 core
#include <flutter/runtime_effect.glsl>

// Dedicated optical liquid glass shader for the tab bar droplet lens.
// Designed for true backdrop refraction: samples the already-rendered icons
// and labels behind it and refracts them through an analytic curved glass lens.
//
// Uniform contract:
// 0-1:   uSize            texture size (px) — engine-set
// 2-5:   uRect            droplet capsule x, y, w, h in texture px
// 6:     uRadius          corner radius (px)
// 7:     uThickness       optical bevel thickness (px)
// 8:     uRefractiveIndex refractive index (e.g. 1.45)
// 9:     uBaseHeight      optical standoff depth (px)
// 10:    uDispersion      chromatic dispersion spread (0.0 = disabled)
// 11:    uSpecular        rim specular highlight intensity
// 12-13: uLight           light direction in texture xy
// 14-17: uTint            straight-alpha glass tint
// 18:    uMotionStrength  motion-driven refraction factor (0.0 = rest, 1.0 = full motion)
// 19:    uRefractionStrength master multiplier for optical refraction displacement

uniform vec2 uSize;
uniform vec4 uRect;
uniform float uRadius;
uniform float uThickness;
uniform float uRefractiveIndex;
uniform float uBaseHeight;
uniform float uDispersion;
uniform float uSpecular;
uniform vec2 uLight;
uniform vec4 uTint;
uniform float uMotionStrength;
uniform float uRefractionStrength;

uniform sampler2D uTex;

out vec4 fragColor;

// Signed distance to a rounded box centered on origin; negative inside.
float sdBox(vec2 p, vec2 hs, float r) {
  vec2 d = abs(p) - (hs - vec2(r));
  return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0) - r;
}

vec4 tap(vec2 px) {
  vec2 uv = clamp(px / uSize, vec2(0.0), vec2(1.0));
  return texture(uTex, uv);
}

void main() {
  vec2 p = FlutterFragCoord().xy;
  vec2 hs = uRect.zw * 0.5;
  vec2 q = p - (uRect.xy + hs);
  float r = min(uRadius, min(hs.x, hs.y));
  float sd = sdBox(q, hs, r);

  // Motion-only refraction:
  // When resting on the selected tab (motionFactor <= 0.0005) or refraction is disabled (refrStrength <= 0.0005):
  // Return the backdrop untouched!
  // This guarantees that at rest (or when refractionStrength == 0.0), the droplet's appearance
  // is 100% defined by the authentic droplet design: _lensSurface (gradient, border, shadow) and
  // LiquidDropletChromaticPainter (specular hairline), with ZERO extra tint,
  // ZERO extra specular highlights, and ZERO distortion.
  float motionFactor = clamp(uMotionStrength, 0.0, 1.0);
  float refrStrength = max(uRefractionStrength, 0.0);
  if (motionFactor <= 0.0005 || refrStrength <= 0.0005) {
    fragColor = tap(p);
    return;
  }

  // Outside the droplet capsule: return backdrop untouched.
  if (sd > 1.5) {
    fragColor = tap(p);
    return;
  }

  // Compute 2D surface gradient analytically for the capsule SDF.
  // This provides mathematically exact, artifact-free normals and 100% compatibility
  // across all Flutter shader backends (Impeller Metal/Vulkan and SkSL fallback).
  vec2 d = abs(q) - (hs - vec2(r));
  vec2 m = max(d, 0.0);
  vec2 g = (m.x > 0.0 || m.y > 0.0)
      ? m / max(length(m), 1e-4)
      : ((d.x > d.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0));
  vec2 s = vec2(q.x < 0.0 ? -1.0 : 1.0, q.y < 0.0 ? -1.0 : 1.0);
  vec2 boundaryNormal = g * s;

  // Height and circular-arc lens profile:
  // At edge (sd = 0): x = thickness -> n_cos = 1, n_sin = 0 (outward in-plane normal)
  // At depth >= thickness: n_cos = 0, n_sin = 1 (vertical normal)
  // Between: smooth circular arc transition
  float thickness = max(uThickness, 1.0);
  float x = clamp(thickness + sd, 0.0, thickness);
  float height = sqrt(max(0.0, thickness * thickness - x * x));

  float n_cos = x / thickness;
  float n_sin = sqrt(max(0.0, 1.0 - n_cos * n_cos));

  // 3D surface normal:
  vec3 normal = normalize(vec3(boundaryNormal * n_cos, n_sin));

  // Snell's law refraction:
  // Incident ray from viewer looking straight down: (0, 0, -1)
  vec3 incident = vec3(0.0, 0.0, -1.0);
  float eta = 1.0 / max(uRefractiveIndex, 1.0);
  vec3 refracted = refract(incident, normal, eta);

  // Lateral displacement:
  // Center: n_cos = 0 -> normal = (0,0,1) -> refracted = (0,0,-1) -> displacement = (0,0).
  // This guarantees a completely calm, stable, legible center!
  // Edge: strong inward displacement proportional to optical depth.
  float optDepth = height + uBaseHeight;
  vec2 disp = refracted.xy * (optDepth / max(abs(refracted.z), 0.2)) * (motionFactor * refrStrength);

  // Background texture sampling:
  vec4 bgCol;
  float effDispersion = uDispersion * motionFactor;
  if (effDispersion <= 0.001) {
    bgCol = tap(p + disp);
  } else {
    float redOff = 1.0 + effDispersion;
    float blueOff = 1.0 - effDispersion;
    float rChannel = tap(p + disp * redOff).r;
    vec4 gSample = tap(p + disp);
    float bChannel = tap(p + disp * blueOff).b;
    bgCol = vec4(rChannel, gSample.g, bChannel, gSample.a);
  }

  // During motion: subtle refractive edge sheen to define the moving lens boundary
  float edgeSheen = pow(n_cos, 2.5) * motionFactor * max(uSpecular, 0.0);
  vec3 col = bgCol.rgb + vec3(edgeSheen);

  // Antialiasing: smooth transition from refracted interior to unaffected exterior
  float aa = 1.0 - smoothstep(0.0, 1.5, sd);
  fragColor = mix(tap(p), vec4(col, 1.0), aa);
}
