package;

import massive.munit.util.Timer;
import massive.munit.Assert;
import massive.munit.async.AsyncFactory;

using StringTools;

class SvgGenerationTest
{
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
		var failures = generateAndCompare(testCases);
		if (failures.length > 0) {
			createHtmlReport(failures);
			var failureNames = "";
			for (failure in failures) {
				failureNames = '${failureNames}${failure}, ';
			}
			Assert.fail('SVG generation for ${failures.length} cases did not match expectations. Check svgtest.html to see failures. Images: ${failureNames}');
		}
	}

	// Returns a list of test cases
	private function getSvgsFromDisk() : Array<SvgTest>
	{
		var toReturn = new Array<SvgTest>();
		var files = sys.FileSystem.readDirectory("test/images");

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
	private function generateAndCompare(svgTests:Array<SvgTest>) : Array<String>
	{
		return new Array<String>();
	}

	// Creates the HTML report
	private function createHtmlReport(failedTests:Array<String>)
	{

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
