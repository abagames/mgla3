package mgla3;
import flash.display.Sprite;
import flash.geom.Vector3D;
import flash.display3D.Context3DClearMask;
import flash.Lib;
import away3d.cameras.Camera3D;
import away3d.containers.View3D;
import away3d.containers.ObjectContainer3D;
import away3d.core.managers.Stage3DManager;
import away3d.core.managers.Stage3DProxy;
import away3d.events.Stage3DEvent;
import away3d.filters.BloomFilter3D;
import away3d.filters.DepthOfFieldFilter3D;
import away3d.lights.DirectionalLight;
import away3d.materials.lightpickers.StaticLightPicker;
import away3d.materials.methods.CascadeShadowMapMethod;
import mgla3.V;
class W { // vieW
	static public function a(objectContainer:ObjectContainer3D, displayPriority:Int = 1):Void {
		addChild(objectContainer, displayPriority);
	}
	static public function r(objectContainer:ObjectContainer3D, displayPriority:Int = 1):Void {
		removeChild(objectContainer, displayPriority);
	}
	static public var cl(get, null):Bool; // clear
	static public function cp(x:Float = 0, y:Float = 0, z:Float = -DEFAULT_DEPTH):Void {
		setCameraPos(x, y, z);
	}
	
	static public var rn(get, null):Bool; // render

	static public inline var VIEW_COUNT = 3;
	static public var topView:View3D;
	static public var lightPicker:StaticLightPicker;
	static inline var DEFAULT_DEPTH = 1.75;
	static var views:Array<View3D>;
	static var cameras:Array<Camera3D>;
	static var lookAtPos:Vector3D;
	static var stage3DProxy:Stage3DProxy;
	static public function initializeProxy(callBack:Dynamic -> Void):Void {
		var stage3DManager = Stage3DManager.getInstance(Lib.current.stage);
		stage3DProxy = stage3DManager.getFreeStage3DProxy();
		stage3DProxy.addEventListener(Stage3DEvent.CONTEXT3D_CREATED, callBack);
		stage3DProxy.antiAlias = 1;
		stage3DProxy.color = 0;
	}
	static public function initialize():Void {
		views = new Array<View3D>();
		cameras = new Array<Camera3D>();
		lookAtPos = new Vector3D();
		var dl = new DirectionalLight(0, 0, 1);
		dl.diffuse = .5;
		dl.specular = .5;
		dl.ambient = .5;
		lightPicker = new StaticLightPicker([dl]);
		for (i in 0...VIEW_COUNT) {
			var v = new View3D();
			v.stage3DProxy = stage3DProxy;
			v.shareContext = true;
			Lib.current.addChild(v);
			views.push(v);
			var c = v.camera;
			c.lens.near = .5;
			c.lens.far = 10;
			c.z = -DEFAULT_DEPTH;
			c.lookAt(lookAtPos);
			cameras.push(c);
		}
		topView = views[VIEW_COUNT - 1];
	}
	static public function addChild(oc:ObjectContainer3D, viewIndex:Int):Void {
		views[viewIndex].scene.addChild(oc);
	}
	static public function removeChild(oc:ObjectContainer3D, viewIndex:Int):Void {
		views[viewIndex].scene.removeChild(oc);
		oc.dispose();
	}
	static public function get_cl():Bool {
		for (i in 0...VIEW_COUNT) {
			var scene = views[i].scene;
			while (scene.numChildren > 0) {
				var oc = scene.getChildAt(0);
				scene.removeChildAt(0);
				oc.dispose();
			}
		}
		return true;
	}
	static public function setCameraPos(x:Float, y:Float, z:Float):Void {
		for (i in 0...VIEW_COUNT - 1) {
			var c = cameras[i];
			c.x = x;
			c.y = y;
			c.z = z;
			c.lookAt(lookAtPos);
		}
	}
	static public function get_rn():Bool {
		stage3DProxy.clear();
		for (v in views) {
			stage3DProxy.context3D.clear(0, 0, 0, 1, 1, 0, Context3DClearMask.DEPTH);
			v.render();
		}
		stage3DProxy.present();
		return true;
	}
}