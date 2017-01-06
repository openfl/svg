package;

import massive.munit.util.Timer;
import massive.munit.Assert;
import massive.munit.async.AsyncFactory;

import format.SVG;

import openfl.Assets;
import openfl.display.Shape;
import openfl.display.PNGEncoderOptions;
import openfl.display.BitmapData;
import openfl.display.Bitmap;
import openfl.utils.Object;

import sys.io.File;

using StringTools;

/**
* Tests SVG generation. We run through a list of known (working) SVGs, generating
* them as (usually 256x256, unless the source is smaller) images, and comparing
* those to expected PNGs.
* To aid troubleshooting, this test generates a generation.html file which
* shows both expected and actual values side-by-side, so it's easy to see what
* went wrong in the SVG generation.
*/
class SvgGenerationTest
{
	private static inline var RESULTS_HTML_FILE:String = "svg-tests.html";
	private static inline var IMAGES_PATH:String = "test/images";
	private static inline var GENERATED_IMAGES_PATH:String = "generated";
    // Maximum size we render the expected image to
    private static inline var MAX_IMAGE_SIZE:Int = 256;
    // Percentage difference allowable between expected/actual images
    // Ranges from 0 to 1 (0.1 = 10% diff)
    // Currently at 15% because anti-aliasing artifacts on small images makes a big difference
    private static inline var SVG_DIFF_TOLERANCE_PERCENT:Float = 0.10;
    
    private var results:GenerationResults;
    
	public function new() {	}
    
    @Test
	public function ubuntuLogoRendersCorrectly()
	{
        generateAndCompare("ubuntu-logo-orange.svg", 256, 256);
	}
    
    @Test
    public function allRightsReservedRendersCorrectly()
    {
        // This file is a small circle; it has a lot of anti-aliasing artifacts in the diff.
        // This might be problematic. Hence, we render a larger version (4x).
        generateAndCompare("all_rights_reserved_white.svg", 256, 256);
    }
    
    @Test
    public function fancySunIconRendersCorrectly()
    {
        generateAndCompare("fancy-sun.svg");
    }

    @Test
    public function scaleRectStrokeWidth()
    {
      generateAndCompare("scale_rect.svg", 256, 256);
    }

    @Test
    public function alphaChannelAnd3CharHexColors()
    {
      generateAndCompare("alphachannel.svg", 100, 100);
    }

    @Test
    public function fillColorRGB()
    {
      generateAndCompare("fill_rgb.svg", 100, 100);
    }
    
    @Test
    public function rotatedSquareRendersRotated()
    {
        generateAndCompare("rotated-square.svg", 100, 100);
    }

    @Test
    public function matrixRotatedSquare()
    {
        generateAndCompare("matrix-rotated-square.svg", 100, 100);
    }

    @Test
    public function layerFiltering()
    {
        generateAndCompareTo("layer_test1.svg", "layer_test2.svg");
    }

    @BeforeClass
    public function cleanPreviousTestRunResults() {
        
        this.results = {
            passedTests: new Array<SvgTest>(), failedTests: new Array<SvgTest>()
        };
        
        // Delete the old report
        if (sys.FileSystem.exists(RESULTS_HTML_FILE))
        {
			sys.FileSystem.deleteFile(RESULTS_HTML_FILE);
		}
        
        // Delete generated images path (if it exists)
		if (sys.FileSystem.exists(GENERATED_IMAGES_PATH)) {
			for (file in sys.FileSystem.readDirectory(GENERATED_IMAGES_PATH)) {
				sys.FileSystem.deleteFile('${GENERATED_IMAGES_PATH}/${file}');
			}
		} else {
			sys.FileSystem.createDirectory(GENERATED_IMAGES_PATH);
		}
    }
    
