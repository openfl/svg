package format;


import flash.display.Graphics;
import flash.geom.Matrix;
import flash.geom.Rectangle;
import format.svg.SVGData;
import format.svg.SVGRenderer;


class SVG {
	
	
	public var data:SVGData;
	
	
	public function new (content:String) {
		
		data = new SVGData (Xml.parse (content));
		
	}
	
	
	public function render (graphics:Graphics, x:Float = 0, y:Float = 0, width:Int = -1, height:Int = -1) {
		
		var matrix = new Matrix ();
		matrix.identity ();
		matrix.translate (x, y);
		
		if (width > -1 && height > -1) {
			
			matrix.scale (width / data.width, height / data.height);
			
		}
		
		var renderer = new SVGRenderer (data);
		renderer.render (graphics, matrix);
		
	}
	
	
}