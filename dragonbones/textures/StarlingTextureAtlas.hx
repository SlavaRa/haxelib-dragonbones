/**
 * Copyright 2012-2013. DragonBones. All Rights Reserved.
 */
package dragonbones.textures;
import dragonbones.objects.DataParser;
import dragonbones.textures.TextureData;
import openfl.display.BitmapData;
import starling.textures.Texture;
import starling.textures.TextureAtlas;

/**
	 * The StarlingTextureAtlas creates and manipulates TextureAtlas from starling.display.DisplayObject.
	 */
class StarlingTextureAtlas extends TextureAtlas implements ITextureAtlas
{
    public var name(get, never):String;

    var _bitmapData:BitmapData;
    var _subTextureDic:Dynamic;
    var _isDifferentConfig:Bool;
    var _scale:Float;
    var _name:String;
    /**
		 * The name of this StarlingTextureAtlas instance.
		 */
    function get_Name():String
    {
        return _name;
    }
    /**
		 * Creates a new StarlingTextureAtlas instance.
		 * @param texture A texture instance.
		 * @param textureAtlasRawData A textureAtlas config data
		 * @param isDifferentXML
		 */
    public function new(texture:Texture, textureAtlasRawData:Dynamic, isDifferentConfig:Bool = false)
    {
        super(texture, null);
        if (texture != null) 
        {
            _scale = texture.scale;
            _isDifferentConfig = isDifferentConfig;
        }
        _subTextureDic = { };
        parseData(textureAtlasRawData);
    }
    /**
		 * Clean up all resources used by this StarlingTextureAtlas instance.
		 */
    public override function dispose():Void
    {
        super.dispose();
        for (subTexture/* AS3HX WARNING could not determine type for var: subTexture exp: EIdent(_subTextureDic) type: Dynamic */ in _subTextureDic)
        {
            subTexture.dispose();
        }
        _subTextureDic = null;
        
        if (_bitmapData != null) 
        {
            _bitmapData.dispose();
        }
        _bitmapData = null;
    }
    
    /**
		 * Get the Texture with that name.
		 * @param name The name ofthe Texture instance.
		 * @return The Texture instance.
		 */
    public override function getTexture(name:String):Texture
    {
        var texture:Texture = Reflect.field(_subTextureDic, name);
        if (texture == null) 
        {
            texture = super.getTexture(name);
            if (texture != null) 
            {
                Reflect.setField(_subTextureDic, name, texture);
            }
        }
        return texture;
    }
    /**
		 * @private
		 */
    function parseData(textureAtlasRawData:Dynamic):Void
    {
        var textureAtlasData:Dynamic = DataParser.parseTextureAtlas(textureAtlasRawData, (_isDifferentConfig) ? _scale:1);
        _name = textureAtlasData.__name;
        //delete textureAtlasData.__name;
        textureAtlasData.__name = null;
        for (subTextureName in Reflect.fields(textureAtlasData))
        {
            var textureData:TextureData = Reflect.field(textureAtlasData, subTextureName);
            //, textureData.rotated
            this.addRegion(subTextureName, textureData.region, textureData.frame);
        }
    }
}
