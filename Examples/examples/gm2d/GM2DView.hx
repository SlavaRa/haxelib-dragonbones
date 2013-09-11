package examples.gm2d;

import dragonbones.animation.WorldClock;
import dragonbones.Armature;
import dragonbones.display.DisplayObject;
import dragonbones.factorys.ArmatureFactory;
import flash.events.Event;
import flash.Lib;
import flash.net.URLLoader;
import flash.net.URLLoaderDataFormat;
import flash.net.URLRequest;
import flash.utils.ByteArray;
import gm2d.Game;
import gm2d.Screen;
import gm2d.ScreenScaleMode;

/**
 * @author SlavaRa
 */
class GM2DView extends Screen{

	public function new() {
		super();
		initialize();
		loadAndCreateAnimations();
		makeCurrent();
	}
	
	public override function getScaleMode():ScreenScaleMode {
		return ScreenScaleMode.TOPLEFT_SCALED;
	}
	
	public override function updateDelta(inDT:Float) {
		WorldClock.instance.advanceTime(inDT);
	}
	
	var factory:ArmatureFactory;
	
	function initialize() {
		#if (cpp || neko)
		Game.showFPS = false;
		#else
		Game.showFPS = true;
		#end
		Game.fpsColor = 0xFFFFFF;
	}
	
	function loadAndCreateAnimations() {
		#if flash
		var url = "../../../Resources/dragonbones_png/character.png";
		#elseif (cpp || neko)
		var url = "../../../../Resources/dragonbones_png/character.png";
		#end
		var urlRequest = new URLRequest(url);
		var urlLoader = new URLLoader();
		urlLoader.addEventListener(Event.COMPLETE, onUrlLoaderComplete);
		urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
		urlLoader.load(urlRequest);
	}
	
	function onUrlLoaderComplete(event:Event) {
		var urlLoader = cast(event.target, URLLoader);
		urlLoader.removeEventListener(Event.COMPLETE, onUrlLoaderComplete);
		
		factory = new ArmatureFactory();
		factory.onDataParsed.addOnce(onFactoryDataParsed);
		factory.parseData(cast(urlLoader.data, ByteArray));
	}
	
	function onFactoryDataParsed() {
		var x:Float = 100;
		var y:Float = 150;
		
		for (i in 0...10) {
			var armature = factory.buildArmature("CharacterAnimations");
			var display = cast(armature.displayContainer, DisplayObject);
			display.x = x;
			display.y = y;
			x += display.width + 10;
			if((x + display.width) >= Lib.current.stage.stageWidth) {
				x = 100;
				y += display.height + 10;
			}
			armature.animation.gotoAndPlay("Idle", -1, -1, true);
			addChild(display);
			WorldClock.instance.add(armature);
		}
	}
}