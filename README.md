mgla3 (Mini Game programming Library with Away3D)
======================
Mgla3 is a mini game programming library written in Haxe, OpenFL and Away3D. Mgla3 is useful for creating a simple Flash game in short term.

Using the [SiON](https://github.com/keim/SiON "SiON") synthesizer library.

####Sample game

[BACKATTACKER](http://abagames.sakura.ne.jp/flash/ba/)

[LASER VS BOUNCE RECTS](http://abagames.sakura.ne.jp/flash/lvbr/)

###Sample code

[AVOIDER](http://abagames.sakura.ne.jp/flash/avd/)

```haxe
import mgla3.*; // https://github.com/abagames/mgla3
using Math;
using mgla3.F;
using mgla3.U;
class Main extends G {
	function new() {
		super(this);
	}
	var bss:S;
	// Initialize.
	override function i() {
		// Create the begining stage sound.
		bss = S.i.mj.m().t(.5, 10, .2).mj.m().t(.6, 10, .1).e;
		// Set the title and end the initalize process.
		tt("AVOIDER").ie;
	}
	// Load and save the stage number.
	var stg = 0;
	override function ls(d) {
		stg = d.stg;
	}
	override function ss(d) {
		d.stg = stg;
	}
	// Begin the game.
	override function b() {
		stg--;
		En.pl = new Pl();
		// If the game is not started, remove the player,
		if (!G.ig) En.pl.r;
		// else add the text of the operating key instruction.
		else T.i.tx("[udlr]: MOVE").xy( -.9, .9).t(180).ao;
		bs();
	}
	// Enemy appearance parameters.
	var ec = 0;
	var ei = 1;
	var esmin = .0;
	var esmax = .0;
	var eav = .0;
	var eaav = .0;
	var edmin = .0;
	var edmax = .0;
	var ea = .0;
	var et = 0;
	// Set the enemy appearance parameters of the current stage.
	function bs() {
		stg++;
		var r = R.i.st(stg);
		ei = Std.int(20 - r.dc * 19);
		ec = Std.int(60 / ei);
		esmax = .01 + r.dc * .04;
		esmin = (esmax - r.dc * .05).c(.01, .1);
		eav = 30 + r.dc * 150;
		eaav = r.dc * 20;
		edmin = .9 - r.dc * .5;
		edmax = edmin + r.dc * .3;
		ea = 360.rn();
		et = 0;
		if (G.ig) T.i.tx('STAGE ${stg + 1}').xy(0, .5).ac.t();
		bss.p;
	}
	// Update every frame.
	override function u() {
		if (ec > 0 && --et <= 0) {
			// Spawn the new enemy.
			et = ei;
			var en = new En();
			en.p.aw(ea, edmin.rf(edmax));
			en.s = esmin.rf(esmax);
			en.w = en.p.wt(En.pl.p) + eaav.rp();
			ea += eav.rp();
			ec--;
		}
		if (!G.ig) return;
		// If the number of enemy actors is zero, begin the next stage.
		if (A.acs("En").length <= 0) bs();
	}
	public static function main() {
		new Main();
	}
}
// Player.
class Pl extends A {
	static var ep:P;
	static var es:S;
	// Initialize the class.
	override function i() {
		// Generate the green shape in the size .16 x .16.
		ah(H.i.c(C.gi).dg(.16));
		// Hit rect (collision) is .05 x .05.
		hr(.05);
		// Explosion particle emitter.
		ep = P.i.c(C.gi.gr).cn(1000);
		// Explosion sound.
		es = S.i.mn.w(.6).t(.9, 10, .2).e;
	}
	// Update every frame.
	override function u() {
		// If moving (arrow of wasd) keys are pressed,
		if (K.st.l > 0) {
			// change the way and the position.
			w = w.aw(K.st.w, 7);
			p.a(K.st.m(.03));
			p.x = p.x.c(-1, 1);
			p.y = p.y.c(-1, 1);
		}
		// If the player is hitting with Enemy actors,
		if (ih("En")) {
			// add particles, 
			ep.p(p).a;
			// play sounds,
			es.p;
			// remove this actor and
			r;
			// end the game.
			G.eg;
		}
	}
	
}
// Enemy.
class En extends A {
	static public var pl:Pl;
	static var ep:P;
	static var es:S;
	override function i() {
		// Generate the shape, the paricle emitter and the sound.
		ah(H.i.c(C.ri).dg(.16));
		ep = P.i.c(C.ri.gb).cn(100).t(20);
		es = S.i.mj.w(.4).t(.5, 5, .1).e;
	}
	// Begin the actor.
	override function b() {
		z = 1.0;
	}
	override function u() {
		if (z > 0) {
			z -= .025;
			if (z <= 0) {
				z = 0;
				hr(.1);
			}
		}
		// If this actor passed the player, remove this actor.
		if ((p.wt(pl.p) - w).nw().abs() > 100) {
			ep.p(p).a;
			es.p;
			r;
		}
		// If the position is not in the screen, remove this actor.
		if (!p.ii()) r;
	}
}
```

License
----------
Copyright &copy; 2013 ABA Games

Distributed under the [MIT License][MIT].

[MIT]: http://www.opensource.org/licenses/mit-license.php
