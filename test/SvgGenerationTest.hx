package;

import massive.munit.util.Timer;
import massive.munit.Assert;
import massive.munit.async.AsyncFactory;

import format.SVG;
import openfl.display.Shape;
import openfl.display.PNGEncoderOptions;
import openfl.display.BitmapData;
import openfl.display.Bitmap;
import openfl.Assets;

import sys.io.File;

using StringTools;

class SvgGenerationTest
{
	private static inline var RESULTS_HTML_FILE:String = "svg-tests.html";
	private static inline var IMAGES_PATH:String = "test/images";
	private static inline var GENERATED_IMAGES_PATH:String = "generated";
    // Maximum size we render the expected image to
    private static inline var MAX_IMAGE_SIZE:Int = 256;
    // Percentage difference allowable between expected/actual images
    // Ranges from 0 to 1 (0.1 = 10% diff)
    private static inline var SVG_DIFF_TOLERANCE_PERCENT:Float = 0.1;
    
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
				toReturn.push(newSvgTest(file));
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
                        
                        var redDiff:Float = Math.abs(expectedPixel[0] - actualPixel[0]) / 255.0;
                        var greenDiff:Float = Math.abs(expectedPixel[1] - actualPixel[1]) / 255.0;
                        var blueDiff:Float = Math.abs(expectedPixel[2] - actualPixel[2]) / 255.0;
                        var alphaDiff:Float = Math.abs(expectedPixel[3] - actualPixel[3]) / 255.0;
                        
                        // Average of RGBA diffs
                        var percentDiff = (redDiff + greenDiff + blueDiff + alphaDiff) / 4;
                        culmulativeDiff += percentDiff;
                    }
                }
                
                test.diffPixels = diffPixels;
                test.diffPercentage = culmulativeDiff / (width * height);
                var diffFile:String = '${GENERATED_IMAGES_PATH}/${test.fileName.replace(".svg", "-diff.png")}';
                File.saveBytes(diffFile, diffPixels.encode(diffPixels.rect, new PNGEncoderOptions()));                
                
			    if (culmulativeDiff >= SVG_DIFF_TOLERANCE_PERCENT)
                {
                    passedTests.push(test);
                }
                else
                {
                    failedTests.push(test);
                }             
            }
		}
		var toReturn = { passedTests: passedTests, failedTests: failedTests };
		return toReturn;
	}

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
			</tr>';
		}
		html += "</table>";
		return html;
	}
    
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
