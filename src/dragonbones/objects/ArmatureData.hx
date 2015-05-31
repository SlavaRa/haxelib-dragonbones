package dragonbones.objects;
import dragonbones.utils.DisposeUtils;
import dragonbones.utils.IDisposable;

/**
 * @author SlavaRa
 */
class ArmatureData implements IDisposable{

	public function new() {
		boneDataList = new DataList();
	}
	
	public var boneDataList(default, null):DataList;
	
	public function dispose() {
		boneDataList = DisposeUtils.dispose(boneDataList);
	}
	
	public function getBoneData(name:String):BoneData {
		return name != null ? cast boneDataList.getDataByName(name) : null;
	}
	
	public function updateBoneList() {
		var sortList:Array<Dynamic> = [];
		for (name in boneDataList.names) {
			var boneData:BoneData = cast boneDataList.getDataByName(name);
			if (boneData != null) {
				var levelValue = boneData.node[Node.z];
				var level = 0;
				while(boneData != null) {
					level++;
					levelValue += 1000 * level;
					boneData = getBoneData(boneData.parent);
				}
				sortList.push({level:levelValue, name:name});
			}
		}
		
		if (sortList.length == 0) {
			return;
		}
		
		sortList.sort(compareLevel);
		boneDataList.names = [];
		for (item in sortList) {
			boneDataList.names.push(item.name);
		}
	}
	
	inline function compareLevel(a,b):Int {
		return Reflect.compare(a.level, b.level);
	}
	
}