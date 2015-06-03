package dragonbones.objects;
import openfl.errors.ArgumentError;

@:final class SkinData
{
    public var slotDataList(get, never):Array<SlotData>;
    var _slotDataList:Array<SlotData>;
    function get_slotDataList() return _slotDataList;

    public var name:String;
    
    public function new()
    {
        _slotDataList = new Array<SlotData>();
    }
    
    public function dispose():Void {
        var i:Int = _slotDataList.length;
        while (i-->0) _slotDataList[i].dispose();
        _slotDataList = null;
    }
    
    public function getSlotData(slotName:String):SlotData
    {
        var i:Int = _slotDataList.length;
        while (i-->0)
        {
            if (_slotDataList[i].name == slotName) 
            {
                return _slotDataList[i];
            }
        }
        return null;
    }
    
    public function addSlotData(slotData:SlotData):Void
    {
        if (slotData == null) 
        {
            throw new ArgumentError();
        }
        
        if (Lambda.indexOf(_slotDataList, slotData) < 0) 
        {
            _slotDataList[_slotDataList.length] = slotData;
        }
        else 
        {
            throw new ArgumentError();
        }
    }
}
