package dragonbones.objects;
import dragonbones.animation.Tween;
import dragonbones.objects.Node;
import dragonbones.utils.ByteArrayUtils;
import dragonbones.utils.BytesType;
import dragonbones.utils.ConstValues;
import dragonbones.utils.MathUtils;
import dragonbones.utils.TransformUtils;
import flash.geom.ColorTransform;
import flash.utils.ByteArray;

/**
 * @author SlavaRa
 */
class XMLDataParser{

	static var _curSkeletonData:SkeletonData;
	static var _helpNode:HelpNode = Node.create();
	static var _helpFrameData:FrameData = new FrameData();
	static var _buffer:ByteArray = new ByteArray();
	
	public static function decompressData(compressedBytes:ByteArray):DecompressedData {
		switch(BytesType.getType(compressedBytes)) {
			case BytesType.SWF, BytesType.PNG, BytesType.JPG:
				var skeletonXml:Xml = getXml(compressedBytes, _buffer);
				var texAtlasXml:Xml = getXml(compressedBytes, _buffer);
				return new DecompressedData(skeletonXml, texAtlasXml, compressedBytes);
			case BytesType.ZIP: throw "Can not decompress zip!";
			case _: throw "Unknow format";
		}
		return null;
	}
	
	static inline function checkSkeletonXMLVersion(skeletonXML:Xml) {
		switch (skeletonXML.firstElement().get(ConstValues.A_VERSION)) {
			case ConstValues.VERSION_14, ConstValues.VERSION, ConstValues.VERSION_21:
				return;
			case _: throw "Nonsupport data version!";
		}
	}
	
	static function getXml(compressedBytes:ByteArray, buffer:ByteArray):Xml {
		var strSize:Int = 0;
		var position:Int = 0;
		
		ByteArrayUtils.clear(buffer);
		
		compressedBytes.position = compressedBytes.length - 4;
		strSize = compressedBytes.readInt();
		position = compressedBytes.length - 4 - strSize;
		
		buffer.writeBytes(compressedBytes, position, strSize);
		buffer.uncompress();
		buffer.position = 0;
		
		ByteArrayUtils.setLenght(compressedBytes, position);
		
		return Xml.parse(buffer.readUTFBytes(buffer.length));
	}
	
	public static function parseSkeletonData(skeletonXml:Xml):SkeletonData {
		checkSkeletonXMLVersion(skeletonXml);
		
		var skeletonData:SkeletonData = new SkeletonData();
		skeletonData.name = skeletonXml.firstElement().get(ConstValues.A_NAME);
		skeletonData.frameRate = Std.parseInt(skeletonXml.firstElement().get(ConstValues.A_FRAME_RATE));
		_curSkeletonData = skeletonData;
		
		parseArmatures(skeletonXml.firstChild());
		parseAnimations(skeletonXml.firstChild());
		
		_curSkeletonData = null;
		return skeletonData;
	}
	
	static function parseArmatures(armaturesXml:Xml) {
		for (armatures in armaturesXml.elementsNamed(ConstValues.ARMATURES)) {
			for (armature in armatures.elementsNamed(ConstValues.ARMATURE)) {
				var name:String = armature.get(ConstValues.A_NAME);
				var armatureData:ArmatureData = _curSkeletonData.getArmatureData(name);
				if (armatureData != null) {
					parseArmatureData(armature, armatureData);
				} else {
					armatureData = new ArmatureData();
					parseArmatureData(armature, armatureData);
					_curSkeletonData.armatureDataList.addData(armatureData, name);
				}
			}
		}
	}
	
	static function parseArmatureData(armatureXml:Xml, armatureData:ArmatureData) {
		for (boneXml in armatureXml.elementsNamed(ConstValues.BONE)) {
			var boneName:String 	= boneXml.get(ConstValues.A_NAME);
			var parentName:String 	= boneXml.get(ConstValues.A_PARENT);
			var parentXML:Xml 		= null;//BUG: getElementsByAttribute(boneXMLList, ConstValues.A_NAME, parentName)[0];
			var boneData:BoneData 	= armatureData.getBoneData(boneName);
			if(boneData != null) {
				parseBoneData(boneXml, parentXML, boneData);
			} else {
				boneData = new BoneData();
				parseBoneData(boneXml, parentXML, boneData);
				armatureData.boneDataList.addData(boneData, boneName);
			}
		}
		
		armatureData.updateBoneList();
	}
	
