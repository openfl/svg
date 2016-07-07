package format.svg;

import flash.geom.Matrix;
import flash.geom.Rectangle;

class RenderContext
{
   public function new(inMatrix:Matrix,?inRect:Rectangle,?inW:Float, ?inH:Float)
   {
      matrix = inMatrix;
      rect = inRect;
      rectW = inW!=null ? inW : inRect!=null? inRect.width : 1;
      rectH = inH!=null ? inH : inRect!=null? inRect.height : 1;
      firstX = 0;
      firstY = 0;
      lastX = 0;
      lastY = 0;
   }
   public function  transX(inX:Float, inY:Float)
   {
      if (rect!=null && inX>rect.x)
      {
         if (inX>rect.right)
            inX += rectW - rect.width;
         else
            inX = rect.x + rectW * (inX-rect.x)/rect.width;
      }
      return inX*matrix.a + inY*matrix.c + matrix.tx;
   }
   public function  transY(inX:Float, inY:Float)
   {
      if (rect!=null && inY>rect.y)
      {
         if (inY>rect.right)
            inY += rectH - rect.height;
         else
            inY = rect.y + rectH * (inY-rect.y)/rect.height;
      }
      return inX*matrix.b + inY*matrix.d + matrix.ty;
   }


   public function setLast(inX:Float, inY:Float)
   {
      lastX = transX(inX,inY);
      lastY = transY(inX,inY);
   }
   public var matrix:Matrix;
   public var rect:Rectangle;
   public var rectW:Float;
   public var rectH:Float;

   public var firstX:Float;
   public var firstY:Float;
   public var lastX:Float;
   public var lastY:Float;
}
