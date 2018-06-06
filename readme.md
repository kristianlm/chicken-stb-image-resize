  [CHICKEN]: http://call-cc.org
  [stb_image_resize.h]: https://github.com/nothings/stb

# chicken-stb-image

This is a [CHICKEN] egg that wraps [stb_image_resize.h] version 0.95
from Jorge L Rodriguez and friends. It works on [CHICKEN] 4 and 5.

# API

    [procedure] (image-resize pixels width height channels target-width target-height #!key filter region)

Takes in raw `pixels` (a srfi-4 u8/u16/u32/f32vector) of size
`width`*`height`*`channels` and returns raw pixels after resizing. The
returned type is the same as `pixels`' of size
`target-width`*`target-height`*`channels`.

`channels` must be 1, 2, 3 or 4.

- `filter:` one of `box`, `triangle`, `cubicbspline`, `catmullrom` or
  the default `mitchell`.
- `region:` a vector of 4 elements `s0 t0 s1 t1`, representing the
  UV-coordinates to use as source image. This can be used to crop the
  image. These values must be in the range of `[0, 1]` and represent
  the fraction of the input image. `#(0 0 0.5 1)`, for example, cuts
  off the right half of the image.