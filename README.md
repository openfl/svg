[![MIT License](https://img.shields.io/badge/license-MIT-blue.svg?style=flat)](LICENSE.md) [![Haxelib Version](https://img.shields.io/github/tag/openfl/svg.svg?style=flat&label=haxelib)](http://lib.haxe.org/p/svg) ![build status](https://api.travis-ci.org/openfl/svg.svg)

SVG
===

Provides SVG parsing and rendering


Installation
============

You can easily install SVG using haxelib:

    haxelib install svg

To add it to a Lime or OpenFL project, add this to your project file:

    <haxelib name="svg" />
    

Usage
=====

```haxe
package;


import format.SVG;
import openfl.display.Sprite;
import openfl.Assets;


class Main extends Sprite {
	
	
	public function new () {
		
		super ();
		
		var svg = new SVG (Assets.getText ("assets/icon.svg"));
		svg.render (graphics);
		
	}
	
	
}
```


Development Builds
==================

Clone the SVG repository:

    git clone https://github.com/openfl/svg

Tell haxelib where your development copy of SVG is installed:

    haxelib dev svg svg

To return to release builds:

    haxelib dev svg


Running SVG's Tests
===================

`svg` includes some tests that render SVGs and make sure they look the way they're supposed to. These tests run automatically with each build/commit. To run them manually, run `haxe test.hxml`. For more information, check `README.md` in `test`.
