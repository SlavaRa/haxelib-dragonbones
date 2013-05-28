package dragonbones;

import dragonbones.animation.Animation;
import dragonbones.animation.IAnimatable;
import dragonbones.events.ArmatureEvent;
import dragonbones.objects.Node;
import dragonbones.utils.DisposeUtils;
import dragonbones.utils.IDisposable;
import nme.display.DisplayObject;
import nme.display.Sprite;
import nme.events.EventDispatcher;
import nme.geom.ColorTransform;

/**
 * @author SlavaRa
 */
class Armature extends EventDispatcher implements IAnimatable implements IDisposable{

	public function new(display:Sprite) {
		super();
		this.displayContainer = display;
		bones = [];
		_rootBones = [];
		animation = new Animation(this);
		bonesIndexChanged = false;
	}
	
	public var name:String;
	public var displayContainer(default, null):Sprite;
	public var animation(default, null):Animation;
	public var bones(default, null):Array<Bone>;
	public var bonesIndexChanged:Bool;
	public var colorTransform(default, set_colorTransform):ColorTransform;
	public var colorTransformChange:Bool;
	
	function set_colorTransform(value:ColorTransform):ColorTransform {
		if (value == colorTransform) {
			return value;
		}
		colorTransform = value;
		colorTransformChange = true;
		return value;
	}
	
	var _rootBones:Array<Bone>;
	
	public function dispose() {
		for (i in _rootBones) DisposeUtils.dispose(i);
		DisposeUtils.dispose(animation);
		
		displayContainer = null;
		animation = null;
		bones = null;
		_rootBones = null;
		colorTransform = null;
	}
	
	public function addBone(bone:Bone, ?parentName:String) {
		if (bone == null) {
			return;
		}
		
		var boneParent:Bone = null;
		if (parentName != null) {
			boneParent = getBone(parentName);
		}
		
		if (boneParent != null) {
			boneParent.addChild(bone);
		} else {
			bone.removeFromParent();
			addToBones(bone, true);
		}
	}
	
	public function addToBones(bone:Bone, ?root:Bool) {
		if (bone == null) {
			return;
		}
		
		if(hasNot(bone)) {
			bones.push(bone);
			Reflect.callMethod(bone, Reflect.field(bone, Bone.SET_ARMATURE), [this]);
		}
		
		if (root) {
			if (!Lambda.has(_rootBones, bone)) {
				_rootBones.push(bone);
			}
		} else {
			_rootBones.remove(bone);
		}
		
		bone.addDisplayTo(displayContainer, Std.int(bone.global[Node.z]));
		for(i in bone.children) {
			addToBones(i);
		}
		bonesIndexChanged = true;
	}
	
	public function removeBone(bone:Bone) {
		if (bone == null) {
			return;
		}
		
		if(bone.parent != null) {
			bone.removeFromParent();
		} else {
			removeFromBones(bone);
		}
	}
	
	public function removeBoneByName(name:String) {
		if (name == null) {
			return;
		}
		removeBone(getBone(name));
	}
	
	public function removeFromBones(bone:Bone)	{
		if (bone == null) {
			return;
		}
		
		bones.remove(bone);
		Reflect.callMethod(bone, Reflect.field(bone, Bone.SET_ARMATURE), [null]);
		
		_rootBones.remove(bone);
		
		bone.removeDisplayFromParent();
		for(i in bone.children) {
			removeFromBones(i);
		}
		bonesIndexChanged = true;
	}
	
	public function getBone(name:String):Bone {
		if(name == null) {
			return null;
		}
		for(bone in bones) {
			if(bone.name == name) {
				return bone;
			}
		}
		return null;
	}
	
	public function getBoneByDisplay(display:DisplayObject):Bone {
		if(display == null) {
			return null;
		}
		for (bone in bones) {
			if(bone.display == display) {
				return bone;
			}
		}
		return null;
	}
	
	public function advanceTime(passedTime:Float) {
		animation.advanceTime(passedTime);
		update();
	}
	
	public function update() {
		var length:Int = _rootBones.length;
		for (i in 0...length) {
			_rootBones[i].update();
		}
		
		if(bonesIndexChanged) {
			updateBonesZ();
		}
	}
	
	function updateBonesZ() {
		bones.sort(compareZ);
		for (bone in bones){
			if (bone.isOnStage) {
				bone.addDisplayTo(displayContainer);
			}
		}
		bonesIndexChanged = false;
		
		if(hasEventListener(ArmatureEvent.Z_ORDER_UPDATED)) {
			dispatchEvent(new ArmatureEvent(ArmatureEvent.Z_ORDER_UPDATED));
		}
	}
	
	function compareZ(a:Bone, b:Bone):Int {
		return Std.int(a.global[Node.z] - b.global[Node.z]);
	}
	
	private inline function has(bone:Bone):Bool {
		return bone.armature == this;
	}
	
	private inline function hasNot(bone:Bone):Bool {
		return (bone.armature == null) || (bone.armature != this);
	}
	
}