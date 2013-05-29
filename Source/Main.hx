package;

import examples.nme.NMEView;
import examples.starling.StarlingView;
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
	
	#if (flash11 && starling)
	function initialize() addChild(new StarlingView());
	#if gm2d
	
	#if genome2d
	
	#else
	function initialize() addChild(new NMEView());
	#end
}