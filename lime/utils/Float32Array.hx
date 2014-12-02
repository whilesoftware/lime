package lime.utils; #if !js


@:forward() @:generic @:arrayAccess abstract Float32Array(ArrayBufferView) from ArrayBufferView to ArrayBufferView {
	
	
	public static inline var BYTES_PER_ELEMENT = 4;
	
	public var length (get, never):Int;
	
	
	public function new<T> (buffer:T, byteOffset:Int = 0, length:Null<Int> = null) {
		
		this = new ArrayBufferView ();
		
		switch (Type.getClass (buffer)) {
			
			case ArrayBuffer:
				
				this.buffer = cast buffer;
				this.byteOffset = byteOffset;
				
				if (length == null) {
					
					length = this.buffer.length >> 2;
					
				}
				
				if (byteOffset < 0 || byteOffset > length || byteOffset + length < 0 || byteOffset + length > (this.buffer.length << 2)) {
					
					throw "Invalid typed array length";
					
				}
				
				this.length = length;
			
			case ArrayBufferView:
				
				var bufferView:ArrayBufferView = cast buffer;
				
				this.buffer = new ArrayBuffer (bufferView.buffer.length);
				this.byteOffset = 0;
				this.length = bufferView.buffer.length << 2;
				
				// TODO: Faster clone
				
				for (i in 0...bufferView.buffer.length) {
					
					this.buffer[i] = bufferView.buffer[i];
					
				}
			
			case Array:
				
				var array:Array<Float> = cast buffer;
				
				this.buffer = new ArrayBuffer (array.length >> 2);
				this.byteOffset = 0;
				this.length = array.length;
				
				#if cpp
				var bytes = this.buffer.getData ();
				#end
				
				for (i in 0...this.length) {
					
					#if cpp
					untyped __global__.__hxcpp_memory_set_float (bytes, (i << 2), array[i]);
					#else
					this.buffer.writeFloat (array[i]);
					#end
					
				}
				
			case null:
				
				if (Std.is (buffer, Int)) {
					
					this.byteOffset = 0;
					this.length = cast buffer;
					this.buffer = new ArrayBuffer (this.length >> 2);
					
				}
			
			default:
			
		}
		
	}
	
	
	public function set<T> (data:T, offset:Int = 0):Void {
		
		/*switch (Type.getClass (data)) {
			
			case ArrayBufferView:
				
				var bufferView:ArrayBufferView = cast data;
				var length = data.buffer.length - offset;
				
				for (i in 0...length) {
					
					__set ()
					
				}
			
		}
		
		if (Std.is (bufferOrArray, Array)) {
			
			var floats:Array<Float> = cast bufferOrArray;
			
			for (i in 0...floats.length) {
				
				setFloat32 ((i + offset) << 2, floats[i]);
				
			}
			
		} else if (Std.is (bufferOrArray, Float32Array)) {
			
			var floats:Float32Array = cast bufferOrArray;
			
			for (i in 0...floats.length) {
				
				setFloat32 ((i + offset) << 2, floats[i]);
				
			}
			
		} else {
			
			throw "Invalid input buffer";
			
		}*/
		
	}
	
	
	public function subarray (begin:Int, end:Null<Int> = null):Float32Array {
		
		if (end == null) end == this.length;
		return new Float32Array (this.buffer, begin << 2, end - begin);
		
	}
	
	
	private function get_length ():Int {
		
		return this.length;
		
	}
	
	
	@:noCompletion @:arrayAccess public inline function __get (index:Int):Null<Float> {
		
		#if cpp
		untyped return __global__.__hxcpp_memory_get_float (this.buffer.getData (), index + this.byteOffset);
		#else
		this.buffer.position = index + this.byteOffset;
		return this.buffer.readFloat ();
		#end

	}
	
	
	@:noCompletion @:arrayAccess public inline function __set (index:Int, value:Float):Float {
		
		#if cpp
		untyped __global__.__hxcpp_memory_set_float (this.buffer.getData (), index + this.byteOffset, value);
		#else
		this.buffer.position = index + this.byteOffset;
		this.buffer.writeFloat (value);
		#end
		return value;
		
	}
	
	
}


