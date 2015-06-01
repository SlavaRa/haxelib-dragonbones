package dragonbones.objects;
import dragonbones.objects.Timeline;
import dragonbones.objects.TransformTimeline;
import openfl.errors.ArgumentError;

@:final class AnimationData extends Timeline
{
    public var timelineList(get, never):Array<TransformTimeline>;

    public var name:String;
    public var frameRate:Int;
    public var fadeTime:Float;
    public var playTimes:Int;
    //use frame tweenEase, NaN
    //overwrite frame tweenEase, [-1, 0):ease in, 0:line easing, (0, 1]:ease out, (1, 2]:ease in out
    public var tweenEasing:Float;
    public var autoTween:Bool;
    public var lastFrameDuration:Int;
    
    public var hideTimelineNameMap:Array<String>;
    
    var _timelineList:Array<TransformTimeline>;
    function get_TimelineList():Array<TransformTimeline>
    {
        return _timelineList;
    }
    
    public function new()
    {
        super();
        fadeTime = 0;
        playTimes = 0;
        autoTween = true;
        tweenEasing = Math.Nan;
        hideTimelineNameMap = new Array<String>();
        hideTimelineNameMap.fixed = true;
        
        _timelineList = new Array<TransformTimeline>();
        _timelineList.fixed = true;
    }
    
    public override function dispose():Void
    {
        super.dispose();
        
        hideTimelineNameMap.fixed = false;
        hideTimelineNameMap.length = 0;
        hideTimelineNameMap = null;
        
        _timelineList.fixed = false;
        for (timeline in _timelineList)
        {
            timeline.dispose();
        }
        _timelineList.fixed = false;
        _timelineList.length = 0;
        _timelineList = null;
    }
    
    public function getTimeline(timelineName:String):TransformTimeline
    {
        var i:Int = _timelineList.length;
        while (i-->0)
        {
            if (_timelineList[i].name == timelineName) 
            {
                return _timelineList[i];
            }
        }
        return null;
    }
    
    public function addTimeline(timeline:TransformTimeline):Void
    {
        if (timeline == null) 
        {
            throw new ArgumentError();
        }
        
        if (Lambda.indexOf(_timelineList, timeline) < 0) 
        {
            _timelineList.fixed = false;
            _timelineList[_timelineList.length] = timeline;
            _timelineList.fixed = true;
        }
    }
}
