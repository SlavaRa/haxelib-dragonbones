/**
 * Copyright 2012-2013. DragonBones. All Rights Reserved.
 */
package dragonbones.factorys;
import dragonbones.Armature;
import dragonbones.display.NativeSlot;
import dragonbones.Slot;
import dragonbones.textures.ITextureAtlas;
import dragonbones.textures.NativeTextureAtlas;
import openfl.errors.Error;
import openfl.display.MovieClip;
import openfl.display.Shape;
import openfl.display.Sprite;
import openfl.geom.Matrix;
import openfl.geom.Rectangle;

class NativeFactory extends BaseFactory
{
	static var _helpMatrix = new Matrix();
	
    /**
	 * If enable BitmapSmooth
	 */
    public var fillBitmapSmooth:Bool;
    
    /**
	 * If use bitmapData Texture（When using dbswf，you can use vector element，if enable useBitmapDataTexture，dbswf will be force converted to BitmapData）
	 */
    public var useBitmapDataTexture:Bool;
    
    public function new() super();
    
    override function generateTextureAtlas(content:Dynamic, textureAtlasRawData:Dynamic):ITextureAtlas
    {
        var textureAtlas:NativeTextureAtlas = new NativeTextureAtlas(content, textureAtlasRawData, 1, false);
        return textureAtlas;
    }
    
    
    override function generateArmature():Armature
    {
        var display:Sprite = new Sprite();
        var armature:Armature = new Armature(display);
        return armature;
    }
    
    
    override function generateSlot():Slot
    {
        var slot:Slot = new NativeSlot();
        return slot;
    }
    
    
    override function generateDisplay(textureAtlas:Dynamic, fullName:String, pivotX:Float, pivotY:Float):Dynamic
    {
        var nativeTextureAtlas:NativeTextureAtlas;
        if (Std.is(textureAtlas, NativeTextureAtlas)) 
        {
            nativeTextureAtlas = try cast(textureAtlas, NativeTextureAtlas) catch(e:Dynamic) null;
        }
        
        if (nativeTextureAtlas != null) 
        {
            var movieClip:MovieClip = nativeTextureAtlas.movieClip;
            if (useBitmapDataTexture && movieClip != null) 
            {
                nativeTextureAtlas.movieClipToBitmapData();
            }
            
            if (!useBitmapDataTexture && movieClip != null && movieClip.totalFrames >= 3) 
            {
                movieClip.gotoAndStop(movieClip.totalFrames);
                movieClip.gotoAndStop(fullName);
                if (movieClip.numChildren > 0) 
                {
                    try
                    {
                        var displaySWF:Dynamic = movieClip.getChildAt(0);
                        displaySWF.x = 0;
                        displaySWF.y = 0;
                        return displaySWF;
                    }                    catch (e:Error)
                    {
                        throw new Error("Can not get the movie clip, please make sure the version of the resource compatible with app version!");
                    }
                }
            }
            else if (nativeTextureAtlas.bitmapData) 
            {
                var subTextureRegion:Rectangle = nativeTextureAtlas.getRegion(fullName);
                if (subTextureRegion != null) 
                {
                    var subTextureFrame:Rectangle = nativeTextureAtlas.getFrame(fullName);
                    if (subTextureFrame != null) 
                    {
                        pivotX += subTextureFrame.x;
                        pivotY += subTextureFrame.y;
                    }
                    
                    var displayShape:Shape = new Shape();
                    _helpMatrix.a = 1;
                    _helpMatrix.b = 0;
                    _helpMatrix.c = 0;
                    _helpMatrix.d = 1;
                    _helpMatrix.scale(1 / nativeTextureAtlas.scale, 1 / nativeTextureAtlas.scale);
                    _helpMatrix.tx = -pivotX - subTextureRegion.x;
                    _helpMatrix.ty = -pivotY - subTextureRegion.y;
                    
                    displayShape.graphics.beginBitmapFill(nativeTextureAtlas.bitmapData, _helpMatrix, false, fillBitmapSmooth);
                    displayShape.graphics.drawRect(-pivotX, -pivotY, subTextureRegion.width, subTextureRegion.height);
                    
                    return displayShape;
                }
            }
            else 
            {
                throw new Error();
            }
        }
        return null;
    }
}
