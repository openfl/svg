package format.svg;

import flash.geom.Matrix;
import flash.display.GradientType;
import flash.display.SpreadMethod;
import flash.display.InterpolationMethod;
import flash.display.CapsStyle;
import flash.display.JointStyle;
import flash.display.LineScaleMode;

class Gradient
{
   public function new()
   {
      type = GradientType.LINEAR;
      colors = [];
      alphas = [];
      ratios = [];
      matrix = new Matrix();
      spread = SpreadMethod.PAD;
      interp = InterpolationMethod.RGB;
      focus = 0.0;
   }

   public var type:GradientType;
   public var colors:Array<Int>;
   public var alphas:Array<Float>;
   public var ratios:Array<Int>;
   public var matrix: Matrix;
   public var spread: SpreadMethod;
   public var interp:InterpolationMethod;
   public var focus:Float;

}

