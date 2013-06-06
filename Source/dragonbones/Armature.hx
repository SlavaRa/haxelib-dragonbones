package dragonbones;

import dragonbones.animation.Animation;
import dragonbones.animation.IAnimatable;
import dragonbones.display.DisplayObject;
import dragonbones.display.Sprite;
import dragonbones.objects.Node;
import dragonbones.utils.DisposeUtils;
import dragonbones.utils.IDisposable;
import flash.geom.ColorTransform;
import msignal.Signal;

typedef BoneFrameData = { bone:Bone, movementID:String, frameLabel:String };

/**
 * @author SlavaRa
 */
class Armature implements IAnimatable implements IDisposable{

	public function new(display:Sprite) {
		displayContainer = display;
		bones = [];
		_rootBones = [];
		animation = new Animation(this);
		bonesIndexChanged = false;
		onZOrderUpdate = new Signal0();
		onBoneFrame = new Signal1<BoneFrameData>();
		onMovementChange = new Signal2<String, String>();
		onMovementFrame = new Signal1<BoneFrameData>();
		onAnimationStart = new Signal1<String>();
		onAnimationComplete = new Signal1<String>();
		onAnimationLoopComplete = new Signal1<String>();
	}
	
	public var name:String;
	public var displayContainer(default, null):Sprite;
	public var animation(default, null):Animation;
	public var bones(default, null):Array<Bone>;
	public var bonesIndexChanged:Bool;
	public var colorTransform(default, set_colorTransform):ColorTransform;
	public var colorTransformChange:Bool;
	public var onZOrderUpdate(default, null):Signal0;
	public var onBoneFrame(default, null):Signal1<BoneFrameData>;
	public var onMovementChange(default, null):Signal2<String, String>/*of <exMovementID, movementID>*/;
	public var onMovementFrame(default, null):Signal1<BoneFrameData>;
	public var onAnimationStart(default, null):Signal1<String>/*of <movementID>*/;
	public var onAnimationComplete(default, null):Signal1<String>/*of <movementID>*/;
	public var onAnimationLoopComplete(default, null):Signal1<String>/*of <movementID>*/;
	
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
		DisposeUtils.dispose(onZOrderUpdate);
		DisposeUtils.dispose(onBoneFrame);
		DisposeUtils.dispose(onMovementChange);
		DisposeUtils.dispose(onMovementFrame);
		DisposeUtils.dispose(onAnimationStart);
		DisposeUtils.dispose(onAnimationComplete);
		DisposeUtils.dispose(onAnimationLoopComplete);
		DisposeUtils.dispose(animation);
		
		for (i in _rootBones) DisposeUtils.dispose(i);
		
		_rootBones = null;
		onZOrderUpdate = null;
		onBoneFrame = null;
		onMovementChange = null;
		onMovementFrame = null;
		onAnimationStart = null;
		onAnimationComplete = null;
		onAnimationLoopComplete = null;
		displayContainer = null;
		animation = null;
		bones = null;
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
		for (i in 0..._rootBones.length) {
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
		
		
		if(onZOrderUpdate.numListeners > 0) {
			onZOrderUpdate.dispatch();
		}
	}
	
	inline function compareZ(a:Bone, b:Bone):Int {
		return Std.int(a.global[Node.z] - b.global[Node.z]);
	}
	
	inline function has(bone:Bone):Bool {
		return bone.armature == this;
	}
	
	inline function hasNot(bone:Bone):Bool {
		return (bone.armature == null) || (bone.armature != this);
	}
	
}