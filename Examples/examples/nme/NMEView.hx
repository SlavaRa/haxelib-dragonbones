package examples.nme;

import dragonbones.animation.WorldClock;
import dragonbones.Armature;
import dragonbones.factorys.ArmatureFactory;
import nme.display.DisplayObject;
import nme.display.Sprite;
import nme.display.StageAlign;
import nme.display.StageScaleMode;
import nme.events.Event;
import nme.Lib;
import nme.net.URLLoader;
import nme.net.URLLoaderDataFormat;
import nme.net.URLRequest;
import nme.utils.ByteArray;

/**
 * @author SlavaRa
 */
class NMEView extends Sprite{

	public static function main() Lib.current.addChild(new NMEView());
	
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
		configureStage();
		initialize();
	}
	
	function configureStage() {
		stage.align = StageAlign.TOP_LEFT;
		stage.scaleMode = StageScaleMode.NO_SCALE;
	}
	
	var factory:ArmatureFactory;
	
	function initialize() {
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
		addEventListener(Event.ENTER_FRAME, onEnterFrame);
	}
	
	function onEnterFrame(_) WorldClock.instance.advanceTime( -1);
}