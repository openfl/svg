package format.gfx;

import openfl.display.LineScaleMode;
import openfl.display.CapsStyle;
import openfl.display.JointStyle;

class LineStyle
{
   public var thickness:Float;
   public var color:Int;
   public var alpha:Float;
   public var pixelHinting:Bool;
   public var scaleMode:LineScaleMode;
   public var capsStyle:CapsStyle;
   public var jointStyle:JointStyle;
   public var miterLimit:Float;

   public function new()
   {
      thickness = 1.0;
      color = 0x000000;
      alpha = 1.0;
      pixelHinting = false;
      scaleMode = LineScaleMode.NORMAL;
      capsStyle = CapsStyle.ROUND;
      jointStyle = JointStyle.ROUND;
      miterLimit = 3.0;
   }
}
