package examples.gm2d;

import dragonbones.animation.WorldClock;
import dragonbones.Armature;
import dragonbones.display.DisplayObject;
import dragonbones.factorys.ArmatureFactory;
import gm2d.Game;
import gm2d.Screen;
import gm2d.ScreenScaleMode;
import haxe.Log;
import nme.events.Event;
import nme.Lib;
import nme.net.URLLoader;
import nme.net.URLLoaderDataFormat;
import nme.net.URLRequest;
import nme.utils.ByteArray;

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
		//{ region BUG. if (Game.showFPS == true) app crashes(cpp, neko only).
		#if (cpp || neko)
		Game.showFPS = false;
		#else
		Game.showFPS = true;
		#end
		//} endregion
		Game.fpsColor = 0xFFFFFF;
	}
	
	function loadAndCreateAnimations() {
		#if flash
		var url:String = "../../../Resources/dragonbones_png/character.png";
		#elseif (cpp || neko)
		var url:String = "../../../../Resources/dragonbones_png/character.png";
		#end
		var urlRequest:URLRequest = new URLRequest(url);
		var urlLoader:URLLoader = new URLLoader();
		urlLoader.addEventListener(Event.COMPLETE, onUrlLoaderComplete);
		urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
		urlLoader.load(urlRequest);
	}
	
	function onUrlLoaderComplete(event:Event) {
		var urlLoader:URLLoader = cast(event.target, URLLoader);
		urlLoader.removeEventListener(Event.COMPLETE, onUrlLoaderComplete);
		
		factory = new ArmatureFactory();
		factory.onDataParsed.addOnce(onFactoryDataParsed);
		factory.parseData(cast(urlLoader.data, ByteArray));
	}
	
	function onFactoryDataParsed() {
		var x:Float = 100;
		var y:Float = 150;
		
		for (i in 0...10) {
			var armature:Armature = factory.buildArmature("CharacterAnimations");
			var display:DisplayObject = cast(armature.displayContainer, DisplayObject);
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