#else
typedef Float32Array = js.html.Float32Array;
#end


/*package lime.utils;
#if js
typedef Float32Array = js.html.Float32Array;
#else


@:generic class Float32Array extends ArrayBufferView implements ArrayAccess<Float> {
	
	
	public static inline var BYTES_PER_ELEMENT = 4;
	
	public var length (default, null):Int;
	
	
	public function new<T> (bufferOrArray:T, start:Int = 0, length:Null<Int> = null) {
		
		#if (openfl && neko && !lime_legacy)
		if (Std.is (bufferOrArray, openfl.Vector.VectorData)) {
			
			var vector:openfl.Vector<Float> = cast bufferOrArray;
			var floats:Array<Float> = vector;
			this.length = (length != null) ? length : floats.length - start;
			
			super (this.length << 2);
			
			#if !cpp
			buffer.position = 0;
			#end
			
			for (i in 0...this.length) {
				
				#if cpp
				untyped __global__.__hxcpp_memory_set_float (bytes, (i << 2), floats[i + start]);
				#else
				buffer.writeFloat (floats[i + start]);
				#end
				
			}
			
			return;
			
		}
		#end
		
		if (Std.is (bufferOrArray, Int)) {
			
			super (Std.int (cast bufferOrArray) << 2);
			
			this.length = cast bufferOrArray;
			
		} else if (Std.is (bufferOrArray, Array)) {
			
			var floats:Array<Float> = cast bufferOrArray;
			this.length = (length != null) ? length : floats.length - start;
			
			super (this.length << 2);
			
			#if !cpp
			buffer.position = 0;
			#end
			
			for (i in 0...this.length) {
				
				#if cpp
				untyped __global__.__hxcpp_memory_set_float (bytes, (i << 2), floats[i + start]);
				#else
				buffer.writeFloat (floats[i + start]);
				#end
				
			}
			
		} else if (Std.is (bufferOrArray, Float32Array)) {
			
			var floats:Float32Array = cast bufferOrArray;
			this.length = (length != null) ? length : floats.length - start;
			
			super (this.length << 2);
			
			#if !cpp
			buffer.position = 0;
			#end
			
			for (i in 0...this.length) {
				
				#if cpp
				untyped __global__.__hxcpp_memory_set_float (bytes, (i << 2), floats[i + start]);
				#else
				buffer.writeFloat (floats[i + start]);
				#end
				
			}
			
		} else {
			
			super (bufferOrArray, start, (length != null) ? length << 2 : null);
			
			if ((byteLength & 0x03) > 0) {
				
				throw "Invalid array size";
				
			}
			
			this.length = byteLength >> 2;
			
			if ((this.length << 2) != byteLength) {
				
				throw "Invalid length multiple";
				
			}
			
		}
		
	}
	
	
	public function set<T> (bufferOrArray:T, offset:Int = 0):Void {
		
		if (Std.is (bufferOrArray, Array)) {
			
			var floats:Array<Float> = cast bufferOrArray;
			
			for (i in 0...floats.length) {
				
				setFloat32 ((i + offset) << 2, floats[i]);
				
			}
			
		} else if (Std.is (bufferOrArray, Float32Array)) {
			
			var floats:Float32Array = cast bufferOrArray;
			
			for (i in 0...floats.length) {
				
				setFloat32 ((i + offset) << 2, floats[i]);
				
			}
			
		} else {
			
			throw "Invalid input buffer";
			
		}
		
	}
	
	
	public function subarray (start:Int, end:Null<Int> = null):Float32Array {
		
		end = (end == null) ? length : end;
		return new Float32Array (buffer, start << 2, end - start);
		
	}
	
	
	@:noCompletion @:keep inline public function __get (index:Int):Float { return getFloat32 (index << 2); }
	@:noCompletion @:keep inline public function __set (index:Int, value:Float) { setFloat32 (index << 2, value); }
	
	
}


#end*/