package mgla3;
import away3d.core.base.Geometry;
import away3d.containers.ObjectContainer3D;
import away3d.entities.Entity;
import away3d.entities.Mesh;
import away3d.entities.SegmentSet;
import away3d.materials.ColorMaterial;
import away3d.materials.TextureMaterial;
import away3d.primitives.CubeGeometry;
import away3d.primitives.CylinderGeometry;
import away3d.primitives.PlaneGeometry;
import away3d.primitives.SphereGeometry;
import away3d.primitives.WireframeCube;
import away3d.primitives.WireframeCylinder;
import away3d.primitives.WireframePlane;
import away3d.primitives.WireframeSphere;
import away3d.tools.commands.Merge;
import flash.Vector;
using Math;
using mgla3.U;
class H { // mesH
	static public var i(get, null):H; // instance
	public function dp(priority:Int = 1):H { return setDisplayPriority(priority); }
	public function c(color:C):H { return setColor(color); }
	public function a(alpha:Float = 1.0):H { return setAlpha(alpha); }
	public function o(x:Float = 0, y:Float = 0, z:Float = 0):H { return setOffset(x, y, z); }
	public function or(angle:Float):H { return setOffsetRotate(angle); }
	public function ac(width:Float, height:Float = -1, depth:Float = -1):H {
		return addCube(width, height, depth);
	}
	public function ay(height:Float, top:Float, bottom:Float = -1):H {
		return addCylinder(height, top, bottom);
	}
	public function ap(width:Float, height:Float = -1):H {
		return addPlane(width, height);
	}
	public function as(radius:Float):H {
		return addSphere(radius);
	}
	public function ds(dotSize:Float = .03):H {
		return setDotSize(dotSize);
	}
	public function dg(width:Float, height:Float, seed:Int = -1):H {
		return generateDotShape(width, height, seed, 3);
	}
	public function dg1(width:Float, height:Float, seed:Int = -1):H {
		return generateDotShape(width, height, seed, 1);
	}
	public function dr(width:Float, height:Float, seed:Int = -1):H {
		return fillDotRect(width, height, seed, 3);
	}
	public function dr1(width:Float, height:Float, seed:Int = -1):H {
		return fillDotRect(width, height, seed, 1);
	}
	public function drl(width:Float, height:Float):H {
		return lineDotRect(width, height);
	}
	public var dic(get, null):H; // dot is cube
	public var dip(get, null):H; // dot is plane
	
	public function p(pos:V):H { return setPos(pos); }
	public function xy(x:Float, y:Float):H { return setXy(x, y); }
	public function z(z:Float):H { return setZ(z); }
	public function rt(angle:Float):H { return rotate(angle); }
	public function sc(x:Float = 1, y:Float = -1):H { return setScale(x, y); }
	public function dc(color:C = null):H { return setDrawColor(color); }
	public var r(get, null):Bool; // remove
	
	public var cl(get, null):H; // clone
	public var clc(get, null):H; // clone using color

