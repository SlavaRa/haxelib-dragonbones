/**
 * Copyright 2012-2013. DragonBones. All Rights Reserved.
 */
package dragonbones.textures;
import dragonbones.objects.DataParser;
import dragonbones.textures.TextureData;
import openfl.display.BitmapData;
import openfl.display.MovieClip;
import openfl.geom.Rectangle;

/**
 * The NativeTextureAtlas creates and manipulates TextureAtlas from traditional openfl.display.DisplayObject.
 */
class NativeTextureAtlas implements ITextureAtlas {
    public var name(get, never):String;
    public var movieClip(get, never):MovieClip;
    public var bitmapData(get, never):BitmapData;
    public var scale(get, never):Float;

    var _subTextureDataDic:Dynamic;
    var _isDifferentConfig:Bool;
    var _name:String;

    /**
	 * The name of this NativeTextureAtlas instance.
	 */
    function get_name():String
    {
        return _name;
    }
    
    var _movieClip:MovieClip;
    /**
	 * The MovieClip created by this NativeTextureAtlas instance.
	 */
    function get_movieClip():MovieClip
    {
        return _movieClip;
    }
    
    var _bitmapData:BitmapData;
    /**
	 * The BitmapData created by this NativeTextureAtlas instance.
	 */
    function get_bitmapData():BitmapData
    {
        return _bitmapData;
    }
    
    var _scale:Float;
    function get_scale():Float
    {
        return _scale;
    }
	
    /**
	 * Creates a new NativeTextureAtlas instance. 
	 * @param texture A MovieClip or Bitmap.
	 * @param textureAtlasRawData The textureAtlas config data.
	 * @param textureScale A scale value (x and y axis)
	 * @param isDifferentConfig 
	 */
    public function new(texture:Dynamic, textureAtlasRawData:Dynamic, textureScale:Float = 1, isDifferentConfig:Bool = false)
    {
        _scale = textureScale;
        _isDifferentConfig = isDifferentConfig;
        if (Std.is(texture, BitmapData)) _bitmapData = cast(texture, BitmapData);
        else if (Std.is(texture, MovieClip)) {
            _movieClip = cast(texture, MovieClip);
            _movieClip.stop();
        }
        parseData(textureAtlasRawData);
    }
	
    /**
	 * Clean up all resources used by this NativeTextureAtlas instance.
	 */
    public function dispose():Void
    {
        _movieClip = null;
        if(_bitmapData != null) _bitmapData.dispose();
        _bitmapData = null;
    }
	
    /**
	 * The area occupied by all assets related to that name.
	 * @param name The name of these assets.
	 * @return Rectangle The area occupied by all assets related to that name.
	 */
    public function getRegion(name:String):Rectangle
    {
        var textureData:TextureData = cast(Reflect.field(_subTextureDataDic, name), TextureData);
        if (textureData != null) return textureData.region;
        return null;
    }
    
    public function getFrame(name:String):Rectangle
    {
        var textureData:TextureData = cast(Reflect.field(_subTextureDataDic, name), TextureData);
        if (textureData != null) return textureData.frame;
        return null;
    }
    
    function parseData(textureAtlasRawData:Dynamic):Void
    {
        _subTextureDataDic = DataParser.parseTextureAtlas(textureAtlasRawData, (_isDifferentConfig) ? _scale:1);
        _name = _subTextureDataDic.__name;
        //delete _subTextureDataDic.__name;
        _subTextureDataDic.__name = null;
    }

    public
    function movieClipToBitmapData():Void
    {
        if (_bitmapData == null && _movieClip != null) 
        {
            _movieClip.gotoAndStop(1);
            _bitmapData = new BitmapData(getNearest2N(Std.int(_movieClip.width)), getNearest2N(Std.int(_movieClip.height)), true, 0xFF00FF);
            _bitmapData.draw(_movieClip);
            _movieClip.gotoAndStop(_movieClip.totalFrames);
        }
    }
    
    function getNearest2N(_n:Int):Int return (_n & _n - 1) != 0 ? 1 << Std.string(_n).length : _n;
}