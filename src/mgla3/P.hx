package mgla3;
import away3d.animators.ParticleAnimationSet;
import away3d.animators.ParticleAnimator;
import away3d.animators.data.ParticleProperties;
import away3d.animators.data.ParticlePropertiesMode;
import away3d.animators.nodes.ParticleColorNode;
import away3d.animators.nodes.ParticleScaleNode;
import away3d.animators.nodes.ParticleVelocityNode;
import away3d.core.base.Geometry;
import away3d.core.base.ParticleGeometry;
import away3d.entities.Mesh;
import away3d.materials.ColorMaterial;
import away3d.primitives.PlaneGeometry;
import away3d.tools.helpers.ParticleGeometryHelper;
import flash.geom.ColorTransform;
import flash.geom.Vector3D;
import flash.Vector;
import mgla3.A;
class P { // Particle
	static public var i(get, null):P; // instance
	public function cn(count:Int):P { return setCount(count); }
	public function sz(size:Float):P { return setSize(size); }
	public function s(speed:Float):P { return setSpeed(speed); }
	public function t(ticks:Float):P { return setTicks(ticks); }
	public function w(angle:Float, angleWidth:Float):P { return setWay(angle, angleWidth); }
	public function f(initAnimationSet:ParticleAnimationSet -> Void = null,
	initProperties:ParticleProperties -> Void = null):P {
		return setInitFuncs(initAnimationSet, initProperties);
	}

	public function p(pos:V):P { return setPos(pos); }
	public function xy(x:Float, y:Float):P { return setXy(x, y); }
	public function c(color:C):P { return setColor(color); }
	public function rt(angle:Float):P { return setRotate(angle); }
	public function sc(scale:Float):P { return setScale(scale); }
	public var a(get, null):P; // add
	
	public var r(get, null):Bool; // remove
	
