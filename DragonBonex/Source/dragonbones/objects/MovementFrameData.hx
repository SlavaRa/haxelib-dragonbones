package dragonbones.objects;

/**
 * @author SlavaRa
 */
class MovementFrameData{

	public function new() {
	}
	
	public var duration:Float;
	public var movement:String;
	public var event:String;
	public var sound:String;
	public var soundEffect:String;

	public function setValues(duration:Float, movement:String, event:String, sound:String) {
		this.duration = duration;
		this.movement = movement;
		this.event = event;
		this.sound = sound;
	}
	
}