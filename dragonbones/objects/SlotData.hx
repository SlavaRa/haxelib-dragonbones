package dragonbones.objects;
import openfl.errors.ArgumentError;

@:final class SlotData
{
    public var displayDataList(get, never):Array<DisplayData>;

    public var name:String;
    public var parent:String;
    public var zOrder:Float;
    public var blendMode:String;
    
    var _displayDataList:Array<DisplayData>;
    function get_DisplayDataList():Array<DisplayData>
    {
        return _displayDataList;
    }
    
    public function new()
    {
        _displayDataList = new Array<DisplayData>();
        zOrder = 0;
    }
    
    public function dispose():Void
    {
        var i:Int = _displayDataList.length;
        while (i-->0)
        {
            _displayDataList[i].dispose();
        }
        _displayDataList.fixed = false;
        _displayDataList.length = 0;
        _displayDataList = null;
    }
    
    public function addDisplayData(displayData:DisplayData):Void
    {
        if (displayData == null) 
        {
            throw new ArgumentError();
        }
        if (Lambda.indexOf(_displayDataList, displayData) < 0) 
        {
            _displayDataList.fixed = false;
            _displayDataList[_displayDataList.length] = displayData;
            _displayDataList.fixed = true;
        }
        else 
        {
            throw new ArgumentError();
        }
    }
    
    public function getDisplayData(displayName:String):DisplayData
    {
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
