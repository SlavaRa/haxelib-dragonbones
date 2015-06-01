package dragonbones.objects;
import openfl.errors.ArgumentError;

@:final class SkinData
{
    public var slotDataList(get, never):Array<SlotData>;

    public var name:String;
    
    var _slotDataList:Array<SlotData>;
    function get_SlotDataList():Array<SlotData>
    {
        return _slotDataList;
    }
    
    public function new()
    {
        _slotDataList = new Array<SlotData>();
    }
    
    public function dispose():Void
    {
        var i:Int = _slotDataList.length;
        while (i-->0)
        {
            _slotDataList[i].dispose();
        }
        _slotDataList.fixed = false;
        _slotDataList.length = 0;
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
            _slotDataList.fixed = false;
            _slotDataList[_slotDataList.length] = slotData;
            _slotDataList.fixed = true;
        }
        else 
        {
            throw new ArgumentError();
        }
    }
}
