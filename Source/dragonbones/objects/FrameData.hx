package dragonbones.objects;
import dragonbones.objects.Node;
import dragonbones.utils.IDisposable;
import flash.geom.ColorTransform;

/**
 * @author SlavaRa
 */
class FrameData implements IDisposable{

	public function new() {
		duration = 0;
		tweenEasing = 0;
		node = Node.create();
		colorTransform = new ColorTransform();
		visible = true;
	}
	
	public var duration:Float;
	public var tweenEasing:Float;
	public var displayIndex:Int;
	public var movement:String;
	public var visible:Bool;
	public var event:String;
	public var sound:String;
	public var soundEffect:String;
	public var node(default, null):HelpNode;
	public var colorTransform(default, null):ColorTransform;
	
	public function dispose() {
		node = null;
		colorTransform = null;
	}
}