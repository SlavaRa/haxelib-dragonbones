package;

import nme.display.FPS;
import nme.display.Sprite;
import nme.display.StageAlign;
import nme.display.StageScaleMode;
import nme.events.Event;
import nme.Lib;

/**
 * @author SlavaRa
 */
class Main extends Sprite {
	
	public static function main() {
		Lib.current.addChild(new Main());
	}
	
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
	
	function initialize() {
		//addChild(new FPS());
		cast(addChild(new NMETestView()), NMETestView).start();
	}
	
}