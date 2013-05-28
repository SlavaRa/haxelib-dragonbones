package dragonbones.events;

import dragonbones.Armature;
import dragonbones.Bone;
import nme.events.Event;

/**
 * @author SlavaRa
 */
class FrameEvent extends Event{

	public static inline var MOVEMENT_FRAME_EVENT:String = "movementFrameEvent";
	public static inline var BONE_FRAME_EVENT:String = "boneFrameEvent";
	
	public function new(type:String, bubbles:Bool = false, cancelable:Bool = false, bone:Bone = null) {
		super(type, false, cancelable);
		this.bone = bone;
	}
	
	public var movementID:String;
	public var frameLabel:String;
	public var armature(get_armature, null):Armature;
	public var bone(default, null):Bone;
	
	function get_armature():Armature {
		return cast(target, Armature);
	}
	
	public override function clone():Event {
		var event:FrameEvent = new FrameEvent(type, cancelable);
		event.movementID = movementID;
		event.frameLabel = frameLabel;
		event.bone = bone;
		return event;
	}
}