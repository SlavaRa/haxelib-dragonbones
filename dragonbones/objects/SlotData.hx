package dragonbones.objects;
import openfl.display.BlendMode;
import openfl.errors.ArgumentError;

@:final class SlotData
{
    public var displayDataList(get, never):Array<DisplayData>;
    var _displayDataList:Array<DisplayData>;
    function get_displayDataList() return _displayDataList;

    public var name:String;
    public var parent:String;
    public var zOrder:Float;
    public var blendMode:BlendMode;
    
    public function new() {
        _displayDataList = [];
        zOrder = 0;
    }
    
    public function dispose():Void {
        var i:Int = _displayDataList.length;
        while (i-->0) _displayDataList[i].dispose();
        _displayDataList = null;
    }
    
    public function addDisplayData(displayData:DisplayData):Void {
        if (displayData == null) throw new ArgumentError();
        if (!Lambda.has(_displayDataList, displayData)) {
            _displayDataList[_displayDataList.length] = displayData;
        }
        else throw new ArgumentError();
    }
    
    public function getDisplayData(displayName:String):DisplayData {
        var i:Int = _displayDataList.length;
        while (i-->0)
        {
            if (_displayDataList[i].name == displayName) 
            {
                return _displayDataList[i];
            }
        }
        return null;
    }
}