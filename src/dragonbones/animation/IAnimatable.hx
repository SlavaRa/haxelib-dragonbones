package dragonbones.animation;

/**
 * @author SlavaRa
 */
#if (flash11 && starling)
typedef IAnimatable = starling.animation.IAnimatable;
#else
interface IAnimatable {
	function advanceTime(passedTime:Float):Void;
}
#end

