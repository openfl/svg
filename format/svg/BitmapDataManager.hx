package format.svg;

//import gm2d.reso.Resources;
//import format.svg.SVGRenderer;

import openfl.display.DisplayObjectContainer;
import openfl.display.Shape;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.geom.Matrix;

class BitmapDataManager
{
   static var bitmaps = new Map<String, BitmapData>();
   static var mScale = 0.0;

   public static function create(inSVG:String, inGroup:String, inScale:Float, inCache=false)
   {
      var key = inSVG + " : " + inGroup + " : " +inScale;
      if (bitmaps.exists(key)) {
          return bitmaps.get(key);
      }

      var svg = null;

      var shape = new Shape();

      svg = new SVG(inSVG);
      svg.render(shape.graphics, 0, 0);

      var matrix = new Matrix();
      matrix.scale(inScale,inScale);

      var w = Std.int(svg.data.width);
      var h = Std.int(svg.data.height);
      var bmp = new BitmapData(w,h,true,0x00);

      bmp.draw(shape,matrix);

      if (inCache)
         bitmaps.set(key,bmp);

      return bmp;
   }

   static public function setCacheScale(inScale:Float)
   {
      if (inScale!=mScale)
      {
         bitmaps = new Map<String, BitmapData>();
         mScale = inScale;
      }
   }
}
