package format.svg;
import flash.geom.Rectangle;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.display.Graphics;
import format.gfx.Gfx;

class PathSegment
{
   public static inline var MOVE  = 1;
   public static inline var DRAW  = 2;
   public static inline var CURVE = 3;
   public static inline var CUBIC = 4;
   public static inline var ARC   = 5;

   public var x:Float;
   public var y:Float;

   public function new(inX:Float,inY:Float)
   {
      x = inX;
      y = inY;
   }
   public function getType() : Int { return 0; }

   public function prevX() { return x; }
   public function prevY() { return y; }
   public function prevCX() { return x; }
   public function prevCY() { return y; }

   public function toGfx(inGfx:Gfx,ioContext:RenderContext)
   {
      ioContext.setLast(x,y);
      ioContext.firstX = ioContext.lastX;
      ioContext.firstY = ioContext.lastY;
      inGfx.moveTo(ioContext.lastX, ioContext.lastY);
   }

}

class MoveSegment extends PathSegment
{
   public function new(inX:Float,inY:Float) { super(inX,inY); }
   override public function getType() : Int { return PathSegment.MOVE; }
}


class DrawSegment extends PathSegment
{
   public function new(inX:Float, inY:Float) { super(inX,inY); }
   override public function toGfx(inGfx:Gfx,ioContext:RenderContext)
   {
      ioContext.setLast(x,y);
      inGfx.lineTo(ioContext.lastX,ioContext.lastY);
   }

   override public function getType() : Int { return PathSegment.DRAW; }
}

class QuadraticSegment extends PathSegment
{
   public var cx:Float;
   public var cy:Float;

   public function new(inCX:Float, inCY:Float, inX:Float, inY:Float)
   {
      super(inX,inY);
      cx = inCX;
      cy = inCY;
   }

   override public function prevCX() { return cx; }
   override public function prevCY() { return cy; }

   override public function toGfx(inGfx:Gfx,ioContext:RenderContext)
   {
      ioContext.setLast(x,y);
      inGfx.curveTo(ioContext.transX(cx,cy) , ioContext.transY(cx,cy),
                    ioContext.lastX , ioContext.lastY );
   }

   override public function getType() : Int { return PathSegment.CURVE; }
}

class CubicSegment extends PathSegment
{
   public var cx1:Float;
   public var cy1:Float;
   public var cx2:Float;
   public var cy2:Float;

   public function new(inCX1:Float, inCY1:Float, inCX2:Float, inCY2:Float, inX:Float, inY:Float )
   {
      super(inX,inY);
      cx1 = inCX1;
      cy1 = inCY1;
      cx2 = inCX2;
      cy2 = inCY2;
   }

   override public function prevCX() { return cx2; }
   override public function prevCY() { return cy2; }

   function Interp(a:Float, b:Float, frac:Float)
   {
      return a + (b-a)*frac;
   }

   override public function toGfx(inGfx:Gfx,ioContext:RenderContext)
   {
      // Transformed endpoints/controlpoints
      var tx0 = ioContext.lastX;
      var ty0 = ioContext.lastY;

      var tx1 = ioContext.transX(cx1,cy1);
      var ty1 = ioContext.transY(cx1,cy1);
      var tx2 = ioContext.transX(cx2,cy2);
      var ty2 = ioContext.transY(cx2,cy2);

      ioContext.setLast(x,y);
      var tx3 = ioContext.lastX;
      var ty3 = ioContext.lastY;

      // from http://www.timotheegroleau.com/Flash/articles/cubic_bezier/bezier_lib.as

      var pa_x = Interp(tx0,tx1,0.75);
      var pa_y = Interp(ty0,ty1,0.75);
      var pb_x = Interp(tx3,tx2,0.75);
      var pb_y = Interp(ty3,ty2,0.75);

	   // get 1/16 of the [P3, P0] segment
	   var dx = (tx3 - tx0)/16;
	   var dy = (ty3 - ty0)/16;
	
	   // calculates control point 1
	   var pcx_1 = Interp(tx0, tx1, 3/8);
	   var pcy_1 = Interp(ty0, ty1, 3/8);
	
	   // calculates control point 2
	   var pcx_2 = Interp(pa_x, pb_x, 3/8) - dx;
	   var pcy_2 = Interp(pa_y, pb_y, 3/8) - dy;
	
	   // calculates control point 3
	   var pcx_3 = Interp(pb_x, pa_x, 3/8) + dx;
	   var pcy_3 = Interp(pb_y, pa_y, 3/8) + dy;
	
	   // calculates control point 4
	   var pcx_4 = Interp(tx3, tx2, 3/8);
	   var pcy_4 = Interp(ty3, ty2, 3/8);
	
	   // calculates the 3 anchor points
	   var pax_1 = (pcx_1+pcx_2) * 0.5;
	   var pay_1 = (pcy_1+pcy_2) * 0.5;

	   var pax_2 = (pa_x+pb_x) * 0.5;
	   var pay_2 = (pa_y+pb_y) * 0.5;

	   var pax_3 = (pcx_3+pcx_4) * 0.5;
	   var pay_3 = (pcy_3+pcy_4) * 0.5;

	   // draw the four quadratic subsegments
	   inGfx.curveTo(pcx_1, pcy_1, pax_1, pay_1);
	   inGfx.curveTo(pcx_2, pcy_2, pax_2, pay_2);
	   inGfx.curveTo(pcx_3, pcy_3, pax_3, pay_3);
	   inGfx.curveTo(pcx_4, pcy_4, tx3, ty3);

   }