	static inline var ANIMATION_SET_COUNT = 8;
	static var random:R;
	static var vel:V;
	static var velZ:V;
	public static function initialize():Void {
		random = new R();
		vel = V.i;
		velZ = V.i;
	}
	var aCount = 1;
	var aSize = .05;
	var aSpeed = .025;
	var aTicks = 60;
	var aAngle = .0;
	var aAngleWidth = 360.0;
	var aInitAnimationSet:ParticleAnimationSet -> Void;
	var aInitProperties:ParticleProperties -> Void;
	var geometries:Vector<Geometry>;
	var geometry:ParticleGeometry;
	var animationSets:Array<ParticleAnimationSet>;
	var mesh:Mesh;
	var pos:V;
	var color:C;
	var angle = .0;
	var scale = 1.0;
	public function new() {
		pos = new V();
		color = C.wi;
	}
	static function get_i():P {
		return new P();
	}
	function setCount(count:Int):P {
		aCount = count;
		return this;
	}
	function setSize(size:Float):P {
		aSize = size;
		return this;
	}
	function setSpeed(speed:Float):P {
		aSpeed = speed;
		return this;
	}
	function setTicks(ticks:Float):P {
		aTicks = Std.int(ticks);
		return this;
	}
	function setWay(angle:Float, angleWidth:Float):P {
		aAngle = angle;
		aAngleWidth = angleWidth;
		return this;
	}
	function setInitFuncs(initAnimationSet:ParticleAnimationSet -> Void,
	initProperties:ParticleProperties -> Void):P {
		aInitAnimationSet = initAnimationSet;
		aInitProperties = initProperties;
		return this;
	}
	function setPos(pos:V):P {
		this.pos.v(pos);
		return this;
	}
	function setXy(x:Float, y:Float):P {
		pos.xy(x, y);
		return this;
	}
	function setColor(color:C):P {
		this.color = color;
		return this;
	}
	function setRotate(angle:Float):P {
		this.angle = angle;
		return this;
	}
	function setScale(scale:Float):P {
		this.scale = scale;
		return this;
	}
	function get_a():P {
		if (geometry == null) {
			var g = new PlaneGeometry(1, 1, 1, 1, false);
			geometries = new Vector<Geometry>();
			for (i in 0...aCount) geometries.push(g);
			geometry = ParticleGeometryHelper.generateGeometry(geometries);
			animationSets = new Array<ParticleAnimationSet>();
			for (i in 0...ANIMATION_SET_COUNT) animationSets.push(createAnimationSet());
		}
		var pa = new ParticleAnimator(animationSets[U.rni(ANIMATION_SET_COUNT - 1)]);
		var cm = new ColorMaterial(color.i);
		mesh = new Mesh(geometry, cm);
		mesh.animator = pa;
		mesh.x = pos.x;
		mesh.y = pos.y;
		mesh.rotationZ = angle;
		mesh.scale(scale);
		new PrActor(mesh, Std.int(aTicks * 1.5), this);
		pa.start();
		return this;
	}
	function createAnimationSet():ParticleAnimationSet {
			var animationSet = new ParticleAnimationSet(true);
			animationSet.addAnimation(
				new ParticleColorNode(ParticlePropertiesMode.GLOBAL, false, true, true, false,
					new ColorTransform(1, 1, 1, 1, 64, 64, -64, 0),
					new ColorTransform(1, 1, 1, 1, -64, -64, 64, 0),
					.1));
			animationSet.addAnimation(
				new ParticleColorNode(ParticlePropertiesMode.LOCAL_STATIC, false, true));
			animationSet.addAnimation(
				new ParticleScaleNode(ParticlePropertiesMode.LOCAL_STATIC, false, false));
			animationSet.addAnimation(
				new ParticleVelocityNode(ParticlePropertiesMode.LOCAL_STATIC));
			if (aInitAnimationSet != null) aInitAnimationSet(animationSet);
			animationSet.initParticleFunc = initParticle;
			return animationSet;
	}
	function initParticle(pp:ParticleProperties):Void {
		var dr = aTicks * random.f(.5, 1.5) / 60;
		pp.duration = dr;
		Reflect.setField(pp, ParticleColorNode.COLOR_START_COLORTRANSFORM,
			new ColorTransform(1, 1, 1, 1,
			random.fi(-128, 128), random.fi(-128, 128), random.fi(-128, 128), 0));
		Reflect.setField(pp, ParticleColorNode.COLOR_END_COLORTRANSFORM,
			new ColorTransform(1, 1, 1, 1,
			random.fi(-128, 128), random.fi(-128, 128), random.fi(-128, 128), 0));
		Reflect.setField(pp, ParticleScaleNode.SCALE_VECTOR3D,
			new Vector3D(aSize * random.f(.5, 1.5), 0));
		velZ.n(0).aw(random.p(60), random.n(aSpeed) * 60);
		vel.n(0).aw(aAngle + random.p(aAngleWidth / 2), velZ.y);
		Reflect.setField(pp, ParticleVelocityNode.VELOCITY_VECTOR3D,
			new Vector3D(vel.x, vel.y, velZ.x));
		if (aInitProperties != null) aInitProperties(pp);
	}
	function get_r():Bool {
		for (g in geometries) g.dispose();
		geometry.dispose();
		for (as in animationSets) as.dispose();
		return true;
	}
}
class PrActor extends A {
	var mesh:Mesh;
	var removeTicks = 60;
	var pi:P;
	public function new(mesh:Mesh, removeTicks:Int = 60, pi:P) {
		this.mesh = mesh;
		this.removeTicks = removeTicks;
		this.pi = pi;
		super();
	}
	override public function b() {
		W.a(mesh, displayPriority);
	}
	override public function u() {
		if (ticks > removeTicks) r;
	}
	override function get_r():Bool {
		if (!super.get_r()) return false;
		cast(mesh.animator, ParticleAnimator).stop();
		W.r(mesh, displayPriority);
		return true;
	}
}