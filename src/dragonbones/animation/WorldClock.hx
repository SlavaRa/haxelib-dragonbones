package dragonbones.animation;
import dragonbones.animation.IAnimatable;
import haxe.Timer;

/**
 * @author SlavaRa
 */
class WorldClock implements IAnimatable {
	
	public static var instance(get_instance, null):WorldClock;
	
	static function get_instance():WorldClock {
		if (instance == null) {
			instance = new WorldClock();
		}
		return instance;
	}
	
	function new() {
		time = Timer.stamp();
		timeScale = 1;
		_animatableList = [];
	}
	
	public var time(default, null):Float;
	public var timeScale(default, set_timeScale):Float;
	
	function set_timeScale(value:Float):Float {
		if((value < 0) || (value != value)) {
			value = 0;
		}
		timeScale = value;
		return value;
	}
	
	var _animatableList:Array<IAnimatable>;
	
	public function has(animatable:IAnimatable):Bool {
		return Lambda.has(_animatableList, animatable);
	}
	
	public function add(animatable:IAnimatable) {
		if((animatable != null) && !has(animatable)) {
			_animatableList.push(animatable);
		}
	}
	
	public function remove(animatable:IAnimatable) {
		_animatableList.remove(animatable);
	}
	
	public function clear() {
		_animatableList = [];
	}
	
	public function advanceTime(passedTime:Float) {
		if(passedTime < 0) {
			var curTime:Float = Timer.stamp();
			passedTime = curTime - time;
			time = curTime;
		}
		
		passedTime *= timeScale;
		
		for (i in 0..._animatableList.length) {
			_animatableList[i].advanceTime(passedTime);
		}
	}
	
}