	static function parseBoneData(boneXml:Xml, ?parentXml:Xml, boneData:BoneData) {
		parseNode(boneXml, boneData.node);
		
		if(parentXml != null) {
			boneData.parent = parentXml.get(ConstValues.A_NAME);
			parseNode(parentXml, _helpNode);
			TransformUtils.transformPointWithParent(boneData.node, _helpNode);
		} else {
			boneData.parent = null;
		}
		
		if (_curSkeletonData != null) {
			var i:Int = 0;
			for (displayXML in boneXml.elementsNamed(ConstValues.DISPLAY)) {
				var name:String = displayXML.get(ConstValues.A_NAME);
				boneData.displayNames[i++] = name;
				var displayData:DisplayData = _curSkeletonData.getDisplayData(name);
				if(displayData != null) {
					parseDisplayData(displayXML, displayData);
				} else {
					displayData = new DisplayData();
					parseDisplayData(displayXML, displayData);
					_curSkeletonData.displayDataList.addData(displayData, name);
				}
			}
		}
	}
	
	static inline function parseDisplayData(displayXml:Xml, displayData:DisplayData) {
		displayData.isArmature 	= displayXml.get(ConstValues.A_IS_ARMATURE) != null;
		
		var pivotX:Null<Int> = Std.parseInt(displayXml.get(ConstValues.A_PIVOT_X));
		var pivotY:Null<Int> = Std.parseInt(displayXml.get(ConstValues.A_PIVOT_Y));
		
		displayData.pivotX = pivotX != null ? pivotX : 0;
		displayData.pivotY = pivotY != null ? pivotY : 0;
	}
	
	static function parseAnimations(animationsXml:Xml) {
		for (animations in animationsXml.elementsNamed(ConstValues.ANIMATIONS)) {
			for (animation in animations.elementsNamed(ConstValues.ANIMATION)) {
				var name:String = animation.get(ConstValues.A_NAME);
				var armatureData:ArmatureData = _curSkeletonData.getArmatureData(name);
				var animationData:AnimationData = _curSkeletonData.getAnimationData(name);
				if (animationData != null) {
					parseAnimationData(animation, animationData, armatureData);
				} else {
					animationData = new AnimationData();
					parseAnimationData(animation, animationData, armatureData);
					_curSkeletonData.animationDataList.addData(animationData, name);
				}
			}
		}
	}
	
	static function parseAnimationData(animationXml:Xml, animationData:AnimationData, armatureData:ArmatureData) {
		for (movement in animationXml.elementsNamed(ConstValues.MOVEMENT)) {
			var name:String = movement.get(ConstValues.A_NAME);
			var movementData:MovementData = animationData.getMovementData(name);
			if(movementData != null) {
				parseMovementData(movement, armatureData, movementData);
			} else {
				movementData = new MovementData();
				parseMovementData(movement, armatureData, movementData);
				animationData.movementDataList.addData(movementData, name);
			}
		}
	}
	
	static function parseMovementData(movementXml:Xml, armatureData:ArmatureData, movementData:MovementData) {
		if(_curSkeletonData != null) {
			var frameRate:Int = _curSkeletonData.frameRate;
			var duration:Int = Std.parseInt(movementXml.get(ConstValues.A_DURATION));
			
			movementData.duration 		= (duration > 1) ? (duration / frameRate) : 0;
			movementData.durationTo 	= Std.parseInt(movementXml.get(ConstValues.A_DURATION_TO))		/ frameRate;
			movementData.durationTween 	= Std.parseInt(movementXml.get(ConstValues.A_DURATION_TWEEN))	/ frameRate;
			movementData.loop 			= Std.parseInt(movementXml.get(ConstValues.A_LOOP)) == 1;
			movementData.tweenEasing 	= Std.parseFloat(movementXml.get(ConstValues.A_TWEEN_EASING));
		}
		
		var boneNames:Array<String> = armatureData.boneDataList.names.copy();
		
		var movementBoneXMLList:Iterator<Xml> = movementXml.elementsNamed(ConstValues.BONE);
		for (movementBoneXML in movementXml.elementsNamed(ConstValues.BONE)) {
			var boneName:String = movementBoneXML.get(ConstValues.A_NAME);
			var boneData:BoneData = armatureData.getBoneData(boneName);
			var parentMovementBoneXml:Xml = null;//BUG: getElementsByAttribute(movementBoneXMLList, ConstValues.A_NAME, boneData.parent)[0];
			var movementBoneData:MovementBoneData = movementData.getMovementBoneData(boneName);
			if(movementBoneXML != null) {
				if(movementBoneData != null) {
					parseMovementBoneData(movementBoneXML, parentMovementBoneXml, boneData, movementBoneData);
				} else {
					movementBoneData = new MovementBoneData();
					parseMovementBoneData(movementBoneXML, parentMovementBoneXml, boneData, movementBoneData);
					movementData.movementBoneDataList.addData(movementBoneData, boneName);
				}
			}
			
			var index:Int = Lambda.indexOf(boneNames, boneName);
			if(index != -1) {
				boneNames.splice(index, 1);
			}
		}
		
		for (boneName in boneNames) {
			movementData.movementBoneDataList.addData(MovementBoneData.HIDE_DATA, boneName);
		}
		
		var i:Int = 0;
		for (movementFrameXML in movementXml.elementsNamed(ConstValues.FRAME)) {
			var movementFrameData:MovementFrameData = (movementData.movementFrameList.length > i) ? movementData.movementFrameList[i] : null;
			if(movementFrameData != null) {
				parseMovementFrameData(movementFrameXML, movementFrameData);
			} else {
				movementFrameData = new MovementFrameData();
				parseMovementFrameData(movementFrameXML, movementFrameData);
				if(!Lambda.has(movementData.movementFrameList, movementFrameData)){
					movementData.movementFrameList.push(movementFrameData);
				}
			}
			i++;
		}
	}
	
