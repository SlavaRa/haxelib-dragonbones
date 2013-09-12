package dragonbones.utils;
import haxe.Log;

/**
 * @author SlavaRa
 */
class MathUtils {

	public static inline function DOUBLE_PI():Float {
		return Math.PI * 2;
	}
	
	public static inline function HALF_PI():Float {
		return Math.PI / 2;
	}
	
	public static inline function ANGLE_TO_RADIAN():Float {
		return Math.PI / 180;
	}
}