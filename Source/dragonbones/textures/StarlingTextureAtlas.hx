package dragonbones.textures;

import dragonbones.utils.ConstValues;
import flash.xml.XML;
import nme.display.BitmapData;
import nme.geom.Rectangle;
import starling.textures.Texture;
import starling.textures.TextureAtlas;

/**
 * @author SlavaRa
 */
class StarlingTextureAtlas extends TextureAtlas #if !haxe3 , #end implements ITextureAtlas{

	public function new(texture:Texture, textureAtlasXML:XML = null, isDifferentXML:Bool = false) {
		if(texture != null) {
			_scale = texture.scale;
			_isDifferentXML = isDifferentXML;
		}
		super(texture, textureAtlasXML);
		if(textureAtlasXML != null) {
			name = textureAtlasXML.attribute(ConstValues.A_NAME).toString();
		}
		_subTextureDic = new Map();
	}
	
	public var bitmapData:BitmapData;
	var _subTextureDic:Map<String, Texture>;
	var _isDifferentXML:Bool;
	var _scale:Float;
	
	//{ region INTERFACE dragonbones.textures.ITextureAtlas
	
	public var name(default, null):String;
	
	public override function dispose() {
		super.dispose();
		
		for (i in _subTextureDic) {
			i.dispose();
		}
		
		_subTextureDic = null;
		
		if(bitmapData != null) {
			bitmapData.dispose();
			bitmapData = null;
		}
	}
	
	//}
	
	public override function getTexture(name:String):Texture {
		var texture:Texture = _subTextureDic.get(name);
		if(texture == null) {
			texture = super.getTexture(name);
			if(texture != null) {
				_subTextureDic.set(name, texture);
			}
		}
		return texture;
	}
	
	function parseAtlasXml(atlasXml:Xml) {
		var scale:Float = _isDifferentXML ? _scale : 1;
		
		for (subTexture in atlasXml.firstElement().elementsNamed("SubTexture")) {
			var name:String 		= subTexture.get("name");
			var x:Float 			= Std.parseFloat(subTexture.get("x")) 			/ scale;
			var y:Float 			= Std.parseFloat(subTexture.get("y")) 			/ scale;
			var width:Float 		= Std.parseFloat(subTexture.get("width")) 		/ scale;
			var height:Float 		= Std.parseFloat(subTexture.get("height")) 		/ scale;
			var frameX:Float 		= Std.parseFloat(subTexture.get("frameX")) 		/ scale;
			var frameY:Float 		= Std.parseFloat(subTexture.get("frameY")) 		/ scale;
			var frameWidth:Float 	= Std.parseFloat(subTexture.get("frameWidth")) 	/ scale;
			var frameHeight:Float 	= Std.parseFloat(subTexture.get("frameHeight")) / scale;
			
			//1.4
			var region:SubTextureData = new SubTextureData(x, y, width, height);
			region.pivotX = Std.parseInt(subTexture.get(ConstValues.A_PIVOT_X));
			region.pivotY = Std.parseInt(subTexture.get(ConstValues.A_PIVOT_Y));
			
			var frame:Rectangle = null;
			if((frameWidth > 0) && (frameHeight > 0)) {
				frame = new Rectangle(frameX, frameY, frameWidth, frameHeight);
			}
			
			addRegion(name, region, frame);
		}
	}
	
}