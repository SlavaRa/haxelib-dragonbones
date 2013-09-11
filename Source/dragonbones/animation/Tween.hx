package dragonbones.animation;
import dragonbones.Armature;
import dragonbones.Bone;
import dragonbones.events.SoundEvent;
import dragonbones.events.SoundEventManager;
import dragonbones.objects.FrameData;
import dragonbones.objects.MovementBoneData;
import dragonbones.objects.Node;
import dragonbones.utils.MathUtils;
import dragonbones.utils.TransformUtils;
import flash.geom.ColorTransform;

/**
 * @author SlavaRa
 */
class Tween{

	static var _soundManager:SoundEventManager = SoundEventManager.instance;
	
	public static inline function getEaseValue(value:Float, ?easing:Float):Float {
		var valueEase:Float = 0;
		if (easing != easing) {
			valueEase = 0;
			easing = 0;
			value = 0;
		} else if (easing > 1) {
			valueEase = 0.5 * (1 - MathUtils.cos(value * Math.PI)) - value;
			easing -= 1;
		} else if (easing > 0) {
			valueEase = MathUtils.sin(value * MathUtils.HALF_PI()) - value;
		} else if (easing < 0) {
			valueEase = 1 - MathUtils.cos(value * MathUtils.HALF_PI()) - value;
			easing *= -1;
		}
		return valueEase * easing + value;
	}
	
	public function new(bone:Bone) {
		_bone = bone;
		_node = _bone.tweenNode;
		_colorTransform = _bone.tweenColorTransform;
		
		_curNode = Node.create();
		_curColorTransform = new ColorTransform();
		
		_offSetNode = Node.create();
		_offSetColorTransform = new ColorTransform();
	}
	
	public var differentColorTransform:Bool;
	
	var _bone:Bone;
	var _movementBoneData:MovementBoneData;
	var _node:HelpNode;
	var _colorTransform:ColorTransform;
	var _curNode:HelpNode;
	var _curColorTransform:ColorTransform;
	var _offSetNode:HelpNode;
	var _offSetColorTransform:ColorTransform;
	var _curFrameData:FrameData;
	var _tweenEasing:Float;
	var _frameTweenEasing:Float;
	var _isPause:Bool;
	var _rawDuration:Float;
	var _nextFrameDataTimeEdge:Float;
	var _frameDuration:Float;
	var _nextFrameDataID:Int;
	var _loop:Int;
	
	public function gotoAndPlay(movementBoneData:MovementBoneData, rawDuration:Float, loop:Bool, tweenEasing:Float) {
		if(movementBoneData == null) {
			return;
		}
		
		_movementBoneData = movementBoneData;
		var totalFrames:Int = _movementBoneData.frameList.length;
		if (totalFrames == 0) {
			_bone.changeDisplay(-1);
			stop();
			return;
		}
		
		_node[Node.skewX] %= 360;
		_node[Node.skewY] %= 360;
		_isPause = false;
		_curFrameData = null;
		_loop = loop ? 0 : -1;
		
		_nextFrameDataTimeEdge = 0;
		_nextFrameDataID = 0;
		_rawDuration = rawDuration;
		_tweenEasing = tweenEasing;
		
		var nextFrameData:FrameData = null;
		if (totalFrames == 1) {
			_frameTweenEasing = 1;
			_rawDuration = 0;
			nextFrameData = _movementBoneData.frameList[0];
			setOffset(_node, _colorTransform, nextFrameData.node, nextFrameData.colorTransform);
		} else if (loop && (_movementBoneData.delay != 0)) {
			getLoopListNode();
			setOffset(_node, _colorTransform, _offSetNode, _offSetColorTransform);
		} else {
			nextFrameData = _movementBoneData.frameList[0];
			setOffset(_node, _colorTransform, nextFrameData.node, nextFrameData.colorTransform);
		}
		
		if (nextFrameData != null) {
			updateBoneDisplayIndex(nextFrameData);
		}
	}
	
	public function stop() {
		_isPause = true;
	}
	
	public function advanceTime(progress:Float, playType:Int) {
		if(_isPause) {
			return;
		}
		
		if(_rawDuration == 0) {
			playType = Animation.SINGLE;
			if(progress == 0) {
				progress = 1;
			}
		}
		
		if(playType == Animation.LOOP) {
			progress /= _movementBoneData.scale;
			progress += _movementBoneData.delay;
			var loop:Int = Std.int(progress);
			if(loop != _loop) {
				_nextFrameDataTimeEdge = 0;
				_nextFrameDataID = 0;
				_loop = loop;
			}
			progress -= loop;
			progress = updateFrameData(progress, false);
		} else if (playType == Animation.LIST) {
			progress = updateFrameData(progress, true, true);
		} else if ((playType == Animation.SINGLE) && (progress == 1)) {
			_curFrameData = _movementBoneData.frameList[0];
			_isPause = true;
		} else {
			progress = Math.sin(progress * MathUtils.HALF_PI());
		}
		
		if ((_frameTweenEasing == _frameTweenEasing) || (_curFrameData != null)) {
			TransformUtils.setTweenNode(_curNode, _offSetNode, _node, progress);
			if(differentColorTransform) {
				TransformUtils.setTweenColorTransform(_curColorTransform, _offSetColorTransform, _colorTransform, progress);
			}
		}
		
		if(_curFrameData != null) {
			arriveFrameData(_curFrameData);
			_curFrameData = null;
		}
	}
	
