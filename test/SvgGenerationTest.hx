package;

import massive.munit.util.Timer;
import massive.munit.Assert;
import massive.munit.async.AsyncFactory;
<<<<<<< HEAD

import format.SVG;
=======
>>>>>>> 697633feec7af2c452dc91db80e078b3e9bac541
import openfl.display.Shape;
import openfl.display.PNGEncoderOptions;
import openfl.display.BitmapData;
import openfl.display.Bitmap;
<<<<<<< HEAD
import openfl.Assets;

import sys.io.File;
=======
import sys.io.File;
import format.SVG;
>>>>>>> 697633feec7af2c452dc91db80e078b3e9bac541

using StringTools;

class SvgGenerationTest
{
<<<<<<< HEAD
	private static inline var RESULTS_HTML_FILE:String = "svg-tests.html";
	private static inline var IMAGES_PATH:String = "test/images";
	private static inline var GENERATED_IMAGES_PATH:String = "generated";
    // Maximum size we render the expected image to
    private static inline var MAX_IMAGE_SIZE:Int = 256;
    // Percentage difference allowable between expected/actual images
    // Ranges from 0 to 1 (0.1 = 10% diff)
    private static inline var SVG_DIFF_TOLERANCE_PERCENT:Float = 0.01;
    
=======
	private static inline var RESULTS_HTML_FILE = "svg-tests.html";
	private static inline var IMAGES_PATH = "test/images";
	private static inline var GENERATED_IMAGES_PATH = "generated";

>>>>>>> 697633feec7af2c452dc91db80e078b3e9bac541
	public function new() {	}

	/**
	* Tests SVG generation. We run through a list of known (working) SVGs, generating
	* them as (usually 256x256, unless the source is smaller) images, and comparing
	// those to expected PNGs.
	* To aid troubleshooting, this test generates a generation.html file which
	* shows both expected and actual values side-by-side, so it's easy to see what
	* went wrong in the SVG generation.
	*/
	@Test
	public function testSvgGeneration():Void
	{
		var testCases:Array<SvgTest> = getSvgsFromDisk();

		var results = generateAndCompare(testCases);
		createHtmlReport(results);

		if (results.failedTests.length > 0) {
			Assert.fail('SVG generation for ${results.failedTests.length} cases did not match expectations. Check ${RESULTS_HTML_FILE} to see failures.');
		}
	}

	// Returns a list of test cases
	private function getSvgsFromDisk() : Array<SvgTest>
	{
		var toReturn = new Array<SvgTest>();
		var files = sys.FileSystem.readDirectory(IMAGES_PATH);

		for (file in files) {
			if (file.indexOf('.svg') > -1) {
				// Fail fast if someone added an SVG without a PNG
				var pngFile:String = file.replace(".svg", ".png");
				if (files.indexOf(pngFile) == -1) {
					throw 'Found svg to test (${file}) without PNG of how it should look (${pngFile})';
				}
<<<<<<< HEAD
				toReturn.push(newSvgTest(file));
=======
				toReturn.push(new SvgTest(file));
>>>>>>> 697633feec7af2c452dc91db80e078b3e9bac541
			}
		}

		return toReturn;
	}

