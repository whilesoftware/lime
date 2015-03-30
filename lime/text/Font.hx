package lime.text;


import lime.graphics.Image;
import lime.graphics.ImageBuffer;
import lime.math.Vector2;
import lime.utils.ByteArray;
import lime.utils.UInt8Array;
import lime.system.System;

#if (js && html5)
import js.html.CanvasElement;
import js.html.CanvasRenderingContext2D;
#end

@:access(lime.text.Glyph)

#if (!display && !nodejs)
@:autoBuild(lime.Assets.embedFont())
#end


class Font {
	
	
	public var ascender (get, null):Int;
	public var descender (get, null):Int;
	public var height (get, null):Int;
	public var name (default, null):String;
	public var numGlyphs (get, null):Int;
	public var src:Dynamic;
	public var underlinePosition (get, null):Int;
	public var underlineThickness (get, null):Int;
	public var unitsPerEM (get, null):Int;
	
	@:noCompletion private var __fontPath:String;
	
	
	public function new (name:String = null) {
		
		this.name = name;
		
		if (__fontPath != null) {
			
			__fromFile (__fontPath);
			
		}
		
	}
	
	
	public function decompose ():NativeFontData {
		
		#if (cpp || neko || nodejs)
		
		if (src == null) throw "Uninitialized font handle.";
		return lime_font_outline_decompose (src, 1024 * 20);
		
		#else
		
		return null;
		
		#end
		
	}
	
	
	public static function fromBytes (bytes:ByteArray):Font {
		
		var font = new Font ();
		font.__fromBytes (bytes);
		
		#if (cpp || neko || nodejs)
		return (font.src != null) ? font : null;
		#else
		return font;
		#end
		
	}
	
	
	public static function fromFile (path:String):Font {
		
		var font = new Font ();
		font.__fromFile (path);
		
		#if (cpp || neko || nodejs)
		return (font.src != null) ? font : null;
		#else
		return font;
		#end
		
	}
	
	
	public function getGlyph (character:String):Glyph {
		
		#if (cpp || neko || nodejs)
		return lime_font_get_glyph_index (src, character);
		#else
		return -1;
		#end
		
	}
	
	
	public function getGlyphs (characters:String = #if (display && haxe_ver < "3.2") "" #else "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^`'\"/\\&*()[]{}<>|:;_-+=?,. " #end):Array<Glyph> {
		
		#if (cpp || neko || nodejs)
		return lime_font_get_glyph_indices (src, characters);
		#else
		return null;
		#end
		
	}
	
	
	public function getGlyphMetrics (glyph:Glyph):GlyphMetrics {
		
		#if (cpp || neko || nodejs)
		var value = lime_font_get_glyph_metrics (src, glyph);
		var metrics = new GlyphMetrics ();
		
		metrics.advance = new Vector2 (value.horizontalAdvance, value.verticalAdvance);
		metrics.height = value.height;
		metrics.horizontalBearing = new Vector2 (value.horizontalBearingX, value.horizontalBearingY);
		metrics.verticalBearing = new Vector2 (value.verticalBearingX, value.verticalBearingY);
		
		return metrics;
		#else
		return null;
		#end
		
	}
	
	
	public function renderGlyph (glyph:Glyph, fontSize:Int):Image {
		
		#if (cpp || neko || nodejs)
		
		lime_font_set_size (src, fontSize);
		
		var bytes = new ByteArray ();
		bytes.endian = "littleEndian";
		
		if (lime_font_render_glyph (src, glyph, bytes)) {
			
			bytes.position = 0;
			
			var index = bytes.readUnsignedInt ();
			var width = bytes.readUnsignedInt ();
			var height = bytes.readUnsignedInt ();
			var x = bytes.readUnsignedInt ();
			var y = bytes.readUnsignedInt ();
			
			var data = new ByteArray (width * height);
			bytes.readBytes (data, 0, width * height);
			
			#if js
			var buffer = new ImageBuffer (data.byteView, width, height, 1);
			#else
			var buffer = new ImageBuffer (new UInt8Array (data), width, height, 1);
			#end
			var image = new Image (buffer, 0, 0, width, height);
			image.x = x;
			image.y = y;
			
			return image;
			
		}
		
		#end
		
		return null;
		
	}
	
	
	public function renderGlyphs (glyphs:Array<Glyph>, fontSize:Int):Map<Glyph, Image> {
		
		#if (cpp || neko || nodejs)
		
		var uniqueGlyphs = new Map<Int, Bool> ();
		
		for (glyph in glyphs) {
			
			uniqueGlyphs.set (glyph, true);
			
		}
		
		var glyphList = [];
		
		for (key in uniqueGlyphs.keys ()) {
			
			glyphList.push (key);
			
		}
		
		lime_font_set_size (src, fontSize);
		
		var bytes = new ByteArray ();
		bytes.endian = "littleEndian";
		
		if (lime_font_render_glyphs (src, glyphList, bytes)) {
			
			bytes.position = 0;
			
			var count = bytes.readUnsignedInt ();
			
			var bufferWidth = 128;
			var bufferHeight = 128;
			var offsetX = 0;
			var offsetY = 0;
			var maxRows = 0;
			
			var width, height;
			var i = 0;
			
			while (i < count) {
				
				bytes.position += 4;
				width = bytes.readUnsignedInt ();
				height = bytes.readUnsignedInt ();
				bytes.position += (4 * 2) + width * height;
				
				if (offsetX + width > bufferWidth) {
					
					offsetY += maxRows + 1;
					offsetX = 0;
					maxRows = 0;
					
				}
				
				if (offsetY + height > bufferHeight) {
					
					if (bufferWidth < bufferHeight) {
						
						bufferWidth *= 2;
						
					} else {
						
						bufferHeight *= 2;
						
					}
					
					offsetX = 0;
					offsetY = 0;
					maxRows = 0;
					
					// TODO: make this better
					
					bytes.position = 4;
					i = 0;
					continue;
					
				}
				
				offsetX += width + 1;
				
				if (height > maxRows) {
					
					maxRows = height;
					
				}
				
				i++;
				
			}
			
			var map = new Map<Int, Image> ();
			var buffer = new ImageBuffer (null, bufferWidth, bufferHeight, 1);
			var data = new ByteArray (bufferWidth * bufferHeight);
			
			bytes.position = 4;
			offsetX = 0;
			offsetY = 0;
			maxRows = 0;
			
			var index, x, y, image;
			
			for (i in 0...count) {
				
				index = bytes.readUnsignedInt ();
				width = bytes.readUnsignedInt ();
				height = bytes.readUnsignedInt ();
				x = bytes.readUnsignedInt ();
				y = bytes.readUnsignedInt ();
				
				if (offsetX + width > bufferWidth) {
					
					offsetY += maxRows + 1;
					offsetX = 0;
					maxRows = 0;
					
				}
				
				for (i in 0...height) {
					
					data.position = ((i + offsetY) * bufferWidth) + offsetX;
					//bytes.readBytes (data, 0, width);
					
					for (x in 0...width) {
						
						var byte = bytes.readUnsignedByte ();
						data.writeByte (byte);
						
					}
					
				}
				
				image = new Image (buffer, offsetX, offsetY, width, height);
				image.x = x;
				image.y = y;
				
				map.set (index, image);
				
				offsetX += width + 1;
				
				if (height > maxRows) {
					
					maxRows = height;
					
				}
				
			}
			
			#if js
			buffer.data = data.byteView;
			#else
			buffer.data = new UInt8Array (data);
			#end
			
			return map;
			
		}
		
		#end
		
		return null;
		
	}
	
	
	@:noCompletion private function __fromBytes (bytes:ByteArray):Void {
		
		__fontPath = null;
		
		#if (cpp || neko || nodejs)
		
		src = lime_font_load (bytes);
		
		if (src != null && name == null) {
			
			name = lime_font_get_family_name (src);
			
		}
		
		#end
		
	}
	
	
	@:noCompletion private function __fromFile (path:String):Void {
		
		__fontPath = path;
		
		#if (cpp || neko || nodejs)
		
		src = lime_font_load (__fontPath);
		
		if (src != null && name == null) {
			
			name = lime_font_get_family_name (src);
			
		}
		
		#end
		
	}
	
	
	
	
	// Get & Set Methods
	
	
	
	
	private function get_ascender ():Int {
		
		#if (cpp || neko || nodejs)
		return lime_font_get_ascender (src);
		#else
		return 0;
		#end
		
	}
	
	
	private function get_descender ():Int {
		
		#if (cpp || neko || nodejs)
		return lime_font_get_descender (src);
		#else
		return 0;
		#end
		
	}
	
	
	private function get_height ():Int {
		
		#if (cpp || neko || nodejs)
		return lime_font_get_height (src);
		#else
		return 0;
		#end
		
	}
	
	
	private function get_numGlyphs ():Int {
		
		#if (cpp || neko || nodejs)
		return lime_font_get_num_glyphs (src);
		#else
		return 0;
		#end
		
	}
	
	
	private function get_underlinePosition ():Int {
		
		#if (cpp || neko || nodejs)
		return lime_font_get_underline_position (src);
		#else
		return 0;
		#end
		
	}
	
	
	private function get_underlineThickness ():Int {
		
		#if (cpp || neko || nodejs)
		return lime_font_get_underline_thickness (src);
		#else
		return 0;
		#end
		
	}
	
	
	private function get_unitsPerEM ():Int {
		
		#if (cpp || neko || nodejs)
		return lime_font_get_units_per_em (src);
		#else
		return 0;
		#end
		
	}
	
	
	
	
	// Native Methods
	
	
	
	
	#if (cpp || neko || nodejs)
	private static var lime_font_get_ascender = System.load ("lime", "lime_font_get_ascender", 1);
	private static var lime_font_get_descender = System.load ("lime", "lime_font_get_descender", 1);
	private static var lime_font_get_family_name = System.load ("lime", "lime_font_get_family_name", 1);
	private static var lime_font_get_glyph_index = System.load ("lime", "lime_font_get_glyph_index", 2);
	private static var lime_font_get_glyph_indices = System.load ("lime", "lime_font_get_glyph_indices", 2);
	private static var lime_font_get_glyph_metrics = System.load ("lime", "lime_font_get_glyph_metrics", 2);
	private static var lime_font_get_height = System.load ("lime", "lime_font_get_height", 1);
	private static var lime_font_get_num_glyphs = System.load ("lime", "lime_font_get_num_glyphs", 1);
	private static var lime_font_get_underline_position = System.load ("lime", "lime_font_get_underline_position", 1);
	private static var lime_font_get_underline_thickness = System.load ("lime", "lime_font_get_underline_thickness", 1);
	private static var lime_font_get_units_per_em = System.load ("lime", "lime_font_get_units_per_em", 1);
	private static var lime_font_load:Dynamic = System.load ("lime", "lime_font_load", 1);
	private static var lime_font_outline_decompose = System.load ("lime", "lime_font_outline_decompose", 2);
	private static var lime_font_render_glyph = System.load ("lime", "lime_font_render_glyph", 3);
	private static var lime_font_render_glyphs = System.load ("lime", "lime_font_render_glyphs", 3);
	private static var lime_font_set_size = System.load ("lime", "lime_font_set_size", 2);
	#end
	
	
}


typedef NativeFontData = {
	
	var has_kerning:Bool;
	var is_fixed_width:Bool;
	var has_glyph_names:Bool;
	var is_italic:Bool;
	var is_bold:Bool;
	var num_glyphs:Int;
	var family_name:String;
	var style_name:String;
	var em_size:Int;
	var ascend:Int;
	var descend:Int;
	var height:Int;
	var glyphs:Array<NativeGlyphData>;
	var kerning:Array<NativeKerningData>;
	
}


typedef NativeGlyphData = {
	
	var char_code:Int;
	var advance:Int;
	var min_x:Int;
	var max_x:Int;
	var min_y:Int;
	var max_y:Int;
	var points:Array<Int>;
	
}


typedef NativeKerningData = {
	
	var left_glyph:Int;
	var right_glyph:Int;
	var x:Int;
	var y:Int;
	
}
