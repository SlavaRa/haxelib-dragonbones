/**
 * Copyright 2012-2013. DragonBones. All Rights Reserved.
 */
package dragonbones.animation;

/**
 * The IAnimatable interface defines the methods used by all animatable instance type used by the DragonBones system.
 * @see dragonBones.Armature
 * @see dragonBones.animation.WorldClock
 */
interface IAnimatable
{

    /**
	 * Update the animation using this method typically in an ENTERFRAME Event or with a Timer.
	 * @param The amount of second to move the playhead ahead.
	 */
    function advanceTime(passedTime:Float):Void;
}