package examples.starling;

import dragonbones.Armature;
import dragonbones.factorys.ArmatureFactory;
import nme.Lib;
import nme.net.URLLoader;
import nme.net.URLLoaderDataFormat;
import nme.net.URLRequest;
import nme.utils.ByteArray;
import starling.core.Starling;
import starling.display.DisplayObject;
import starling.display.Sprite;
import starling.events.Event;

/**
 * @author SlavaRa
 */
class StarlingRoot extends Sprite {

	public function new() {
		super();
		addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
	}
	
	private function onAddedToStage(_) {
		removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		initialize();
	}
	
	var factory:ArmatureFactory;
	
	function initialize() {
		var url:String = "../../../Resources/dragonbones_png/character.png";
		var urlRequest:URLRequest = new URLRequest(url);
		var urlLoader:URLLoader = new URLLoader();
		urlLoader.addEventListener(nme.events.Event.COMPLETE, onUrlLoaderComplete);
		urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
		urlLoader.load(urlRequest);
	}
	
	function onUrlLoaderComplete(event:nme.events.Event) {
		var urlLoader:URLLoader = cast(event.target, URLLoader);
		urlLoader.removeEventListener(nme.events.Event.COMPLETE, onUrlLoaderComplete);
		
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
			Starling.juggler.add(armature);
		}
	}
	
}