    @AfterClass
    public function createHtmlReport() {
        var total = results.failedTests.length + results.passedTests.length;
        
        var html:String = '<html><head>
		<title>${results.failedTests.length}/${total} failures | SVG Generation Tests</title>
		</head><body style="background-color: #eee">';        
        
        html += this.getReportHtml();
                
        html += "</body></html>";
        
        sys.io.File.saveContent(RESULTS_HTML_FILE, html);
    }
    
    private function generateAndCompare(svgName:String, pngWidth:Int = 0, pngHeight:Int = 0)
    {
        var pngName = generatePng(svgName, pngWidth, pngHeight);
        compareGeneratedToExpected(svgName, pngName);
    }

    private function generateAndCompareTo(svgName1:String, svgName2:String)
    {
        var pngName1 = generatePng(svgName1);
        var pngName2 = generatePng(svgName2, 0, 0, "red");
        compareGeneratedPNGs(pngName1, pngName2);
    }

    // Generates a PNG from an SVG at the specified width/height.
    private function generatePng(svgName:String, pngWidth:Int = 0, pngHeight:Int = 0, ?pLayerID:String = null):String
    {
        var svg = new SVG(File.getContent('${IMAGES_PATH}/${svgName}'));

        // Render to the size of the PNG image representing our "expected" value.
        // If the user passed in a width/height, we use that. Otherwise, we use
        // the original SVG height. If the image is over 256x256, we render it at 256x256
        // (this makes it easier to see in the report).
        var width:Int = pngWidth;
        var height:Int = pngHeight;
        var layerid:String = pLayerID;
        
        if (pngWidth == 0 || pngHeight == 0)
        {
            width = Math.round(svg.data.width);
            height = Math.round(svg.data.height);
        }
        
        // Scale down (proportionally).
        if (width > 256)
        {
            var scale:Float = 256 / width;
            width = 256;
            height = Math.round(height * scale);
        }
        
        if (height > 256)
        {
            var scale:Float = 256 / height;
            height = 256;
            width = Math.round(width * scale);
        }

        var pngFileName = svgName.replace(".svg", '-${width}x${height}.png');
        var outputFile = '${GENERATED_IMAGES_PATH}/${pngFileName}';
        
        // Fully-transparent and white
        var backgroundColor = 0x00FFFFFF;
        var shape = new Shape();
        // scale/render the SVG to this size
        svg.render(shape.graphics, 0, 0, width, height, layerid);

        // generated image size
        var actualBitmapData = new BitmapData(width, height, true, backgroundColor);
        actualBitmapData.draw(shape);

        File.saveBytes(outputFile, actualBitmapData.encode(actualBitmapData.rect, new PNGEncoderOptions()));
        
        return pngFileName;
    }

