package dragonbones;

import dragonbones.animation.Tween;
import dragonbones.display.DisplayBridge;
import dragonbones.display.DisplayObject;
import dragonbones.display.DisplayObjectContainer;
import dragonbones.objects.Node;
import dragonbones.utils.DisposeUtils;
import dragonbones.utils.IDisposable;
import dragonbones.utils.TransformUtils;
import flash.geom.ColorTransform;
import flash.geom.Matrix;
import flash.geom.Point;

/**
 * @author SlavaRa
 */
class Bone implements IDisposable {

	public static inline var SET_ARMATURE:String = "setArmature";
	public static inline var SET_DISPLAY:String = "setDisplay";
	public static inline var SET_CHILD_ARMATURE:String = "setChildArmature";
	
	static var _helpPoint:Point = new Point();
	
	public function new(bridge:DisplayBridge) {
		global = Node.create();
		origin = Node.create();
		node = Node.create();
		visible = true;
		tweenNode = Node.create();
		tweenColorTransform = new ColorTransform();
		children = [];
		tween = new Tween(this);
		globalTransformMatrix = new Matrix();
		isOnStage = false;
		
		_displayBridge = bridge;
	}
	
	public var name:String;
	public var global(default, null):HelpNode;
	public var origin(default, null):HelpNode;
	public var node(default, null):HelpNode;
	public var armature(default, null):Armature;
	public var childArmature(default, null):Armature;
	public var parent(default, null):Bone;
	public var display(default, null):DisplayObject;
	public var visible:Bool;
	public var tweenNode(default, null):HelpNode;
	public var tweenColorTransform(default, null):ColorTransform;
	public var children(default, null):Array<Bone>;
	public var tween(default, null):Tween;
	public var globalTransformMatrix(default, null):Matrix;
	public var isOnStage(default, null):Bool;
	
	var _displayBridge:DisplayBridge;
	
	/**
	 * Method called from Armature
	 */
	function setArmature(value:Armature) {
		armature = value;
	}
	
	/**
	 * Method called from BaseFactory
	 */
	function setDisplay(value:DisplayObject) {
		display = _displayBridge.display = value;
	}
	
	/**
	 * Method called from BaseFactory
	 */
	function setChildArmature(value:Armature) {
		childArmature = value;
		display = _displayBridge.display = value.displayContainer;
	}
	
	//TODO: refactor this
	public function dispose() {
		for (i in children) DisposeUtils.dispose(i);
		children = null;
		armature = null;
		parent = null;
	}
	
	public function changeDisplay(displayIndex:Int) {
		if (displayIndex < 0) {
			if(isOnStage) {
				isOnStage = false;
				_displayBridge.removeDisplayFromParent();
			}
		} else {
			if(!isOnStage) {
				isOnStage = true;
				if(armature != null) {
					_displayBridge.addDisplayTo(armature.displayContainer, Std.int(global[Node.z]));
					armature.bonesIndexChanged = true;
				}
			}
		}
	}
	
	public function contains(bone:Bone, ?deepLevel:Bool):Bool {
		if (bone == null) {
			return false;
		}
		
		if(deepLevel) {
			var ancestor:Bone = this;
			while ((ancestor != bone) && (ancestor != null)) {
				ancestor = ancestor.parent;
			}
			if (ancestor == bone) {
				return true;
			}
			return false;
		}
		return bone.parent == this;
	}
	
	public function addChild(child:Bone) {
		if (child == null) {
			return;
		}
		
		if (child.parent != this) {
			child.removeFromParent();
			
			children.push(child);
			child.parent = this;
			
			if (armature != null) {
				armature.addToBones(child);
			}
		}
	}
	
	public function removeChild(child:Bone) {
		if (child == null) {
			return;
		}
		
		if(child.parent == this) {
			if (armature != null) {
				armature.removeFromBones(child);
			}
			children.remove(child);
			child.parent = null;
		}
	}
	
	public function removeFromParent() {
		if(parent != null) {
			parent.removeChild(this);
		}
	}
	
	public function addDisplayTo(container:DisplayObjectContainer, index:Int = -1) {
		_displayBridge.addDisplayTo(container, index);
	}
	
	public function removeDisplayFromParent() {
		_displayBridge.removeDisplayFromParent();
	}
	
	public function update() {
		if (!isOnStage) {
			return;
		}
		updateGlobalNode();
		TransformUtils.nodeToMatrix(global, globalTransformMatrix);
		updateChildArmature();
		_displayBridge.update(globalTransformMatrix, global, getColorTransform(), visible);
	}
	
	private inline function updateGlobalNode() {
		global[Node.x] 		= origin[Node.x] 		+ node[Node.x] 		+ tweenNode[Node.x];
		global[Node.y] 		= origin[Node.y] 		+ node[Node.y] 		+ tweenNode[Node.y];
		global[Node.z] 		= origin[Node.z] 		+ node[Node.z] 		+ tweenNode[Node.z];
		global[Node.skewX] 	= origin[Node.skewX] 	+ node[Node.skewX] 	+ tweenNode[Node.skewX];
		global[Node.skewY] 	= origin[Node.skewY] 	+ node[Node.skewY] 	+ tweenNode[Node.skewY];
		global[Node.scaleX]	= origin[Node.scaleX] 	+ node[Node.scaleX] + tweenNode[Node.scaleX];
		global[Node.scaleY]	= origin[Node.scaleY] 	+ node[Node.scaleY] + tweenNode[Node.scaleY];
		global[Node.pivotX]	= origin[Node.pivotX] 	+ node[Node.pivotX] + tweenNode[Node.pivotX];
		global[Node.pivotY]	= origin[Node.pivotY] 	+ node[Node.pivotY] + tweenNode[Node.pivotY];
		
		if (parent != null) {
			_helpPoint.x 	= global[Node.x];
			_helpPoint.y 	= global[Node.y];
			_helpPoint 		= parent.globalTransformMatrix.transformPoint(_helpPoint);
			global[Node.x] 		= _helpPoint.x;
			global[Node.y] 		= _helpPoint.y;
			global[Node.skewX] 	+= parent.global[Node.skewX];
			global[Node.skewY] 	+= parent.global[Node.skewY];
		}
	}
	
	private inline function updateChildArmature() {
		if (childArmature != null) {
			childArmature.update();
		}
	}
	
	private inline function getColorTransform():ColorTransform {
		if (tween.differentColorTransform) {
			if (armature.colorTransform != null) {
				tweenColorTransform.concat(armature.colorTransform);
			}
			return tweenColorTransform;
		} else if (armature.colorTransformChange) {
			armature.colorTransformChange = false;
			return armature.colorTransform;
		} else return null;
	}
	
}