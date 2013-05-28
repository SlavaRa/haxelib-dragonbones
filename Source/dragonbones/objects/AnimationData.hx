package dragonbones.objects;
import dragonbones.utils.DisposeUtils;
import dragonbones.utils.IDisposable;

/**
 * @author SlavaRa
 */
class AnimationData implements IDisposable {

	public function new() {
		movementDataList = new DataList();
	}
	
	public var movementDataList(default, null):DataList;
	
	public function dispose() {
		DisposeUtils.dispose(movementDataList);
		movementDataList = null;
	}
	
	public function getMovementData(name:String):MovementData {
		if (name == null) {
			return null;
		}
		return cast movementDataList.getDataByName(name);
	}
	
}