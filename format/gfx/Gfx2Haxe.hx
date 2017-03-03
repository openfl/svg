package format.gfx;

import openfl.display.GradientType;
import openfl.display.SpreadMethod;
import openfl.display.InterpolationMethod;
import openfl.display.CapsStyle;
import openfl.display.JointStyle;
import openfl.display.LineScaleMode;
import openfl.geom.Matrix;


class Gfx2Haxe extends Gfx
{
    public var commands : Array<String>;

    public function new( )
    {
       super();
       commands = [];
    }

    function f2a(f:Float):String
    {
       if (Math.abs(f)<0.000001) return "0";
       if (Math.abs(1-f)<0.000001) return "1";
       return f+"";
    }


    function newMatrix(m:Matrix)
    {
       return "new Matrix(" + f2a(m.a) + "," + f2a(m.b) + "," + f2a(m.c) + "," + f2a(m.d) + "," + f2a(m.tx) + "," + f2a(m.ty) + ")";
    }


   override public function beginGradientFill(grad:Gradient)
   {
      commands.push("g.beginGradientFill(" + grad.type + ","+  grad.colors + "," +  grad.alphas + "," + 
                       grad.ratios + "," +  newMatrix(grad.matrix) + "," +  grad.spread + "," + 
                       grad.interp+ "," +  grad.focus  + ");" );
   }

	override public function beginFill(color:Int, alpha:Float)
   {
      commands.push("g.beginFill(" + color + "," + f2a(alpha)  + ");");
   }
   override public function endFill() { commands.push("g.endFill();"); }


   override public function lineStyle(style:LineStyle)
   {
      commands.push("g.lineStyle("+f2a(style.thickness)+","+style.color+","+f2a(style.alpha)+"," + style.pixelHinting + "," +
                             style.scaleMode + "," + style.capsStyle + "," + style.jointStyle + "," + f2a(style.miterLimit)+ ");" );
   }


   override public function endLineStyle() { commands.push("g.lineStyle();"); }

   override public function moveTo(inX:Float, inY:Float)
      { commands.push("g.moveTo(" + inX + "," + inY + ");"); }
   override public function lineTo(inX:Float, inY:Float)
      { commands.push("g.lineTo(" + inX + "," + inY + ");"); }
   override public function curveTo(inCX:Float, inCY:Float,inX:Float,inY:Float)
      { commands.push("g.curveTo(" + inCX + "," + inCY + "," + inX + "," + inY + ");"); }
}

