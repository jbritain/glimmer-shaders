#ifndef GBUFFER_GLSL
#define GBUFFER_GLSL

vec3 getSurfaceNormal(vec2 texcoord, mat3 tbn){
  vec3 surfaceNormal = texture(normals, texcoord).rgb;
  surfaceNormal = surfaceNormal * 2.0 - 1.0;
  surfaceNormal.z = sqrt(1.0 - dot(surfaceNormal.xy, surfaceNormal.xy)); // reconstruct z due to labPBR encoding

  return tbn * surfaceNormal;
}

#endif