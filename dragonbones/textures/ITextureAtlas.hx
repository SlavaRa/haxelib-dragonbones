/**
 * Copyright 2012-2013. DragonBones. All Rights Reserved.
 */
package dragonbones.textures;
import openfl.geom.Rectangle;

/**
 * The ITextureAtlas interface defines the methods used by all ITextureAtlas within the dragonBones system (flash or starling DisplayObject based).
 * @see dragonBones.Armature
 */
interface ITextureAtlas
{
    
    /**
	 * The name of this ITextureAtlas.
	 */
    var name(get, never):String;

    /**
	 * Clean up resources.
	 */
    function dispose():Void;
	
    /**
	 * Get the specific region of the TextureAtlas occupied by assets defined by that name.
	 * @param name The name of the assets represented by that name.
	 * @return Rectangle The rectangle area occupied by those assets.
	 */
    function getRegion(name:String):Rectangle;
}