package format.gfx;

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
}

