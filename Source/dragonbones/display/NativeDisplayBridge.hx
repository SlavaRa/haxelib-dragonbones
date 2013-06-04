package dragonbones.display;
import dragonbones.display.DisplayObject;
import dragonbones.display.DisplayObjectContainer;
import dragonbones.objects.Node;
import flash.geom.ColorTransform;
import flash.geom.Matrix;

/**
 * @author SlavaRa
 */
class NativeDisplayBridge{

	public function new() {
	}
	
	public var display(default, set_display):DisplayObject;
	
	function set_display(value:DisplayObject):DisplayObject {
		if (value == display) {
			return value;
		}
		var index:Int = 0;
		var parent:DisplayObjectContainer = null;
		if (display != null) {
			parent = display.parent;
			if (parent != null) {
				index = parent.getChildIndex(display);
			}
			removeDisplayFromParent();
		}
		display = value;
		addDisplayTo(parent, index);
		return value;
	}
	
	public function update(matrix:Matrix, node:HelpNode, colorTransform:ColorTransform, visible:Bool) {
		var pivotX:Float = node[Node.pivotX];
		var pivotY:Float = node[Node.pivotY];
		matrix.tx -= matrix.a * pivotX + matrix.c * pivotY;
		matrix.ty -= matrix.b * pivotX + matrix.d * pivotY;
		
		//TODO: refactor this
		cast(display, flash.display.DisplayObject).transform.matrix = matrix;
		if(colorTransform != null) {
			cast(display, flash.display.DisplayObject).transform.colorTransform = colorTransform;
		}
		display.visible = visible;
	}
	
	public function addDisplayTo(container:DisplayObjectContainer, index:Int = -1) {
		if ((container == null) || (display == null)) {
			return;
		}
		
		if(index < 0) {
			container.addChild(display);
		} else {
			if (index >= container.numChildren) {
				container.addChildAt(display, container.numChildren);
			} else {
				container.addChildAt(display, index);
			}
		}
	}
	
	public function removeDisplayFromParent() {
		if((display != null) && (display.parent != null)) {
			display.parent.removeChild(display);
		}
	}
}