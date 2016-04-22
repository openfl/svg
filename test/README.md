# SVG Tests

`svg` includes unit tests. These tests render SVGs at different sizes, and compare those images against known, "good" versions. If the images are similar enough, the test passes; otherwise, they fail.

To run the tests, run `haxe test.hxml`. This generates an `svg-tests.html` file in the repository root, which shows a row per image. For each row, it displays:
- The SVG
- The actual (expected) PNG rendering
- The rendered PNG version

The actual (expected) PNG is pre-generated ahead of time using GIMP.

# Adding New Tests

To add a new test, you need to:

- Drop the SVG in `test/images` (eg. `apple.png`)
- Open the SVG in GIMP, and render it to PNG at whatever size you want to render the SVG to. Save it with the filename `<pngname>-<width>x<height>.png` (eg. `apple-64x64.png`).
- Open up `test/SvgGeneration.hx` and add a new test. Something like this:

```
@Test
public function appleScalesUpCorrectly()
{
    generateAndCompare("apple.svg"); // 56x56 (SVG size)
    generateAndCompare("apple.svg", 256, 256);
    generateAndCompare("apple.svg", 137, 137);
}
```

This sample test renders `apple.svg` three times: at its original size (56x56), at 256x256, and 137x137. You need to add three new files to the `test/images` directory:
- `apple-56x56.png`
- `apple-137x137.png`
- `apple-256x256.png`

Run the test and make sure it passes before you commit/push!

# Difference Algorithm

Currently, the tests look at the number of different pixels between the actual and expected PNGs. For example, if an image is 10x10 pixels, and 5 pixels are different, the total image difference is 5%.

If the number of different pixels exceeds a threshold, the rendered PNG is deemed disimilar and the test fails.