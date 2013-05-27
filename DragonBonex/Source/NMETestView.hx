package ;

import dragonbones.animation.WorldClock;
import dragonbones.Armature;
import dragonbones.factorys.BaseFactory;
import haxe.Log;
import nme.Assets;
import nme.display.Sprite;
import nme.events.Event;

/**
 * @author SlavaRa
 */
class NMETestView extends Sprite {
	
	public function new() {
		super();
	}
	
	public function start() {
		factory = new BaseFactory();
		factory.onDataParsed.addOnce(onFactoryDataParsed);
		factory.parseData(Assets.getBytes("assets/character"));
	}
	
	var factory:BaseFactory;
	
	function onFactoryDataParsed() {
		var columnNum:Int = 15;
		var paddingWidth:Int = 50;
		var paddingHeight:Int = 20;
		var paddingLeft:Int = 25;
		var paddingTop:Int = 150;
		var Dx:Int = 25;
		
		#if debug
		for (i in 0...1) {
		#else
		for (i in 0...10) {
		#end
			var armature:Armature = factory.buildArmature("CharacterAnimations");
			var display:Sprite = armature.displayContainer;
			display.x = (i % columnNum) * paddingWidth + paddingLeft + ((i / columnNum) % 2) * Dx;
			display.y = ((i / columnNum)) * paddingHeight + paddingTop;
			armature.animation.gotoAndPlay("Idle", -1, -1, true);
			addChild(display);
			WorldClock.instance.add(armature);
		}
		addEventListener(Event.ENTER_FRAME, onEnterFrame);
	}
	
	function onEnterFrame(_) {
		WorldClock.instance.advanceTime( -1);
	}
}