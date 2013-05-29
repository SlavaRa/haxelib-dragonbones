package dragonbones.utils;
import nme.display.BitmapData;
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