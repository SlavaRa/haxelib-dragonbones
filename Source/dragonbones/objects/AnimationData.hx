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
		movementDataList = DisposeUtils.dispose(movementDataList);
	}
	
	public function getMovementData(name:String):MovementData {
		return name != null ? cast movementDataList.getDataByName(name) : null;
	}
	
}