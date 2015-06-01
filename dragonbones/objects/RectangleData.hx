package dragonbones.objects;


import openfl.geom.Point;

@:final class RectangleData implements IAreaData
{
    public var name:String;
    
    public var width:Float;
    public var height:Float;
    public var transform:DBTransform;
    public var pivot:Point;
    
    public function new()
    {
        width = 0;
        height = 0;
        transform = new DBTransform();
        pivot = new Point();
    }
    
    public function dispose():Void
    {
        transform = null;
        pivot = null;
    }
}
