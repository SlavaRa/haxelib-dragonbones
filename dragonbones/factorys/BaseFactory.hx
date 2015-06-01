package dragonbones.factorys;
import dragonbones.Armature;
import dragonbones.Bone;
import dragonbones.objects.ArmatureData;
import dragonbones.objects.BoneData;
import dragonbones.objects.DataParser;
import dragonbones.objects.DecompressedData;
import dragonbones.objects.DisplayData;
import dragonbones.objects.SkeletonData;
import dragonbones.objects.SkinData;
import dragonbones.objects.SlotData;
import dragonbones.Slot;
import dragonbones.textures.ITextureAtlas;
import openfl.display.Bitmap;
import openfl.display.Loader;
import openfl.display.MovieClip;
import openfl.display.Sprite;
import openfl.errors.ArgumentError;
import openfl.errors.Error;
import openfl.errors.IllegalOperationError;
import openfl.events.Event;
import openfl.events.EventDispatcher;
import openfl.geom.Matrix;
import openfl.geom.Point;
import openfl.system.ApplicationDomain;
import openfl.system.LoaderContext;
import openfl.utils.ByteArray;
import openfl.utils.Dictionary;

/** Dispatched after a sucessful call to parseData(). */
@:meta(Event(name = "complete", type = "openfl.events.Event"))

class BaseFactory extends EventDispatcher
{
    
    static var _helpMatrix:Matrix = new Matrix();
    static var _loaderContext:LoaderContext = new LoaderContext(false, ApplicationDomain.currentDomain);
    
    var _dataDic:Dynamic;
    var _textureAtlasDic:Dynamic;
    var _currentDataName:String;
    var _currentTextureAtlasName:String;
    
    public function new(self:BaseFactory)
    {
        super(this);
        
        if (self != this) 
        {
            throw new IllegalOperationError("Abstract class can not be instantiated!");
        }
        
        _loaderContext.allowCodeImport = true;
        
        _dataDic = { };
        _textureAtlasDic = { };
        
        _currentDataName = null;
        _currentTextureAtlasName = null;
    }
    
    /**
		 * Returns a SkeletonData instance.
		 * @param The name of an existing SkeletonData instance.
		 * @return A SkeletonData instance with given name (if exist).
		 */
    public function getSkeletonData(name:String):SkeletonData
    {
        return Reflect.field(_dataDic, name);
    }
    
    /**
		 * Add a SkeletonData instance to this BaseFactory instance.
		 * @param A SkeletonData instance.
		 * @param (optional) A name for this SkeletonData instance.
		 */
    public function addSkeletonData(data:SkeletonData, name:String = null):Void
    {
        if (data == null) 
        {
            throw new ArgumentError();
        }
        name = name || data.name;
        if (name == null) 
        {
            throw new ArgumentError("Unnamed data!");
        }
        if (Reflect.field(_dataDic, name)) 
        {
            throw new ArgumentError();
        }
        Reflect.setField(_dataDic, name, data);
    }
    
    /**
	 * Remove a SkeletonData instance from this BaseFactory instance.
	 * @param The name for the SkeletonData instance to remove.
	 */
    public function removeSkeletonData(name:String):Void
    {
		//TODO slavara: check this
    }
    
    /**
		 * Return the TextureAtlas by that name.
		 * @param The name of the TextureAtlas to return.
		 * @return A textureAtlas.
		 */
    public function getTextureAtlas(name:String):Dynamic
    {
        return Reflect.field(_textureAtlasDic, name);
    }
    
    /**
		 * Add a textureAtlas to this BaseFactory instance.
		 * @param A textureAtlas to add to this BaseFactory instance.
		 * @param (optional) A name for this TextureAtlas.
		 */
    public function addTextureAtlas(textureAtlas:Dynamic, name:String = null):Void
    {
        if (textureAtlas == null) 
        {
            throw new ArgumentError();
        }
        if (name == null && Std.is(textureAtlas, ITextureAtlas)) 
        {
            name = textureAtlas.name;
        }
        if (name == null) 
        {
            throw new ArgumentError("Unnamed data!");
        }
        if (Reflect.field(_textureAtlasDic, name)) 
        {
            throw new ArgumentError();
        }
        Reflect.setField(_textureAtlasDic, name, textureAtlas);
    }
    
    /**
		 * Remove a textureAtlas from this baseFactory instance.
		 * @param The name of the TextureAtlas to remove.
		 */
    public function removeTextureAtlas(name:String):Void
    {
		//TODO slavara: check this
    }
    
