package format.gfx;

import openfl.display.GradientType;
import openfl.display.SpreadMethod;
import openfl.display.InterpolationMethod;
import openfl.display.CapsStyle;
import openfl.display.JointStyle;
import openfl.display.LineScaleMode;
import openfl.geom.Matrix;

import openfl.utils.ByteArray;

import haxe.io.Bytes;

#if (haxe_211 || haxe3)
import haxe.crypto.BaseCode;
#else
import haxe.BaseCode;
#end


class GfxBytes extends Gfx
{
   static inline var EOF = 0;
   static inline var SIZE = 1;

   static inline var BEGIN_FILL = 10;
   static inline var GRADIENT_FILL = 11;
   static inline var END_FILL = 12;

   static inline var LINE_STYLE = 20;
   static inline var END_LINE_STYLE = 21;

   static inline var MOVE = 30;
   static inline var LINE = 31;
   static inline var CURVE = 32;


   public var buffer:ByteArray;

	private static var base64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
	private static var baseCoder:BaseCode;

   public function new(?inBuffer:ByteArray,inFlags:Int = 0)
   {
       super();
       buffer = inBuffer==null ? new ByteArray() : inBuffer;
   }

   public function toString() : String
   {
 	  #if js
 	  return "";
 	  #else
      #if flash
      var buf = new ByteArray();
      buf.length = buffer.length;
      #else
      var buf = new ByteArray(buffer.length);
      #end
      buffer.position=0;
      buffer.readBytes(buf);
      buf.compress();
      if (baseCoder==null)
         baseCoder = new BaseCode(haxe.io.Bytes.ofString(base64));
      #if flash
      return baseCoder.encodeBytes(haxe.io.Bytes.ofData(buf)).toString();
      #else
      return baseCoder.encodeBytes(buf).toString();
      #end
      #end
   }
   public static function fromString(inString:String) : GfxBytes
   {
      if (baseCoder==null)
         baseCoder = new BaseCode(haxe.io.Bytes.ofString(base64));
      #if flash
      var bytes:ByteArray = baseCoder.decodeBytes(haxe.io.Bytes.ofString(inString)).getData();
      #elseif js
      var bytes:ByteArray = new ByteArray();
      bytes.writeUTF( inString );
      #else
      var bytes = ByteArray.fromBytes( baseCoder.decodeBytes(haxe.io.Bytes.ofString(inString)) );
      #end
      #if !js
      bytes.uncompress();
      #end
      return new GfxBytes(bytes);
   }

   override public function eof() { buffer.writeByte(EOF); }

   static var scaleModes = [ LineScaleMode.NORMAL, LineScaleMode.NONE, LineScaleMode.VERTICAL, LineScaleMode.HORIZONTAL ];
   static var capsStyles = [ CapsStyle.ROUND, CapsStyle.NONE, CapsStyle.SQUARE ];
   static var jointStyles = [ JointStyle.ROUND, JointStyle.MITER, JointStyle.BEVEL ];
   static var spreadMethods = [ SpreadMethod.PAD, SpreadMethod.REPEAT, SpreadMethod.REFLECT ];
   static var interpolationMethods = [ InterpolationMethod.RGB, InterpolationMethod.LINEAR_RGB ];

   public function iterate(inGfx:Gfx)
   {
      buffer.position = 0;
      while(true)
      {
         switch(buffer.readByte())
         {
            case EOF:
               return;

            case SIZE:
               var w = buffer.readFloat();
               var h = buffer.readFloat();
               inGfx.size(w,h);

            case BEGIN_FILL:
               var col = readRGB();
               var alpha = buffer.readFloat();
               inGfx.beginFill(col,alpha);

            case GRADIENT_FILL:
              var grad = new Gradient();
              #if (openfl_legacy || openfl < "3.6.0")
              grad.type = Type.createEnumIndex(GradientType,buffer.readByte());
              #else
              grad.type = cast buffer.readByte();
              #end
              var len = buffer.readByte();
              for(i in 0...len)
              {
                 grad.colors.push(readRGB());
                 grad.alphas.push(buffer.readByte()/255.0);
                 grad.ratios.push(buffer.readByte());
              }
              grad.matrix.a = buffer.readFloat();
              grad.matrix.b = buffer.readFloat();
              grad.matrix.c = buffer.readFloat();
              grad.matrix.d = buffer.readFloat();
              grad.matrix.tx = buffer.readFloat();
              grad.matrix.ty = buffer.readFloat();
              #if (openfl_legacy || openfl < "3.6.0")
              grad.spread = spreadMethods[buffer.readByte()];
              grad.interp = interpolationMethods[buffer.readByte()];
              #else
              grad.spread = cast buffer.readByte();
              grad.interp = cast buffer.readByte();
              #end
              grad.focus = buffer.readFloat();
              inGfx.beginGradientFill(grad);

            case END_FILL:
              inGfx.endFill();

            case LINE_STYLE:
              var style = new LineStyle();
              style.thickness = buffer.readFloat();
              style.color = readRGB();
              style.alpha = buffer.readFloat();
              style.pixelHinting = buffer.readByte() > 0;
              #if (openfl_legacy || openfl < "3.6.0")
              style.scaleMode = scaleModes[buffer.readByte()];
              style.capsStyle = capsStyles[buffer.readByte()];
              style.jointStyle = jointStyles[buffer.readByte()];
              #else
              style.scaleMode = cast buffer.readByte();
              style.capsStyle = cast buffer.readByte();
              style.jointStyle = cast buffer.readByte();
              #end
              style.miterLimit = buffer.readFloat();
              inGfx.lineStyle(style);

            case END_LINE_STYLE:
              inGfx.endLineStyle();

            case MOVE:
              var x = buffer.readFloat();
              var y = buffer.readFloat();
              inGfx.moveTo(x,y);
              
            case LINE:
              var x = buffer.readFloat();
              var y = buffer.readFloat();
              inGfx.lineTo(x,y);
              
            case CURVE:
              var cx = buffer.readFloat();
              var cy = buffer.readFloat();
              var x = buffer.readFloat();
              var y = buffer.readFloat();
              inGfx.curveTo(cx,cy,x,y);
            default:
              throw "Unknown gfx buffer format.";
         }
      }
   }
  

