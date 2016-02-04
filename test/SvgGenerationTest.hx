package;

import massive.munit.util.Timer;
import massive.munit.Assert;
import massive.munit.async.AsyncFactory;

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
		var results = generateAndCompare(testCases);
		createHtmlReport(results);
		if (results.failures.length > 0) {
			var failureNames = "";
			for (failure in results.failures) {
				failureNames = '${failureNames}${failure}, ';
			}
			Assert.fail('SVG generation for ${results.failures.length} cases did not match expectations. Check svgtest.html to see failures. Images: ${failureNames}');
		}
	}

	private function getSvgsFromDisk() : Array<SvgTest>
	{
		return new Array<SvgTest>();
	}

	private function generateAndCompare(svgTests:Array<SvgTest>) : GenerationResults
	{
		return new GenerationResults();
	}

	private function createHtmlReport(results:GenerationResults)
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

class GenerationResults
{
	public var failures(default, null):Array<String>;

	public function new() {
		this.failures = new Array<String>();
	}
}
