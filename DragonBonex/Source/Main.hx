package;

import haxe.Log;
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
	
	public function new() {
		super();
		Lib.current.stage.align = StageAlign.TOP_LEFT;
		Lib.current.stage.scaleMode = StageScaleMode.NO_SCALE;
		addEventListener(Event.ADDED_TO_STAGE, onStageAddedToStage);
	}
	
	function onStageAddedToStage(_) {
		removeEventListener(Event.ADDED_TO_STAGE, onStageAddedToStage);
		initialize();
	}
	
	function initialize() {
		addChild(new FPS(10, 10, 0xffffff));
		cast(addChild(new NMETestView()), NMETestView).start();
	}
}