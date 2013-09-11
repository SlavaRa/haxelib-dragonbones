package dragonbones.utils;
import flash.display.BitmapData;
import msignal.Signal;

/**
 * @author SlavaRa
 */
class DisposeUtils {

	/**
	 * @return null only
	 */
	public static inline function dispose(target:Dynamic):Dynamic {
		var d:IDisposable = cast target;
		if (d != null) {
			d.dispose();
		} else if (Std.is(target, BitmapData)) {
			cast(target, BitmapData).dispose();
		} else if (Std.is(target, AnySignal)) {
			cast(target, AnySignal).removeAll();
		} else if (Std.is(target, Array)) {
			//var array:Array<IDisposable> = cast(target, Array);
			//for (i in 0...array.lenght) {
				//array[i] = dispose(array[i]);
			//}
		}
		
		return null;
	}
	
}