package dragonbones.events;

import nme.events.Event;

/**
 * @author SlavaRa
 */
class ArmatureEvent extends Event{

	public static inline var Z_ORDER_UPDATED:String = "zOrderUpdated";
	
	public function new(type:String, bubbles:Bool=false, cancelable:Bool=false) {
		super(type, false, false);
	}
	
	public override function clone():Event {
		return new ArmatureEvent(type);
	}
	
}