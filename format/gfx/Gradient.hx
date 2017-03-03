package format.gfx;

import openfl.geom.Matrix;
import openfl.display.GradientType;
import openfl.display.SpreadMethod;
import openfl.display.InterpolationMethod;
import openfl.display.CapsStyle;
import openfl.display.JointStyle;
import openfl.display.LineScaleMode;

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
   public var colors:Array<UInt>;
   public var alphas:Array<Float>;
   public var ratios:Array<Int>;
   public var matrix: Matrix;
   public var spread: SpreadMethod;
   public var interp:InterpolationMethod;
   public var focus:Float;

}