   override public function size(inWidth:Float,inHeight:Float)
   {
      buffer.writeByte(SIZE);
      buffer.writeFloat(inWidth);
      buffer.writeFloat(inHeight);
   }

   inline function pushClipped(inVal:Float)
   {
       buffer.writeByte(inVal<0 ? 0 : inVal>255.0 ? 255 : Std.int(inVal) );
   }
   function writeRGB(inVal:Int)
   {
      buffer.writeByte((inVal>>16) & 0xff);
      buffer.writeByte((inVal>>8) & 0xff);
      buffer.writeByte((inVal) & 0xff);
   }
   function readRGB()
   {
      var r = buffer.readByte();
      var g = buffer.readByte();
      var b = buffer.readByte();
      return (r<<16) | (g<<8) | b;
   }



   override public function beginGradientFill(grad:Gradient)
   {
      buffer.writeByte(GRADIENT_FILL);
      #if (openfl_legacy || openfl < "3.6.0")
      buffer.writeByte(Type.enumIndex(grad.type));
      #else
      buffer.writeByte(cast grad.type);
      #end
      buffer.writeByte(grad.colors.length);
      for(i in 0...grad.colors.length)
      {
          writeRGB(#if neko grad.colors[i]==null ? 0 : #end Std.int(grad.colors[i]));
          pushClipped(grad.alphas[i]*255.0);
          pushClipped(grad.ratios[i]);
      }
      buffer.writeFloat(grad.matrix.a);
      buffer.writeFloat(grad.matrix.b);
      buffer.writeFloat(grad.matrix.c);
      buffer.writeFloat(grad.matrix.d);
      buffer.writeFloat(grad.matrix.tx);
      buffer.writeFloat(grad.matrix.ty);
      #if (openfl_legacy || openfl < "3.6.0")
      buffer.writeByte(Type.enumIndex(grad.spread));
      buffer.writeByte(Type.enumIndex(grad.interp));
      #else
      buffer.writeByte(cast grad.spread);
      buffer.writeByte(cast grad.interp);
      #end
      buffer.writeFloat(grad.focus);
   }

   override public function beginFill(color:Int, alpha:Float)
   {
      buffer.writeByte(BEGIN_FILL);
      writeRGB(color);
      buffer.writeFloat(alpha);
   }
   override public function endFill()
   {
      buffer.writeByte(END_FILL);
   }

   override public function lineStyle(style:LineStyle)
   {
      buffer.writeByte(LINE_STYLE);
      buffer.writeFloat(style.thickness);
      writeRGB(style.color);
      buffer.writeFloat(style.alpha);
      buffer.writeByte(style.pixelHinting?1:0);
      #if (openfl_legacy || openfl < "3.6.0")
      buffer.writeByte(Type.enumIndex(style.scaleMode));
      buffer.writeByte(Type.enumIndex(style.capsStyle));
      buffer.writeByte(Type.enumIndex(style.jointStyle));
      #else
      buffer.writeByte(cast style.scaleMode);
      buffer.writeByte(cast style.capsStyle);
      buffer.writeByte(cast style.jointStyle);
      #end
      buffer.writeFloat(style.miterLimit);
   }

   override public function endLineStyle()
   {
      buffer.writeByte(END_LINE_STYLE);
   }

   override public function moveTo(inX:Float, inY:Float)
   {
      buffer.writeByte(MOVE);
      buffer.writeFloat(inX);
      buffer.writeFloat(inY);
   }

   override public function lineTo(inX:Float, inY:Float)
   {
      buffer.writeByte(LINE);
      buffer.writeFloat(inX);
      buffer.writeFloat(inY);
   }

   override public function curveTo(inCX:Float, inCY:Float,inX:Float,inY:Float)
   {
      buffer.writeByte(CURVE);
      buffer.writeFloat(inCX);
      buffer.writeFloat(inCY);
      buffer.writeFloat(inX);
      buffer.writeFloat(inY);
   }
}


