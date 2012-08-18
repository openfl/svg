package format.svg;

import Xml;

// To help old code...

class SVG2Gfx
{
   var renderer : SvgRenderer;

   public function new (inXml:Xml)
   {
      renderer = new SvgRenderer(new Svg(inXml) );
   }

   public function CreateShape()
   {
      return renderer.createShape();
   }

}
