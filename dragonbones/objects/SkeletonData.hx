package dragonbones.objects;
import openfl.errors.ArgumentError;
import openfl.geom.Point;

class SkeletonData
{

    public var name:String;
    
    var _subTexturePivots:Dynamic;
    
    public var armatureNames(get, never):Array<String>;
    function get_armatureNames():Array<String>
    {
        var nameList:Array<String> = new Array<String>();
        for (armatureData in _armatureDataList)
        {
            nameList[nameList.length] = armatureData.name;
        }
        return nameList;
    }
    
	public var armatureDataList(get, never):Array<ArmatureData>;
    var _armatureDataList:Array<ArmatureData>;
    function get_armatureDataList() return _armatureDataList;
    
    public function new()
    {
        _armatureDataList = new Array<ArmatureData>();
        _subTexturePivots = { };
    }
    
    public function dispose():Void
    {
        for (armatureData in _armatureDataList) armatureData.dispose();
        _armatureDataList = null;
        _subTexturePivots = null;
    }
    
    public function getArmatureData(armatureName:String):ArmatureData
    {
        var i:Int = _armatureDataList.length;
        while (i-->0)
        {
            if (_armatureDataList[i].name == armatureName) 
            {
                return _armatureDataList[i];
            }
        }
        
        return null;
    }
    
    public function addArmatureData(armatureData:ArmatureData):Void
    {
        if (armatureData == null) 
        {
            throw new ArgumentError();
        }
        
        if (Lambda.indexOf(_armatureDataList, armatureData) < 0) 
        {
            _armatureDataList[_armatureDataList.length] = armatureData;
        }
        else 
        {
            throw new ArgumentError();
        }
    }
    
    public function removeArmatureData(armatureData:ArmatureData):Void
    {
        var index:Int = Lambda.indexOf(_armatureDataList, armatureData);
        if (index >= 0) 
        {
            _armatureDataList.splice(index, 1);
        }
    }
    
    public function removeArmatureDataByName(armatureName:String):Void
    {
        var i:Int = _armatureDataList.length;
        while (i-->0)
        {
            if (_armatureDataList[i].name == armatureName) 
            {
                _armatureDataList.splice(i, 1);
            }
        }
    }
    
    public function getSubTexturePivot(subTextureName:String):Point
    {
        return Reflect.field(_subTexturePivots, subTextureName);
    }
    
    public function addSubTexturePivot(x:Float, y:Float, subTextureName:String):Point
    {
        var point:Point = Reflect.field(_subTexturePivots, subTextureName);
        if (point != null) 
        {
            point.x = x;
            point.y = y;
        }
        else 
        {
            Reflect.setField(_subTexturePivots, subTextureName, point = new Point(x, y));
        }
        
        return point;
    }
    
    public function removeSubTexturePivot(subTextureName:String):Void
    {
        if (subTextureName != null) 
        {
			//TODO slavara check this
        }
        else 
        {
            for (subTextureName in Reflect.fields(_subTexturePivots))
            {
				//TODO slavara check this
            }
        }
    }
}