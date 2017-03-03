package format.gfx;

import openfl.display.GradientType;
import openfl.display.SpreadMethod;
import openfl.display.InterpolationMethod;
import openfl.display.CapsStyle;
import openfl.display.JointStyle;
import openfl.display.LineScaleMode;
import openfl.display.Graphics;

import openfl.geom.Matrix;

class GfxGraphics extends Gfx
{
   var graphics : Graphics;

   public function new(inGraphics:Graphics)
   {
     super();
     graphics = inGraphics;
   }

   override public function beginGradientFill(grad:Gradient)
   {
      graphics.beginGradientFill(grad.type,grad.colors,grad.alphas,grad.ratios,grad.matrix,grad.spread,grad.interp,grad.focus);
   }

	override public function beginFill(color:Int, alpha:Float) { graphics.beginFill(color,alpha); }
   override public function endFill() { graphics.endFill(); }

   override public function lineStyle(style:LineStyle)
   {
      graphics.lineStyle(style.thickness,style.color,style.alpha,style.pixelHinting,style.scaleMode,style.capsStyle,style.jointStyle,style.miterLimit);
   }
   override public function endLineStyle() { graphics.lineStyle(); }

   override public function moveTo(inX:Float, inY:Float) { graphics.moveTo(inX,inY); }
   override public function lineTo(inX:Float, inY:Float) { graphics.lineTo(inX,inY); }
   override public function curveTo(inCX:Float, inCY:Float,inX:Float,inY:Float)
     { graphics.curveTo(inCX,inCY,inX,inY); }
}

