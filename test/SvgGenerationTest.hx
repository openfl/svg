package;

import massive.munit.util.Timer;
import massive.munit.Assert;
import massive.munit.async.AsyncFactory;

using StringTools;

class SvgGenerationTest
{
	private static inline var RESULTS_HTML_FILE = "svg-tests.html";
	private static inline var IMAGES_PATH = "test/images";
	private static inline var GENERATED_IMAGES_PATH = "generated";

	public function new() {	}

	/**
	* Tests SVG generation. We run through a list of known (working) SVGs, generating
	* them as (usually) 128x128 images, and comparing those to expected PNGs.
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
			var failureNames = "";
			for (failure in results.failedTests) {
				failureNames = '${failureNames}${failure.fileName}, ';
			}
			Assert.fail('SVG generation for ${results.failedTests.length} cases did not match expectations. Check ${RESULTS_HTML_FILE} to see failures. Images: ${failureNames}');
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
				toReturn.push(new SvgTest(file, 128, 128));
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
			// Generate the SVG
			/*
			var svg:SVG = new SVG(Assets.getText(test.fileName));
	    var shape:Shape  = new Shape();
	    svg.render(shape.graphics, 0, 0, test.expectedWidth, test.expectedHeight);
			*/
			var actualFile = '${GENERATED_IMAGES_PATH}/${test.fileName.replace(".svg", ".png")}';
			// TODO: render to a PNG file ...
			sys.io.File.saveBytes(actualFile, haxe.io.Bytes.ofString("DUMMY STRING"));

			// Compare expected and actual
			var expectedHash = haxe.crypto.Md5.make(sys.io.File.getBytes('${IMAGES_PATH}/${test.fileName}'));
			var actualHash = haxe.crypto.Md5.make(sys.io.File.getBytes(actualFile));

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
		var html:String = '<html><head><title>${results.failedTests.length} failures | SVG Generation Tests</title></head><body>';

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
		html += "<table><tr><th>Image File</th><th>Expected</th><th>Actual</th>";

		for (test in tests) {
			var pngFile = test.fileName.replace('.svg', '.png');
			html += '<tr>
				<td>${test.fileName}</td>
				<td><img width="128" height="128" src="${IMAGES_PATH}/${pngFile}" /></td>
				<td><img src="${IMAGES_PATH}/${test.fileName}" /></td>
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
	public var expectedWidth(default, default):Int;
	public var expectedHeight(default, default):Int;

	public function new(fileName:String, width:Int, height:Int)
	{
		this.fileName = fileName;
		this.expectedWidth = width;
		this.expectedHeight = height;
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