	inline function getLoopListNode() {
		var playedTime = _rawDuration * _movementBoneData.delay;
		var length = _movementBoneData.frameList.length;
		var nextFrameDataID:Int = 0;
		var nextFrameDataTimeEdge:Float= 0;
		var curFrameDataID:Int;
		var frameDuration:Float;
		do {
			curFrameDataID = nextFrameDataID;
			frameDuration = _movementBoneData.frameList[curFrameDataID].duration;
			nextFrameDataTimeEdge += frameDuration;
			if (++nextFrameDataID >= length) {
				nextFrameDataID = 0;
			}
		} while (playedTime >= nextFrameDataTimeEdge);
		
		var currentFrameData = _movementBoneData.frameList[curFrameDataID];
		var nextFrameData = _movementBoneData.frameList[nextFrameDataID];
		
		setOffset(currentFrameData.node, currentFrameData.colorTransform, nextFrameData.node, nextFrameData.colorTransform);
		
		var progress = 1 - (nextFrameDataTimeEdge - playedTime) / frameDuration;
		
		var tweenEasing = (_tweenEasing != _tweenEasing) ? currentFrameData.tweenEasing : _tweenEasing;
		if (tweenEasing != 0) {
			progress = getEaseValue(progress, tweenEasing);
		}
		
		TransformUtils.setOffSetNode(currentFrameData.node, nextFrameData.node, _offSetNode);
		TransformUtils.setTweenNode(_curNode, _offSetNode, _offSetNode, progress);
		
		TransformUtils.setOffSetColorTransform(currentFrameData.colorTransform, nextFrameData.colorTransform, _offSetColorTransform);
		TransformUtils.setTweenColorTransform(_curColorTransform, _offSetColorTransform, _offSetColorTransform, progress);
	}
	
	inline function setOffset(curNode:HelpNode, curColorTransform:ColorTransform, nextNode:HelpNode, nextColorTransform:ColorTransform) {
		Node.copy(curNode, _curNode);
		TransformUtils.setOffSetNode(_curNode, nextNode, _offSetNode);
		TransformUtils.copyColorTransform(curColorTransform, _curColorTransform);
		TransformUtils.setOffSetColorTransform(_curColorTransform, nextColorTransform, _offSetColorTransform);
		
		if(
			_offSetColorTransform.alphaOffset 		!= 0 ||
			_offSetColorTransform.redOffset 		!= 0 ||
			_offSetColorTransform.greenOffset 		!= 0 ||
			_offSetColorTransform.blueOffset 		!= 0 ||
			_offSetColorTransform.alphaMultiplier 	!= 0 ||
			_offSetColorTransform.redMultiplier 	!= 0 ||
			_offSetColorTransform.greenMultiplier 	!= 0 ||
			_offSetColorTransform.blueMultiplier 	!= 0
		) {
			differentColorTransform = true;
		} else {
			differentColorTransform = false;
		}
	}
	
	inline function updateBoneDisplayIndex(frameData:FrameData) {
		if(frameData.displayIndex >= 0) {
			if(_node[Node.z] != frameData.node[Node.z]) {
				_node[Node.z] = frameData.node[Node.z];
				if(_bone.armature != null){
					_bone.armature.bonesIndexChanged = true;
				}
			}
		}
	}
	
	inline function arriveFrameData(frameData:FrameData) {
		updateBoneDisplayIndex(frameData);
		_bone.visible = frameData.visible;
		
		if((frameData.event != null) && (_bone.armature.onBoneFrame.numListeners > 0)) {
			_bone.armature.onBoneFrame.dispatch({ bone: _bone, movementID: _bone.armature.animation.movementID, frameLabel: frameData.event });
		}
		
		if((frameData.sound != null) && _soundManager.hasEventListener(SoundEvent.SOUND)) {
			var soundEvent = new SoundEvent(SoundEvent.SOUND);
			soundEvent.movementID = _bone.armature.animation.movementID;
			soundEvent.sound = frameData.sound;
			soundEvent.armature = _bone.armature;
			soundEvent.bone = _bone;
			_soundManager.dispatchEvent(soundEvent);
		}
		
		if((frameData.movement != null) && (_bone.childArmature != null)) {
			_bone.childArmature.animation.gotoAndPlay(frameData.movement);
		}
	}
	
	function updateFrameData(progress:Float, ?activeFrame:Bool, ?isList:Bool):Float {
		var playedTime = _rawDuration * progress;
		if (playedTime >= _nextFrameDataTimeEdge) {
			var curFrameDataID:Int = 0;
			var length = _movementBoneData.frameList.length;
			do {
				curFrameDataID = _nextFrameDataID;
				_frameDuration = _movementBoneData.frameList[curFrameDataID].duration;
				_nextFrameDataTimeEdge += _frameDuration;
				if (++_nextFrameDataID >= length) {
					_nextFrameDataID = 0;
				}
			} while (playedTime >= _nextFrameDataTimeEdge);
			
			var curFrameData = _movementBoneData.frameList[curFrameDataID];
			var nextFrameData = _movementBoneData.frameList[_nextFrameDataID];
			
			if((nextFrameData.displayIndex >= 0) && _bone.armature.animation.tweenEnabled) {
				_frameTweenEasing = curFrameData.tweenEasing;
			} else {
				_frameTweenEasing = Math.NaN;
			}
			
			setOffset(curFrameData.node, curFrameData.colorTransform, nextFrameData.node, nextFrameData.colorTransform);
			
			if (activeFrame) {
				_curFrameData = curFrameData;
			}
			
			if(isList && (_nextFrameDataID == 0)) {
				_isPause = true;
				return 0;
			}
		}
		
		progress = 1 - (_nextFrameDataTimeEdge - playedTime) / _frameDuration;
		
		if (_frameTweenEasing == _frameTweenEasing) {
			var tweenEasing = (_tweenEasing != _tweenEasing) ? _frameTweenEasing : _tweenEasing;
			if (tweenEasing != 0) {
				progress = getEaseValue(progress, tweenEasing);
			}
		}
		return getEaseValue(progress, _frameTweenEasing);
	}
	
}