    /**
		 * Cleans up resources used by this BaseFactory instance.
		 * @param (optional) Destroy all internal references.
		 */
    public function dispose(disposeData:Bool = true):Void
    {
        if (disposeData) 
        {
            for (skeletonName in Reflect.fields(_dataDic))
            {
                (try cast(Reflect.field(_dataDic, skeletonName), SkeletonData) catch(e:Dynamic) null).dispose();
            }
            
            for (textureAtlasName in Reflect.fields(_textureAtlasDic))
            {
                (try cast(Reflect.field(_textureAtlasDic, textureAtlasName), ITextureAtlas) catch(e:Dynamic) null).dispose();
            }
        }
        
        _dataDic = null;
        _textureAtlasDic = null;
        _currentDataName = null;
        _currentTextureAtlasName = null;
    }
    
    /**
		 * Build and returns a new Armature instance.
		 * @example 
		 * <listing>
		 * var armature:Armature = factory.buildArmature('dragon');
		 * </listing>
		 * @param armatureName The name of this Armature instance.
		 * @param The name of this animation.
		 * @param The name of this SkeletonData.
		 * @param The name of this textureAtlas.
		 * @param The name of this skin.
		 * @return A Armature instance.
		 */
    public function buildArmature(armatureName:String, animationName:String = null, skeletonName:String = null, textureAtlasName:String = null, skinName:String = null):Armature
    {
        var data:SkeletonData;
        var armatureData:ArmatureData;
        var animationArmatureData:ArmatureData;
        var skinData:SkinData;
        var skinDataCopy:SkinData;
        
        if (skeletonName != null) 
        {
            data = Reflect.field(_dataDic, skeletonName);
            if (data != null) 
            {
                armatureData = data.getArmatureData(armatureName);
            }
        }
        else 
        {
            for (skeletonName in Reflect.fields(_dataDic))
            {
                data = Reflect.field(_dataDic, skeletonName);
                armatureData = data.getArmatureData(armatureName);
                if (armatureData != null) 
                {
                    break;
                }
            }
        }
        
        if (armatureData == null) 
        {
            return null;
        }
        
        _currentDataName = skeletonName;
        _currentTextureAtlasName = textureAtlasName || skeletonName;
        
        if (animationName != null && animationName != armatureName) 
        {
            animationArmatureData = data.getArmatureData(animationName);
            if (animationArmatureData == null) 
            {
                for (skeletonName in Reflect.fields(_dataDic))
                {
                    data = Reflect.field(_dataDic, skeletonName);
                    animationArmatureData = data.getArmatureData(animationName);
                    if (animationArmatureData != null) 
                    {
                        break;
                    }
                }
            }
            
            if (animationArmatureData != null) 
            {
                skinDataCopy = animationArmatureData.getSkinData("");
            }
        }
        
        skinData = armatureData.getSkinData(skinName);
        
        var armature:Armature = generateArmature();
        armature.name = armatureName;
        armature._armatureData = armatureData;
        
        if (animationArmatureData != null) 
        {
            armature.animation.animationDataList = animationArmatureData.animationDataList;
        }
        else 
        {
            armature.animation.animationDataList = armatureData.animationDataList;
        }  //  
        
        
        
        buildBones(armature, armatureData);
        
        //
        if (skinData != null) 
        {
            buildSlots(armature, armatureData, skinData, skinDataCopy);
        }  // update armature pose  
        
        
        
        armature.advanceTime(0);
        return armature;
    }
    
    /**
		 * Add a new animation to armature.
		 * @param animationRawData (XML, JSON).
		 * @param target armature.
		 */
    public function addAnimationToArmature(animationRawData:Dynamic, armature:Armature, isGlobalData:Bool = false):Void
    {
        armature._armatureData.addAnimationData(DataParser.parseAnimationDataByAnimationRawData(animationRawData, armature._armatureData, isGlobalData));
    }
    
