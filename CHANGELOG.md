SVG Changelog
=============

1.2.0 (04/23/2026)
------------------

- Optimized applying matrix transformations.
- Fixed child styles affecting group styles, which applied them to other siblings.
- Fixed parsing of whitespace in transforms like rotation, scale, and translate.
- Fixed `%` values for gradient stop offset incorrect and `NaN` stop offsets
- Fixed quote parsing in `url()`.
- Fixed path not inheriting stroke, fille and stroke-width from parent group.
- Fixed a second decimal not getting treated as a new float in `PathParser`.
- Fixed arc rendering by drawing with `curveTo()` instead of `lineTo()`.
- Fixed width and height calculation when `viewBox` is present.
- Fixed `T` parsing in `<path d=/>` tag.
- Removed `BitmapDataManager`, which was not used.
