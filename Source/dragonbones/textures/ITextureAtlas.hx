package dragonbones.textures;
import dragonbones.utils.IDisposable;
import flash.geom.Rectangle;

/**
 * @author SlavaRa
 */

interface ITextureAtlas extends IDisposable {
	var name(default, null):String;
	function getRegion(name:String):Rectangle;
}