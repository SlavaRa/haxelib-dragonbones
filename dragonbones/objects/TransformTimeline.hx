package dragonbones.objects;


import openfl.geom.Point;

@:final class TransformTimeline extends Timeline
{
    public var name:String;
    public var transformed:Bool;
    
    public var originTransform:DBTransform;
    public var originPivot:Point;
    
    public var offset:Float;
    
    public var timelineCached:TimelineCached;
    
    var _slotTimelineCachedMap:Dynamic;
    
    public function new()
    {
        super();
        
        _slotTimelineCachedMap = { };
        
        originTransform = new DBTransform();
        
        originTransform.scaleX = 1;
        originTransform.scaleY = 1;
        originPivot = new Point();
        offset = 0;
        
        timelineCached = new TimelineCached();
    }
    
    public function getSlotTimelineCached(slotName:String):TimelineCached
    {
        var slotTimelineCached:TimelineCached = Reflect.field(_slotTimelineCachedMap, slotName);
        if (slotTimelineCached == null) 
        {
            Reflect.setField(_slotTimelineCachedMap, slotName, 
            slotTimelineCached = new TimelineCached());
        }
        return slotTimelineCached;
    }
    
    public override function dispose():Void
    {
        super.dispose();
        
        timelineCached.dispose();
        
        for (slotTimelineCached/* AS3HX WARNING could not determine type for var: slotTimelineCached exp: EIdent(_slotTimelineCachedMap) type: Dynamic */ in _slotTimelineCachedMap)
        {
            slotTimelineCached.dispose();
        }  //_slotTimelineCachedMap.clear();  
        
        
        originTransform = null;
        originPivot = null;
        
        timelineCached = null;
        
        _slotTimelineCachedMap = null;
    }
}
