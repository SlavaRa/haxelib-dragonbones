package ;

import dragonbones.animation.WorldClock;
import dragonbones.Armature;
import dragonbones.factorys.BaseFactory;
import nme.display.Sprite;
import nme.events.Event;
import nme.events.SecurityErrorEvent;
import nme.Lib;
import nme.net.URLLoader;
import nme.net.URLLoaderDataFormat;
import nme.net.URLRequest;
import nme.utils.ByteArray;

/**
 * @author SlavaRa
 */
class NMETestView extends Sprite {
	
	
	
	public function new() {
		super();
	}
	
	public function start() {
		var url:String = "../../../Resources/dragonbones_png/character.png";
		var urlRequest:URLRequest = new URLRequest(url);
		var urlLoader:URLLoader = new URLLoader();
		urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onUrlLoaderSecurityError);
		urlLoader.addEventListener(Event.COMPLETE, onUrlLoaderComplete);
		urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
		urlLoader.load(urlRequest);
	}
	
	private function onUrlLoaderSecurityError(event:SecurityErrorEvent) {
		throw event.text;
	}
	
	private function onUrlLoaderComplete(event:Event) {
		var urlLoader:URLLoader = cast(event.target, URLLoader);
		urlLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onUrlLoaderSecurityError);
		urlLoader.removeEventListener(Event.COMPLETE, onUrlLoaderComplete);
		
		factory = new BaseFactory();
		factory.onDataParsed.addOnce(onFactoryDataParsed);
		factory.parseData(cast(urlLoader.data, ByteArray));
	}
	
	var factory:BaseFactory;
	
	function onFactoryDataParsed() {
		var x:Float = 100;
		var y:Float = 150;
		
		#if debug
		for (i in 0...1) {
		#else
		for (i in 0...10) {
		#end
			var armature:Armature = factory.buildArmature("CharacterAnimations");
			var display:Sprite = armature.displayContainer;
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
	
	function onEnterFrame(_) {
		WorldClock.instance.advanceTime( -1);
	}
}