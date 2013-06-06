package dragonbones.factorys;
import dragonbones.Armature;
import dragonbones.Bone;
import dragonbones.display.DisplayBridge;
import dragonbones.display.Sprite;
import dragonbones.objects.AnimationData;
import dragonbones.objects.ArmatureData;
import dragonbones.objects.BoneData;
import dragonbones.objects.DecompressedData;
import dragonbones.objects.DisplayData;
import dragonbones.objects.Node;
import dragonbones.objects.SkeletonData;
import dragonbones.objects.XMLDataParser;
import dragonbones.textures.ITextureAtlas;
import dragonbones.textures.NativeTextureAtlas;
import dragonbones.textures.SubTextureData;
import dragonbones.utils.DisposeUtils;
import flash.display.BitmapData;
import flash.display.Bitmap;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Loader;
import flash.display.LoaderInfo;
import flash.display.MovieClip;
import flash.display.Shape;
import flash.events.Event;
import flash.geom.Matrix;
import flash.geom.Rectangle;
import flash.utils.ByteArray;
import msignal.Signal;

/**
 * @author SlavaRa
 */
class BaseFactory {

	static var helpMatrix:Matrix = new Matrix();
	
	public function new() {
		onDataParsed = new Signal0();
		_name2SkeletonData = new Map<String, SkeletonData>();
		_name2TexAtlas = new Map<String, ITextureAtlas>();
		_loader2TexAtlasXML = new Map<Loader, Xml>();
	}
	
	public var onDataParsed(default, null):Signal0;
	
	var _name2SkeletonData:Map<String, SkeletonData>;
	var _name2TexAtlas:Map<String, ITextureAtlas>;
	var _loader2TexAtlasXML:Map<Loader, Xml>;
	var _curSkeletonData:SkeletonData;
	var _curTexAtlas:Dynamic;
	var _curSkeletonName:String;
	var _curTexAtlasName:String;
	
	public function dispose(disposeData:Bool = true) {
		onDataParsed = null;
		
		if (disposeData) {
			for (i in _name2SkeletonData) DisposeUtils.dispose(i);
			for (i in _name2TexAtlas) DisposeUtils.dispose(i);
		}
		
		_name2SkeletonData = null;
		_name2TexAtlas = null;
		_loader2TexAtlasXML = null;
		_curSkeletonData = null;
		_curTexAtlas = null;
		_curSkeletonName = null;
		_curTexAtlasName = null;
	}
	
	public function parseData(bytes:ByteArray, ?skeletonName:String):SkeletonData {
		var decompressedData:DecompressedData = XMLDataParser.decompressData(bytes);
		
		var skeletonData:SkeletonData = XMLDataParser.parseSkeletonData(decompressedData.skeletonXml);
		if (skeletonName == null) {
			skeletonName = skeletonData.name;
		}
		addSkeletonData(skeletonData, skeletonName);
		
		var loader:Loader = new Loader();
		_loader2TexAtlasXML.set(loader, decompressedData.texAtlasXml);
		loader.name = skeletonName;
		loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loaderCompleteHandler);
		loader.loadBytes(decompressedData.texBytes);
		
