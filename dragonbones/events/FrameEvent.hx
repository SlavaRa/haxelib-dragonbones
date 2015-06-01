package dragonbones.events;


/**
	* Copyright 2012-2013. DragonBones. All Rights Reserved.
	* @playerversion Flash 10.0, Flash 10
	* @langversion 3.0
	* @version 2.0
	*/
import dragonbones.Armature;
import dragonbones.Bone;
import dragonbones.animation.AnimationState;

import openfl.events.Event;

/**
	 * The FrameEvent class provides and defines all events dispatched by an Animation or Bone instance entering a new frame.
	 *
	 * 
	 * @see dragonBones.animation.Animation
	 */
class FrameEvent extends Event
{
    public static var MOVEMENT_FRAME_EVENT(get, never):String;
    public var armature(get, never):Armature;

    static function get_MOVEMENT_FRAME_EVENT():String
    {
        return ANIMATION_FRAME_EVENT;
    }
    
    /**
		 * Dispatched when the animation of the armatrue enter a frame.
		 */
    public static inline var ANIMATION_FRAME_EVENT:String = "animationFrameEvent";
    
    /**
		 * 
		 */
    public static inline var BONE_FRAME_EVENT:String = "boneFrameEvent";
    
    /**
		 * The entered frame label.
		 */
    public var frameLabel:String;
    
    public var bone:Bone;
    
    /**
		 * The armature that is the target of this event.
		 */
    function get_Armature():Armature
    {
        return try cast(target, Armature) catch(e:Dynamic) null;
    }
    
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
		 * @private
		 *
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