	// Returns a list of failures
	private function generateAndCompare(svgTests:Array<SvgTest>) : GenerationResults
	{
		// Delete generated images path (if it exists)
		if (sys.FileSystem.exists(GENERATED_IMAGES_PATH)) {
			for (file in sys.FileSystem.readDirectory(GENERATED_IMAGES_PATH)) {
				sys.FileSystem.deleteFile('${GENERATED_IMAGES_PATH}/${file}');
			}
		} else {
			sys.FileSystem.createDirectory(GENERATED_IMAGES_PATH);
		}

		var passedTests = new Array<SvgTest>();
		var failedTests = new Array<SvgTest>();

		for (test in svgTests) {
			// Generate the SVG (starts here)
			var svg = new SVG(File.getContent('${IMAGES_PATH}/${test.fileName}'));
			var outputFile = '${GENERATED_IMAGES_PATH}/${test.fileName.replace(".svg", ".png")}';

<<<<<<< HEAD
			// Render to the size of the PNG image representing our "expected" value.
            // We want to test rendering properly. So we render to the smaller of the
            // SVG size and 256x256.
			var width:Int = Math.round(svg.data.width);
            if (width > 256)
            {
                width = 256;
            }
                        
			var height:Int = Math.round(svg.data.height);
            if (height > 256)
            {
                height = 256;
            }

			var backgroundColor = 0x00FFFFFF;
			var shape = new Shape();
            // scale/render the SVG to this size
			svg.render(shape.graphics, 0, 0, width, height);

            // generated image size
			var actualBitmapData = new BitmapData(width, height, true, backgroundColor);
			actualBitmapData.draw(shape);

			File.saveBytes(outputFile, actualBitmapData.encode(actualBitmapData.rect, new PNGEncoderOptions()));
			// Generate the SVG (ends here)

            var expectedImage:String = '${IMAGES_PATH}/${test.fileName.replace(".svg", ".png")}';
            var expectedBitmapData:BitmapData = BitmapData.fromFile(expectedImage);
            
			if (expectedBitmapData.width != actualBitmapData.width || expectedBitmapData.height != actualBitmapData.height)
            {
				failedTests.push(test);
            }
            else
            {
                // Calculate the average actual-value pixel diff from the expected-value pixel
                // Since we're averaging across the entire image, even if a few pixels are
                // drastically different, if the overall images are similar, we get a small diff.
                var diffPixels:BitmapData = actualBitmapData.compare(expectedBitmapData);
                var culmulativeDiff:Float = 0;
                for (y in 0 ... diffPixels.height)
                {
                    for (x in 0 ... diffPixels.width)
                    {
                        var expectedPixel = getComponents(expectedBitmapData.getPixel32(x, y));
                        var actualPixel = getComponents(actualBitmapData.getPixel32(x, y));
                        
                        var percentDiff = diffPixelsRgba(expectedPixel, actualPixel);
                        culmulativeDiff += percentDiff;
                    }
                }
                
                // Average over all pixels
                culmulativeDiff = culmulativeDiff / (width * height);
                test.diffPixels = diffPixels;
                test.diffPercentage = culmulativeDiff;
                var diffFile:String = '${GENERATED_IMAGES_PATH}/${test.fileName.replace(".svg", "-diff.png")}';
                File.saveBytes(diffFile, diffPixels.encode(diffPixels.rect, new PNGEncoderOptions()));                
                
			    if (culmulativeDiff >= SVG_DIFF_TOLERANCE_PERCENT)
                {
                    failedTests.push(test);
                }
                else
                {
                    passedTests.push(test);
                }             
            }
		}
		var toReturn = { passedTests: passedTests, failedTests: failedTests };
		return toReturn;
	}
    
    // Given expected/actual pixels, calculate the RGBA diff as a percentage of
    // deviation from the expected pixel.
    // Eg. if a pixel's expected red value is 255 and actual is 64, return 0.75 (191/255).
    // The input is the array [r, g, b, a] with values from 0..255
    private function diffPixelsRgba(expectedPixel:Array<Int>, actualPixel:Array<Int>):Float
    {
        // Special case: if expected or actual are [0, 0, 0, 0] but the other isn't, return 100%
        // Usually, all four components are zero. But we don't check, because it makes the if
        // statement very, very tedious to read.
        var expectedIsZero = expectedPixel[3] == 0;
        var actualIsZero = actualPixel[3] == 0;
        if ((expectedIsZero || actualIsZero) && !(expectedIsZero && actualIsZero))
        {
            return 1;
        }
        var redDiff:Float = Math.abs(expectedPixel[0] - actualPixel[0]) / 255.0;
        var greenDiff:Float = Math.abs(expectedPixel[1] - actualPixel[1]) / 255.0;
        var blueDiff:Float = Math.abs(expectedPixel[2] - actualPixel[2]) / 255.0;
        var alphaDiff:Float = Math.abs(expectedPixel[3] - actualPixel[3]) / 255.0;
        
        // Average of RGBA diffs
        var percentDiff = (redDiff + greenDiff + blueDiff + alphaDiff) / 4;
        return percentDiff;
    }
=======
			// Render to the size of the PNG image representing our "expected" value
			// We can't easily load the image and get the size, so instead, we pull
			// size data from render_size.txt. For more details, see the SvgTest constructor.
			var width:Int = test.expectedWidth; //Math.round(svg.data.width);
			var height:Int = test.expectedHeight; //Math.round(svg.data.height);

			var backgroundColor = 0x00FFFFFF;
			var shape = new Shape ();
			svg.render(shape.graphics, 0, 0, width, height);

			var bitmapData = new BitmapData(width, height, true, backgroundColor);
			bitmapData.draw(shape);

			File.saveBytes(outputFile, bitmapData.encode(bitmapData.rect, new PNGEncoderOptions()));
			// Generate the SVG (ends here)

			// Compare expected and actual
			var expectedHash = haxe.crypto.Md5.encode(sys.io.File.getContent('${IMAGES_PATH}/${test.fileName}'));
			var actualHash = haxe.crypto.Md5.encode(sys.io.File.getContent(outputFile));

			test.expectedHash = expectedHash;
			test.actualHash = actualHash;

			// TODO: build in some tolerance for slight mis-matches
			if (expectedHash != actualHash) {
				failedTests.push(test);
			} else {
				passedTests.push(test);
			}
		}
		var toReturn = new GenerationResults(passedTests, failedTests);
		return toReturn;
	}
