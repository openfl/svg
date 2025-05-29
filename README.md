[![MIT License](https://img.shields.io/badge/license-MIT-blue.svg?style=flat)](LICENSE.md) [![Haxelib Version](https://img.shields.io/github/tag/openfl/svg.svg?style=flat&label=haxelib)](http://lib.haxe.org/p/svg) [![Build Status](https://img.shields.io/github/actions/workflow/status/openfl/svg/main.yml?branch=master)](https://github.com/openfl/svg/actions)

SVG
===

Provides SVG parsing and rendering


Installation
============

You can easily install SVG using haxelib:

    haxelib install svg

To add it to a Lime or OpenFL project, add this to your project file:

```xml
<haxelib name="svg" />
```

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

Install the haxelib from GitHub:

    haxelib git svg https://github.com/openfl/svg

To return to release builds:

    haxelib dev svg


Running SVG's Tests
===================

`svg` includes some tests that render SVGs and make sure they look the way they're supposed to. These tests run automatically with each build/commit. For more information about running them manually, see [test/README.md](test/README.md).
