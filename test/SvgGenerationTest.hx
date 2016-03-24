package;

import massive.munit.util.Timer;
import massive.munit.Assert;
import massive.munit.async.AsyncFactory;
import openfl.display.Shape;
import openfl.display.PNGEncoderOptions;
import openfl.display.BitmapData;
import openfl.display.Bitmap;
import sys.io.File;
import format.SVG;

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
				toReturn.push(new SvgTest(file));
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

            var expectedBitmapData:BitmapData = BitmapData.fromFile('${IMAGES_PATH}/${test.fileName}');
            
			var diffPercentage = diffImages(expectedBitmapData, actualBitmapData);
            test.diffPercentage = diffPercentage;

			// TODO: build in some tolerance for slight mis-matches
			if (diffPercentage >= SVG_DIFF_TOLERANCE_PERCENT)
            {
				failedTests.push(test);
			}
            else
            {
				passedTests.push(test);
			}
		}
		var toReturn = new GenerationResults(passedTests, failedTests);
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
			<th>Source Image (SVG)</th>
			<th>Expected (PNG)</th>
			<th>Actual (PNG)</th>
            <th>Diff Percentage</th>";
            

		for (test in tests) {
			var pngFile = test.fileName.replace('.svg', '.png');
			html += '<tr>
				<td><img src="${IMAGES_PATH}/${test.fileName}" width="${test.expectedWidth}" height="${test.expectedHeight}" /><br /></td>
				<td><img src="${IMAGES_PATH}/${pngFile}" /></td>
				<td><img src="${GENERATED_IMAGES_PATH}/${pngFile}" /></td>
                <td>${test.diffPercentage * 100}%</td>
			</tr>';
		}
		html += "</table>";
		return html;
	}
    
    private function diffImages(expected:BitmapData, actual:BitmapData):Float
    {
        return 1;
    }
}

/**
* Encapsulates everything we need to test a single SVG
*/
class SvgTest
{
	// SVG filename, with extension (eg. sun.svg)
	public var fileName(default, default):String;
	public var expectedWidth(default, default):Int;
	public var expectedHeight(default, default):Int;
	public var diffPercentage(default, default):Float;

	private static var renderSizes:String;

	public function new(fileName:String)
	{
		this.fileName = fileName;
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
}
