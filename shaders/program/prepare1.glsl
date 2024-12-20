#include "/lib/common.glsl"

#ifdef csh

layout (local_size_x = 1, local_size_y = 1) in;
const ivec3 workGroups = ivec3(1, 1, 1);

#include "/lib/common.glsl"

#include "/lib/atmosphere/sky/sky.glsl"

void main()
{
    const int samples = 4;

    // skylightColor += getSky(vec3(0.0, 1.0, 0.0), false);

    // take a few evenly distributed hemisphere samples
    for(int i = 0; i < samples; i++){
        float phi = float(i) * 2.0 * PI / float(samples);
        float theta = acos(1.0 - 2.0 * float(i) + 0.5) / float(samples);

        vec3 dir = vec3(
            sin(theta) * cos(phi),
            sin(theta) * sin(phi),
            cos(theta)
        );

        skylightColor += getSky(dir, false);
    }
    skylightColor /= float(samples);
}

#endif