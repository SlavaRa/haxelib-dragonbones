/**
 * Copyright 2012-2013. DragonBones. All Rights Reserved.
 */
package dragonbones.events;
import dragonbones.animation.AnimationState;
import dragonbones.Armature;
import dragonbones.Bone;
import openfl.events.Event;

/**
 * The FrameEvent class provides and defines all events dispatched by an Animation or Bone instance entering a new frame.
 * @see dragonBones.animation.Animation
 */
class FrameEvent extends Event
{
    public static var MOVEMENT_FRAME_EVENT(get, never):String;
    static function get_MOVEMENT_FRAME_EVENT():String return ANIMATION_FRAME_EVENT;
	
    /**
	 * The armature that is the target of this event.
	 */
    public var armature(get, never):Armature;
	function get_armature() return Std.is(target, Armature) ? cast(target, Armature) : null;
    
    /**
	 * Dispatched when the animation of the armatrue enter a frame.
	 */
    public static inline var ANIMATION_FRAME_EVENT = "animationFrameEvent";
    public static inline var BONE_FRAME_EVENT = "boneFrameEvent";
    
    /**
	 * The entered frame label.
	 */
    public var frameLabel:String;
    public var bone:Bone;
    
    /**
	 * The animationState instance.
	 */
    public var animationState:AnimationState;
    
    /**
	 * Creates a new FrameEvent instance.
	 * @param type
	 * @param cancelable
	 */
    public function new(type:String, cancelable:Bool = false)
    {
        super(type, false, cancelable);
    }
    
    /**
	 * @return An exact duplicate of the current object.
	 */
    public override function clone():Event
    {
        var event:FrameEvent = new FrameEvent(type, cancelable);
        event.animationState = animationState;
        event.bone = bone;
        event.frameLabel = frameLabel;
        return event;
    }
}