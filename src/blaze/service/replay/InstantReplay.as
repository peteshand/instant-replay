package blaze.service.replay 
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	/**
	 * ...
	 * @author P.J.Shand
	 */
	public class InstantReplay 
	{
		private static var instantReplayObjects:Vector.<InstantReplayObject>;// = new Vector.<InstantReplayObject>();
		private static var _record:Boolean = false;
		private static var _playing:Boolean = false;
		
		public static var currentFrame:int = 0;
		public static var totalFrames:int = 0;
		
		private static var broadcaster:Sprite = new Sprite();
		
		private static var STATE_PLAY:String = 'play';
		private static var STATE_STOP:String = 'stop';
		private static var STATE_RECORDING:String = 'recording';
		
		private static var _state:String;
		
		public function InstantReplay() 
		{
			
		}
		
		private static function init():void
		{
			if (!instantReplayObjects) {
				instantReplayObjects = new Vector.<InstantReplayObject>();
			}
		}
		
		public static function clear():void 
		{
			InstantReplay.init();
			for (var i:int = 0; i < instantReplayObjects.length; i++) 
			{
				instantReplayObjects[i].clear();
			}
			currentFrame = totalFrames = 0;
			broadcaster.removeEventListener(Event.ENTER_FRAME, PlaybackUpdate);
			broadcaster.removeEventListener(Event.ENTER_FRAME, RecordUpdate);
		}
		
		public static function play():void
		{
			if (record) record = false;
			state = InstantReplay.STATE_PLAY;
		}
		
		public static function stop():void
		{
			if (record) record = false;
			state = InstantReplay.STATE_STOP;
		}
		
		public static function get record():Boolean 
		{
			return _record;
		}
		
		public static function set record(value:Boolean):void 
		{
			if (_record == value) return;
			_record = value;
			if (record) {
				state = InstantReplay.STATE_RECORDING;
			}
			else {
				state = InstantReplay.STATE_STOP;
			}
		}
		
		private static function get state():String 
		{
			return _state;
		}
		
		private static function set state(value:String):void 
		{
			if (_state == value) return;
			InstantReplay.init();
			_state = value;
			if (state == InstantReplay.STATE_RECORDING) {
				_playing = false;
				broadcaster.removeEventListener(Event.ENTER_FRAME, PlaybackUpdate);
				broadcaster.addEventListener(Event.ENTER_FRAME, RecordUpdate);
			}
			else {
				broadcaster.removeEventListener(Event.ENTER_FRAME, RecordUpdate);
				if (state == InstantReplay.STATE_PLAY) {
					_playing = true;
					//currentFrame = 0;
					broadcaster.addEventListener(Event.ENTER_FRAME, PlaybackUpdate);
				}
				else if (state == InstantReplay.STATE_STOP) {
					_playing = false;
					broadcaster.removeEventListener(Event.ENTER_FRAME, PlaybackUpdate);
				}
			}
		}
		
		static public function get playing():Boolean 
		{
			return _playing;
		}
		
		private static function RecordUpdate(e:Event):void 
		{
			for (var i:int = 0; i < instantReplayObjects.length; i++) 
			{
				instantReplayObjects[i].record(currentFrame);
			}
			currentFrame++;
			if (totalFrames < currentFrame) totalFrames = currentFrame;
		}
		
		private static function PlaybackUpdate(e:Event):void 
		{
			currentFrame++;
			
			if (currentFrame >= totalFrames) {
				currentFrame = 0;
			}
			for (var i:int = 0; i < instantReplayObjects.length; i++) 
			{
				instantReplayObjects[i].play(currentFrame);
			}
		}
		
		public static function register(displayObject:DisplayObject):void
		{
			InstantReplay.init();
			for (var i:int = 0; i < instantReplayObjects.length; i++) 
			{
				if (instantReplayObjects[i].displayObject == displayObject) return;
			}
			instantReplayObjects.push(new InstantReplayObject(displayObject));
		}
		
		public static function deregister(displayObject:DisplayObject):void
		{
			InstantReplay.init();
			for (var i:int = 0; i < instantReplayObjects.length; i++) 
			{
				if (instantReplayObjects[i].displayObject == displayObject) {
					instantReplayObjects[i].dispose();
					instantReplayObjects.splice(i, 1);
				}
			}
		}
	}
}

