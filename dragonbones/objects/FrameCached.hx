package dragonbones.objects;


import openfl.geom.Matrix;


class FrameCached
{
    public var transform:DBTransform;
    public var matrix:Matrix;
    
    public function new()
    {
        
        
    }
    
    public function dispose():Void
    {
        transform = null;
        matrix = null;
    }
}
