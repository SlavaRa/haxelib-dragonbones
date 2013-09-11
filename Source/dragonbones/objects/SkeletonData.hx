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
		armatureDataList = DisposeUtils.dispose(armatureDataList);
		animationDataList = DisposeUtils.dispose(animationDataList);
		displayDataList = DisposeUtils.dispose(displayDataList);
	}
	
	public function getArmatureData(name:String):ArmatureData {
		return name != null ? cast armatureDataList.getDataByName(name) : null;
	}
	
	public function getAnimationData(name:String):AnimationData {
		return name != null ? cast animationDataList.getDataByName(name) : null;
	}
	
	public function getDisplayData(name:String):DisplayData {
		return name != null ? cast displayDataList.getDataByName(name) : null;
	}
}