package dragonbones.factorys;
import dragonbones.Armature;
import dragonbones.Bone;
import dragonbones.display.DisplayBridge;
import dragonbones.textures.ITextureAtlas;
import dragonbones.textures.StarlingTextureAtlas;
import dragonbones.textures.SubTextureData;
import dragonbones.utils.ConstValues;
import flash.xml.XML;
import nme.display.BitmapData;
import nme.display.MovieClip;
import nme.geom.Matrix;
import nme.geom.Rectangle;
import starling.core.Starling;
import starling.display.Image;
import starling.display.Sprite;
import starling.textures.SubTexture;
import starling.textures.Texture;
import starling.textures.TextureAtlas;

/**
 * @author SlavaRa
 */
class StarlingFactory extends BaseFactory{

	static var helpMatrix:Matrix = new Matrix();
	
	public function new() {
		super();
		generateMipMaps = true;
		optimizeForRenderToTexture = true;
		scaleForTex = 1;
	}
	
	public var generateMipMaps:Bool;
	public var optimizeForRenderToTexture:Bool;
	public var scaleForTex:Float;
	
	override function createArmature():Armature {
		return new Armature(new Sprite());
	}
	
	override function createBone():Bone {
		return new Bone(new DisplayBridge());
	}
	
	override function createTextureDisplay(texAtlas:ITextureAtlas, fullName:String, pivotX:Int = 0, pivotY:Int = 0):Dynamic {
		//1.4
		if(Std.is(texAtlas, StarlingTextureAtlas)) {
			var starlingTextureAtlas:StarlingTextureAtlas = cast(texAtlas, StarlingTextureAtlas);
			var rectangle:Rectangle = starlingTextureAtlas.getRegion(fullName);
			if(Std.is(rectangle, SubTextureData)){
				var subTextureData:SubTextureData = cast(rectangle, SubTextureData);
				if (pivotX == 0) {
					pivotX = subTextureData.pivotX;
				}
				if (pivotY == 0) {
					pivotY = subTextureData.pivotY;
				}
			}
		}
		
		var texture:Texture = cast(texAtlas, TextureAtlas).getTexture(fullName);
		if(Std.is(texture, SubTexture)) {
			var image:Image = new Image(cast(texture, SubTexture));
			image.pivotX = pivotX;
			image.pivotY = pivotY;
			return image;
		}
		
		return null;
	}
	
	override function createTextureAtlas(content:Dynamic, textureAtlasXML:Dynamic):Dynamic {
		var texAtlasXml:Xml = cast(textureAtlasXML, Xml);
		var tex:Texture = null;
		var bitmapData:BitmapData = null;
		if(Std.is(content, BitmapData)) {
			bitmapData = cast(content, BitmapData);
			tex = Texture.fromBitmapData(bitmapData, generateMipMaps, optimizeForRenderToTexture, scaleForTex);
		} else if(Std.is(content, MovieClip)) {
			var width:Int = Std.parseInt(texAtlasXml.get(ConstValues.A_WIDTH)) * Std.int(scaleForTex);
			var height:Int = Std.parseInt(texAtlasXml.get(ConstValues.A_HEIGHT)) * Std.int(scaleForTex);
			
			helpMatrix.identity();
			helpMatrix.scale(scaleForTex, scaleForTex);
			helpMatrix.tx = 0;
			helpMatrix.ty = 0;
			
			var movieClip:MovieClip = cast(content, MovieClip);
			movieClip.gotoAndStop(1);
			bitmapData = new BitmapData(width, height, true, 0xFF00FF);
			bitmapData.draw(movieClip, helpMatrix);
			movieClip.gotoAndStop(movieClip.totalFrames);
			tex = Texture.fromBitmapData(bitmapData, generateMipMaps, optimizeForRenderToTexture, scaleForTex);
		} else {
			//
		}
		
		var texAtlas:StarlingTextureAtlas = new StarlingTextureAtlas(tex, new XML(texAtlasXml.toString()));
		if(Starling.handleLostContext) {
			texAtlas.bitmapData = bitmapData;
		} else {
			bitmapData.dispose();
		}
		return texAtlas;
	}
	
}