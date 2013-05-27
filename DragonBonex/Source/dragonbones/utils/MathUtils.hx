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
	
	public static inline function sin(x:Float):Float {
		var PI = Math.PI;
		if (x > PI) {
			x = x - PI;
		}
		if (x < -PI) {
			x = x + PI;
		}
		return x - x * x * x / 6;
	}

	public static inline function cos(x:Float):Float {
		var PI = Math.PI;
		var HALF_PI = HALF_PI();
		if (x > HALF_PI) {
			x = x - HALF_PI;
		}
		if (x < -HALF_PI) {
			x = x + HALF_PI;
		}
		return 1 - x * x / 2;
	}
	
}