    /**
		 * Return the TextureDisplay.
		 * @param The name of this Texture.
		 * @param The name of the TextureAtlas.
		 * @param The registration pivotX position.
		 * @param The registration pivotY position.
		 * @return An Object.
		 */
    public function getTextureDisplay(textureName:String, textureAtlasName:String = null, pivotX:Float = Math.Nan, pivotY:Float = Math.Nan):Dynamic
    {
        var textureAtlas:Dynamic;
        if (textureAtlasName != null) 
        {
            textureAtlas = Reflect.field(_textureAtlasDic, textureAtlasName);
        }
        
        if (textureAtlas == null && textureAtlasName == null) 
        {
            for (textureAtlasName in Reflect.fields(_textureAtlasDic))
            {
                textureAtlas = Reflect.field(_textureAtlasDic, textureAtlasName);
                if (textureAtlas.getRegion(textureName)) 
                {
                    break;
                }
                textureAtlas = null;
            }
        }
        
        if (textureAtlas != null) 
        {
            if (Math.isNaN(pivotX) || Math.isNaN(pivotY)) 
            {
                var data:SkeletonData = Reflect.field(_dataDic, textureAtlasName);
                if (data != null) 
                {
                    var pivot:Point = data.getSubTexturePivot(textureName);
                    if (pivot != null) 
                    {
                        pivotX = pivot.x;
                        pivotY = pivot.y;
                    }
                }
            }
            
            return generateDisplay(textureAtlas, textureName, pivotX, pivotY);
        }
        return null;
    }
    
    
    function buildBones(armature:Armature, armatureData:ArmatureData):Void
    {
        //按照从属关系的顺序建立
        for (i in 0...armatureData.boneDataList.length){
            var boneData:BoneData = armatureData.boneDataList[i];
            var bone:Bone = new Bone();
            bone.name = boneData.name;
            bone.inheritRotation = boneData.inheritRotation;
            bone.inheritScale = boneData.inheritScale;
            bone.origin.copy(boneData.transform);
            if (armatureData.getBoneData(boneData.parent)) 
            {
                armature.addBone(bone, boneData.parent);
            }
            else 
            {
                armature.addBone(bone);
            }
        }
    }
    
    
    function buildSlots(armature:Armature, armatureData:ArmatureData, skinData:SkinData, skinDataCopy:SkinData):Void
    {
        var helpArray:Array<Dynamic> = [];
        for (slotData/* AS3HX WARNING could not determine type for var: slotData exp: EField(EIdent(skinData),slotDataList) type: null */ in skinData.slotDataList)
        {
            var bone:Bone = armature.getBone(slotData.parent);
            if (bone == null) 
            {
                continue;
            }
            var slot:Slot = generateSlot();
            slot.name = slotData.name;
            slot.blendMode = slotData.blendMode;
            slot._originZOrder = slotData.zOrder;
            slot._displayDataList = slotData.displayDataList;
            
            helpArray.length = 0;
            var i:Int = slotData.displayDataList.length;
            while (i-->0)
            {
                var displayData:DisplayData = slotData.displayDataList[i];
                
                var _sw0_ = (displayData.type);                

                switch (_sw0_)
                {
                    case DisplayData.ARMATURE:
                        var displayDataCopy:DisplayData = null;
                        if (skinDataCopy != null) 
                        {
                            var slotDataCopy:SlotData = skinDataCopy.getSlotData(slotData.name);
                            if (slotDataCopy != null) 
                            {
                                displayDataCopy = slotDataCopy.displayDataList[i];
                            }
                        }
                        
                        var childArmature:Armature = buildArmature(displayData.name, (displayDataCopy != null) ? displayDataCopy.name:null, _currentDataName, _currentTextureAtlasName);
                        helpArray[i] = childArmature;
                    
                    case DisplayData.IMAGE:
                        helpArray[i] = generateDisplay(Reflect.field(_textureAtlasDic, _currentTextureAtlasName), displayData.name, displayData.pivot.x, displayData.pivot.y);
                    
                    default:
                        helpArray[i] = null;
                        break;
                }
            }  //如果显示对象有name属性并且name属性可以设置的话，将name设置为与slot同名，dragonBones并不依赖这些属性，只是方便开发者    //==================================================  
            
            
            
            
            
            for (displayObject in helpArray)
            {
                if (Std.is(displayObject, Armature)) 
                {
                    (try cast(displayObject, Armature) catch(e:Dynamic) null).display["name"] = slot.name;
                }
                else 
                {
                    if (displayObject != null && Lambda.has(displayObject, "name")) 
                    {
                        try
                        {
                            Reflect.setField(displayObject, "name", slot.name);
                        }                        catch (err:Error)
                        {
                            
                        }
                    }
                }
            }  //==================================================  
            
            
            bone.addChild(slot);
            slot.displayList = helpArray;
            slot.changeDisplay(0);
        }
    }
    
    
    function generateTextureAtlas(content:Dynamic, textureAtlasRawData:Dynamic):ITextureAtlas
    {
        return null;
    }
    
