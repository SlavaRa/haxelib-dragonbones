/**
 * Copyright 2012-2013. DragonBones. All Rights Reserved.
 */
package dragonbones.factorys;
import dragonbones.Armature;
import dragonbones.display.StarlingSlot;
import dragonbones.Slot;
import dragonbones.textures.ITextureAtlas;
import dragonbones.textures.StarlingTextureAtlas;
import openfl.display.BitmapData;
import openfl.display.MovieClip;
import openfl.errors.Error;
import openfl.geom.Rectangle;
import starling.core.Starling;
import starling.display.Image;
import starling.display.Sprite;
import starling.textures.SubTexture;
import starling.textures.Texture;
import starling.textures.TextureAtlas;
import starling.textures.TextureSmoothing;

/**
 * A object managing the set of armature resources for Starling engine. It parses the raw data, stores the armature resources and creates armature instances.
 * @see dragonBones.Armature
 */
/**
 * A StarlingFactory instance manages the set of armature resources for the starling DisplayList. It parses the raw data (ByteArray), stores the armature resources and creates armature instances.
 * <p>Create an instance of the StarlingFactory class that way:</p>
 * <listing>
 * import openfl.events.Event; 
 * import dragonBones.factorys.BaseFactory;
 * 
 * [Embed(source = "../assets/Dragon2.png", mimeType = "application/octet-stream")]  
 *	static const ResourcesData:Class;
 * var factory:StarlingFactory = new StarlingFactory(); 
 * factory.addEventListener(Event.COMPLETE, textureCompleteHandler);
 * factory.parseData(new ResourcesData());
 * </listing>
 * @see dragonBones.Armature
 */
class StarlingFactory extends BaseFactory
{
    /**
		 * Whether to generate mapmaps (true) or not (false).
		 */
    public var generateMipMaps:Bool;
    /**
		 * Whether to optimize for rendering (true) or not (false).
		 */
    public var optimizeForRenderToTexture:Bool;
    /**
		 * Apply a scale for SWF specific texture. Use 1 for no scale.
		 */
    public var scaleForTexture:Float;
    /**
		 * Apply a smoothing to generated display. Select from TextureSmoothing class.
		 */
    public var displaySmoothing:String = TextureSmoothing.BILINEAR;
    
    /**
		 * Creates a new StarlingFactory instance.
		 */
    public function new()
    {
        super(this);
        scaleForTexture = 1;
    }
    
    
    override function generateTextureAtlas(content:Dynamic, textureAtlasRawData:Dynamic):ITextureAtlas
    {
        var texture:Texture;
        var bitmapData:BitmapData;
        if (Std.is(content, BitmapData)) 
        {
            bitmapData = try cast(content, BitmapData) catch(e:Dynamic) null;
            texture = Texture.fromBitmapData(bitmapData, generateMipMaps, optimizeForRenderToTexture);
        }
        else if (Std.is(content, MovieClip)) 
        {
            var width:Int = getNearest2N(content.width) * scaleForTexture;
            var height:Int = getNearest2N(content.height) * scaleForTexture;
            
            _helpMatrix.a = 1;
            _helpMatrix.b = 0;
            _helpMatrix.c = 0;
            _helpMatrix.d = 1;
            _helpMatrix.scale(scaleForTexture, scaleForTexture);
            _helpMatrix.tx = 0;
            _helpMatrix.ty = 0;
            var movieClip:MovieClip = try cast(content, MovieClip) catch(e:Dynamic) null;
            movieClip.gotoAndStop(1);
            bitmapData = new BitmapData(width, height, true, 0xFF00FF);
            bitmapData.draw(movieClip, _helpMatrix);
            movieClip.gotoAndStop(movieClip.totalFrames);
            texture = Texture.fromBitmapData(bitmapData, generateMipMaps, optimizeForRenderToTexture, scaleForTexture);
        }
        else 
        {
            throw new Error();
        }
        var textureAtlas:StarlingTextureAtlas = new StarlingTextureAtlas(texture, textureAtlasRawData, false);
        if (Starling.handleLostContext) 
        {
            textureAtlas._bitmapData = bitmapData;
        }
        else 
        {
            bitmapData.dispose();
        }
        return textureAtlas;
    }
    
    
    override function generateArmature():Armature
    {
        var armature:Armature = new Armature(new Sprite());
        return armature;
    }
    
    
    override function generateSlot():Slot
    {
        var slot:Slot = new StarlingSlot();
        return slot;
    }
    
    
    override function generateDisplay(textureAtlas:Dynamic, fullName:String, pivotX:Float, pivotY:Float):Dynamic
    {
        var subTexture:SubTexture = try cast((try cast(textureAtlas, TextureAtlas) catch(e:Dynamic) null).getTexture(fullName), SubTexture) catch(e:Dynamic) null;
        if (subTexture != null) 
        {
            var subTextureFrame:Rectangle = (try cast(textureAtlas, TextureAtlas) catch(e:Dynamic) null).getFrame(fullName);
            if (subTextureFrame != null) 
            {
                pivotX += subTextureFrame.x;
                pivotY += subTextureFrame.y;
            }
            
            var image:Image = new Image(subTexture);
            image.pivotX = pivotX;
            image.pivotY = pivotY;
            image.smoothing = displaySmoothing;
            return image;
        }
        return null;
    }
    
    function getNearest2N(_n:Int):Int
    {
        return _n & _n - (1) ? 1 << Std.string(_n).length:_n;
    }
}