	static function parseMovementBoneData(movementBoneXML:Xml, parentMovementBoneXML:Xml, boneData:BoneData, movementBoneData:MovementBoneData) {
		var scale:Float = Std.parseFloat(movementBoneXML.get(ConstValues.A_MOVEMENT_SCALE));
		var delay:Float = Std.parseFloat(movementBoneXML.get(ConstValues.A_MOVEMENT_DELAY));
		movementBoneData.setValues(scale, delay);
		
		var parentFrameXMLList:Iterator<Xml> = null;
		var parentFrameCount:Int = 0;
		var parentFrameXML:Xml = null;
		var parentTotalDuration:Int = 0;
		var totalDuration:Int = 0;
		var currentDuration:Int = 0;
		if (parentMovementBoneXML != null) {
			parentFrameXMLList 	= parentMovementBoneXML.elementsNamed(ConstValues.FRAME);
			parentFrameCount	= Lambda.count(parentMovementBoneXML);
		}
		
		var frameXMLList:Iterator<Xml> = movementBoneXML.elementsNamed(ConstValues.FRAME);
		var frameList:Array<FrameData> = movementBoneData.frameList;
		
		var i:Int = 0;
		var j:Int = 0;
		for(frameXML in frameXMLList){
			var frameData:FrameData = frameList.length > j ? frameList[j] : null;
			
			if (frameData != null) {
				parseFrameData(frameXML, frameData);
			} else {
				frameData = new FrameData();
				frameList.push(frameData);
				parseFrameData(frameXML, frameData);
			}
			
			if(parentMovementBoneXML != null) {
				while((i < parentFrameCount) && ((parentFrameXML != null) ? (totalDuration < parentTotalDuration || totalDuration >= parentTotalDuration + currentDuration):true)) {
					parentFrameXML = parentFrameXMLList.next();
					parentTotalDuration += currentDuration;
					currentDuration = Std.parseInt(parentFrameXML.get(ConstValues.A_DURATION));
					i++;
				}
				
				parseFrameData(parentFrameXML, _helpFrameData);
				
				var tweenFrameXML:Xml = null;
				var progress:Float;
				if(tweenFrameXML != null) {
					progress = (totalDuration - parentTotalDuration) / currentDuration;
				} else {
					tweenFrameXML = parentFrameXML;
					progress = 0;
				}
				
				if(_helpFrameData.tweenEasing != _helpFrameData.tweenEasing) {
					progress = 0;
				} else {
					progress = Tween.getEaseValue(progress, _helpFrameData.tweenEasing);
				}
				
				parseNode(tweenFrameXML, _helpNode);
				TransformUtils.setOffSetNode(_helpFrameData.node, _helpNode, _helpNode);
				
				Node.setValues(_helpNode,
					_helpFrameData.node[Node.x] 		+ progress * _helpNode[Node.x],
					_helpFrameData.node[Node.y] 		+ progress * _helpNode[Node.y],
					0,
					_helpFrameData.node[Node.skewX] 	+ progress * _helpNode[Node.skewX],
					_helpFrameData.node[Node.skewY] 	+ progress * _helpNode[Node.skewY],
					_helpFrameData.node[Node.scaleX] 	+ progress * _helpNode[Node.scaleX],
					_helpFrameData.node[Node.scaleY] 	+ progress * _helpNode[Node.scaleY],
					_helpFrameData.node[Node.pivotX] 	+ progress * _helpNode[Node.pivotX],
					_helpFrameData.node[Node.pivotY] 	+ progress * _helpNode[Node.pivotY]
				);
				
				TransformUtils.transformPointWithParent(frameData.node, _helpNode);
			}
			totalDuration += Std.parseInt(frameXML.get(ConstValues.A_DURATION));
			
			Node.setOffset(boneData.node, frameData.node);
			j++;
		}
	}
	
