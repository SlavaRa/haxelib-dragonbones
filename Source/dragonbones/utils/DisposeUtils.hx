package dragonbones.utils;
import flash.display.BitmapData;
import msignal.Signal;

/**
 * @author SlavaRa
 */
class DisposeUtils {

	public static inline function dispose(target:Dynamic) {
		var d:IDisposable = cast target;
		if (d != null) {
			d.dispose();
		} else if (Std.is(target, BitmapData)) {
			cast(target, BitmapData).dispose();
		} else if (Std.is(target, AnySignal)) {
			cast(target, AnySignal).removeAll();
		}
	}
	
}