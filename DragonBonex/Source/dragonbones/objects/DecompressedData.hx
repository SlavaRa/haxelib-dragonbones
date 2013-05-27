package dragonbones.objects;
import dragonbones.utils.IDisposable;
import nme.utils.ByteArray;

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
}