	static inline function parseMovementFrameData(movementFrameXml:Xml, movementFrameData:MovementFrameData) {
		movementFrameData.setValues(
			Std.parseFloat(movementFrameXml.get(ConstValues.A_DURATION)) / _curSkeletonData.frameRate,
			movementFrameXml.get(ConstValues.A_MOVEMENT),
			movementFrameXml.get(ConstValues.A_EVENT),
			movementFrameXml.get(ConstValues.A_SOUND)
		);
	}
	
	static function parseFrameData(frameXml:Xml, frameData:FrameData) {
		parseNode(frameXml, frameData.node);
		if (_curSkeletonData != null) {
			var colorTransformXML:Xml = frameXml.elementsNamed(ConstValues.COLOR_TRANSFORM).next();
			if(colorTransformXML != null) {
				parseColorTransform(colorTransformXML, frameData.colorTransform);
			}
			frameData.duration 		= Std.parseInt(frameXml.get(ConstValues.A_DURATION)) / _curSkeletonData.frameRate;
			frameData.tweenEasing 	= Std.parseFloat(frameXml.get(ConstValues.A_TWEEN_EASING));
			frameData.displayIndex 	= Std.parseInt(frameXml.get(ConstValues.A_DISPLAY_INDEX));
			frameData.movement 		= frameXml.get(ConstValues.A_MOVEMENT);
			frameData.event 		= frameXml.get(ConstValues.A_EVENT);
			frameData.sound 		= frameXml.get(ConstValues.A_SOUND);
			frameData.soundEffect 	= frameXml.get(ConstValues.A_SOUND_EFFECT);
			
			var visible:String = frameXml.get(ConstValues.A_VISIBLE);
			frameData.visible = ((visible == "1") || (visible == "") || (visible == null));
		}
	}
	
	static inline function parseNode(xml:Xml, node:HelpNode) {
		var angle2radian:Float = MathUtils.ANGLE_TO_RADIAN();
		Node.setValues(node,
			Std.parseFloat(xml.get(ConstValues.A_X)),
			Std.parseFloat(xml.get(ConstValues.A_Y)),
			Std.parseFloat(xml.get(ConstValues.A_Z)),
			Std.parseFloat(xml.get(ConstValues.A_SKEW_X)) * angle2radian,
			Std.parseFloat(xml.get(ConstValues.A_SKEW_Y)) * angle2radian,
			Std.parseFloat(xml.get(ConstValues.A_SCALE_X)),
			Std.parseFloat(xml.get(ConstValues.A_SCALE_Y)),
			Std.parseFloat(xml.get(ConstValues.A_PIVOT_X)),
			Std.parseFloat(xml.get(ConstValues.A_PIVOT_Y))
		);
	}
	
	static inline function parseColorTransform(xml:Xml, colorTransform:ColorTransform) {
		colorTransform.alphaOffset 		= Std.parseInt(xml.get(ConstValues.A_ALPHA));
		colorTransform.redOffset 		= Std.parseInt(xml.get(ConstValues.A_RED));
		colorTransform.greenOffset 		= Std.parseInt(xml.get(ConstValues.A_GREEN));
		colorTransform.blueOffset 		= Std.parseInt(xml.get(ConstValues.A_BLUE));
		colorTransform.alphaMultiplier 	= Std.parseInt(xml.get(ConstValues.A_ALPHA_MULTIPLIER)) * 0.01;
		colorTransform.redMultiplier 	= Std.parseInt(xml.get(ConstValues.A_RED_MULTIPLIER)) 	* 0.01;
		colorTransform.greenMultiplier 	= Std.parseInt(xml.get(ConstValues.A_GREEN_MULTIPLIER)) * 0.01;
		colorTransform.blueMultiplier 	= Std.parseInt(xml.get(ConstValues.A_BLUE_MULTIPLIER)) 	* 0.01;
	}
	
}