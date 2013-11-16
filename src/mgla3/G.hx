package mgla3;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.display.MovieClip;
import flash.events.Event;
import flash.net.SharedObject;
import flash.utils.ByteArray;
import flash.Lib;
using mgla3.U;
class G { // Game
	static public var ig(get, null):Bool; // is in game
	static public var eg(get, null):Bool; // end game
	static public var t(get, null):Int; // ticks
	static public var ld(get, null):Bool; // load
	static public var sv(get, null):Bool; // save
	static public var r:R;
	public function new(main:Dynamic) { initialize(main); }
	public function tt(title:String, title2:String = ""):G { return setTitle(title, title2); }
	public function vr(version:Int = 1):G { return setVersion(version); }
	public var dm(get, null):G; // debugging mode
	public function yr(ratio:Float):G { return setYRatio(ratio); }
	public var ie(get, null):G; // initialize end

	public function i():Void { ie; } // initialize
	public function b():Void { } // begin
	public function u():Void { } // update
	public function is():Void { } // initialize state
	public function ls(d:Dynamic):Void { } // load state
	public function ss(d:Dynamic):Void { } // save state

	static public var isInGame = false;
	static public var ticks = 0;
	static public var fps = 0.0;
	static public var pixelSize:V;
	static public var pixelWHRatio = 1.0;
	static var mainInstance:Dynamic;
	static var title = "";
	static var title2 = "";
	static var version = 1;
	static var gInstance:G;
	var baseSprite:Sprite;
	var titleTicks = 0;
	var wasClicked = false;
	var wasReleased = false;
	var isDebugging = false;
	var isPausing = false;
	var isPaused = false;
	var fpsCount = 0;
	var lastTimer = 0;
	function initialize(mi:Dynamic):Void {
		pixelSize = V.i.xy(Lib.current.stage.stageWidth, Lib.current.stage.stageHeight);
		pixelWHRatio = pixelSize.x / pixelSize.y;
		mainInstance = mi;
		gInstance = this;
		W.initializeProxy(initializeRest);
	}
	function initializeRest(e:Dynamic):Void {
		W.initialize();
		A.initialize();
		C.initialize();
		F.initialize();
		H.initialize(mainInstance);
		K.initialize();
		M.initialize(W.topView);
		P.initialize();
		S.initialize(mainInstance);
		T.initialize();
		r = R.i;
		mainInstance.i();
	}
	function setTitle(t:String, t2:String):G {
		title = t;
		title2 = t2;
		return this;
	}
	function setVersion(v:Int):G {
		version = v;
		return this;
	}
	function get_dm():G {
		isDebugging = true;
		return this;
	}
	function setYRatio(ratio:Float):G {
		pixelSize.y = pixelSize.x * ratio;
		pixelWHRatio = pixelSize.x / pixelSize.y;
		return this;
	}
	function get_ie():G {
		G.ld;
		if (isDebugging) beginGame();
		else {
			initializeGame();
			beginTitle();
		}
		lastTimer = Std.int(Date.now().getTime());
		Lib.current.addEventListener(Event.ACTIVATE, onActivated);
		Lib.current.addEventListener(Event.DEACTIVATE, onDeactivated);
		Lib.current.addEventListener(Event.ENTER_FRAME, updateFrame);
		return this;
	}
	static function get_ig():Bool {
		return isInGame;
	}
	static function get_t():Int {
		return ticks;
	}
	static function get_eg():Bool {
		if (!isInGame) return false;
		G.sv;
		gInstance.beginTitle();
		return true;
	}
	static function get_ld():Bool {
		#if (flash || js)
		try {
			var storeKey = StringTools.replace(title + "_" + title2 + "_" + version, " ", "");
			var sharedObject:SharedObject = SharedObject.getLocal(storeKey);
			if (sharedObject.size < 10) {
				mainInstance.is();
			} else {
				mainInstance.ls(sharedObject.data);
				K.ls(sharedObject.data);
			}
			return true;
		} catch (e:Dynamic) {
			mainInstance.is();
		}
		#end
		return false;
	}
	static function get_sv():Bool {
		#if (flash || js)
		try {
			var storeKey = StringTools.replace(title + "_" + title2 + "_" + version, " ", "");
			var sharedObject:SharedObject = SharedObject.getLocal(storeKey);
			mainInstance.ss(sharedObject.data);
			K.ss(sharedObject.data);
			sharedObject.flush();
			return true;
		} catch (e:Dynamic) { }
		#end
		return false;
	}
	
	function beginTitle():Void {
		var tx = .0;
		if (title2.length <= 0) {
			T.i.tx(title).xy(tx, .2).ac.tf;
		} else {
			T.i.tx(title).xy(tx, .24).ac.tf;
			T.i.tx(title2).xy(tx, .18).ac.tf;
		}
		T.i.tx("CLICK/TOUCH/PUSH").xy(tx, -.08).ac.tf;
		T.i.tx("TO").xy(tx, -.16).ac.tf;
		T.i.tx("START").xy(tx, -.23).ac.tf;
		isInGame = false;
		wasClicked = wasReleased = false;
		ticks = 0;
		titleTicks = 10;
	}
	function beginGame():Void {
		isInGame = true;
		ticks = 0;
		r.s();
		initializeGame();
	}
	function initializeGame():Void {
		A.cl;
		F.cl;
		mainInstance.b();
	}
	function handleTitleScreen():Void {
		if (M.ip || K.ib || K.iu || K.id || K.ir || K.il) {
			if (wasReleased) wasClicked = true;
		} else {
			if (wasClicked) beginGame();
			if (--titleTicks <= 0) wasReleased = true;
		}
	}
	var pauseT1:T;
	var pauseT2:T;
	function updateFrame(e:Event):Void {
		K.u();
		if (!isPaused) {
			if (isPausing) {
				isPausing = false;
				pauseT1 = T.i.tx("PAUSED").xy(0, .1).ac.tf;
				pauseT2 = T.i.tx("CLICK/TOUCH TO RESUME").xy(0, -.1).ac.tf;
				isPaused = true;
			}
			A.update();
			F.update();
			mainInstance.u();
			if (isDebugging) {
				T.i.tx('FPS: ${Std.string(Std.int(fps))}').xy(-1, -.95);
			}
			for (s in S.ss) s.u();
			ticks++;
		}
		if (!isInGame) handleTitleScreen();
		W.rn;
		calcFps();
	}
	function onActivated(e:Event):Void {
		if (isPaused) {
			pauseT1.r;
			pauseT2.r;
			isPaused = false;
		}
	}
	function onDeactivated(e:Event):Void {
		K.r;
		if (isInGame) isPausing = true;
	}
	function calcFps():Void {
		fpsCount++;
		var currentTimer = Std.int(Date.now().getTime());
		var delta = currentTimer - lastTimer;
		if (delta >= 1000) {
			fps = fpsCount * 1000 / delta;
			lastTimer = currentTimer;
			fpsCount = 0;
		}
	}
}