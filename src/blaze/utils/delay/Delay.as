package blaze.utils.delay 
{
	import flash.display.Sprite;
	/**
	 * ...
	 * @author P.J.Shand
	 */
	public class Delay 
	{
		private static var broadcaster:Sprite = new Sprite();
		private static var delayObjects:Vector.<DelayObject>;
		
		public function Delay() 
		{
			
		}
		
		private static function init():void 
		{
			if (!delayObjects) delayObjects = new Vector.<DelayObject>();
		}
		
		public static function nextFrame(callback:Function, params:Array=null):void
		{
			Delay.by(1, callback, params)
		}
		
		public static function by(frames:int, callback:Function, params:Array=null):void 
		{
			init();
			var delayObject:DelayObject = new DelayObject(broadcaster)
			delayObjects.push(delayObject);
			delayObject.by(frames, clearObject, callback, params);
		}
		
		private static function clearObject(delayObject:DelayObject):void 
		{
			for (var i:int = 0; i < delayObjects.length; i++) 
			{
				if (delayObjects[i] == delayObject) {
					delayObject.dispose();
					delayObject = null;
					delayObjects.splice(i, 1);
				}
			}
		}
		
		public static function killDelay(callback:Function):void 
		{
			if (!delayObjects) return;
			for (var i:int = 0; i < delayObjects.length; i++) 
			{
				if (delayObjects[i].callback == callback) {
					delayObjects[i].dispose();
					delayObjects[i] = null;
					delayObjects.splice(i, 1);
					i--;
				}
			}
		}
	}
}

import flash.display.Sprite;
import flash.events.Event;

class DelayObject
{
	private var broadcaster:Sprite;
	public var callback:Function;
	private var params:Array;
	private var clearObject:Function;
	
	private var frameCount:int = 0;
	private var frames:int;
	
	
	public function DelayObject(broadcaster:Sprite):void
	{
		this.broadcaster = broadcaster;
	}
	
	public function nextFrame(clearObject:Function, callback:Function, params:Array=null):void 
	{
		by(1, clearObject, callback, params);
	}
	
	public function by(frames:int, clearObject:Function, callback:Function, params:Array=null):void 
	{
		this.frames = frames;
		this.clearObject = clearObject;
		this.params = params;
		this.callback = callback;
		broadcaster.addEventListener(Event.ENTER_FRAME, Update);
		Update(null);
	}
	
	private function Update(e:Event):void 
	{
		if (frames == frameCount) {
			broadcaster.removeEventListener(Event.ENTER_FRAME, Update);
			callback.apply(this, params);
			clearObject(this);
			return;
		}
		frameCount++;
	}
	
	public function dispose():void
	{
		broadcaster = null;
		callback = null;
		params = null;
		clearObject = null;
	}
}