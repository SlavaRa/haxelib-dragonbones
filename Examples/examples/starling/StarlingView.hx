package examples.starling;

import flash.display.Sprite;
import flash.events.Event;
import flash.Lib;
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