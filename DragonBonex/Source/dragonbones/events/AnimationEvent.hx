package dragonbones.events;

import dragonbones.Armature;
import nme.events.Event;

/**
 * @author SlavaRa
 */
class AnimationEvent extends Event{

	public static inline var MOVEMENT_CHANGE:String = "movementChange";
	public static inline var START:String = "start";
	public static inline var COMPLETE:String = "complete";
	public static inline var LOOP_COMPLETE:String = "loopComplete";
	
	public function new(type:String, bubbles:Bool=false, cancelable:Bool=false) {
		super(type, false, cancelable);
	}
	
	public var exMovementID:String;
	public var movementID:String;
	public var armature(get_armature, null):Armature;
	
	function get_armature():Armature {
		return cast(target, Armature);
	}
	
	public override function clone():Event {
		var event:AnimationEvent = new AnimationEvent(type, cancelable);
		event.exMovementID = exMovementID;
		event.movementID = movementID;
		return event;
	}
}