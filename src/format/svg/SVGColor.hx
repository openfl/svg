package format.svg;

import haxe.ds.StringMap;

class SVGColor
{
	public static var nameMap:StringMap<String> =
	[
		"maroon" => "800000",
		"red" => "ff0000",
		"orange" => "ffA500",
		"yellow" => "ffff00",
		"olive" => "808000",
		"purple" => "800080",
		"fuchsia" => "ff00ff",
		"white" => "ffffff",
		"lime" => "00ff00",
		"green" => "008000",
		"navy" => "000080",
		"blue" => "0000ff",
		"aqua" => "00ffff",
		"teal" => "008080",
		"black" => "000000",
		"silver" => "c0c0c0",
		"gray" => "808080",
		"aliceblue" => "F0F8FF",
		"antiquewhite" => "FAEBD7",
		"aquamarine" => "7FFFD4",
		"azure" => "F0FFFF",
		"beige" => "F5F5DC",
		"bisque" => "FFE4C4",
		"blanchedalmond" => "FFEBCD",
		"blueviolet" => "8A2BE2",
		"brown" => "A52A2A",
		"burlywood" => "DEB887",
		"cadetblue" => "5F9EA0",
		"chartreuse" => "7FFF00",
		"chocolate" => "D2691E",
		"coral" => "FF7F50",
		"cornflowerblue" => "6495ED",
		"cornsilk" => "FFF8DC",
		"crimson" => "DC143C",
		"cyan" => "00FFFF",
		"darkblue" => "00008B",
		"darkcyan" => "008B8B",
		"darkgoldenrod" => "B8860B",
		"darkgray" => "A9A9A9",
		"darkgrey" => "A9A9A9",
		"darkgreen" => "006400",
		"darkkhaki" => "BDB76B",
		"darkmagenta" => "8B008B",
		"darkolivegreen" => "556B2F",
		"darkorange" => "FF8C00",
		"darkorchid" => "9932CC",
		"darkred" => "8B0000",
		"darksalmon" => "E9967A",
		"darkseagreen" => "8FBC8F",
		"darkslateblue" => "483D8B",
		"darkslategray" => "2F4F4F",
		"darkslategrey" => "2F4F4F",
		"darkturquoise" => "00CED1",
		"darkviolet" => "9400D3",
		"deeppink" => "FF1493",
		"deepskyblue" => "00BFFF",
		"dimgray" => "696969",
		"dimgrey" => "696969",
		"dodgerblue" => "1E90FF",
		"firebrick" => "B22222",
		"floralwhite" => "FFFAF0",
		"forestgreen" => "228B22",
		"gainsboro" => "DCDCDC",
		"ghostwhite" => "F8F8FF",
		"gold" => "FFD700",
		"goldenrod" => "DAA520",
		"grey" => "808080",
		"greenyellow" => "ADFF2F",
		"honeydew" => "F0FFF0",
		"hotpink" => "FF69B4",
		"indianred" => "CD5C5C",
		"indigo" => "4B0082",
		"ivory" => "FFFFF0",
		"khaki" => "F0E68C",
		"lavender" => "E6E6FA",
		"lavenderblush" => "FFF0F5",
		"lawngreen" => "7CFC00",
		"lemonchiffon" => "FFFACD",
		"lightblue" => "ADD8E6",
		"lightcoral" => "F08080",
		"lightcyan" => "E0FFFF",
		"lightgoldenrodyellow" => "FAFAD2",
		"lightgray" => "D3D3D3",
		"lightgrey" => "D3D3D3",
		"lightgreen" => "90EE90",
		"lightpink" => "FFB6C1",
		"lightsalmon" => "FFA07A",
		"lightseagreen" => "20B2AA",
		"lightskyblue" => "87CEFA",
		"lightslategray" => "778899",
		"lightslategrey" => "778899",
		"lightsteelblue" => "B0C4DE",
		"lightyellow" => "FFFFE0",
		"limegreen" => "32CD32",
		"linen" => "FAF0E6",
		"magenta" => "FF00FF",
		"mediumaquamarine" => "66CDAA",
		"mediumblue" => "0000CD",
		"mediumorchid" => "BA55D3",
		"mediumpurple" => "9370D8",
		"mediumseagreen" => "3CB371",
		"mediumslateblue" => "7B68EE",
		"mediumspringgreen" => "00FA9A",
		"mediumturquoise" => "48D1CC",
		"mediumvioletred" => "C71585",
		"midnightblue" => "191970",
		"mintcream" => "F5FFFA",
		"mistyrose" => "FFE4E1",
		"moccasin" => "FFE4B5",
		"navajowhite" => "FFDEAD",
		"oldlace" => "FDF5E6",
		"olivedrab" => "6B8E23",
		"orangered" => "FF4500",
		"orchid" => "DA70D6",
		"palegoldenrod" => "EEE8AA",
		"palegreen" => "98FB98",
		"paleturquoise" => "AFEEEE",
		"palevioletred" => "D87093",
		"papayawhip" => "FFEFD5",
		"peachpuff" => "FFDAB9",
		"peru" => "CD853F",
		"pink" => "FFC0CB",
		"plum" => "DDA0DD",
		"powderblue" => "B0E0E6",
		"rosybrown" => "BC8F8F",
		"royalblue" => "4169E1",
		"saddlebrown" => "8B4513",
		"salmon" => "FA8072",
		"sandybrown" => "F4A460",
		"seagreen" => "2E8B57",
		"seashell" => "FFF5EE",
		"sienna" => "A0522D",
		"skyblue" => "87CEEB",
		"slateblue" => "6A5ACD",
		"slategray" => "708090",
		"slategrey" => "708090",
		"snow" => "FFFAFA",
		"springgreen" => "00FF7F",
		"steelblue" => "4682B4",
		"tan" => "D2B48C",
		"thistle" => "D8BFD8",
		"tomato" => "FF6347",
		"turquoise" => "40E0D0",
		"violet" => "EE82EE",
		"wheat" => "F5DEB3",
		"whitesmoke" => "F5F5F5",
		"yellowgreen" => "9ACD32"
	];

	public static function parseHex(hex:String):Int
	{
		// Support 3-character hex color shorthand
		//	e.g. #RGB -> #RRGGBB
		if (hex.length == 3) {
			hex = hex.substr(0,1) + hex.substr(0,1) +
						hex.substr(1,1) + hex.substr(1,1) +
						hex.substr(2,1) + hex.substr(2,1);
		}

		return Std.parseInt ("0x" + hex);
	}

	public static function parseRGBMatch(rgbMatch:EReg):Int
	{
			// CSS2 rgb color definition, matches 0-255 or 0-100%
			// e.g. rgb(255,127,0) == rgb(100%,50%,0)

			inline function range(val:Float):Int {
				// constrain to Int 0-255
				if (val < 0) { val = 0; }
				if (val > 255) { val = 255; }
				return Std.int( val );
			}

			var r = Std.parseFloat(rgbMatch.matched (1));
			if (rgbMatch.matched(2)=='%') { r = r * 255 / 100; }

			var g = Std.parseFloat(rgbMatch.matched (3));
			if (rgbMatch.matched(4)=='%') { g = g * 255 / 100; }

			var b = Std.parseFloat(rgbMatch.matched (5));
			if (rgbMatch.matched(6)=='%') { b = b * 255 / 100; }

			return ( range(r)<<16 ) | ( range(g)<<8 ) | range(b);
	}

}
