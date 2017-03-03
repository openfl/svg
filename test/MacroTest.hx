package;

import massive.munit.Assert;

import format.SVG;

/**
* Tests that using SVGs inside macros actually compiles. If the `flash` package
* is used instead of the `openfl` package.
*/
class MacroTest
{
	macro static function makeSvg()
	{
		// This macro will fail if the `flash` package is used.
		return macro new SVG("<svg></svg>");
	}

	@Test
	public function compilesInMacro()
	{
		Assert.isNotNull(makeSvg());
	}
}
