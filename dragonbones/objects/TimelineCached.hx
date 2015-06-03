package dragonbones.objects;
import openfl.geom.Matrix;

@:final class TimelineCached
{
    public var timeline(get, never):Array<FrameCached>;

    var _timeline:Array<FrameCached>;
    function get_timeline():Array<FrameCached>
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
        while (i-->0) _timeline[i].dispose();
        _timeline = null;
    }
    
    public function getFrame(framePosition:Int):FrameCached
    {
        return framePosition >= 0 && framePosition < _timeline.length ? _timeline[framePosition]:null;
    }
    
    public function addFrame(transform:DBTransform, matrix:Matrix, framePosition:Int, frameDuration:Int):Void
    {
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
