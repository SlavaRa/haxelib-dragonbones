package dragonbones.objects;


import openfl.geom.Point;


@:final class DisplayData
{
    public static inline var ARMATURE:String = "armature";
    public static inline var IMAGE:String = "image";
    
    public var name:String;
    public var type:String;
    public var transform:DBTransform;
    public var pivot:Point;
    
    public function new()
    {
        transform = new DBTransform();
    }
    
    public function dispose():Void
    {
        transform = null;
        pivot = null;
    }
}
