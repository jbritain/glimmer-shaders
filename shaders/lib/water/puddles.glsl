#ifndef PUDDLES_GLSL
#define PUDDLES_GLSL

float overlayBlend(float a, float b) {
  return a < 0.5
    ? 2.0 * a * b
    : 1.0 - 2.0 * (1.0 - a) * (1.0 - b);
}

void applyPuddles(
  inout Material material,
  float heightMap,
  vec3 worldPos,
  inout vec3 mappedNormal,
  vec3 geometryNormal,
  float skyLightmap
) {
  vec2 noisePos = fract(worldPos.xz / 128.0);
  float noise = texture(perlinNoiseTex, noisePos).r;

  noise *= wetness;
  noise *= saturate(dot(geometryNormal, gbufferModelView[1].xyz));
  noise *= smoothstep(0.8, 1.0, skyLightmap);

  noise = noise * 1.8;

  noise = clamp01(noise + (1.0 - heightMap) * 2.0 - 0.2);

  // if porosity is less than 0.5, we make the puddles larger as it approaches zero, but only below 0.5 on the heightMap
  if (material.porosity < 0.5 && material.porosity != 0.0) {
    noise += float(heightMap < 0.5) * (1.0 - material.porosity);
  } else if (material.porosity != 0.0) {
    // otherwise we make the dark parts wider but the wet parts smaller
    noise = mix(noise, 0.5, material.porosity);
  }

  // darkening around and in puddle
  material.albedo *= (1.0 - smoothstep(0.7, 0.8, noise)) * 0.5 + 0.5;

  // mix with water material
  material.roughness = mix(material.roughness, 0.0, noise);
  material.f0 = mix(material.f0, vec3(0.02), noise);

  // flatten normal as it gets wetter
  mappedNormal = normalize(mix(mappedNormal, geometryNormal, noise));

}

#endif // PUDDLES_GLSL
