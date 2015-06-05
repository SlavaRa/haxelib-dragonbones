package dragonbones.objects;
import dragonbones.objects.DBTransform;
import dragonbones.objects.IAreaData;
import openfl.errors.ArgumentError;

@:final class BoneData {
    public var areaDataList(default, null):Array<IAreaData>;
    public var name:String;
    public var parent:String;
    public var length:Float;
    public var global:DBTransform;
    public var transform:DBTransform;
    public var inheritScale:Bool;
    public var inheritRotation:Bool;
    
    public function new() {
        length = 0;
        global = new DBTransform();
        transform = new DBTransform();
        inheritRotation = true;
        inheritScale = false;
        areaDataList = new Array<IAreaData>();
    }
    
    public function dispose():Void {
		for(areaData in areaDataList) areaData.dispose();
		areaDataList = null;
        global = null;
        transform = null;
    }
    
    public function getAreaData(areaName:String):IAreaData {
        if(areaName == null && areaDataList.length > 0) return areaDataList[0];
        for(it in areaDataList) {
            if(Reflect.getProperty(it, "name") == areaName) return it;
        }
        return null;
    }
    
    public function addAreaData(areaData:IAreaData):Void {
        if (areaData == null) throw new ArgumentError();
        if (!Lambda.has(areaDataList, areaData)) {
            areaDataList[areaDataList.length] = areaData;
        }
    }
}