   public function toQuadratics(tx0:Float,ty0:Float) : Array<QuadraticSegment>
   {
      var result = new Array<QuadraticSegment>();
      // from http://www.timotheegroleau.com/Flash/articles/cubic_bezier/bezier_lib.as

      var pa_x = Interp(tx0,cx1,0.75);
      var pa_y = Interp(ty0,cy1,0.75);
      var pb_x = Interp(x,cx2,0.75);
      var pb_y = Interp(y,cy2,0.75);

	   // get 1/16 of the [P3, P0] segment
	   var dx = (x - tx0)/16;
	   var dy = (y - ty0)/16;
	
	   // calculates control point 1
	   var pcx_1 = Interp(tx0, cx1, 3/8);
	   var pcy_1 = Interp(ty0, cy1, 3/8);
	
	   // calculates control point 2
	   var pcx_2 = Interp(pa_x, pb_x, 3/8) - dx;
	   var pcy_2 = Interp(pa_y, pb_y, 3/8) - dy;
	
	   // calculates control point 3
	   var pcx_3 = Interp(pb_x, pa_x, 3/8) + dx;
	   var pcy_3 = Interp(pb_y, pa_y, 3/8) + dy;
	
	   // calculates control point 4
	   var pcx_4 = Interp(x, cx2, 3/8);
	   var pcy_4 = Interp(y, cy2, 3/8);
	
	   // calculates the 3 anchor points
	   var pax_1 = (pcx_1+pcx_2) * 0.5;
	   var pay_1 = (pcy_1+pcy_2) * 0.5;

	   var pax_2 = (pa_x+pb_x) * 0.5;
	   var pay_2 = (pa_y+pb_y) * 0.5;

	   var pax_3 = (pcx_3+pcx_4) * 0.5;
	   var pay_3 = (pcy_3+pcy_4) * 0.5;

	   // draw the four quadratic subsegments
	   result.push(new QuadraticSegment(pcx_1, pcy_1, pax_1, pay_1));
	   result.push(new QuadraticSegment(pcx_2, pcy_2, pax_2, pay_2));
	   result.push(new QuadraticSegment(pcx_3, pcy_3, pax_3, pay_3));
	   result.push(new QuadraticSegment(pcx_4, pcy_4, x, y));
      return result;
   }


   override public function getType() : Int { return PathSegment.CUBIC; }
}

class ArcSegment extends PathSegment
{
   var x1:Float;
   var y1:Float;
   var rx:Float;
   var ry:Float;
   var phi:Float;
   var fA:Bool;
   var fS:Bool;

   public function new( inX1:Float, inY1:Float, inRX:Float, inRY:Float, inRotation:Float,
                        inLargeArc:Bool, inSweep:Bool, x:Float, y:Float)
   {
      x1 = inX1;
      y1 = inY1;
      super(x,y);
      rx = inRX;
      ry = inRY;
      phi = inRotation;
      fA = inLargeArc;
      fS = inSweep;
   }

