package dragonbones.objects;
import openfl.errors.ArgumentError;

class Timeline
{
    public var frameList(get, never):Array<Frame>;

    var _frameList:Array<Frame>;
    function get_FrameList():Array<Frame>
    {
        return _frameList;
    }
    
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
        while (i-->0)
        {
            _frameList[i].dispose();
        }
        _frameList.fixed = false;
        _frameList.length = 0;
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
            _frameList.fixed = false;
            _frameList[_frameList.length] = frame;
            _frameList.fixed = true;
        }
        else 
        {
            throw new ArgumentError();
        }
    }
}

