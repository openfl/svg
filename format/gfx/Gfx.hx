package format.gfx;

import openfl.display.GradientType;
import openfl.display.SpreadMethod;
import openfl.display.InterpolationMethod;
import openfl.display.CapsStyle;
import openfl.display.JointStyle;
import openfl.display.LineScaleMode;
import format.svg.Text;

import openfl.geom.Matrix;

class Gfx
{
   public function new() { }
   public function geometryOnly() { return false; }
   public function size(inWidth:Float,inHeight:Float) { }
   public function beginGradientFill(grad:Gradient) { }

	public function beginFill(color:Int, alpha:Float) { }
   public function endFill() { }

   public function lineStyle(style:LineStyle) { }
   public function endLineStyle() { }

   public function moveTo(inX:Float, inY:Float) { }
   public function lineTo(inX:Float, inY:Float) { }
   public function curveTo(inCX:Float, inCY:Float,inX:Float,inY:Float) { }

   public function renderText(text:Text) { }

   public function eof() {}
}



