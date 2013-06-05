package dragonbones;

import examples.ExampleView;
import nme.display.Sprite;
import nme.Lib;

/**
 * @author SlavaRa
 */
class Main extends Sprite {
	
	public static function main() Lib.current.addChild(new Main());
	
	public function new() {
		super();
		initialize();
	}
	
	function initialize() addChild(new ExampleView());
}