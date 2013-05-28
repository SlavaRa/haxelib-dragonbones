package dragonbones.objects;
import dragonbones.utils.DisposeUtils;
import dragonbones.utils.IDisposable;
import haxe.ds.ObjectMap;

/**
 * @author SlavaRa
 */
class DataList implements IDisposable {

	public function new() {
		_data2name = new ObjectMap<Dynamic, String>();
		_name2data = new Map<String, Dynamic>();
		names = [];
	}
	
	public var names:Array<String>;
	var _name2data:Map<String, Dynamic>;
	var _data2name:Map<Dynamic, String>;
	
	public function dispose() {
		for (data in _name2data) {
			var name:String = _data2name.get(data);
			_data2name.remove(data);
			_name2data.remove(name);
			names.remove(name);
			DisposeUtils.dispose(data);
		}
		_data2name = null;
		_name2data = null;
		names = null;
	}
	
	public function addData(data:Dynamic, name:String) {
		if ((data == null) || (name == null)) {
			return;
		}
		_name2data.set(name, data);
		_data2name.set(data, name);
		names.push(name);
	}
	
	public function removeData(data:Dynamic) {
		if (data == null) {
			return;
		}
		removeDataByName(_data2name.get(data));
		_data2name.remove(data);
	}
	
	public function removeDataByName(name:String) {
		if (name == null) {
			return;
		}
		_name2data.remove(name);
		names.remove(name);
	}
	
	public function getDataByName(name:String):Dynamic {
		if (name == null) {
			return null;
		}
		return _name2data.get(name);
	}
}