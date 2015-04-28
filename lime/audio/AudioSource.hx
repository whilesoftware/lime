package lime.audio;


import haxe.Timer;
import lime.app.Event;
import lime.audio.openal.AL;

#if flash
import flash.media.SoundChannel;
#end


class AudioSource {
	
	
	public var onComplete = new Event<Void->Void> ();
	
	public var buffer:AudioBuffer;
	public var currentTime (get, set):Int;
	public var gain (get, set):Float;
	public var length (get, set):Int;
	public var loops:Int;
	public var offset:Int;
	
	private var id:UInt;
	private var playing:Bool;
	private var pauseTime:Int;
	private var __length:Null<Int>;
	
	#if flash
	private var channel:SoundChannel;
	#end
	
	#if (cpp || neko || nodejs)
	private var timer:Timer;
	#end
	
	
	public function new (buffer:AudioBuffer = null, offset:Int = 0, length:Null<Int> = null, loops:Int = 0) {
		
		this.buffer = buffer;
		this.offset = offset;
		
		if (length != null && length != 0) {
			
			this.length = length;
			
		}
		
		this.loops = loops;
		id = 0;
		
		if (buffer != null) {
			
			init ();
			
		}
		
	}
	
	
	private function init ():Void {
		
		switch (AudioManager.context) {
			
			case OPENAL (alc, al):
				
				if (buffer.id == 0) {
					
					buffer.id = al.genBuffer ();
					
					var format = 0;
					
					if (buffer.channels == 1) {
						
						if (buffer.bitsPerSample == 8) {
							
							format = al.FORMAT_MONO8;
							
						} else if (buffer.bitsPerSample == 16) {
							
							format = al.FORMAT_MONO16;
							
						}
						
					} else if (buffer.channels == 2) {
						
						if (buffer.bitsPerSample == 8) {
							
							format = al.FORMAT_STEREO8;
							
						} else if (buffer.bitsPerSample == 16) {
							
							format = al.FORMAT_STEREO16;
							
						}
						
					}
					
					al.bufferData (buffer.id, format, buffer.data, buffer.data.length, buffer.sampleRate);
					
				}
				
				id = al.genSource ();
				al.sourcei (id, al.BUFFER, buffer.id);
			
			default:
			
		}
		
	}
	
	
	public function play ():Void {
		
		#if html5
		#elseif flash
			
			if (channel != null) channel.stop ();
			var channel = buffer.src.play (pauseTime / 1000);
			
		#else
			
			if (playing) {
				
				return;
				
			}
			
			playing = true;
			
			var time = currentTime;
			
			AL.sourcePlay (id);
			
			currentTime = time;
			
			if (timer != null) {
				
				timer.stop ();
				
			}
			
			timer = new Timer (length - currentTime);
			timer.run = timer_onRun;
			
		#end
		
	}
	
	
	public function pause ():Void {
		
		#if html5
		#elseif flash
			
			if (channel != null) {
				
				pauseTime = Std.int (channel.position * 1000);
				channel.stop ();
				
			}
			
		#else
			
			playing = false;
			AL.sourcePause (id);
			
			if (timer != null) {
				
				timer.stop ();
				
			}
			
		#end
		
	}
	
	
	public function stop ():Void {
		
		#if html5
		#elseif flash
			
			pauseTime = 0;
			if (channel != null) channel.stop ();
			
		#else
			
			playing = false;
			AL.sourceStop (id);
			
			if (timer != null) {
				
				timer.stop ();
				
			}
			
		#end
		
	}
	
	
	
	
	// Event Handlers
	
	
	
	
	private function timer_onRun () {
		
		#if (!flash && !html5)
		
		playing = false;
		
		if (loops > 0) {
			
			loops--;
			currentTime = 0;
			play ();
			return;
			
		} else {
			
			AL.sourceStop (id);
			timer.stop ();
			
		}
		
		onComplete.dispatch ();
		
		#end
		
	}
	
	
	
	
	// Get & Set Methods
	
	
	
	
	private function get_currentTime ():Int {
		
		#if html5
			
			return 0;
			
		#elseif flash
			
			return Std.int (channel.position);
			
		#else
			
			var time = Std.int (AL.getSourcef (id, AL.SEC_OFFSET) * 1000) - offset;
			if (time < 0) return 0;
			return time;
			
		#end
		
	}
	
	
	private function set_currentTime (value:Int):Int {
		
		#if html5
			
			return pauseTime = value;
			
		#elseif flash
			
			// TODO: create new sound channel
			//channel.position = value;
			return pauseTime = value;
			
		#else
			
			if (buffer != null) {
				
				AL.sourceRewind (id);
				AL.sourcef (id, AL.SEC_OFFSET, (value + offset) / 1000);
				if (playing) AL.sourcePlay (id);
				
			}
			
			return value;
			
		#end
		
	}
	
	
	private function get_gain ():Float {
		
		#if html5
			
			return 1;
			
		#elseif flash
			
			return channel.soundTransform.volume;
			
		#else
			
			return AL.getSourcef (id, AL.GAIN);
			
		#end
		
	}
	
	
	private function set_gain (value:Float):Float {
		
		#if html5
			
			return 1;
			
		#elseif flash
			
			var soundTransform = channel.soundTransform;
			soundTransform.volume = value;
			channel.soundTransform = soundTransform;
			return value;
			
		#else
			
			AL.sourcef (id, AL.GAIN, value);
			return value;
			
		#end
		
	}
	
	
	private function get_length ():Int {
		
		if (__length != null) {
			
			return __length;
			
		}
		
		#if html5
			
			return 0;
			
		#elseif flash
			
			return Std.int (buffer.src.length);
			
		#else
			
			var samples = (buffer.data.length * 8) / (buffer.channels * buffer.bitsPerSample);
			return Std.int (samples / buffer.sampleRate * 1000) - offset;
			
		#end
		
	}
	
	
	private function set_length (value:Int):Int {
		
		return __length = value;
		
	}
	
	
}