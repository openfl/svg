package format.svg;

import flash.geom.Matrix;
import flash.display.BitmapData;

class BitmapFill extends format.gfx.BitmapFill {
    public var fillMatrix: Matrix;
    public var x1:Float;
    public var y1:Float;
    public var x2:Float;
    public var y2:Float;

    public function new() {
        super();
        fillMatrix = new Matrix();
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

        mtx.rotate(theta);
        mtx.translate(x1,y1);
        mtx.concat(fillMatrix);
        mtx.concat(inMatrix);
        matrix = mtx;
    }
}