    // Compares pixels from the generated PNG to the hand-made PNG.
	private function compareGeneratedToExpected(svgName:String, pngName:String)
	{
        var expectedImage:String = '${IMAGES_PATH}/${pngName}';
        if (sys.FileSystem.exists(pngName))
        {
            throw '${expectedImage} doesn\'t exist. Please create it.';
        }
        var expectedBitmapData:BitmapData = BitmapData.fromFile(expectedImage);
        var actualImage:String = '${GENERATED_IMAGES_PATH}/${pngName}';
        var actualBitmapData:BitmapData = BitmapData.fromFile(actualImage);
        
        var test = newSvgTest(svgName);
        
        if (expectedBitmapData.width != actualBitmapData.width || expectedBitmapData.height != actualBitmapData.height)
        {
            test.diffPercentage = 1;
            results.failedTests.push(test);
            Assert.fail('${svgName} generated at the wrong size (expected ${expectedBitmapData.width}x${expectedBitmapData.height}, got ${actualBitmapData.width}x${actualBitmapData.height})');
        }
        else
        {
            test.expectedWidth = expectedBitmapData.width;
            test.expectedHeight = expectedBitmapData.height;
            
            // Calculate the number of pixels that are different from what they should be.
            // Since we're averaging across the entire image, even if a few pixels are
            // drastically different, if the overall images are similar, we get a small diff.
            // We use BitmapData.compare to generate the "diff image" between two images.
            // The diff image has one non-transparent pixel for every pixel that differs.
            // Because of the way it calculates transparency, the safest way to know if
            // there's a diff is to get the pixel RGB values (not RGBA).
            // To see how this diff image works, just replace any SVG with a coloured rectangle and re-run the tests.
            var result:Object = actualBitmapData.compare(expectedBitmapData);
            var numPixelsThatAreDifferent:Int = 0;
            
            if (result == 0)
            {
                // A rare, but awesome, exact match!
                results.passedTests.push(test);
            }
            else
            {
                var diffPixels = cast(result, BitmapData);
                
                for (y in 0 ... diffPixels.height)
                {
                    for (x in 0 ... diffPixels.width)
                    {
                        var diffPixel = diffPixels.getPixel(x, y);
                        // Extract RGB values
                        var components = getComponents(diffPixel);
                        var red = components[0];
                        var green = components[1];
                        var blue = components[2];
                        if (red > 0 || green > 0 || blue > 0)
                        {
                            numPixelsThatAreDifferent++;                        
                        }                        
                    }
                }
                
                // Average over all pixels in the image
                var culmulativeDiff:Float = numPixelsThatAreDifferent / (diffPixels.width * diffPixels.height);
                test.diffPixels = diffPixels;
                test.diffPercentage = culmulativeDiff;
                var diffPngFile = svgName.replace(".svg", '-${test.expectedWidth}x${test.expectedHeight}-diff.png');
                var diffFile:String = '${GENERATED_IMAGES_PATH}/${diffPngFile}';
                File.saveBytes(diffFile, diffPixels.encode(diffPixels.rect, new PNGEncoderOptions()));                
                
                if (culmulativeDiff >= SVG_DIFF_TOLERANCE_PERCENT)
                {
                    results.failedTests.push(test);
                    Assert.fail('${svgName} has ${Math.round(culmulativeDiff * 100)}% pixels different, which is over the threshold of ${SVG_DIFF_TOLERANCE_PERCENT * 100}%');                
                }
                else
                {
                    results.passedTests.push(test);
                } 
            }
        }
	}
    
    // Compares 2 generated PNGs
    private function compareGeneratedPNGs(pngName1:String, pngName2:String)
    {

        var actualImage1:String = '${GENERATED_IMAGES_PATH}/${pngName1}';
        var actualBitmapData1:BitmapData = BitmapData.fromFile(actualImage1);

        var actualImage2:String = '${GENERATED_IMAGES_PATH}/${pngName2}';
        var actualBitmapData2:BitmapData = BitmapData.fromFile(actualImage2);
        
        var test = newSvgTest(pngName1);
        
        // Calculate the number of pixels that are different from what they should be.
        // Since we're averaging across the entire image, even if a few pixels are
        // drastically different, if the overall images are similar, we get a small diff.
        // We use BitmapData.compare to generate the "diff image" between two images.
        // The diff image has one non-transparent pixel for every pixel that differs.
        // Because of the way it calculates transparency, the safest way to know if
        // there's a diff is to get the pixel RGB values (not RGBA).
        // To see how this diff image works, just replace any SVG with a coloured rectangle and re-run the tests.
        var result:Object = actualBitmapData1.compare(actualBitmapData2);
        var numPixelsThatAreDifferent:Int = 0;
        
        if (result == 0)
        {
            // Expected match if layers filtered correctly
            results.passedTests.push(test);
        }
        else
        {
            var diffPixels = cast(result, BitmapData);
            
            for (y in 0 ... diffPixels.height)
            {
                for (x in 0 ... diffPixels.width)
                {
                    var diffPixel = diffPixels.getPixel(x, y);
                    // Extract RGB values
                    var components = getComponents(diffPixel);
                    var red = components[0];
                    var green = components[1];
                    var blue = components[2];
                    if (red > 0 || green > 0 || blue > 0)
                    {
                        numPixelsThatAreDifferent++;
                    }
                }
            }
            
            // Average over all pixels in the image
            var culmulativeDiff:Float = numPixelsThatAreDifferent / (diffPixels.width * diffPixels.height);
            test.diffPixels = diffPixels;
            test.diffPercentage = culmulativeDiff;
            var diffPngFile = pngName1.replace(".png", '-diff.png');
            var diffFile:String = '${GENERATED_IMAGES_PATH}/${diffPngFile}';
            File.saveBytes(diffFile, diffPixels.encode(diffPixels.rect, new PNGEncoderOptions()));
            
            if (culmulativeDiff >= SVG_DIFF_TOLERANCE_PERCENT)
            {
                results.failedTests.push(test);
                Assert.fail('${pngName2} differs from ${pngName1} by ${Math.round(culmulativeDiff * 100)}% pixels, which is over the threshold of ${SVG_DIFF_TOLERANCE_PERCENT * 100}%');
            }
            else
            {
                results.passedTests.push(test);
            }
        }
    }