	static inline var WIREFRAME_WIDTH = 1;
	static var baseRandomSeed = 0;
	static var rPos:V;
	static var aVec:V;
	static var whiteColorMaterial:ColorMaterial;
	public static function initialize(mi:Dynamic) {
		baseRandomSeed = U.ch(mi);
		rPos = new V();
		aVec = new V();
		whiteColorMaterial = new ColorMaterial(0xffffff);
	}
	var baseMesh:Mesh;
	var meshes:Vector<Mesh>;
	var color:C;
	var alpha = 1.0;
	var offset:V;
	var offsetZ = .0;
	var offsetAngle = .0;
	var mesh:Mesh;
	var displayPriority = 0;
	var isAdded = false;
	var colorTop:C;
	var colorTopSpot:C;
	var colorBottom:C;
	var colorBottomSpot:C;
	var spotThreshold = .3;
	var xSpotInterval = .0;
	var ySpotInterval = .0;
	var xySpotInterval = .0;
	var dotSize = .02;
	var isDotCube = true;
	public function new() {
		color = C.wi;
		offset = V.i;
	}
	static function get_i():H  {
		return new H();
	}
	function setDisplayPriority(priority:Int):H {
		displayPriority = priority;
		return this;
	}
	function setColor(color:C):H {
		this.color = color;
		return this;
	}
	function setAlpha(alpha:Float):H {
		this.alpha = alpha;
		return this;
	}
	function setOffset(x:Float, y:Float, z:Float):H {
		offset.x = x;
		offset.y = y;
		offsetZ = z;
		return this;
	}
	function setOffsetRotate(angle:Float):H {
		offsetAngle = angle;
		return this;
	}
	function addCube(width:Float, height:Float, depth:Float):H {
		if (height < 0) height = width;
		if (depth < 0) depth = width;
		addPolygon(new CubeGeometry(width, height, depth, 1, 1, 1, false));
		return this;
	}
	function addCylinder(height:Float, top:Float, bottom:Float):H {
		if (bottom < 0) bottom = top;
		addPolygon(new CylinderGeometry(top, bottom, height, 6, 1));
		return this;
	}
	function addPlane(width:Float, height:Float):H {
		if (height < 0) height = width;
		addPolygon(new PlaneGeometry(width, height, 1, 1, false));
		return this;
	}
	function addSphere(radius:Float):H {
		addPolygon(new SphereGeometry(radius, 6, 4));
		return this;
	}
	function setDotSize(dotSize:Float):H {
		this.dotSize = dotSize;
		return this;
	}
	function generateDotShape(width:Float, height:Float, seed:Int, layerCount:Int):H {
		if (seed < 0) seed = baseRandomSeed++;
		var fillRatio = .4;
		var sideRatio = .2;
		var crossRatio = .2;
		var c = C.di.v(color);
		for (z in 0...layerCount) {
			setGeneratedColors(c, seed);
			generateDotShapePlane(width, height, -z, seed, fillRatio, sideRatio, crossRatio);
			fillRatio -= .1;
		}
		return this;
	}
	function fillDotRect(width:Float, height:Float, seed:Int, layerCount:Int):H {
		if (seed < 0) seed = baseRandomSeed++;
		var w = Std.int(width / dotSize);
		var h = Std.int(height / dotSize);
		var ox = -Std.int(w / 2), oy = -Std.int(h / 2);
		var c = C.di.v(color);
		for (z in 0...layerCount) {
			setGeneratedColors(c, seed);
			for (y in 1 + z...h - 1 - z) {
				for (x in 1 + z...w - 1 - z) {
					setDot(x + ox, y + oy, y / h, -z);
				}
			}
		}
		return lineDotRect(width, height);
	}
	function lineDotRect(width:Float, height:Float):H {
		var w = Std.int(width / dotSize);
		var h = Std.int(height / dotSize);
		var ox = -Std.int(w / 2), oy = -Std.int(h / 2);
		setTopBottomColor(color);
		for (x in 0...w) {
			setDot(x + ox, oy, 0);
			setDot(x + ox, h - 1 + oy, 1);
		}
		for (y in 1...h - 1) {
			setDot(0 + ox, y + oy, y / h);
			setDot(w - 1 + ox, y + oy, y / h);
		}
		return this;
	}
	function get_dic():H {
		isDotCube = true;
		return this;
	}
	function get_dip():H {
		isDotCube = false;
		return this;
	}
	function get_cl():H { return clone(false); }
	function get_clc():H { return clone(true); }
	function clone(isUsingColor:Bool):H {
		if (baseMesh == null) {
			var mr = new Merge(!isUsingColor);
			baseMesh = new Mesh(new Geometry());
			if (meshes != null) mr.applyToMeshes(baseMesh, meshes);
			if (isUsingColor) baseMesh.material = whiteColorMaterial;
		}
		var h = H.i;
		h.mesh = cast(baseMesh.clone(), Mesh);
		h.displayPriority = displayPriority;
		return h;
	}
	function setPos(pos:V):H {
		setXy(pos.x, pos.y);
		return this;
	}
	function setXy(x:Float, y:Float):H {
		if (G.pixelWHRatio == 1) mesh.x = x;
		else mesh.x = x * G.pixelWHRatio;
		mesh.y = y;
		if (!isAdded) {
			W.a(mesh, displayPriority);
			isAdded = true;
		}
		return this;
	}
	function setZ(z:Float):H {
		mesh.z = z;
		return this;
	}
	function rotate(angle:Float):H {
		if (G.pixelWHRatio == 1.0) {
			mesh.rotationZ = angle;
		} else {
			var a = angle * Math.PI / 180;
			aVec.xy(a.sin() * G.pixelWHRatio, -a.cos());
			mesh.rotationZ = aVec.w;
		}
		return this;
	}
	function setScale(x:Float, y:Float):H {
		mesh.scaleX = x;
		mesh.scaleY = (y >= 0 ? y : x);
		return this;
	}
	function setDrawColor(color:C):H {
		mesh.material = new ColorMaterial(color.i);
		return this;
	}
	function get_r():Bool {
		if (isAdded) {
			W.r(mesh, displayPriority);
			isAdded = false;
			return true;
		}
		return false;
	}

