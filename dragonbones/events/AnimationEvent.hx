/**
 * Copyright 2012-2013. DragonBones. All Rights Reserved.
 */
package dragonbones.events;
import dragonbones.Armature;
import dragonbones.animation.AnimationState;
import openfl.events.Event;

/**
 * The AnimationEvent provides and defines all events dispatched during an animation.
 * @see dragonBones.Armature
 * @see dragonBones.animation.Animation
 */
class AnimationEvent extends Event
{
    /**
	 * 不推荐使用.
	 */
    public static var MOVEMENT_CHANGE(get, never):String;
    static function get_MOVEMENT_CHANGE() return FADE_IN;
	
	/**
	 * 不推荐的API.
	 */
	public var movementID(get, never):String;
    function get_movementID() return animationName;
	
	/**
	 * The armature that is the taget of this event.
	 */
	public var armature(get, never):Armature;
    function get_armature() return Std.is(target, Armature) ? cast(target, Armature) : null;
    
	public var animationName(get, never):String;
    function get_animationName() return animationState.name;

    /**
	 * Dispatched when the playback of an animation fade in.
	 */
    public static inline var FADE_IN = "fadeIn";
    
    /**
	 * Dispatched when the playback of an animation fade out.
	 */
    public static inline var FADE_OUT = "fadeOut";
    
    /**
	 * Dispatched when the playback of an animation starts.
	 */
    public static inline var START = "start";
    
    /**
	 * Dispatched when the playback of a animation stops.
	 */
    public static inline var COMPLETE = "complete";
    
    /**
	 * Dispatched when the playback of a animation completes a loop.
	 */
    public static inline var LOOP_COMPLETE = "loopComplete";
    
    /**
	 * Dispatched when the playback of an animation fade in complete.
	 */
    public static inline var FADE_IN_COMPLETE = "fadeInComplete";
    
    /**
	 * Dispatched when the playback of an animation fade out complete.
	 */
    public static inline var FADE_OUT_COMPLETE = "fadeOutComplete";
    
    /**
	 * The animationState instance.
	 */
    public var animationState:AnimationState;
    
    /**
	 * Creates a new AnimationEvent instance.
	 * @param type
	 * @param cancelable
	 */
    public function new(type:String, cancelable:Bool = false)
    {
        super(type, false, cancelable);
    }
    
    public override function clone():Event
    {
        var event:AnimationEvent = new AnimationEvent(type, cancelable);
        event.animationState = animationState;
        return event;
    }
}