>>>>>>> 697633feec7af2c452dc91db80e078b3e9bac541

	// Creates the HTML report
	private function createHtmlReport(results:GenerationResults)
	{
		var html:String = '<html><head>
		<title>${results.failedTests.length} failures | SVG Generation Tests</title>
		</head><body style="background-color: #eee">';

		// TODO: beautify HTML.
		var total = results.failedTests.length + results.passedTests.length;
		// Failures first, because we care about fixing those
		html += createTableFor(results.failedTests, "Failures");
		html += createTableFor(results.passedTests, "Successes");

		html = '${html}</body></html>';

		if (sys.FileSystem.exists(RESULTS_HTML_FILE)) {
			sys.FileSystem.deleteFile(RESULTS_HTML_FILE);
		}
		sys.io.File.saveContent(RESULTS_HTML_FILE, html);
	}

	private function createTableFor(tests:Array<SvgTest>, header:String) : String
	{
		var html:String = '<h1>${tests.length} ${header}</h1>';
		html += "<table><tr>
<<<<<<< HEAD
			<th>Expected (PNG)</th>
			<th>Actual (PNG)</th>
            <th>Diff Image</th>
            <th>Average Pixel Diff %</th>";
            

		for (test in tests) {
			var pngFile = test.fileName.replace('.svg', '.png');
			var diffFile = test.fileName.replace('.svg', '-diff.png');
			html += '<tr>
				<td><img src="${IMAGES_PATH}/${pngFile}" /></td>
				<td><img src="${GENERATED_IMAGES_PATH}/${pngFile}" /></td>
				<td><img src="${GENERATED_IMAGES_PATH}/${diffFile}" /></td>                
                <td>${test.diffPercentage * 100}%</td>
=======
			<th>Image File</th>
			<th>Source Image (SVG)</th>
			<th>Expected (PNG)</th>
			<th>Actual (PNG)</th>";

		for (test in tests) {
			var pngFile = test.fileName.replace('.svg', '.png');
			html += '<tr>
				<td><a href="${IMAGES_PATH}/${test.fileName}">${test.fileName}</a></td>
				<td><img src="${IMAGES_PATH}/${test.fileName}" width="${test.expectedWidth}" height="${test.expectedHeight}" /><br /></td>
				<td><img src="${IMAGES_PATH}/${pngFile}" /><br />${test.expectedHash}</td>
				<td><img src="${GENERATED_IMAGES_PATH}/${pngFile}" /><br />${test.actualHash}</td>
>>>>>>> 697633feec7af2c452dc91db80e078b3e9bac541
			</tr>';
		}
		html += "</table>";
		return html;
	}
<<<<<<< HEAD
    
    // Given a pixel (0xAARRGGBB), return an array [RR, GG, BB, AA]
    // Components are integer values from 0..255
    private function getComponents(pixel:Int):Array<Int>
    {
        // No difference (empty pixel)? Skip calculations.
        if (pixel <= 0)
        {
            return [0, 0, 0, 0];
        }
        
        var blue:Int = 0xFFBB8844 & 0xFF; // BB
        var green:Int = (0xFFBB8844 >> 8) & 0xFF; // GG
        var red:Int = (0xFFBB8844 >> 16) & 0xFF; // RR
        var alpha:Int = (0xFFBB8844 >> 24) & 0xFF; // AA
        var toReturn = [red, green, blue, alpha];
        return toReturn;
    }
    
    private function newSvgTest(fileName:String):SvgTest
    {
        return {fileName: fileName,
            expectedWidth: 0, expectedHeight: 0,
            diffPixels: null, diffPercentage: 0 };        
    }
=======
>>>>>>> 697633feec7af2c452dc91db80e078b3e9bac541
}

/**
* Encapsulates everything we need to test a single SVG
*/
<<<<<<< HEAD
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
=======
class SvgTest
{
	// SVG filename, with extension (eg. sun.svg)
	public var fileName(default, default):String;
	public var expectedWidth(default, default):Int;
	public var expectedHeight(default, default):Int;

	public var expectedHash(default, default):String;
	public var actualHash(default, default):String;

	private static var renderSizes:String;

	// By default, assumes every test case should render at 256x256
	// If there's an entry for the SVG file in render_size.txt, that size is used.
	public function new(fileName:String)
	{
		if (renderSizes == null) {
			renderSizes = File.getContent('test/render_size.txt');
		}

		this.fileName = fileName;
		var regex = new EReg('${fileName}: (\\d+)x(\\d+)', "i");
		if (regex.match(renderSizes)) {
			this.expectedWidth = Std.parseInt(regex.matched(1));
			this.expectedHeight = Std.parseInt(regex.matched(2));
		} else {
			this.expectedWidth = 256;
			this.expectedHeight = 256;
		}
	}
}

class GenerationResults
{
	public var passedTests(default, null):Array<SvgTest>;
	public var failedTests(default, null):Array<SvgTest>;

	public function new(passedTests:Array<SvgTest>, failedTests:Array<SvgTest>)
	{
		this.passedTests = passedTests;
		this.failedTests = failedTests;
	}
>>>>>>> 697633feec7af2c452dc91db80e078b3e9bac541
}
