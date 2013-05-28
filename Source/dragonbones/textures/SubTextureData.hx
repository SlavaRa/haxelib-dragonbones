package dragonbones.textures;

import nme.geom.Rectangle;

/**
 * @author SlavaRa
 * 1.4
 */
class SubTextureData extends Rectangle{

	public function new(x:Float = 0, y:Float = 0, width:Float = 0, height:Float = 0) {
		super(x, y, width, height);
		pivotX = 0;
		pivotY = 0;
	}
	
	public var pivotX:Int;
	public var pivotY:Int;
}