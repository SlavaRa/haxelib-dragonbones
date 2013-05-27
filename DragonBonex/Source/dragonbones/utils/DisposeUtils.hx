package dragonbones.utils;

/**
 * @author SlavaRa
 */
class DisposeUtils {

	public static inline function dispose(target:Dynamic) {
		var d:IDisposable = cast target;
		if (d != null) {
			d.dispose();
		}
	}
	
}