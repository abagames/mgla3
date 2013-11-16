package mgla3;
using Math;
class A { // Actor
	static public function acs(className:String):Array<Dynamic> {
		return getActors(className);
	}
	static public var cl(get, null):Bool; // clear
	static public function cls(className:String):Void { clearSpecificActors(className); }
	public function hr(width:Float, height:Float = -1):A { return setHitRect(width, height); }
	public function ah(h:H):A { return addH(h); }
	public function rh(h:H):A { return removeH(h); }
	public var p:V; // position
	public var z = .0;
	public var v:V; // velocity
	public var w = .0; // way
	public var s = .0; // speed
	public var t(get, null):Int; // ticks
	public var r(get, null):Bool; // remove
	public function ih(actors:Array<Dynamic>):Bool {
		return isHit(actors);
	}
	public function sc(x:Float = 1, y:Float = -1):A { return setScale(x, y); }
	
	public function i():Void { } // initialize
	public function b():Void { } // begin
	public function u():Void { } // update
	public function h(hitActor:Dynamic):Void { } // hit
	
	public var m(get, null):A; // move

	static var groups:Map<String, ActorGroup>;
	static var pixelWHRatio = 1.0;
	static var emptyGroup:Array<A>;
	static public function initialize() {
		pixelWHRatio = G.pixelWHRatio;
		groups = new Map<String, ActorGroup>();
		emptyGroup = new Array<A>();
	}
	static public function update():Void {
		for (g in groups) {
			var actors = g.s;
			var i = 0;
			while (i < actors.length) {
				if (actors[i].isRemoving) {
					actors.splice(i, 1);
				} else {
					actors[i].updateFrame();
					i++;
				}
			}
		}
	}
	static function getActors(className:String):Array<Dynamic> {
		var g = groups.get(className);
		if (g == null) return emptyGroup;
		return g.s;
	}
	static function get_cl():Bool {
		for (g in groups) clearActors(g.s);
		return true;
	}
	static function clearSpecificActors(className:String):Void {
		var g = groups.get(className);
		if (g == null) return;
		clearActors(g.s);
	}
	static function clearActors(s:Array<A>):Void {
		for (a in s) a.r;
		s = new Array<A>();
	}
	public var isRemoving = false;
	public var ticks = 0;
	var hitRect:V;
	var ho:V;
	var displayPriority = 0;
	var hs:Array<H>;
	var fs:Array<F>;
	var group:ActorGroup;
	public function new() {
		p = V.i;
		v = V.i;
		hitRect = V.i;
		ho = V.i;
		fs = new Array<F>();
		var className = Type.getClassName(Type.getClass(this));
		group = groups.get(className);
		if (group == null) {
			group = new ActorGroup(className);
			groups.set(className, group);
			hs = new Array<H>();
			i();
			group.hitRect.v(hitRect);
			group.hs = hs;
		} else {
			hitRect.v(group.hitRect);
		}
		hs = new Array<H>();
		for (h in group.hs) hs.push(h.cl);
		b();
		group.s.push(this);
	}
	function setHitRect(width:Float, height:Float):A {
		hitRect.x = width;
		hitRect.y = (height >= 0 ? height : width);
		return this;
	}
	function addH(h:H):A {
		hs.push(h);
		return this;
	}
	function removeH(h:H):A {
		hs.remove(h);
		h.r;
		return this;
	}
	function get_t():Int {
		return ticks;
	}
	function get_m():A {
		p.a(v);
		p.aw(w, s);
		return this;
	}
	function get_r():Bool {
		if (isRemoving) return false;
		if (hs.length > 0) {
			for (h in hs) h.r;
			hs = new Array<H>();
		}
		isRemoving = true;
		return true;
	}
	function isHit(actors:Array<Dynamic>):Bool {
		if (actors.length <= 0) return false;
		var hitTest:Dynamic -> Bool;
		var ac = actors[0];
		var xyr = (hitRect.x / hitRect.y - 1).abs();
		var acxyr = (ac.hitRect.x / ac.hitRect.y - 1).abs();
		if (xyr > acxyr) {
			hitTest = function(ac:Dynamic):Bool {
				ho.v(p).s(ac.p);
				if (pixelWHRatio < 1) ho.y /= pixelWHRatio;
				else if (pixelWHRatio > 1) ho.x *= pixelWHRatio;
				if (w != 0) ho.rt(-w);
				return (ho.x.abs() <= (hitRect.x + ac.hitRect.x) / 2 &&
					ho.y.abs() <= (hitRect.y + ac.hitRect.y) / 2);
			}
		} else {
			hitTest = function(ac:Dynamic):Bool {
				ho.v(p).s(ac.p);
				if (pixelWHRatio < 1) ho.y /= pixelWHRatio;
				else if (pixelWHRatio > 1) ho.x *= pixelWHRatio;
				if (ac.w != 0) ho.rt(-ac.w);
				return (ho.x.abs() <= (hitRect.x + ac.hitRect.x) / 2 &&
					ho.y.abs() <= (hitRect.y + ac.hitRect.y) / 2);
			}
		}
		var hf:Bool = false;
		for (a in actors) {
			if (this == a) continue;
			if (hitTest(a)) {
				h(a);
				hf = true;
			}
		}
		return hf;
	}
	function setScale(x:Float, y:Float):A {
		for (h in hs) h.sc(x, y);
		return this;
	}
	
	function updateFrame():Void {
		m;
		F.updateAll(fs);
		u();
		for (h in hs) h.p(p).z(z).rt(w);
		ticks++;
	}
}
class ActorGroup {
	public var className:String;
	public var s:Array<A>;
	public var hitRect:V;
	public var hs:Array<H>;
	public function new(className:String) {
		this.className = className;
		s = new Array<A>();
		hitRect = new V();
		hs = new Array<H>();
	}
}