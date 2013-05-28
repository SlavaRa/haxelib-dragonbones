package dragonbones.objects;
import dragonbones.utils.DisposeUtils;
import dragonbones.utils.IDisposable;

/**
 * @author SlavaRa
 */
class MovementData implements IDisposable{

	public function new() {
		duration = 0;
		durationTo = 0;
		durationTween = 0;
		movementBoneDataList = new DataList();
		movementFrameList = [];
	}
	
	public var duration:Float;
	public var durationTo:Float;
	public var durationTween:Float;
	public var loop:Bool;
	public var tweenEasing:Float;
	public var movementBoneDataList(default, null):DataList;
	public var movementFrameList(default, null):Array<MovementFrameData>;
	
	public function dispose() {
		DisposeUtils.dispose(movementBoneDataList);
		movementBoneDataList = null;
		movementFrameList = null;
	}
	
	public function getMovementBoneData(name:String):MovementBoneData {
		if (name == null) {
			return null;
		}
		return cast movementBoneDataList.getDataByName(name);
	}
}