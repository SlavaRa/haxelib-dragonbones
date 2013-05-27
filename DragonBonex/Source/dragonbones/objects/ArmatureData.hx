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
		DisposeUtils.dispose(boneDataList);
		boneDataList = null;
	}
	
	public function getBoneData(name:String):BoneData {
		if (name == null) {
			return null;
		}
		return cast boneDataList.getDataByName(name);
	}
	
	public function updateBoneList() {
		var sortList:Array<Dynamic> = [];
		for (name in boneDataList.names) {
			var boneData:BoneData = cast boneDataList.getDataByName(name);
			if (boneData != null) {
				var levelValue:Float = boneData.node[Node.z];
				var level:Float = 0;
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
	
	function compareLevel(a,b):Int {
		return Reflect.compare(a.level, b.level);
	}
	
}