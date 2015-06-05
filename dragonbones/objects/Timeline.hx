package dragonbones.objects;
import openfl.errors.ArgumentError;

class Timeline {
    public var frameList(default, null):Array<Frame>;
    public var duration:Int;
    public var scale:Float;
    
    public function new() {
        frameList = [];
        duration = 0;
        scale = 1;
    }
    
    public function dispose():Void {
        for(it in frameList) it.dispose();
        frameList = null;
    }
    
    public function addFrame(frame:Frame):Void {
        if (frame == null || Lambda.has(frameList, frame)) throw new ArgumentError();
        frameList[frameList.length] = frame;
    }
}