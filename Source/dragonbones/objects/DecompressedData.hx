package dragonbones.objects;
import dragonbones.utils.IDisposable;
import flash.utils.ByteArray;

/**
 * @author SlavaRa
 */
class DecompressedData implements IDisposable{

	public function new(skeletonXml:Xml, texAtlasXml:Xml, texBytes:ByteArray) {
		this.skeletonXml = skeletonXml;
		this.texAtlasXml = texAtlasXml;
		this.texBytes = texBytes;
	}
	
	public var skeletonXml:Xml;
	public var texAtlasXml:Xml;
	public var texBytes:ByteArray;
	
	public function dispose() {
		skeletonXml = null;
		texAtlasXml = null;
		texBytes = null;
	}
	
	public function toString():String {
		var s = "";
		s += "\n[DecompressedData";
		s += "\n, skeletonXml = " + skeletonXml.toString(); 
		s += "\n, texAtlasXml = " + texAtlasXml.toString();
		s += "\n, texBytes.length = " + Std.string(texBytes.length);
		return s;
	}
}