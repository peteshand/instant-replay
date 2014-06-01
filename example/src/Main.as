package 
{
	import blaze.events.ReplayMouseEvent;
	import blaze.service.replay.InstantReplay;
	import com.bit101.components.PushButton;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	/**
	 * ...
	 * @author P.J.Shand
	 */
	public class Main extends Sprite 
	{
		private var bitmap:Bitmap;
		private var target:Point = new Point();
		private var recordButton:PushButton;
		private var playButton:PushButton;
		
		public function Main():void 
		{
			var bmd:BitmapData = new BitmapData(50, 50, false, 0xFF0000);
			bitmap = new Bitmap(bmd);
			bitmap.x = target.x = stage.stageWidth / 2;
			bitmap.y = target.y = stage.stageHeight / 2;
			addChild(bitmap);
			
			InstantReplay.register(stage);
			
			recordButton = new PushButton(this, 10, 10, 'Record Movement', StartRecording);
			playButton = new PushButton(this, 10, 35, 'Playback Movement', StopRecording);
			
			stage.addEventListener(MouseEvent.MOUSE_MOVE, OnMouseMove);
			addEventListener(Event.ENTER_FRAME, UpdateLocation);
		}
		
		private function StartRecording(e:MouseEvent):void 
		{
			InstantReplay.clear();
			InstantReplay.record = true;
		}
		
		private function StopRecording(e:MouseEvent):void 
		{
			InstantReplay.play();
		}
		
		private function OnMouseMove(e:MouseEvent):void 
		{
			target.x = e.stageX - (bitmap.width / 2);
			target.y = e.stageY - (bitmap.height / 2);
		}
		
		private function UpdateLocation(e:Event):void 
		{
			if (InstantReplay.record) recordButton.alpha = 0.2;
			else recordButton.alpha = 1;
			
			if (InstantReplay.playing) playButton.alpha = 0.2;
			else playButton.alpha = 1;
			
			bitmap.x = ((bitmap.x * 10) + target.x) / 11;
			bitmap.y = ((bitmap.y * 10) + target.y) / 11;
		}
		
	}
	
}