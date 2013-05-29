package examples.starling;

import nme.display.Sprite;
import nme.events.Event;
import nme.Lib;
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