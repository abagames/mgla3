package mgla3;
import mgla3.A;
class T { // Text
	static public var i(get, null):T; // instance
	public function tx(text:String):T { return setText(text); }
	public function p(pos:V):T { return setPos(pos); }
	public function xy(x:Float, y:Float):T { return setXy(x, y); }
	public function sc(x:Float = 1, y:Float = -1):T { return setScale(x, y); }
	public function c(color:C):T { return setColor(color); }
	public var al(get, null):T; // align left
	public var ac(get, null):T; // align center
	public var ar(get, null):T; // align right
	public var avc(get, null):T; // align vertical center
	public function v(vel:V):T { return setVel(vel); }
	public function vxy(x:Float, y:Float):T { return setVelXy(x, y); }
	public function t(ticks:Int = 60):T { return setTicks(ticks); }
	public var tf(get, null):T; // tick forever
	public var ao(get, null):T; // add once
	public var r(get, null):Bool; // remove
	
	static var shownMessages:Array<String>;
	static public function initialize():Void {
		Letter.initialize();
		shownMessages = new Array<String>();
	}
	var actor:TActor;
	var text:String;
	var isFirstTicks = true;
	public function new() {
		actor = new TActor();
	}
	static function get_i():T {
		return new T();
	}
	function setText(text:String):T {
		this.text = text;
		actor.letter.setText(text);
		return this;
	}
	function setPos(pos:V):T {
		actor.p.v(pos);
		return this;
	}
	function setXy(x:Float, y:Float):T {
		actor.p.xy(x, y);
		return this;
	}
	function setVel(vel:V):T {
		actor.v.v(vel);
		return this;
	}
	function setColor(color:C):T {
		actor.letter.setColor(color);
		return this;
	}
	function setScale(x:Float, y:Float):T {
		actor.letter.setScale(x, y);
		return this;
	}
	function get_al():T {
		actor.letter.alignLeft();
		return this;
	}
	function get_ac():T {
		actor.letter.alignCenter();
		return this;
	}
	function get_ar():T {
		actor.letter.alignRight();
		return this;
	}
	function get_avc():T {
		actor.letter.alignVerticalCenter();
		return this;
	}
	function setVelXy(x:Float, y:Float):T {
		actor.v.xy(x, y);
		get_ac();
		get_avc();
		return this;
	}
	function setTicks(ticks:Int):T {
		actor.removeTicks = ticks;
		return this;
	}
	function get_tf():T {
		actor.removeTicks = 9999999;
		return this;
	}
	function get_ao():T {
		for (m in shownMessages) {
			if (m == text) {
				actor.r;
				return null;
			}
		}
		shownMessages.push(text);
		return this;
	}
	function get_r():Bool {
		return actor.r;
	}
}
class TActor extends A {
	public var removeTicks = 1;
	public var letter:Letter;
	var isFirstTicks = true;
	override public function b() {
		letter = new Letter();
	}
	override public function u() {
		if (isFirstTicks) {
			v.d(removeTicks);
			isFirstTicks = false;
		}
		letter.setPos(p.a(v));
		if (ticks >= removeTicks) r;
	}
	override function get_r():Bool {
		if (letter != null) {
			letter.remove();
			letter = null;
		}
		return super.get_r();
	}
}
class Letter {
	static inline var COUNT = 66;
	static var pixelSize:V;
	static var baseHs:Array<H>;
	static var emptyH:H;
	static var charToIndex:Array<Int>;
	static var baseSize = .0085;
	public static function initialize():Void {
		pixelSize = G.pixelSize;
		baseHs = new Array<H>();
		charToIndex = new Array<Int>();
		var patterns = [
		0x4644AAA4, 0x6F2496E4, 0xF5646949, 0x167871F4, 0x2489F697, 0xE9669696, 0x79F99668, 
		0x91967979, 0x1F799976, 0x1171FF17, 0xF99ED196, 0xEE444E99, 0x53592544, 0xF9F11119, 
		0x9DDB9999, 0x79769996, 0x7ED99611, 0x861E9979, 0x994444E7, 0x46699699, 0x6996FD99, 
		0xF4469999, 0x2224F248, 0x26244424, 0x64446622, 0x84284248, 0x40F0F024, 0xF0044E4, 
		0x480A4E40, 0x9A459124, 0xA5A16, 0x640444F0, 0x80004049, 0x40400004, 0x44444040, 
		0xAA00044, 0x6476E400, 0xFAFA61D9, 0xE44E4EAA, 0x24F42445, 0xF244E544, 0x42
		];
		var p = 0, di = 32;
		var pIndex = 0;
		for (i in 0...COUNT) {
			var h = H.i;
			for (j in 0...5) {
				for (k in 0...4) {
					if (++di >= 32) {
						p = patterns[pIndex++];
						di = 0;
					}
					if (p & 1 > 0) {
						h.o(k * baseSize, -j * baseSize).ap(baseSize * 1.2, baseSize * 1.2);
					}
					p >>= 1;
				}
			}
			baseHs.push(h);
		}
		emptyH = H.i;
		var charStr = "()[]<>=+-*/%&_!?,.:|'\"$@#\\urdl";
		var charCodes = new Array<Int>();
		for (i in 0...charStr.length) charCodes.push(charStr.charCodeAt(i));
		for (c in 0...128) {
			var li = -1;
			if (c == 32) {
			} else if (c >= 48 && c < 58) {
				li = c - 48;
			} else if (c >= 65 && c <= 90) {
				li = c - 65 + 10;
			} else {
				li = Lambda.indexOf(charCodes, c);
				if (li >= 0) li += 36;
				else li = -2;
			}
			charToIndex.push(li);
		}
	}
	var text:String;
	var hs:Array<H>;
	var align:LetterAlign;
	var isAlignVerticalCenter = false;
	var interval:V;
	public function new() {
		hs = new Array<H>();
		align = Left;
		interval = V.i;
		setInterval();
	}
	public function setText(text:String):Void {
		this.text = text;
		for (i in 0...text.length) {
			var c = text.charCodeAt(i);
			var li = charToIndex[c];
			if (li >= 0) hs.push(baseHs[li].clc.dp(W.VIEW_COUNT - 1));
			else if (li == -1) hs.push(emptyH.clc.dp(W.VIEW_COUNT - 1));
			else if (li == -2) throw "invalid char: " + text.charAt(i);
		}
	}
	public function setPos(pos:V):Void {
		var tx = pos.x;
		var ty = pos.y;
		switch (align) {
		case Left:
		case Center:
			tx -= text.length * interval.x / 2;
		case Right:
			tx -= text.length * interval.x;
		}
		if (isAlignVerticalCenter) ty -= interval.y / 2;
		for (h in hs) {
			h.xy(tx, ty);
			tx += interval.x;
		}
	}
	public function setColor(color:C):Void {
		for (h in hs) h.dc(color);
	}
	public function setScale(x:Float, y:Float):Void {
		var sx = x;
		var sy = (y >= 0 ? y : x);
		for (h in hs) h.sc(x, y);
		setInterval(sx, sy);
	}
	public function alignLeft():Void {
		align = Left;
	}
	public function alignCenter():Void {
		align = Center;
	}
	public function alignRight():Void {
		align = Right;
	}
	public function alignVerticalCenter():Void {
		isAlignVerticalCenter = true;
	}
	public function remove():Void {
		for (h in hs) h.r;
		hs = new Array<H>();
	}
	function setInterval(sx:Float = 1.0, sy:Float = 1.0):Void {
		interval.xy(baseSize * sx * 5 / G.pixelWHRatio, baseSize * sy * 6);
	}
}
enum LetterAlign {
	Left;
	Center;
	Right;
}