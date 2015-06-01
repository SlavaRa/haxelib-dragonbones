package dragonbones.events;


/**
	* Copyright 2012-2013. DragonBones. All Rights Reserved.
	* @playerversion Flash 10.0, Flash 10
	* @langversion 3.0
	* @version 2.0
	*/
import openfl.events.Event;
/**
	 * The ArmatureEvent provides and defines all events dispatched directly by an Armature instance.
	 *
	 * 
	 * @see dragonBones.animation.Animation
	 */
class ArmatureEvent extends Event
{
    
    /**
		 * Dispatched after a successful z order update.
		 */
    public static inline var Z_ORDER_UPDATED:String = "zOrderUpdated";
    
    public function new(type:String)
    {
        super(type, false, false);
    }
    
    /**
		 * @private
		 * @return
		 */
    public override function clone():Event
    {
        return new ArmatureEvent(type);
    }
}