    // Given a pixel (0xRRGGBB), return an array [RR, GG, BB]
    // Components are integer values from 0..255
    private function getComponents(pixel:Int):Array<Int>
    {
        // No difference (empty pixel)? Skip calculations.
        if (pixel <= 0)
        {
            return [0, 0, 0];
        }
        
        var blue:Int = pixel & 0xFF; // BB
        var green:Int = (pixel >> 8) & 0xFF; // GG
        var red:Int = (pixel >> 16) & 0xFF; // RR
        var toReturn = [red, green, blue];
        return toReturn;
    }

	// Returns the HTML report
	private function getReportHtml():String
	{
		// Failures first, because we care about fixing those
		var html:String = createTableFor(results.failedTests, "Failures");
		html += createTableFor(results.passedTests, "Successes");        
        return html;
	}

	private function createTableFor(tests:Array<SvgTest>, header:String):String
	{
        var html:String = '<h1>${tests.length} ${header}</h1>
        <table><tr>
			<th>Expected (PNG)</th>
			<th>Actual (PNG)</th>
            <th>Diff Image</th>
            <th>Average Pixel Diff %</th>
        </tr>';
        
		for (test in tests) {
			var pngFile = test.fileName.replace('.svg', '-${test.expectedWidth}x${test.expectedHeight}.png');
			var diffFile = test.fileName.replace('.svg', '-${test.expectedWidth}x${test.expectedHeight}-diff.png');
			html += '<tr>
				<td><img src="${IMAGES_PATH}/${pngFile}" /></td>
				<td><img src="${GENERATED_IMAGES_PATH}/${pngFile}" /></td>';
            var diffFilePath = '${GENERATED_IMAGES_PATH}/${diffFile}';
            if (sys.FileSystem.exists(diffFilePath))
            {
				html += '<td><img src="${GENERATED_IMAGES_PATH}/${diffFile}" /></td>';
            }
            else
            {
                html += '<td>(No difference)</td>';
            }
            
            html += '<td>${test.diffPercentage * 100}%</td></tr>';
		}
		html += "</table>";
		return html;
	}
    
    private function newSvgTest(fileName:String):SvgTest
    {
        return {fileName: fileName,
            expectedWidth: 0, expectedHeight: 0,
            diffPixels: null, diffPercentage: 0 };        
    }
}

/**
* Encapsulates everything we need to test a single SVG
*/
typedef SvgTest =
{
	// SVG filename, with extension (eg. sun.svg)
	var fileName:String;
	var expectedWidth:Int;
	var expectedHeight:Int;
    var diffPixels:BitmapData;
	var diffPercentage:Float;
}

typedef GenerationResults =
{
	var passedTests:Array<SvgTest>;
	var failedTests:Array<SvgTest>;
}
