[![MIT License](https://img.shields.io/badge/license-MIT-blue.svg?style=flat)](LICENSE.md) [![Haxelib Version](https://img.shields.io/github/tag/openfl/svg.svg?style=flat&label=haxelib)](http://lib.haxe.org/p/svg)

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

`svg` includes `munit` tests which generate images for a set of SVGs and compare them against known, "good" generated images to see how different they are. The test fails if any of the images are too different.

These tests run automatically with each build/commit. To run them on your local machine, just type `haxelib test.hxml`. (Note that `haxelib run munit test` won't work.)