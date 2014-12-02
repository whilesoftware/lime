package lime.utils; #if !js


@:forward() @:generic @:arrayAccess abstract Int8Array(ArrayBufferView) from ArrayBufferView to ArrayBufferView {
	
	
	public static inline var BYTES_PER_ELEMENT = 1;
	
	public var length (get, never):Int;
	
	
	public function new<T> (buffer:T, byteOffset:Int = 0, length:Null<Int> = null) {
		
		this = new ArrayBufferView ();
		
		switch (Type.getClass (buffer)) {
			
			case ArrayBuffer:
				
				this.buffer = cast buffer;
				this.byteOffset = byteOffset;
				
				if (length == null) {
					
					length = this.buffer.length;
					
				}
				
				if (byteOffset < 0 || byteOffset > length || byteOffset + length < 0 || byteOffset + length > (this.buffer.length)) {
					
					throw "Invalid typed array length";
					
				}
				
				this.length = length;
			
			case ArrayBufferView:
				
				var bufferView:ArrayBufferView = cast buffer;
				
				this.buffer = new ArrayBuffer (bufferView.buffer.length);
				this.byteOffset = 0;
				this.length = bufferView.buffer.length;
				
				// TODO: Faster clone
				
				for (i in 0...bufferView.buffer.length) {
					
					this.buffer[i] = bufferView.buffer[i];
					
				}
			
			case Array:
				
				var array:Array<Float> = cast buffer;
				
				this.buffer = new ArrayBuffer (array.length);
				this.byteOffset = 0;
				this.length = array.length;
				
				#if cpp
				var bytes = this.buffer.getData ();
				#end
				
				for (i in 0...this.length) {
					
					#if cpp
					untyped __global__.__hxcpp_memory_set_float (bytes, (i), array[i]);
					#else
					this.buffer.writeFloat (array[i]);
					#end
					
				}
				
			case null:
				
				if (Std.is (buffer, Int)) {
					
					this.byteOffset = 0;
					this.length = cast buffer;
					this.buffer = new ArrayBuffer (this.length);
					
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
	
	
	public function subarray (begin:Int, end:Null<Int> = null):Int8Array {
		
		if (end == null) end == this.length;
		return new Int8Array (this.buffer, begin, end - begin);
		
	}
	
	
	private function get_length ():Int {
		
		return this.length;
		
	}
	
	
	@:noCompletion @:arrayAccess public inline function __get (index:Int):Null<Int> {
		
		#if cpp
		return untyped __global__.__hxcpp_memory_get_byte (this.buffer.getData (), index + this.byteOffset);
		#else
		this.buffer.position = index + this.byteOffset;
		return this.buffer.readByte ();
		#end

	}
	
	
	@:noCompletion @:arrayAccess public inline function __set (index:Int, value:Int):Int {
		
		#if cpp
		untyped __global__.__hxcpp_memory_set_byte (this.buffer.getData (), index + this.byteOffset, value);
		#else
		this.buffer.position = index + this.byteOffset;
		this.buffer.writeByte (value);
		#end
		return value;
		
	}
	
	
}


#else
typedef Int8Array = js.html.Int8Array;
#end


/*package lime.utils;
#if js
typedef Int8Array = js.html.Int8Array;
#else


@:generic class Int8Array extends ArrayBufferView implements ArrayAccess<Int> {
	
	
	public static inline var BYTES_PER_ELEMENT = 1;
	
	public var length (default, null):Int;
	
	
	public function new<T> (bufferOrArray:T, start:Int = 0, length:Null<Int> = null) {
		
		if (Std.is (bufferOrArray, Int)) {
			
			super (Std.int (cast bufferOrArray));
			
			this.length = cast bufferOrArray;
			
		} else if (Std.is (bufferOrArray, Array)) {
			
			var ints:Array<Int> = cast bufferOrArray;
			this.length = (length != null) ? length : ints.length - start;
			
			super (this.length);
			
			#if !cpp
			buffer.position = 0;
			#end
			
			for (i in 0...this.length) {
				
				#if cpp
				untyped __global__.__hxcpp_memory_set_byte (bytes, i, ints[i + start]);
				#else
				buffer.writeByte (ints[i + start]);
				#end
				
			}
			
		} else if (Std.is (bufferOrArray, Int8Array)) {
			
			var ints:Int8Array = cast bufferOrArray;
			this.length = (length != null) ? length : ints.length - start;
			
			super (this.length);
			
			#if !cpp
			buffer.position = 0;
			#end
			
			for (i in 0...this.length) {
				
				#if cpp
				untyped __global__.__hxcpp_memory_set_byte (bytes, i, ints[i + start]);
				#else
				buffer.writeByte (ints[i + start]);
				#end
				
			}
			
		} else {
			
			super (bufferOrArray, start, length);
			this.length = byteLength;
			
		}
		
	}
	
	
	public function set<T> (bufferOrArray:T, offset:Int = 0):Void {
		
		if (Std.is(bufferOrArray, Array)) {
			
			var ints:Array<Int> = cast bufferOrArray;
			
			for (i in 0...ints.length) {
				
				setInt8 (i + offset, ints[i]);
				
			}
			
		} else if (Std.is (bufferOrArray, Int8Array)) {
			
			var ints:Int8Array = cast bufferOrArray;
			
			for (i in 0...ints.length) {
				
				setInt8 (i + offset, ints[i]);
				
			}
			
		} else {
			
			throw "Invalid input buffer";
			
		}
		
	}
	
	
	public function subarray (start:Int, end:Null<Int> = null):Int8Array {
		
		end = (end == null) ? length : end;
		return new Int8Array (buffer, start, end - start);
		
	}
	
	
	@:noCompletion @:keep inline public function __get (index:Int):Int { return getInt8 (index); }
	@:noCompletion @:keep inline public function __set (index:Int, value:Int) { setInt8 (index, value); }
	
	
}


#end*/