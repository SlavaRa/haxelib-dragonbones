package dragonbones.objects;
import dragonbones.utils.DisposeUtils;
import dragonbones.utils.IDisposable;

/**
 * @author SlavaRa
 */
class SkeletonData implements IDisposable{

	public function new() {
		armatureDataList = new DataList();
		animationDataList = new DataList();
		displayDataList = new DataList();
	}
	
	public var name:String;
	public var frameRate:Int;
	public var armatureDataList(default, null):DataList;
	public var animationDataList(default, null):DataList;
	public var displayDataList(default, null):DataList;
	
	public function dispose() {
		DisposeUtils.dispose(armatureDataList);
		DisposeUtils.dispose(animationDataList);
		DisposeUtils.dispose(displayDataList);
		armatureDataList = null;
		animationDataList = null;
		displayDataList = null;
	}
	
	public function getArmatureData(name:String):ArmatureData {
		if (name == null) {
			return null;
		}
		return cast armatureDataList.getDataByName(name);
	}
	
	public function getAnimationData(name:String):AnimationData {
		if (name == null) {
			return null;
		}
		return cast animationDataList.getDataByName(name);
	}
	
	public function getDisplayData(name:String):DisplayData {
		if (name == null) {
			return null;
		}
		return cast displayDataList.getDataByName(name);
	}
}