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
		private static var playing:Boolean = false;
		
		private static var currentFrame:int = 0;
		private static var totalFrames:int = 0;
		
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
				playing = false;
				broadcaster.removeEventListener(Event.ENTER_FRAME, PlaybackUpdate);
				broadcaster.addEventListener(Event.ENTER_FRAME, RecordUpdate);
			}
			else {
				broadcaster.removeEventListener(Event.ENTER_FRAME, RecordUpdate);
				if (state == InstantReplay.STATE_PLAY) {
					playing = true;
					broadcaster.addEventListener(Event.ENTER_FRAME, PlaybackUpdate);
				}
				else if (state == InstantReplay.STATE_STOP) {
					playing = false;
					broadcaster.removeEventListener(Event.ENTER_FRAME, PlaybackUpdate);
				}
			}
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

class InstantReplayObject
{
	public var displayObject:DisplayObject;
	private var currentActions:FrameActions;
	private var frames:Vector.<FrameActions> = new Vector.<FrameActions>();
	
	public function InstantReplayObject(displayObject:DisplayObject)
	{
		this.displayObject = displayObject;
		currentActions = new FrameActions();
		displayObject.addEventListener(MouseEvent.MOUSE_MOVE, OnMouseEvent);
	}
	
	private function OnMouseEvent(e:MouseEvent):void 
	{
		currentActions.mouseEvents.push(e);
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
		for (var i:int = 0; i < frames[frameIndex].mouseEvents.length; i++) 
		{
			displayObject.dispatchEvent(frames[frameIndex].mouseEvents[i]);
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
	public var mouseEvents:Vector.<MouseEvent> = new Vector.<MouseEvent>();
	
	public function FrameActions()
	{
		
	}
	
	public function dispose():void 
	{
		mouseEvents = null;
	}
}