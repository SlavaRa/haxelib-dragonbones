package dragonbones.objects;
import openfl.errors.ArgumentError;

class Timeline
{
    public var frameList(get, never):Array<Frame>;
    var _frameList:Array<Frame>;
    function get_frameList() return _frameList;
    
    public var duration:Int;
    public var scale:Float;
    
    public function new()
    {
        _frameList = new Array<Frame>();
        duration = 0;
        scale = 1;
    }
    
    public function dispose():Void
    {
        var i:Int = _frameList.length;
        while (i-->0) _frameList[i].dispose();
        _frameList = null;
    }
    
    public function addFrame(frame:Frame):Void
    {
        if (frame == null) 
        {
            throw new ArgumentError();
        }
        
        if (Lambda.indexOf(_frameList, frame) < 0) 
        {
            _frameList[_frameList.length] = frame;
        }
        else 
        {
            throw new ArgumentError();
        }
    }
}

