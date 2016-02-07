package;

import massive.munit.util.Timer;
import massive.munit.Assert;
import massive.munit.async.AsyncFactory;
<<<<<<< HEAD
import openfl.display.Shape;
import openfl.display.PNGEncoderOptions;
import openfl.display.BitmapData;
import sys.io.File;
import format.SVG;
=======
import format.SVG;
import openfl.display.Shape;
import openfl.display.BitmapData;
import openfl.display.PNGEncoderOptions;
import sys.io.File;
>>>>>>> Recover lost code; get SVG test generation to work.

using StringTools;

class SvgGenerationTest
{
	private static inline var RESULTS_HTML_FILE = "svg-tests.html";
	private static inline var IMAGES_PATH = "test/images";
	private static inline var GENERATED_IMAGES_PATH = "generated";

	public function new() {	}

	/**
	* Tests SVG generation. We run through a list of known (working) SVGs, generating
<<<<<<< HEAD
	* them as (usually) 256x256 images, and comparing those to expected PNGs.
=======
	* them as images, and comparing those to expected PNGs.
>>>>>>> Recover lost code; get SVG test generation to work.
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
				toReturn.push(new SvgTest(file, 256, 256));
=======
				toReturn.push(new SvgTest(file));
>>>>>>> Recover lost code; get SVG test generation to work.
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
<<<<<<< HEAD

			var actualFile = '${GENERATED_IMAGES_PATH}/${test.fileName.replace(".svg", ".png")}';

			// Generate the SVG (starts here)
			var inputPath = '${IMAGES_PATH}/${test.fileName}';

			var svg = new SVG(File.getContent(inputPath));
			var width = svg.data.width;
			var height = svg.data.height;

			var backgroundColor = 0x00FFFFFF;

			var shape = new Shape();
=======
			// Generate the SVG (starts here)
			var svg = new SVG (File.getContent('${IMAGES_PATH}/${test.fileName}'));

			var actualFile = '${GENERATED_IMAGES_PATH}/${test.fileName.replace(".svg", ".png")}';
			var width = Math.round(svg.data.width);
			var height = Math.round(svg.data.height);

			var backgroundColor = 0x00FFFFFF;
			var shape = new Shape ();
>>>>>>> Recover lost code; get SVG test generation to work.
			svg.render(shape.graphics, 0, 0, width, height);

			var bitmapData = new BitmapData(width, height, true, backgroundColor);
			bitmapData.draw(shape);

<<<<<<< HEAD
			trace('Saving to ${actualFile} ...');
			File.saveBytes(actualFile, bitmapData.encode(bitmapData.rect, new PNGEncoderOptions()));
=======
			File.saveBytes (actualFile, bitmapData.encode(bitmapData.rect, new PNGEncoderOptions()));
>>>>>>> Recover lost code; get SVG test generation to work.
			// Generate the SVG (ends here)

			// Compare expected and actual
			var expectedHash = haxe.crypto.Md5.encode(sys.io.File.getContent('${IMAGES_PATH}/${test.fileName}'));
			var actualHash = haxe.crypto.Md5.encode(sys.io.File.getContent(actualFile));

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

	// Creates the HTML report
	private function createHtmlReport(results:GenerationResults)
	{
<<<<<<< HEAD
		var html:String = '<html><head><title>${results.failedTests.length} failures | SVG Generation Tests</title>
		</head><body style="background-color: #eee;">';
=======
		var html:String = '<html><head>
		<title>${results.failedTests.length} failures | SVG Generation Tests</title>
		</head><body style="background-color: #eee">';
>>>>>>> Recover lost code; get SVG test generation to work.

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
<<<<<<< HEAD
		html += "<table><tr><th>SVG File Name</th><th>Original (SVG)</th><th>Expected (PNG)</th><th>Actual (PNG)</th>";
=======
		html += "<table><tr>
			<th>Image File</th>
			<th>Source Image (SVG)</th>
			<th>Expected (PNG)</th>
			<th>Actual (PNG)</th>";
>>>>>>> Recover lost code; get SVG test generation to work.

		for (test in tests) {
			var pngFile = test.fileName.replace('.svg', '.png');
			html += '<tr>
				<td><a href="${IMAGES_PATH}/${test.fileName}">${test.fileName}</a></td>
				<td><img src="${IMAGES_PATH}/${test.fileName}" /></td>
<<<<<<< HEAD
				<td><img src="${IMAGES_PATH}/${pngFile}" /><br />${test.expectedHash}</td>
				<td><img src="${GENERATED_IMAGES_PATH}/${pngFile}" /><br />${test.actualHash}</td>
=======
				<td><img src="${IMAGES_PATH}/${pngFile}" /></td>
				<td><img src="${GENERATED_IMAGES_PATH}/${pngFile}" /></td>
>>>>>>> Recover lost code; get SVG test generation to work.
			</tr>';
		}
		html += "</table>";
		return html;
	}
}

/**
* Encapsulates everything we need to test a single SVG
*/
class SvgTest
{
	// SVG filename, with extension (eg. sun.svg)
	public var fileName(default, default):String;

<<<<<<< HEAD
	public var expectedHash(default, default):String;
	public var actualHash(default, default):String;

=======
>>>>>>> Recover lost code; get SVG test generation to work.
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