		decompressedData.dispose();
		return skeletonData;
	}
	
	public function getTextureDisplay(texName:String, ?texAtlasName:String, ?pivotX:Float, ?pivotY:Float):Dynamic {
		var texAtlas:ITextureAtlas = null;
		if(texAtlasName != null) {
			texAtlas = _name2TexAtlas.get(texAtlasName);
		} else {
			for (value in _name2TexAtlas) {
				if (value.getRegion(texName) != null) {
					texAtlas = value;
					break;
				}
				texAtlas = null;
			}
		}
		
		if(texAtlas == null) {
			return null;
		}
		
		if ((pivotX != pivotX) || (pivotY != pivotY)) {
			var skeletonData:SkeletonData = _name2SkeletonData.get(texAtlasName);
			if(skeletonData != null) {
				var displayData:DisplayData = skeletonData.getDisplayData(texName);
				if(displayData != null) {
					if (pivotX != pivotX) {
						pivotX = displayData.pivotX;
					}
					if (pivotY != pivotY) {
						pivotY = displayData.pivotY;
					} 
				}
			}
		}
		return createTextureDisplay(texAtlas, texName, Std.int(pivotX), Std.int(pivotY));
	}
	
	public function buildArmature(armatureName:String, ?animationName:String, ?skeletonName:String, ?texAtlasName:String):Armature {
		if (animationName == null) {
			animationName = armatureName;
		}
		
		var skeletonData:SkeletonData = null;
		var armatureData:ArmatureData = null;
		if (skeletonName != null) {
			skeletonData = _name2SkeletonData.get(skeletonName);
			if (skeletonData != null) {
				armatureData = skeletonData.getArmatureData(armatureName);
			}
		} else {
			for (key in _name2SkeletonData.keys()) {
				skeletonData = _name2SkeletonData.get(key);
				armatureData = skeletonData.getArmatureData(armatureName);
				if (armatureData != null) {
					skeletonName = key;
					break;
				}
			}
		}
		
		if(armatureData == null) {
			return null;
		}
		
		_curSkeletonName = skeletonName;
		_curSkeletonData = skeletonData;
		
		if (texAtlasName != null) {
			_curTexAtlasName = texAtlasName;
		} else {
			_curTexAtlasName = skeletonName;
		}
		
		_curTexAtlas = _name2TexAtlas.get(_curTexAtlasName);
		
		var armature:Armature = createArmature();
		armature.name = armatureName;
		armature.animation.animationData = getAnimationData(animationName);
		for (name in armatureData.boneDataList.names) {
			var data:BoneData = armatureData.getBoneData(name);
			if(data != null) {
				var bone:Bone = buildBone(data);
				bone.name = name;
				armature.addBone(bone, data.parent);
			}
		}
		armature.bonesIndexChanged = true;
		armature.update();
		return armature;
	}
	
	function loaderCompleteHandler(event:Event) {
		var loaderInfo:LoaderInfo = cast(event.target, LoaderInfo);
		loaderInfo.removeEventListener(Event.COMPLETE, loaderCompleteHandler);
		
		var texAtlasXML:Xml = _loader2TexAtlasXML.get(loaderInfo.loader);
		_loader2TexAtlasXML.remove(loaderInfo.loader);
		
		if((loaderInfo.loader.name != null) && (texAtlasXML != null)) {
			
			var texAtlas:ITextureAtlas = createTextureAtlas(getContent(loaderInfo), texAtlasXML);
			addTextureAtlas(texAtlas, loaderInfo.loader.name);
			
			if (Lambda.count(_loader2TexAtlasXML) == 0) {
				onDataParsed.dispatch();
			}
		}
		
		#if flash
		loaderInfo.loader.unloadAndStop();
		#elseif !js
		loaderInfo.loader.unload();
		#end
	}
	
	private inline function addSkeletonData(skeletonData:SkeletonData, name:String) {
		if(name == null) {
			throw "Unnamed data!";
		}
		
		_name2SkeletonData.set(name, skeletonData);
	}
	
	private inline function addTextureAtlas(texAtlas:ITextureAtlas, name:String) {
		if(name == null) {
			throw "Unnamed data!";
		}
		
		_name2TexAtlas.set(name, texAtlas);
	}
	
	private inline function getAnimationData(name:String):AnimationData {
		var data:AnimationData = _curSkeletonData.getAnimationData(name);
		if (data == null) {
			for (i in _name2SkeletonData) {
				data = i.getAnimationData(name);
				if (data != null) {
					break;
				}
			}
		}
		return data;
	}
	
	function buildBone(boneData:BoneData):Bone {
		var bone:Bone = createBone();
		Node.copy(boneData.node, bone.origin);
		
		var i:Int = boneData.displayNames.length;
		while (i --> 0) {
			var name:String = boneData.displayNames[i];
			var data:DisplayData = _curSkeletonData.getDisplayData(name);
			bone.changeDisplay(i);
			if (data.isArmature) {
				var armature:Armature = buildArmature(name, null, _curSkeletonName, _curTexAtlasName);
				if(armature != null) {
					armature.animation.play();
					Reflect.callMethod(bone, Reflect.field(bone, Bone.SET_CHILD_ARMATURE), [armature]);
				}
			} else {
				Reflect.callMethod(bone, Reflect.field(bone, Bone.SET_DISPLAY), [createTextureDisplay(_curTexAtlas, name, Std.int(data.pivotX), Std.int(data.pivotY))]);
			}
		}
		return bone;
	}
	
	function getContent(loaderInfo:LoaderInfo):Dynamic {
		if (Std.is(loaderInfo.content, Bitmap)) {
			return cast(loaderInfo.content, Bitmap).bitmapData;
		}
		
		if (Std.is(loaderInfo.content, DisplayObjectContainer)) {
			return cast(loaderInfo.content, DisplayObjectContainer).getChildAt(0);
		}
		
		return throw "non supported type";
	}
	
	function createTextureAtlas(content:Dynamic, texAtlasXML:Xml):ITextureAtlas {
		return new NativeTextureAtlas(content, texAtlasXML);
	}
	
	function createArmature():Armature {
		return new Armature(new Sprite());
	}
	
	function createBone():Bone {
		return new Bone(new DisplayBridge());
	}
	
	function createTextureDisplay(texAtlas:ITextureAtlas, fullName:String, pivotX:Int = 0, pivotY:Int = 0):Dynamic {
		if (Std.is(texAtlas, NativeTextureAtlas)) {
			var nativeTexAtlas:NativeTextureAtlas = cast(texAtlas, NativeTextureAtlas);
			var clip:MovieClip = nativeTexAtlas.movieClip;
			if ((clip != null) && (clip.totalFrames >= 3)) {
				clip.gotoAndStop(clip.totalFrames);
				clip.gotoAndStop(fullName);
				if (clip.numChildren > 0) {
					var child:DisplayObject = clip.getChildAt(0);
					child.x = 0;
					child.y = 0;
					return child;
				}
			} else if (nativeTexAtlas.bitmapData != null) {
				var rect:Rectangle = nativeTexAtlas.getRegion(fullName);
				if(Std.is(rect, SubTextureData)){
					var subTexData:SubTextureData = cast(rect, SubTextureData);
					
					//1.4
					if (pivotX == 0) {
						pivotX = subTexData.pivotX;
					}
					if (pivotY == 0) {
						pivotY = subTexData.pivotY;
					}
					
					helpMatrix.identity();
					helpMatrix.scale(nativeTexAtlas.scale, nativeTexAtlas.scale);
					helpMatrix.tx = -subTexData.x - pivotX;
					helpMatrix.ty = -subTexData.y - pivotY;
					
					#if !js
					var shape:Shape = new Shape();
					shape.graphics.beginBitmapFill(nativeTexAtlas.bitmapData, helpMatrix, false, true);
					shape.graphics.drawRect( -pivotX, -pivotY, subTexData.width, subTexData.height);
					shape.graphics.endFill();
					return shape;
					#else
					var bitmapData:BitmapData = new BitmapData(cast(subTexData.width, Int), cast(subTexData.height, Int), true, 0x000000);
					bitmapData.draw(nativeTexAtlas.bitmapData, helpMatrix);
					return new Bitmap(bitmapData);
					#end
				}
			}
		}
		return null;
	}
	
}