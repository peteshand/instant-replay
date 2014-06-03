package blaze.events 
{
	import flash.display.InteractiveObject;
	import flash.events.MouseEvent;
	
	/**
	 * ...
	 * @author P.J.Shand
	 */
	public class ReplayMouseEvent extends MouseEvent 
	{
		
		public function ReplayMouseEvent(type:String, bubbles:Boolean=true, cancelable:Boolean=false, localX:Number=NaN, localY:Number=NaN, relatedObject:InteractiveObject=null, ctrlKey:Boolean=false, altKey:Boolean=false, shiftKey:Boolean=false, buttonDown:Boolean=false, delta:int=0, commandKey:Boolean=false, controlKey:Boolean=false, clickCount:int=0) 
		{
			if (CONFIG::air) {
				CONFIG::air {
					super(type, bubbles, cancelable, localX, localY, relatedObject, ctrlKey, altKey, shiftKey, buttonDown, delta, commandKey, controlKey, clickCount);
					return;
				}
			}
			else {
				super(type, bubbles, cancelable, localX, localY, relatedObject, ctrlKey, altKey, shiftKey, buttonDown, delta);
			}
		}
	}
}