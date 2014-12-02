package lime.utils; #if !js


@:forward() @:generic @:arrayAccess abstract Int16Array(ArrayBufferView) from ArrayBufferView to ArrayBufferView {
	
	
	public static inline var BYTES_PER_ELEMENT = 2;
	
	public var length (get, never):Int;
	
	
	public function new<T> (buffer:T, byteOffset:Int = 0, length:Null<Int> = null) {
		
		this = new ArrayBufferView ();
		
		switch (Type.getClass (buffer)) {
			
			case ArrayBuffer:
				
				this.buffer = cast buffer;
				this.byteOffset = byteOffset;
				
				if (length == null) {
					
					length = this.buffer.length >> 1;
					
				}
				
				if (byteOffset < 0 || byteOffset > length || byteOffset + length < 0 || byteOffset + length > (this.buffer.length << 1)) {
					
					throw "Invalid typed array length";
					
				}
				
				this.length = length;
			
			case ArrayBufferView:
				
				var bufferView:ArrayBufferView = cast buffer;
				
				this.buffer = new ArrayBuffer (bufferView.buffer.length);
				this.byteOffset = 0;
				this.length = bufferView.buffer.length << 1;
				
				// TODO: Faster clone
				
				for (i in 0...bufferView.buffer.length) {
					
					this.buffer[i] = bufferView.buffer[i];
					
				}
			
			case Array:
				
				var array:Array<Float> = cast buffer;
				
				this.buffer = new ArrayBuffer (array.length >> 1);
				this.byteOffset = 0;
				this.length = array.length;
				
				#if cpp
				var bytes = this.buffer.getData ();
				#end
				
				for (i in 0...this.length) {
					
					#if cpp
					untyped __global__.__hxcpp_memory_set_float (bytes, (i << 1), array[i]);
					#else
					this.buffer.writeFloat (array[i]);
					#end
					
				}
				
			case null:
				
				if (Std.is (buffer, Int)) {
					
					this.byteOffset = 0;
					this.length = cast buffer;
					this.buffer = new ArrayBuffer (this.length >> 1);
					
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
	
	
	public function subarray (begin:Int, end:Null<Int> = null):Int16Array {
		
		if (end == null) end == this.length;
		return new Int16Array (this.buffer, begin << 1, end - begin);
		
	}
	
	
	private function get_length ():Int {
		
		return this.length;
		
	}
	
	
	@:noCompletion @:arrayAccess public inline function __get (index:Int):Null<Int> {
		
		#if cpp
		untyped return __global__.__hxcpp_memory_get_i16 (this.buffer.getData (), index + this.byteOffset);
		#else
		this.buffer.position = index + this.byteOffset;
		return this.buffer.readShort ();
		#end

	}
	
	
	@:noCompletion @:arrayAccess public inline function __set (index:Int, value:Int):Int {
		
		#if cpp
		untyped __global__.__hxcpp_memory_set_i16 (bytes, index + this.byteOffset, value);
		#else
		this.buffer.position = index + this.byteOffset;
		this.buffer.writeShort (Std.int (value));
		#end
		return value;
		
	}
	
	
}


#else
typedef Int16Array = js.html.Int16Array;
#end


/*package lime.utils;
#if js
typedef Int16Array = js.html.Int16Array;
#else


@:generic class Int16Array extends ArrayBufferView implements ArrayAccess<Int> {
	
	
	public static inline var BYTES_PER_ELEMENT = 2;
	
	public var length (default, null):Int;
	
	
	public function new<T> (bufferOrArray:T, start:Int = 0, length:Null<Int> = null) {
		
		if (Std.is (bufferOrArray, Int)) {
			
			super (Std.int (cast bufferOrArray) << 1);
			
			this.length = cast bufferOrArray;
			
		} else if (Std.is (bufferOrArray, Array)) {
			
			var ints:Array<Int> = cast bufferOrArray;
			this.length = (length != null) ? length : ints.length - start;
			
			super (this.length << 1);
			
			#if !cpp
			buffer.position = 0;
			#end
			
			for (i in 0...this.length) {
				
				#if cpp
				untyped __global__.__hxcpp_memory_set_i16 (bytes, (i << 1), ints[i + start]);
				#else
				buffer.writeShort (ints[i + start]);
				#end
				
			}
			
		} else if (Std.is (bufferOrArray, Int16Array)) {
			
			var ints:Int16Array = cast bufferOrArray;
			this.length = (length != null) ? length : ints.length - start;
			
			super (this.length << 1);
			
			#if !cpp
			buffer.position = 0;
			#end
			
			for (i in 0...this.length) {
				
				#if cpp
				untyped __global__.__hxcpp_memory_set_i16 (bytes, (i << 1), ints[i + start]);
				#else
				buffer.writeShort (ints[i + start]);
				#end
				
			}
			
		} else {
			
			super (bufferOrArray, start, (length != null) ? length << 1 : null);
			
			if ((byteLength & 0x01) > 0) {
				
				throw "Invalid array size";
				
			}
			
			this.length = byteLength >> 1;
			
			if ((this.length << 1) != byteLength) {
				
				throw "Invalid length multiple";
				
			}
			
		}
		
	}
	
	
	public function set<T> (bufferOrArray:T, offset:Int = 0):Void {
		
		if (Std.is (bufferOrArray, Array)) {
			
			var ints:Array<Int> = cast bufferOrArray;
			
			for (i in 0...ints.length) {
				
				setInt16 ((i + offset) << 1, ints[i]);
				
			}
			
		} else if (Std.is (bufferOrArray, Int16Array)) {
			
			var ints:Int16Array = cast bufferOrArray;
			
			for (i in 0...ints.length) {
				
				setInt16 ((i + offset) << 1, ints[i]);
				
			}
			
		} else {
			
			throw "Invalid input buffer";
			
		}
		
	}
	
	
	public function subarray (start:Int, end:Null<Int> = null):Int16Array {
		
		end = (end == null) ? length : end;
		return new Int16Array (buffer, start << 1, end - start);
		
	}
	
	
	@:noCompletion @:keep inline public function __get (index:Int):Int { return getInt16 (index << 1); }
	@:noCompletion @:keep inline public function __set (index:Int, value:Int) { setInt16 (index << 1, value); }
	
	
}


#end*/