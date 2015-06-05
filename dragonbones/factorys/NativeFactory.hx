/**
 * Copyright 2012-2013. DragonBones. All Rights Reserved.
 */
package dragonbones.factorys;
import dragonbones.Armature;
import dragonbones.display.NativeSlot;
import dragonbones.Slot;
import dragonbones.textures.ITextureAtlas;
import dragonbones.textures.NativeTextureAtlas;
import openfl.display.DisplayObject;
import openfl.display.Shape;
import openfl.display.Sprite;
import openfl.errors.Error;
import openfl.geom.Matrix;

class NativeFactory extends BaseFactory {
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
    
    override function generateTextureAtlas(content:Dynamic, textureAtlasRawData:Dynamic):ITextureAtlas {
        var textureAtlas:NativeTextureAtlas = new NativeTextureAtlas(content, textureAtlasRawData, 1, false);
        return textureAtlas;
    }
    
    override function generateArmature():Armature return new Armature(new Sprite());
    
    override function generateSlot():Slot return new NativeSlot();
    
    override function generateDisplay(textureAtlas:Dynamic, fullName:String, pivotX:Float, pivotY:Float):Dynamic {
        var nativeTextureAtlas:NativeTextureAtlas;
        if (Std.is(textureAtlas, NativeTextureAtlas)) {
            nativeTextureAtlas = cast(textureAtlas, NativeTextureAtlas);
        }
        
        if (nativeTextureAtlas != null) {
            var movieClip = nativeTextureAtlas.movieClip;
            if (useBitmapDataTexture && movieClip != null) {
                nativeTextureAtlas.movieClipToBitmapData();
            }
            
            if (!useBitmapDataTexture && movieClip != null && movieClip.totalFrames >= 3) {
                movieClip.gotoAndStop(movieClip.totalFrames);
                movieClip.gotoAndStop(fullName);
                if (movieClip.numChildren > 0) {
                    try {
                        var displaySWF:DisplayObject = movieClip.getChildAt(0);
                        displaySWF.x = 0;
                        displaySWF.y = 0;
                        return displaySWF;
                    } catch (e:Error) {
                        throw new Error("Can not get the movie clip, please make sure the version of the resource compatible with app version!");
                    }
                }
            } else if (nativeTextureAtlas.bitmapData != null) {
                var subTextureRegion = nativeTextureAtlas.getRegion(fullName);
                if (subTextureRegion != null) {
                    var subTextureFrame = nativeTextureAtlas.getFrame(fullName);
                    if (subTextureFrame != null) {
                        pivotX += subTextureFrame.x;
                        pivotY += subTextureFrame.y;
                    }
                    var result = new Shape();
                    _helpMatrix.a = 1;
                    _helpMatrix.b = 0;
                    _helpMatrix.c = 0;
                    _helpMatrix.d = 1;
                    _helpMatrix.scale(1 / nativeTextureAtlas.scale, 1 / nativeTextureAtlas.scale);
                    _helpMatrix.tx = -pivotX - subTextureRegion.x;
                    _helpMatrix.ty = -pivotY - subTextureRegion.y;
                    result.graphics.beginBitmapFill(nativeTextureAtlas.bitmapData, _helpMatrix, false, fillBitmapSmooth);
                    result.graphics.drawRect(-pivotX, -pivotY, subTextureRegion.width, subTextureRegion.height);
                    return result;
                }
            }
            else throw new Error();
        }
        return null;
    }
}