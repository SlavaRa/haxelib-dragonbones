package dragonbones.factorys;
import dragonbones.textures.ITextureAtlas;
import dragonbones.textures.StarlingTextureAtlas;
import dragonbones.utils.ConstValues;
import flash.display.BitmapData;
import flash.display.MovieClip;
import flash.geom.Matrix;
import flash.xml.XML;
import starling.core.Starling;
import starling.display.Image;
import starling.textures.SubTexture;
import starling.textures.Texture;
import starling.textures.TextureAtlas;

/**
 * @author SlavaRa
 */
class StarlingFactory extends BaseFactory{

	static var helpMatrix = new Matrix();
	
	public function new() {
		super();
		generateMipMaps = true;
		optimizeForRenderToTexture = true;
		scaleForTex = 1;
	}
	
	public var generateMipMaps:Bool;
	public var optimizeForRenderToTexture:Bool;
	public var scaleForTex:Float;
	
	override function createTextureDisplay(texAtlas:ITextureAtlas, fullName:String, pivotX:Int = 0, pivotY:Int = 0):Dynamic {
		var texture:Texture = cast(texAtlas, TextureAtlas).getTexture(fullName);
		if(Std.is(texture, SubTexture)) {
			var image = new Image(cast(texture, SubTexture));
			image.pivotX = pivotX;
			image.pivotY = pivotY;
			return image;
		}
		return null;
	}
	
	override function createTextureAtlas(content:Dynamic, textureAtlasXML:Dynamic):Dynamic {
		var texAtlasXml = cast(textureAtlasXML, Xml);
		var tex:Texture = null;
		var bitmapData:BitmapData = null;
		if(Std.is(content, BitmapData)) {
			bitmapData = cast(content, BitmapData);
			tex = Texture.fromBitmapData(bitmapData, generateMipMaps, optimizeForRenderToTexture, scaleForTex);
		} else if(Std.is(content, MovieClip)) {
			var width = Std.parseInt(texAtlasXml.get(ConstValues.A_WIDTH)) * Std.int(scaleForTex);
			var height = Std.parseInt(texAtlasXml.get(ConstValues.A_HEIGHT)) * Std.int(scaleForTex);
			
			helpMatrix.identity();
			helpMatrix.scale(scaleForTex, scaleForTex);
			helpMatrix.tx = 0;
			helpMatrix.ty = 0;
			
			var movieClip = cast(content, MovieClip);
			movieClip.gotoAndStop(1);
			bitmapData = new BitmapData(width, height, true, 0xFF00FF);
			bitmapData.draw(movieClip, helpMatrix);
			movieClip.gotoAndStop(movieClip.totalFrames);
			tex = Texture.fromBitmapData(bitmapData, generateMipMaps, optimizeForRenderToTexture, scaleForTex);
		} else {
			//TODO: ?
		}
		
		var texAtlas = new StarlingTextureAtlas(tex, new XML(texAtlasXml.toString()));
		if(Starling.handleLostContext) {
			texAtlas.bitmapData = bitmapData;
		} else {
			bitmapData.dispose();
		}
		return texAtlas;
	}
	
}