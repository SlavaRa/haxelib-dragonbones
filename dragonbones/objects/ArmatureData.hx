package dragonbones.objects;
import dragonbones.objects.BoneData;
import dragonbones.objects.IAreaData;
import dragonbones.objects.SkinData;
import openfl.errors.ArgumentError;

@:final class ArmatureData {
    public var boneDataList(default, null):Array<BoneData>;
    public var skinDataList(default, null):Array<SkinData>;
    public var animationDataList(default, null):Array<AnimationData>;
    public var areaDataList(default, null):Array<IAreaData>;
    public var name:String;
	
    public function new() {
        boneDataList = [];
        skinDataList = [];
        animationDataList = [];
        areaDataList = [];
    }
    
    public function dispose():Void {
        for(it in boneDataList) it.dispose();
        for(it in skinDataList) it.dispose();
        for(it in animationDataList) it.dispose();
        boneDataList = null;
        skinDataList = null;
        animationDataList = null;
		areaDataList = null;
    }
    
    public function getBoneData(boneName:String):BoneData {
        var i:Int = boneDataList.length;
        while (i-->0) {
            if (boneDataList[i].name == boneName) {
                return boneDataList[i];
            }
        }
        return null;
    }
    
    public function getSkinData(skinName:String):SkinData {
        if (skinName == null && skinDataList.length > 0) {
            return skinDataList[0];
        }
        var i:Int = skinDataList.length;
        while (i-->0) {
            if (skinDataList[i].name == skinName) {
                return skinDataList[i];
            }
        }
        return null;
    }
    
    public function getAnimationData(animationName:String):AnimationData {
        var i:Int = animationDataList.length;
        while (i-->0) {
            if (animationDataList[i].name == animationName) {
                return animationDataList[i];
            }
        }
        return null;
    }
    
    public function addBoneData(boneData:BoneData):Void {
        if (boneData == null) throw new ArgumentError();
        if (Lambda.has(boneDataList, boneData)) throw new ArgumentError();
        boneDataList[boneDataList.length] = boneData;
    }
    
    public function addSkinData(skinData:SkinData):Void {
        if (skinData == null) throw new ArgumentError();
        if (Lambda.has(skinDataList, skinData)) throw new ArgumentError();
        skinDataList[skinDataList.length] = skinData;
    }
    
    public function addAnimationData(animationData:AnimationData):Void {
        if (animationData == null) throw new ArgumentError();
        if (Lambda.has(animationDataList, animationData)) return;
        animationDataList[animationDataList.length] = animationData;
    }
    
    public function sortBoneDataList():Void
    {
        var i:Int = boneDataList.length;
        if (i == 0) return;
        var helpArray:Array<Dynamic> = [];
        while (i-->0)
        {
            var boneData:BoneData = boneDataList[i];
            var level:Int = 0;
            var parentData:BoneData = boneData;
            while (parentData != null)
            {
                level++;
                parentData = getBoneData(parentData.parent);
            }
            helpArray[i] = [level, boneData];
        }
        
        helpArray.sortOn("0", Array.NUMERIC);
        
        i = helpArray.length;
        while (i-->0)
        {
            boneDataList[i] = helpArray[i][1];
        }
    }
    
    public function getAreaData(areaName:String):IAreaData {
        if (areaName == null && areaDataList.length > 0) return areaDataList[0];
		for(it in areaDataList) {
            if (Reflect.getProperty(it, "name") == areaName) {
                return it;
            }
        }
        return null;
    }
    
    public function addAreaData(areaData:IAreaData):Void {
        if (areaData == null) throw new ArgumentError();
        if (Lambda.has(areaDataList, areaData)) return;
        areaDataList[areaDataList.length] = areaData;
    }
}