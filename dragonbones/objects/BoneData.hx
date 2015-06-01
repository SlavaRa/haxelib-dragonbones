package dragonbones.objects;
import dragonbones.objects.DBTransform;
import dragonbones.objects.IAreaData;
import openfl.errors.ArgumentError;

@:final class BoneData
{
    public var areaDataList(get, never):Array<IAreaData>;

    public var name:String;
    public var parent:String;
    public var length:Float;
    
    public var global:DBTransform;
    public var transform:DBTransform;
    
    public var inheritScale:Bool;
    public var inheritRotation:Bool;
    
    var _areaDataList:Array<IAreaData>;
    function get_AreaDataList():Array<IAreaData>
    {
        return _areaDataList;
    }
    
    public function new()
    {
        length = 0;
        global = new DBTransform();
        transform = new DBTransform();
        inheritRotation = true;
        inheritScale = false;
        
        _areaDataList = new Array<IAreaData>();
    }
    
    public function dispose():Void
    {
        global = null;
        transform = null;
        
        if (_areaDataList != null) 
        {
            for (areaData in _areaDataList)
            {
                areaData.dispose();
            }
            _areaDataList.fixed = false;
            _areaDataList.length = 0;
            _areaDataList = null;
        }
    }
    
    public function getAreaData(areaName:String):IAreaData
    {
        if (areaName == null && _areaDataList.length > 0) 
        {
            return _areaDataList[0];
        }
        var i:Int = _areaDataList.length;
        while (i-->0)
        {
            if (_areaDataList[i]["name"] == areaName) 
            {
                return _areaDataList[i];
            }
        }
        return null;
    }
    
    public function addAreaData(areaData:IAreaData):Void
    {
        if (areaData == null) 
        {
            throw new ArgumentError();
        }
        
        if (Lambda.indexOf(_areaDataList, areaData) < 0) 
        {
            _areaDataList.fixed = false;
            _areaDataList[_areaDataList.length] = areaData;
            _areaDataList.fixed = true;
        }
    }
}