    /**
		 * @private
		 * Generates an Armature instance.
		 * @return Armature An Armature instance.
		 */
    function generateArmature():Armature
    {
        return null;
    }
    
    /**
		 * @private
		 * Generates an Slot instance.
		 * @return Slot An Slot instance.
		 */
    function generateSlot():Slot
    {
        return null;
    }
    
    /**
		 * @private
		 * Generates a DisplayObject
		 * @param textureAtlas The TextureAtlas.
		 * @param fullName A qualified name.
		 * @param pivotX A pivot x based value.
		 * @param pivotY A pivot y based value.
		 * @return
		 */
    function generateDisplay(textureAtlas:Dynamic, fullName:String, pivotX:Float, pivotY:Float):Dynamic
    {
        return null;
    }
    
    //==================================================
    //解析dbswf和dbpng，如果不能序列化amf3格式无法实现解析
    
    var _textureAtlasLoadingDic:Dynamic = { };
    
    /**
		 * Parses the raw data and returns a SkeletonData instance.	
		 * @example 
		 * <listing>
		 * import openfl.events.Event; 
		 * import dragonBones.factorys.NativeFactory;
		 * 
		 * [Embed(source = "../assets/Dragon1.swf", mimeType = "application/octet-stream")]
		 *	static const ResourcesData:Class;
		 * var factory:NativeFactory = new NativeFactory(); 
		 * factory.addEventListener(Event.COMPLETE, textureCompleteHandler);
		 * factory.parseData(new ResourcesData());
		 * </listing>
		 * @param ByteArray. Represents the raw data for the whole DragonBones system.
		 * @param String. (optional) The SkeletonData instance name.
		 * @param Boolean. (optional) flag if delay animation data parsing. Delay animation data parsing can reduce the data paring time to improve loading performance.
		 * @param Dictionary. (optional) output parameter. If it is not null, and ifSkipAnimationData is true, it will be fulfilled animationData, so that developers can parse it later.
		 * @return A SkeletonData instance.
		 */
    public function parseData(bytes:ByteArray, dataName:String = null, ifSkipAnimationData:Bool = false, outputAnimationDictionary:Dictionary = null):SkeletonData
    {
        if (bytes == null) 
        {
            throw new ArgumentError();
        }
        var decompressedData:DecompressedData = DataParser.decompressData(bytes);
        
        var data:SkeletonData = DataParser.parseData(decompressedData.dragonBonesData, ifSkipAnimationData, outputAnimationDictionary);
        
        dataName = dataName || data.name;
        addSkeletonData(data, dataName);
        var loader:Loader = new Loader();
        loader.name = dataName;
        Reflect.setField(_textureAtlasLoadingDic, dataName, decompressedData.textureAtlasData);
        loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loaderCompleteHandler);
        loader.loadBytes(decompressedData.textureBytes, _loaderContext);
        decompressedData.dispose();
        return data;
    }
    
    
    function loaderCompleteHandler(e:Event):Void
    {
        e.target.removeEventListener(Event.COMPLETE, loaderCompleteHandler);
        var loader:Loader = e.target.loader;
        var content:Dynamic = e.target.content;
        loader.unloadAndStop();
        
        var name:String = loader.name;
        var textureAtlasRawData:Dynamic = Reflect.field(_textureAtlasLoadingDic, name);
        if (name != null && textureAtlasRawData != null) 
        {
            if (Std.is(content, Bitmap)) 
            {
                content = (try cast(content, Bitmap) catch(e:Dynamic) null).bitmapData;
            }
            else if (Std.is(content, Sprite)) 
            {
                content = try cast((try cast(content, Sprite) catch(e:Dynamic) null).getChildAt(0), MovieClip) catch(e:Dynamic) null;
            }
            else 
            {
                //
                
            }
            
            var textureAtlas:Dynamic = generateTextureAtlas(content, textureAtlasRawData);
            addTextureAtlas(textureAtlas, name);
            
            name = null;
            for (name in Reflect.fields(_textureAtlasLoadingDic))
            {
                break;
            }  //  
            
            if (name == null && this.hasEventListener(Event.COMPLETE)) 
            {
                this.dispatchEvent(new Event(Event.COMPLETE));
            }
        }
    }
}
