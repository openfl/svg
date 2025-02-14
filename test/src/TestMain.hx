
import openfl.display.Sprite;
import utest.Runner;
import utest.ui.Report;

class TestMain extends Sprite
{
	public function new()
	{
		super();

		var runner = new Runner();
		#if !(js && html5)
		runner.addCase(new MacroTest());
		#end
		runner.addCase(new SvgGenerationTest());

		Report.create(runner);

		#if (js && html5)
		runner.onComplete.add((results) -> {
			cast(js.Lib.global, js.html.Window).document.getElementById("openfl-content").style.display = "none";
			cast(js.Lib.global, js.html.Window).document.body.style.overflow = "auto";
		});
		#end
		runner.run();
	}
}
