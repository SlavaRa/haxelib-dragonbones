/**
 * Copyright 2012-2013. DragonBones. All Rights Reserved.
 */
package dragonbones.events;
import dragonbones.Armature;
import dragonbones.animation.AnimationState;
import openfl.events.Event;

/**
 * The AnimationEvent provides and defines all events dispatched during an animation.
 *
 * @see dragonBones.Armature
 * @see dragonBones.animation.Animation
 */
class AnimationEvent extends Event
{
    public static var MOVEMENT_CHANGE(get, never):String;
    public var movementID(get, never):String;
    public var armature(get, never):Armature;
    public var animationName(get, never):String;

    /**
		 * 不推荐使用.
		 */
    static function get_MOVEMENT_CHANGE():String
    {
        return FADE_IN;
    }
    
    /**
		 * Dispatched when the playback of an animation fade in.
		 */
    public static inline var FADE_IN:String = "fadeIn";
    
    /**
		 * Dispatched when the playback of an animation fade out.
		 */
    public static inline var FADE_OUT:String = "fadeOut";
    
    /**
		 * Dispatched when the playback of an animation starts.
		 */
    public static inline var START:String = "start";
    
    /**
		 * Dispatched when the playback of a animation stops.
		 */
    public static inline var COMPLETE:String = "complete";
    
    /**
		 * Dispatched when the playback of a animation completes a loop.
		 */
    public static inline var LOOP_COMPLETE:String = "loopComplete";
    
    /**
		 * Dispatched when the playback of an animation fade in complete.
		 */
    public static inline var FADE_IN_COMPLETE:String = "fadeInComplete";
    
    /**
		 * Dispatched when the playback of an animation fade out complete.
		 */
    public static inline var FADE_OUT_COMPLETE:String = "fadeOutComplete";
    
    /**
		 * 不推荐的API.
		 */
    function get_MovementID():String
    {
        return animationName;
    }
    
    /**
		 * The animationState instance.
		 */
    public var animationState:AnimationState;
    
    /**
		 * The armature that is the taget of this event.
		 */
    function get_Armature():Armature
    {
        return try cast(target, Armature) catch(e:Dynamic) null;
    }
    
    function get_AnimationName():String
    {
        return animationState.name;
    }
    
    /**
		 * Creates a new AnimationEvent instance.
		 * @param type
		 * @param cancelable
		 */
    public function new(type:String, cancelable:Bool = false)
    {
        super(type, false, cancelable);
    }
    
    /**
		 * @private
		 * @return
		 */
    public override function clone():Event
    {
        var event:AnimationEvent = new AnimationEvent(type, cancelable);
        event.animationState = animationState;
        return event;
    }
}
