package format;


import flash.display.Graphics;
import flash.geom.Matrix;
import flash.geom.Rectangle;
import format.svg.SVGData;
import format.svg.SVGRenderer;


class SVG {
	
	
	private var svgData:SVGData;
	
	
	public function new (data:String) {
		
		svgData = new SVGData (Xml.parse (data));
		
	}
	
	
	public function render (graphics:Graphics, x:Float = 0, y:Float = 0, width:Int = -1, height:Int = -1) {
		
		var matrix = new Matrix ();
		matrix.identity ();
		matrix.translate (x, y);
		
		if (width > -1 && height > -1) {
			
			matrix.scale (width / svgData.width, height / svgData.height);
			
		}
		
		var renderer = new SVGRenderer (svgData);
		renderer.render (graphics, matrix);
		
	}
	
	
}