import flash.display.DisplayObject;
import flash.events.MouseEvent;
import blaze.events.ReplayMouseEvent;

class InstantReplayObject
{
	public var displayObject:DisplayObject;
	private var currentActions:FrameActions;
	private var frames:Vector.<FrameActions> = new Vector.<FrameActions>();
	
	public function InstantReplayObject(displayObject:DisplayObject)
	{
		this.displayObject = displayObject;
		currentActions = new FrameActions();
		displayObject.addEventListener(MouseEvent.CLICK, OnMouseEvent);
		displayObject.addEventListener(MouseEvent.DOUBLE_CLICK, OnMouseEvent);
		displayObject.addEventListener(MouseEvent.MOUSE_DOWN, OnMouseEvent);
		displayObject.addEventListener(MouseEvent.MOUSE_MOVE, OnMouseEvent);
		displayObject.addEventListener(MouseEvent.MOUSE_OUT, OnMouseEvent);
		displayObject.addEventListener(MouseEvent.MOUSE_OVER, OnMouseEvent);
		displayObject.addEventListener(MouseEvent.MOUSE_UP, OnMouseEvent);
		displayObject.addEventListener(MouseEvent.MOUSE_WHEEL, OnMouseEvent);
		displayObject.addEventListener(MouseEvent.ROLL_OUT, OnMouseEvent);
		displayObject.addEventListener(MouseEvent.ROLL_OVER, OnMouseEvent);
		
		CONFIG::air {
			displayObject.addEventListener(MouseEvent.CONTEXT_MENU, OnMouseEvent);
			displayObject.addEventListener(MouseEvent.MIDDLE_CLICK, OnMouseEvent);
			displayObject.addEventListener(MouseEvent.MIDDLE_MOUSE_DOWN, OnMouseEvent);
			displayObject.addEventListener(MouseEvent.MIDDLE_MOUSE_UP, OnMouseEvent);
			displayObject.addEventListener(MouseEvent.RELEASE_OUTSIDE, OnMouseEvent);
			displayObject.addEventListener(MouseEvent.RIGHT_CLICK, OnMouseEvent);
			displayObject.addEventListener(MouseEvent.RIGHT_MOUSE_DOWN, OnMouseEvent);
			displayObject.addEventListener(MouseEvent.RIGHT_MOUSE_UP, OnMouseEvent);
		}
	}
	
	private function OnMouseEvent(e:MouseEvent):void 
	{
		CONFIG::air {
			currentActions.mouseEvents.push(new ReplayMouseEvent(e.type, e.bubbles, e.cancelable, e.localX, e.localY, e.relatedObject, e.ctrlKey, e.altKey, e.shiftKey, e.buttonDown, e.delta, e.commandKey, e.controlKey, e.clickCount));
			return;
		}
		currentActions.mouseEvents.push(new ReplayMouseEvent(e.type, e.bubbles, e.cancelable, e.localX, e.localY, e.relatedObject, e.ctrlKey, e.altKey, e.shiftKey, e.buttonDown, e.delta));
	}
	
	public function dispose():void 
	{
		for (var i:int = 0; i < frames.length; i++) 
		{
			frames[i].dispose();
		}
		frames = null;
		currentActions = null;
		displayObject.removeEventListener(MouseEvent.MOUSE_MOVE, OnMouseEvent);
		displayObject = null;
	}
	
	public function record(frameIndex:int):void 
	{
		frames[frameIndex] = currentActions;
		currentActions = new FrameActions();
	}
	
	public function play(frameIndex:int):void 
	{
		if (frames.length == 0) return;
		var len:int = frames[frameIndex].mouseEvents.length;
		for (var i:int = 0; i < len; i++) 
		{
			if (frames.length > i) {
				displayObject.dispatchEvent(frames[frameIndex].mouseEvents[i]);
			}
		}
		
	}
	
	public function clear():void 
	{
		for (var i:int = 0; i < frames.length; i++) 
		{
			frames[i].dispose();
		}
		frames = new Vector.<FrameActions>();
	}
}

class FrameActions
{
	public var mouseEvents:Vector.<ReplayMouseEvent> = new Vector.<ReplayMouseEvent>();
	
	public function FrameActions()
	{
		
	}
	
	public function dispose():void 
	{
		mouseEvents = null;
	}
}