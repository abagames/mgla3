package mgla3;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.TouchEvent;
class M { // Mouse
	static public var p:V; // pos
	static public var ip = false; // isPressing

	static var pixelSize:V;
	static public function initialize(s:Sprite) {
		pixelSize = V.i.v(G.pixelSize);
		p = new V();
		s.addEventListener(MouseEvent.MOUSE_MOVE, onMoved);
		s.addEventListener(MouseEvent.MOUSE_DOWN, onPressed);
		s.addEventListener(MouseEvent.MOUSE_UP, onReleased);
		s.addEventListener(Event.MOUSE_LEAVE, onReleased);
		s.addEventListener(TouchEvent.TOUCH_MOVE, onTouched);
		s.addEventListener(TouchEvent.TOUCH_BEGIN, onTouchStarted);
		s.addEventListener(TouchEvent.TOUCH_END, onReleased);
		s.addEventListener(TouchEvent.TOUCH_OUT, onReleased);
	}
	static function onMoved(e:MouseEvent):Void {
		p.x = e.stageX / pixelSize.x * 2 - 1;
		p.y = 1 - e.stageY / pixelSize.y * 2;
	}
	static function onTouched(e:TouchEvent):Void {
		p.x = e.stageX / pixelSize.x * 2 - 1;
		p.y = 1 - e.stageY / pixelSize.y * 2;
	}
	static function onPressed(e:MouseEvent):Void {
		ip = true;
		onMoved(e);
	}
	static function onTouchStarted(e:TouchEvent):Void {
		ip = true;
		onTouched(e);
	}
	static function onReleased(e:Event):Void {
		ip = false;
	}
}