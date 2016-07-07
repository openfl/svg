package format.gfx;

import flash.display.GradientType;
import flash.display.SpreadMethod;
import flash.display.InterpolationMethod;
import flash.display.CapsStyle;
import flash.display.JointStyle;
import flash.display.LineScaleMode;
import format.svg.Text;

import flash.geom.Matrix;

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



