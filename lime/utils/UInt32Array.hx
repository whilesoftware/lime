package lime.utils; #if !js


@:forward() @:generic @:arrayAccess abstract UInt32Array(ArrayBufferView) from ArrayBufferView to ArrayBufferView {
	
	
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
	
	
	public function subarray (begin:Int, end:Null<Int> = null):UInt32Array {
		
		if (end == null) end == this.length;
		return new UInt32Array (this.buffer, begin << 2, end - begin);
		
	}
	
	
	private function get_length ():Int {
		
		return this.length;
		
	}
	
	
	@:noCompletion @:arrayAccess public inline function __get (index:Int):Null<UInt> {
		
		#if cpp
		untyped return __global__.__hxcpp_memory_get_ui32 (this.buffer.getData (), index + this.byteOffset);
		#else
		this.buffer.position = index + this.byteOffset;
		return this.buffer.readUnsignedInt ();
		#end

	}
	
	
	@:noCompletion @:arrayAccess public inline function __set (index:Int, value:UInt):UInt {
		
		#if cpp
		untyped __global__.__hxcpp_memory_set_ui32 (this.buffer.getData (), index + this.byteOffset, value);
		#else
		this.buffer.position = index + this.byteOffset;
		this.buffer.writeUnsignedInt (Std.int (value));
		#end
		return value;
		
	}
	
	
}


#else
typedef UInt32Array = js.html.Uint32Array;
#end


/*package lime.utils;
#if js
typedef UInt32Array = js.html.Uint32Array;
#else


@:generic class UInt32Array extends ArrayBufferView implements ArrayAccess<Int> {
	
	
	public static inline var BYTES_PER_ELEMENT = 4;
	
	public var length (default, null) : Int;
	
	
	public function new<T> (bufferOrArray:T, start:Int = 0, length:Null<Int> = null) {
		
		if (Std.is (bufferOrArray, Int)) {
			
			super (Std.int (cast bufferOrArray) << 2);
			
			this.length = cast bufferOrArray;
			
		} else if (Std.is (bufferOrArray, Array)) {
			
			var ints:Array<Int> = cast bufferOrArray;
			this.length = (length != null) ? length : ints.length - start;
			
			super (this.length << 2);
			
			#if !cpp
			buffer.position = 0;
			#end
			
			for (i in 0...this.length) {
				
				#if cpp
				untyped __global__.__hxcpp_memory_set_ui32 (bytes, (i << 2), ints[i + start]);
				#else
				buffer.writeInt (ints[i + start]);
				#end
				
			}
			
		} else if (Std.is (bufferOrArray, UInt32Array)) {
			
			var ints:UInt32Array = cast bufferOrArray;
			this.length = (length != null) ? length : ints.length - start;
			
			super (this.length << 2);
			
			#if !cpp
			buffer.position = 0;
			#end
			
			for (i in 0...this.length) {
				
				#if cpp
				untyped __global__.__hxcpp_memory_set_ui32 (bytes, (i << 2), ints[i + start]);
				#else
				buffer.writeInt (ints[i + start]);
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
			
			var ints:Array<Int> = cast bufferOrArray;
			
			for (i in 0...ints.length) {
				
				setUInt32 ((i + offset) << 2, ints[i]);
				
			}
			
		} else if (Std.is (bufferOrArray, UInt32Array)) {
			
			var ints:UInt32Array = cast bufferOrArray;
			
			for (i in 0...ints.length) {
				
				setUInt32 ((i + offset) << 2, ints[i]);
				
			}
			
		} else {
			
			throw "Invalid input buffer";
			
		}
		
	}
	
	
	public function subarray (start:Int, end:Null<Int> = null):UInt32Array {
		
		end = (end == null) ? length : end;
		return new UInt32Array (buffer, start << 2, end - start);
		
	}
	
	
	@:noCompletion @:keep inline public function __get (index:Int):Int { return getUInt32 (index << 2); }
	@:noCompletion @:keep inline public function __set (index:Int, value:Int) { setUInt32 (index << 2, value); }
	
	
}


#end*/