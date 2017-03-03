package format.svg;

import openfl.geom.Matrix;
import openfl.geom.Rectangle;

import openfl.display.GradientType;
import openfl.display.SpreadMethod;
import openfl.display.InterpolationMethod;
import openfl.display.CapsStyle;
import openfl.display.JointStyle;
import openfl.display.LineScaleMode;

class Grad extends /*gm2d.gfx.Gradient*/format.gfx.Gradient
{
   public var gradMatrix:Matrix;
   public var radius:Float;
   public var x1:Float;
   public var y1:Float;
   public var x2:Float;
   public var y2:Float;

   public function new(inType:GradientType)
   {
      super();
      type = inType;
      radius = 0.0;
      gradMatrix = new Matrix();
      x1 = 0.0;
      y1 = 0.0;
      x2 = 0.0;
      y2 = 0.0;
   }

   public function updateMatrix(inMatrix:Matrix)
   {
      var dx = x2 - x1;
      var dy = y2 - y1;
      var theta = Math.atan2(dy,dx);
      var len = Math.sqrt(dx*dx+dy*dy);

      var mtx = new Matrix();

      if (type==GradientType.LINEAR)
      {
         mtx.createGradientBox(1.0,1.0);
         mtx.scale(len,len);
      }
      else
      {
         if (radius!=0.0)
            focus = len/radius;

         mtx.createGradientBox(1.0,1.0);
         mtx.translate(-0.5,-0.5);
         mtx.scale(radius*2,radius*2);
      }

      mtx.rotate(theta);
      mtx.translate(x1,y1);
      mtx.concat(gradMatrix);
      mtx.concat(inMatrix);
      matrix = mtx;
   }


}

#if haxe3
typedef GradHash = haxe.ds.StringMap<Grad>;
#else
typedef GradHash = Hash<Grad>;
#end