	function addPolygon(g:Geometry):Void {
		if (meshes == null) meshes = new Vector<Mesh>();
		var cm = new ColorMaterial(color.i, alpha);
		if (displayPriority == 0) cm.lightPicker = W.lightPicker;
		var m = new Mesh(g, cm);
		m.x = offset.x;
		m.y = offset.y;
		m.z = offsetZ;
		m.rotationZ = offsetAngle;
		meshes.push(m);
	}
	function generateDotShapePlane(width:Float, height:Float, z:Int, seed:Int,
	fillRatio:Float = .2, sideRatio:Float = .2, crossRatio:Float = .2):Void {
		var w = Std.int(width / dotSize / 2);
		var h = Std.int(height / dotSize);
		var oy = -Std.int(h / 2);
		var pixels = new Array<Array<Int>>();
		for (x in 0...w) {
			var lp = new Array<Int>();
			for (y in 0...h) lp.push(0);
			pixels.push(lp);
		}
		var nextPixels = new Array<V>();
		var r = R.i.s(seed);
		for (i in 0...Std.int(w * h * fillRatio)) {
			for (j in 0...100) {
				if (nextPixels.length <= 0) nextPixels.push(V.i.xy(r.fi(1, w - 2), r.fi(1, h - 2)));
				var np = nextPixels[r.ni(nextPixels.length - 1)];
				var nx = np.xi, ny = np.yi;
				nextPixels.remove(np);
				if (pixels[nx][ny] > 0) continue;
				var countSide = 0, countCross = 1;
				for (ix in (nx - 1).ci(0, w)...(nx + 2).ci(0, w)) {
					for (iy in (ny - 1).ci(0, h)...(ny + 2).ci(0, h)) {
						if (pixels[ix][iy] > 0) {
							if (ix == nx || iy == ny) countSide++;
							else countCross++;
						}
					}
				}
				if (r.n() < .9 - countSide * sideRatio && r.n() < .9 - countCross * crossRatio) {
					pixels[nx][ny] = 1;
					for (ix in (nx - 1).ci(0, w)...(nx + 2).ci(0, w)) {
						for (iy in (ny - 1).ci(0, h)...(ny + 2).ci(0, h)) {
							if (pixels[ix][iy] == 0) {
								for (np in nextPixels) if (np.xi == ix && np.yi == iy) continue;
								nextPixels.push(V.i.xy(ix, iy));
							}
						}
					}
					break;
				}
			}
		}
		for (x in 0...w) pixels[x][0] = pixels[x][h - 1] = 0;
		for (y in 0...h) pixels[0][y] = pixels[w - 1][y] = 0;
		for (x in 1...w - 1) {
			for (y in 1...h - 1) {
				if (pixels[x][y] != 1) continue;
				for (ix in (x - 1)...(x + 2)) {
					for (iy in (y - 1)...(y + 2)) {
						if (pixels[ix][iy] == 0 && (ix == x || iy == y)) {
							setDot(ix, iy + oy, iy / h, z);
							setDot(-ix, iy + oy, iy / h, z);
							pixels[ix][iy] = 2;
						}
					}
				}
			}
		}
	}
	function setGeneratedColors(c:C, seed:Int):Void {
		if (colorTop == null) {
			colorTop = C.di;
			colorTopSpot = C.di;
			colorBottom = C.di;
			colorBottomSpot = C.di;
		}
		var r = R.i.s(seed);
		var cbl = C.di.v(c);
		blinkColor(cbl, r, 10);
		colorTop.v(cbl).gd;
		colorBottom.v(cbl);
		blinkColor(cbl, r, 100);
		colorTopSpot.v(cbl).gd;
		colorBottomSpot.v(cbl);
		xSpotInterval = Math.PI / 2 / r.fi(1, 3);
		ySpotInterval = Math.PI / 2 / r.fi(1, 3);
		xySpotInterval = Math.PI / 2 / r.fi(1, 3);
	}
	function blinkColor(c:C, r:R, width:Int):Void {
		c.r += r.pi(width);
		c.g += r.pi(width);
		c.b += r.pi(width);
		c.normalize();
	}
	function setTopBottomColor(c:C):Void {
		colorTop.v(c).gd;
		colorBottom.v(c);
		xSpotInterval = ySpotInterval = xySpotInterval = 0;
	}
	function setDot(x:Int, y:Int, ry:Float, z:Int = 0):Void {
		var ca = (x * xSpotInterval).cos() * (y * ySpotInterval).cos() *
				((x + y) * xySpotInterval).cos();
		var cl:C;
		if (ca.abs() < spotThreshold) cl = colorTopSpot.bl(colorBottomSpot, ry);
		else cl = colorTop.bl(colorBottom, ry);
		var ox = offset.x;
		var oy = offset.y;
		var oz = offsetZ;
		c(cl);
		if (isDotCube) {
			o(x * dotSize + ox, y * dotSize + oy, z * dotSize + oz).ac(dotSize * .8);
		} else {
			o(x * dotSize + ox, y * dotSize + oy, z * dotSize + oz - dotSize * .4).ap(dotSize * .8);
		}
		o(ox, oy, oz);
	}
}