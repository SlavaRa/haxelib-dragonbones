package dragonbones.utils;
import nme.utils.ByteArray;

/**
 * @author SlavaRa
 */
class ByteArrayUtils{
	public static function clear(buffer:ByteArray) {
		#if !js
		buffer.clear();
		#else
		buffer.position = 0;
		buffer.length = 0;
		#end
	}
	
	public static function setLenght(buffer:ByteArray, lenght:Int) {
		#if flash
		buffer.length = lenght;
		#elseif js
		buffer.position = lenght;
		buffer.length = lenght;
		#else
		buffer.setLength(lenght);
		#end
	}
}