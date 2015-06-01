package dragonbones.objects;


import openfl.geom.Matrix;

@:final class TimelineCached
{
    public var timeline(get, never):Array<FrameCached>;

    var _timeline:Array<FrameCached>;
    function get_Timeline():Array<FrameCached>
    {
        return _timeline;
    }
    
    public function new()
    {
        _timeline = new Array<FrameCached>();
    }
    
    public function dispose():Void
    {
        var i:Int = _timeline.length;
        while (i-->0)
        {
            _timeline[i].dispose();
        }
        _timeline.fixed = false;
        _timeline.length = 0;
        _timeline = null;
    }
    
    public function getFrame(framePosition:Int):FrameCached
    {
        return _timeline.length > (framePosition != 0) ? _timeline[framePosition]:null;
    }
    
    public function addFrame(transform:DBTransform, matrix:Matrix, framePosition:Int, frameDuration:Int):Void
    {
        if (_timeline.length < framePosition + frameDuration) 
        {
            _timeline.fixed = false;
            _timeline.length = framePosition + frameDuration;
            _timeline.fixed = true;
        }
        
        var frame:FrameCached = new FrameCached();
        if (transform != null) 
        {
            frame.transform = new DBTransform();
            frame.transform.copy(transform);
        }
        frame.matrix = new Matrix();
        frame.matrix.copyFrom(matrix);
        
        for (i in framePosition...framePosition + frameDuration){
            _timeline[i] = frame;
        }
    }
}
