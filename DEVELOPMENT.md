```
---Buffers---
    0: Main Scene Colour
    1: Material Data
    2: Normals
    3: History buffer
    4: Bloom Colour
    5: 
    6: 
    7: Sky LUT for rough reflections

---Passes---
    setup           : Compute transmittance LUT for atmosphere
    setup1          : Compute multiple scattering LUT for atmosphere

    prepare         : Compute sky view LUT
    prepare1        : Generate sky reflection LUT
    prepare2        : Compute skylight colour by taking several hemisphere samples & Generate mipmaps for sky reflection LUT
    prepare3        : Generate aerial perspective LUT




    shadowcomp      : Floodfill propagation

    deferred        : Render sky
    deferred1       : Distant Horizons SSAO

    composite       : Generate combined depth buffer
    composite1      : Godrays mask
    composite2      : VL/Godrays
    composite3      : Water & water fog


    composite4      : Godrays
    composite5      : Fog

    composite49     : Write luminance for auto exposure
    composite50     : Exposure

    composite51     : Motion blur

    composite80-88  : Bloom
    composite89     : Temporal filter

    composite90     : FXAA
```

Glimmer makes use of a primarily forward rendered pipeline, with the exception of water, which is done deferred. Likewise, fog is also handled in a deferred manner.

A modified version of block_wrangler is used to manage block IDs - if you need to modify them, see `scripts/block_properties.py`.
