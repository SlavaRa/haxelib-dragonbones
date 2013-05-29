package dragonbones.display;
import dragonbones.objects.Node;
import nme.geom.ColorTransform;
import nme.geom.Matrix;
import starling.display.DisplayObject;
import starling.display.DisplayObjectContainer;
import starling.display.Quad;

/**
 * @author SlavaRa
 */
class StarlingDisplayBridge {

	public function new() {
		pivotX = 0;
		pivotY = 0;
	}
	
	public var display(default, set_display):DisplayObject;
	var pivotX:Float;
	var pivotY:Float;
	var transformationMatrix:Matrix;
	var prevVisible:Null<Bool>;
	
	function set_display(value:Dynamic) {
		if(value == display){
			return value;
		}
		
		var index:Int = 0;
		var parent:DisplayObjectContainer = null;
		if(display != null){
			parent = display.parent;
			if(parent != null) {
				index = parent.getChildIndex(display);
			}
			removeDisplayFromParent();
		}
		display = value;
		
		if (value != null) {
			pivotX = value.pivotX;
			pivotY = value.pivotY;
			transformationMatrix = value.transformationMatrix;
			addDisplayTo(parent, index);
		} else {
			pivotX = 0;
			pivotY = 0;
			transformationMatrix = null;
		}
		
		return value;
	}
	
	public function update(matrix:Matrix, node:HelpNode, ?colorTransform:ColorTransform, visible:Bool):Void {
		if (display == null) {
			return;
		}
		
		var pivotX:Float = node[Node.pivotX] + pivotX;
		var pivotY:Float = node[Node.pivotY] + pivotY;
		matrix.tx -= matrix.a * pivotX + matrix.c * pivotY;
		matrix.ty -= matrix.b * pivotX + matrix.d * pivotY;
		
		//6%
		//transformationMatrix.copyFrom(matrix);
		
		//4%
		transformationMatrix.a = matrix.a;
		transformationMatrix.b = matrix.b;
		transformationMatrix.c = matrix.c;
		transformationMatrix.d = matrix.d;
		transformationMatrix.tx = matrix.tx;
		transformationMatrix.ty = matrix.ty;
		
		if ((colorTransform != null) && Std.is(display, Quad)) {
			var quad:Quad = cast(display, Quad);
			quad.alpha = colorTransform.alphaMultiplier;
			var r:UInt = cast((colorTransform.redMultiplier * 0xff), Int) << 16;
			var g:UInt = cast((colorTransform.greenMultiplier * 0xff), Int) << 8;
			var b:UInt = cast(colorTransform.blueMultiplier, Int) * 0xff;
			quad.color = r + g + b;
		}
		
		if ((prevVisible == null) || (prevVisible != visible)) {
			display.visible = visible;
			prevVisible = visible;
		}
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