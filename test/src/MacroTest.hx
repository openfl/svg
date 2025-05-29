import format.SVG;

import utest.Assert;
import utest.Test;

/**
	Tests that using SVGs inside macros actually compiles. If the `flash`
	package is used instead of the `openfl` package.
**/
class MacroTest extends Test
{
	macro static function makeSvg()
	{
		// This macro will fail if the `flash` package is used.
		return macro new SVG("<svg></svg>");
	}

	public function testCompilesInMacro()
	{
		Assert.notNull(makeSvg());
	}
}