   override public function toGfx(inGfx:Gfx,ioContext:RenderContext)
   {
       if (x1==x && y1==y)
          return;
       ioContext.setLast(x,y);
       if (rx==0 || ry==0)
       {
          inGfx.lineTo(ioContext.lastX, ioContext.lastY);
          return;
       }
       if (rx<0) rx = -rx;
       if (ry<0) ry = -ry;

       // See:  http://www.w3.org/TR/SVG/implnote.html#ArcImplementationNotes
       var p = phi*Math.PI/180.0;
       var cos = Math.cos(p);
       var sin = Math.sin(p);

       // Step 1, compute x', y'
       var dx = (x1-x)*0.5;
       var dy = (y1-y)*0.5;
       var x1_ = cos*dx + sin*dy;
       var y1_ = -sin*dx + cos*dy;

       // Step 2, compute cx', cy'
       var rx2 = rx*rx;
       var ry2 = ry*ry;
       var x1_2 = x1_*x1_;
       var y1_2 = y1_*y1_;
       var s = (rx2*ry2 - rx2*y1_2 - ry2*x1_2) /
                 (rx2*y1_2 + ry2*x1_2 );
       if (s<0)
          s=0;
       else if (fA==fS)
          s = -Math.sqrt(s);
       else
          s = Math.sqrt(s);

       var cx_ = s*rx*y1_/ry;
       var cy_ = -s*ry*x1_/rx;

       // Step 3, compute cx,cy from cx',cy'
       // Something not quite right here.

       var xm = (x1+x)*0.5;
       var ym = (y1+y)*0.5;

       var cx = cos*cx_ - sin*cy_ + xm;
       var cy = sin*cx_ + cos*cy_ + ym;

       var theta = Math.atan2( (y1_-cy_)/ry, (x1_-cx_)/rx );
       var dtheta = Math.atan2( (-y1_-cy_)/ry, (-x1_-cx_)/rx ) - theta;

       if (fS && dtheta<0)
          dtheta+=2.0*Math.PI;
       else if (!fS && dtheta>0)
          dtheta-=2.0*Math.PI;


       var m = ioContext.matrix;
       //    var px = cx+cos*rx;
       //    var py = cy+sin*ry;
       //    m.a*px+m.c*py+m.tx    m.b*px+m.d*py+m.ty
       //  Combined
       //    x = m.a(cx+cos*rx) + m.c(cy+sin*ry) + m.tx
       //      = m.a*rx * cos +  m.c*ry*sin + m.a*cx+m.c*cy + m.tx
       //      = Txc cos +  Txc sin + Tx0
       //    y = m.b(cx+cos*rx) + m.d(cy+sin*ry) + m.ty
       //      = m.b*rx * cos +  m.d*ry*sin + m.b*cx+m.d*cy + m.ty
       //      = Tyc cos +  Tys sin + Ty0
       //

       var Txc:Float;
       var Txs:Float;
       var Tx0:Float;
       var Tyc:Float;
       var Tys:Float;
       var Ty0:Float;
       if (m!=null)
       {
          Txc = m.a*rx;
          Txs = m.c*ry;
          Tx0 = m.a*cx + m.c*cy + m.tx;
          Tyc = m.b*rx;
          Tys = m.d*ry;
          Ty0 = m.b*cx + m.d*cy + m.ty;
       }
       else
       {
          Txc = rx;
          Txs = 0;
          Tx0 = cx+m.tx;
          Tyc = 0;
          Tys = ry;
          Ty0 = cy+m.ty;
       }

       var len = Math.abs(dtheta)*Math.sqrt(Txc*Txc + Txs*Txs + Tyc*Tyc + Tys*Tys);
       // TODO: Do as series of quadratics ...
       len *= 5;
       var steps = Math.round(len);
       

       if (steps>1)
       {
          dtheta /= steps;
          for(i in 1...steps-1)
          {
             var c = Math.cos(theta);
             var s = Math.sin(theta);
             theta+=dtheta;
             inGfx.lineTo(Txc*c + Txs*s + Tx0,   Tyc*c + Tys*s + Ty0);
          }
       }
       inGfx.lineTo(ioContext.lastX, ioContext.lastY);
   }
   override public function getType() : Int { return PathSegment.ARC; }
}




