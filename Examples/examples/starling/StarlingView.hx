package examples.starling;

import dragonbones.factorys.ArmatureFactory;
import flash.display.Sprite;
import flash.events.Event;
import flash.Lib;
import flash.net.URLLoader;
import flash.net.URLLoaderDataFormat;
import flash.net.URLRequest;
import starling.core.Starling;

/**
 * @author SlavaRa
 */
class StarlingView extends Sprite {

	public static function main() Lib.current.addChild(new StarlingView());
	
	public function new() {
		super();
		if(stage != null) {
			onStageAddedToStage();
		} else {
			addEventListener(Event.ADDED_TO_STAGE, onStageAddedToStage);
		}
	}
	
	function onStageAddedToStage(?_) {
		removeEventListener(Event.ADDED_TO_STAGE, onStageAddedToStage);
		initialize();
	}
	
	function initialize() new Starling(StarlingRoot, stage).start();
}

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
	
	inline function initialize() {
		var url = "../../../Resources/dragonbones_png/character.png";
		var urlRequest = new URLRequest(url);
		var urlLoader = new URLLoader();
		urlLoader.addEventListener(flash.events.Event.COMPLETE, onUrlLoaderComplete);
		urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
		urlLoader.load(urlRequest);
	}
	
	function onUrlLoaderComplete(event:flash.events.Event) {
		var urlLoader = cast(event.target, URLLoader);
		urlLoader.removeEventListener(flash.events.Event.COMPLETE, onUrlLoaderComplete);
		
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
			Starling.juggler.add(armature);
		}
	}
	
}