package dragonbones.textures;
import openfl.geom.Rectangle;

@:final class TextureData
{
    public var region:Rectangle;
    public var frame:Rectangle;
    public var rotated:Bool;
    
    public function new(region:Rectangle, frame:Rectangle, rotated:Bool)
    {
        this.region = region;
        this.frame = frame;
        this.rotated = rotated;
    }
}
