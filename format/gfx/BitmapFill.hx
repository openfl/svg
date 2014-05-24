package format.gfx;

import flash.geom.ColorTransform;
import flash.geom.Rectangle;
import flash.geom.Matrix;
import flash.display.BitmapData;

class BitmapFill {
    public function new() {
        matrix = new Matrix();
    }

    public var bitmapData:BitmapData;
    public var matrix: Matrix;
    public var repeat: Bool = true;
    public var smooth: Bool = false;
    @:isVar
    public var alpha(default, set): Float = 1;

    private function set_alpha(value:Float):Float {
        alpha = value;
        if(bitmapData != null && value < 1) {
            bitmapData.lock();
            var rect: Rectangle = new Rectangle(0,0,bitmapData.width,bitmapData.height);
            bitmapData.colorTransform(rect, new ColorTransform(1,1,1,alpha));
            bitmapData.unlock(rect);
        }
        return alpha;
    }
}

