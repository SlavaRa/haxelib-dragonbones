package dragonbones.animation;

/**
 * @author SlavaRa
 */
#if (flash11 && starling)
typedef IAnimatable = starling.animation.IAnimatable;
#else
typedef IAnimatable = {
	function advanceTime(passedTime:Float):Void;
}
#end

