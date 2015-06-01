package dragonbones.objects;

import dragonbones.objects.RectangleData;
import nme.errors.ArgumentError;
import nme.errors.Error;

import dragonbones.core.DragonBones;
import dragonbones.core.DragonBonesInternal;
import dragonbones.objects.AnimationData;
import dragonbones.objects.ArmatureData;
import dragonbones.objects.BoneData;
import dragonbones.objects.DBTransform;
import dragonbones.objects.DisplayData;
import dragonbones.objects.Frame;
import dragonbones.objects.SkeletonData;
import dragonbones.objects.SkinData;
import dragonbones.objects.SlotData;
import dragonbones.objects.Timeline;
import dragonbones.objects.TransformFrame;
import dragonbones.objects.TransformTimeline;
import dragonbones.textures.TextureData;
import dragonbones.utils.ConstValues;
import dragonbones.utils.DBDataUtil;

import openfl.geom.ColorTransform;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import openfl.utils.Dictionary;



@:final class ObjectDataParser
{
    public static function parseTextureAtlasData(rawData:Dynamic, scale:Float = 1):Dynamic
    {
        var textureAtlasData:Dynamic = { };
        textureAtlasData.__name = rawData[ConstValues.A_NAME];
        var subTextureFrame:Rectangle;
        for (subTextureObject/* AS3HX WARNING could not determine type for var: subTextureObject exp: EArray(EIdent(rawData),EField(EIdent(ConstValues),SUB_TEXTURE)) type: Dynamic */ in rawData[ConstValues.SUB_TEXTURE])
        {
            var subTextureName:String = subTextureObject[ConstValues.A_NAME];
            var subTextureRegion:Rectangle = new Rectangle();
            subTextureRegion.x = as3hx.Compat.parseInt(subTextureObject[ConstValues.A_X]) / scale;
            subTextureRegion.y = as3hx.Compat.parseInt(subTextureObject[ConstValues.A_Y]) / scale;
            subTextureRegion.width = as3hx.Compat.parseInt(subTextureObject[ConstValues.A_WIDTH]) / scale;
            subTextureRegion.height = as3hx.Compat.parseInt(subTextureObject[ConstValues.A_HEIGHT]) / scale;
            
            var rotated:Bool = subTextureObject[ConstValues.A_ROTATED] == "true";
            
            var frameWidth:Float = as3hx.Compat.parseInt(subTextureObject[ConstValues.A_FRAME_WIDTH]) / scale;
            var frameHeight:Float = as3hx.Compat.parseInt(subTextureObject[ConstValues.A_FRAME_HEIGHT]) / scale;
            
            if (frameWidth > 0 && frameHeight > 0) 
            {
                subTextureFrame = new Rectangle();
                subTextureFrame.x = as3hx.Compat.parseInt(subTextureObject[ConstValues.A_FRAME_X]) / scale;
                subTextureFrame.y = as3hx.Compat.parseInt(subTextureObject[ConstValues.A_FRAME_Y]) / scale;
                subTextureFrame.width = frameWidth;
                subTextureFrame.height = frameHeight;
            }
            else 
            {
                subTextureFrame = null;
            }
            
            Reflect.setField(textureAtlasData, subTextureName, new TextureData(subTextureRegion, subTextureFrame, rotated));
        }
        
        return textureAtlasData;
    }
    
    public static function parseSkeletonData(rawData:Dynamic, ifSkipAnimationData:Bool = false, outputAnimationDictionary:Dictionary = null):SkeletonData
    {
        if (rawData == null) 
        {
            throw new ArgumentError();
        }
        
        var version:String = rawData[ConstValues.A_VERSION];
        switch (version)
        {
            case "2.3", "3.0", DragonBones.DATA_VERSION:
            
            default:
                throw new Error("Nonsupport version!");
        }
        
        var frameRate:Int = as3hx.Compat.parseInt(rawData[ConstValues.A_FRAME_RATE]);
        
        var data:SkeletonData = new SkeletonData();
        data.name = rawData[ConstValues.A_NAME];
        
        var isGlobalData:Bool = rawData[ConstValues.A_IS_GLOBAL] == ("0") ? false:true;
        
        for (armatureObject/* AS3HX WARNING could not determine type for var: armatureObject exp: EArray(EIdent(rawData),EField(EIdent(ConstValues),ARMATURE)) type: Dynamic */ in rawData[ConstValues.ARMATURE])
        {
            data.addArmatureData(parseArmatureData(armatureObject, data, frameRate, isGlobalData, ifSkipAnimationData, outputAnimationDictionary));
        }
        
        return data;
    }
    
    static function parseArmatureData(armatureObject:Dynamic, data:SkeletonData, frameRate:Int, isGlobalData:Bool, ifSkipAnimationData:Bool, outputAnimationDictionary:Dictionary):ArmatureData
    {
        var armatureData:ArmatureData = new ArmatureData();
        armatureData.name = armatureObject[ConstValues.A_NAME];
        
        for (boneObject/* AS3HX WARNING could not determine type for var: boneObject exp: EArray(EIdent(armatureObject),EField(EIdent(ConstValues),BONE)) type: Dynamic */ in armatureObject[ConstValues.BONE])
        {
            armatureData.addBoneData(parseBoneData(boneObject, isGlobalData));
        }
        
        for (skinObject/* AS3HX WARNING could not determine type for var: skinObject exp: EArray(EIdent(armatureObject),EField(EIdent(ConstValues),SKIN)) type: Dynamic */ in armatureObject[ConstValues.SKIN])
        {
            armatureData.addSkinData(parseSkinData(skinObject, data));
        }
        
        if (isGlobalData) 
        {
            DBDataUtil.transformArmatureData(armatureData);
        }
        
        armatureData.sortBoneDataList();
        
        var animationObject:Dynamic;
        if (ifSkipAnimationData) 
        {
            if (outputAnimationDictionary != null) 
            {
                outputAnimationDictionary[armatureData.name] = new Dictionary();
            }
            
            var index:Int = 0;
            for (animationObject/* AS3HX WARNING could not determine type for var: animationObject exp: EArray(EIdent(armatureObject),EField(EIdent(ConstValues),ANIMATION)) type: Dynamic */ in armatureObject[ConstValues.ANIMATION])
            {
                if (index == 0) 
                {
                    armatureData.addAnimationData(parseAnimationData(animationObject, armatureData, frameRate, isGlobalData));
                }
                else if (outputAnimationDictionary != null) 
                {
                    Reflect.setField(outputAnimationDictionary[armatureData.name], Std.string(animationObject[ConstValues.A_NAME]), animationObject);
                }
                index++;
            }
        }
        else 
        {
            for (animationObject/* AS3HX WARNING could not determine type for var: animationObject exp: EArray(EIdent(armatureObject),EField(EIdent(ConstValues),ANIMATION)) type: Dynamic */ in armatureObject[ConstValues.ANIMATION])
            {
                armatureData.addAnimationData(parseAnimationData(animationObject, armatureData, frameRate, isGlobalData));
            }
        }
        
        for (rectangleObject/* AS3HX WARNING could not determine type for var: rectangleObject exp: EArray(EIdent(armatureObject),EField(EIdent(ConstValues),RECTANGLE)) type: Dynamic */ in armatureObject[ConstValues.RECTANGLE])
        {
            armatureData.addAreaData(parseRectangleData(rectangleObject));
        }
        
        for (ellipseObject/* AS3HX WARNING could not determine type for var: ellipseObject exp: EArray(EIdent(armatureObject),EField(EIdent(ConstValues),ELLIPSE)) type: Dynamic */ in armatureObject[ConstValues.ELLIPSE])
        {
            armatureData.addAreaData(parseEllipseData(ellipseObject));
        }
        
        return armatureData;
    }
    
    static function parseBoneData(boneObject:Dynamic, isGlobalData:Bool):BoneData
    {
        var boneData:BoneData = new BoneData();
        boneData.name = boneObject[ConstValues.A_NAME];
        boneData.parent = boneObject[ConstValues.A_PARENT];
        boneData.length = Std.parseFloat(boneObject[ConstValues.A_LENGTH]);
        //boneData.inheritRotation = getBoolean(boneObject, ConstValues.A_INHERIT_ROTATION, true);
        //boneData.inheritScale = getBoolean(boneObject, ConstValues.A_INHERIT_SCALE, true);
        
        parseTransform(boneObject[ConstValues.TRANSFORM], boneData.transform);
        if (isGlobalData)   //绝对数据  
        {
            boneData.global.copy(boneData.transform);
        }
        
        for (rectangleObject/* AS3HX WARNING could not determine type for var: rectangleObject exp: EArray(EIdent(boneObject),EField(EIdent(ConstValues),RECTANGLE)) type: Dynamic */ in boneObject[ConstValues.RECTANGLE])
        {
            boneObject.addAreaData(parseRectangleData(rectangleObject));
        }
        
        for (ellipseObject/* AS3HX WARNING could not determine type for var: ellipseObject exp: EArray(EIdent(boneObject),EField(EIdent(ConstValues),ELLIPSE)) type: Dynamic */ in boneObject[ConstValues.ELLIPSE])
        {
            boneObject.addAreaData(parseEllipseData(ellipseObject));
        }
        
        return boneData;
    }
    
    static function parseRectangleData(rectangleObject:Dynamic):RectangleData
    {
        var rectangleData:RectangleData = new RectangleData();
        rectangleData.name = rectangleObject[ConstValues.A_NAME];
        rectangleData.width = Std.parseFloat(rectangleObject[ConstValues.A_WIDTH]);
        rectangleData.height = Std.parseFloat(rectangleObject[ConstValues.A_HEIGHT]);
        
        parseTransform(rectangleObject[ConstValues.TRANSFORM], rectangleData.transform, rectangleData.pivot);
        
        return rectangleData;
    }
    
    static function parseEllipseData(ellipseObject:Dynamic):EllipseData
    {
        var ellipseData:EllipseData = new EllipseData();
        ellipseData.name = ellipseObject[ConstValues.A_NAME];
        ellipseData.width = Std.parseFloat(ellipseObject[ConstValues.A_WIDTH]);
        ellipseData.height = Std.parseFloat(ellipseObject[ConstValues.A_HEIGHT]);
        
        parseTransform(ellipseObject[ConstValues.TRANSFORM], ellipseData.transform, ellipseData.pivot);
        
        return ellipseData;
    }
    
    static function parseSkinData(skinObject:Dynamic, data:SkeletonData):SkinData
    {
        var skinData:SkinData = new SkinData();
        skinData.name = skinObject[ConstValues.A_NAME];
        
        for (slotObject/* AS3HX WARNING could not determine type for var: slotObject exp: EArray(EIdent(skinObject),EField(EIdent(ConstValues),SLOT)) type: Dynamic */ in skinObject[ConstValues.SLOT])
        {
            skinData.addSlotData(parseSlotData(slotObject, data));
        }
        
        return skinData;
    }
    
    static function parseSlotData(slotObject:Dynamic, data:SkeletonData):SlotData
    {
        var slotData:SlotData = new SlotData();
        slotData.name = slotObject[ConstValues.A_NAME];
        slotData.parent = slotObject[ConstValues.A_PARENT];
        slotData.zOrder = getNumber(slotObject, ConstValues.A_Z_ORDER, 0) || 0;
        slotData.blendMode = slotObject[ConstValues.A_BLENDMODE];
        
        for (displayObject/* AS3HX WARNING could not determine type for var: displayObject exp: EArray(EIdent(slotObject),EField(EIdent(ConstValues),DISPLAY)) type: Dynamic */ in slotObject[ConstValues.DISPLAY])
        {
            slotData.addDisplayData(parseDisplayData(displayObject, data));
        }
        
        return slotData;
    }
    
    static function parseDisplayData(displayObject:Dynamic, data:SkeletonData):DisplayData
    {
        var displayData:DisplayData = new DisplayData();
        displayData.name = displayObject[ConstValues.A_NAME];
        displayData.type = displayObject[ConstValues.A_TYPE];
        
        displayData.pivot = data.addSubTexturePivot(
                        0,
                        0,
                        displayData.name
                        );
        
        parseTransform(displayObject[ConstValues.TRANSFORM], displayData.transform, displayData.pivot);
        
        return displayData;
    }
    
    
    static function parseAnimationData(animationObject:Dynamic, armatureData:ArmatureData, frameRate:Int, isGlobalData:Bool):AnimationData
    {
        var animationData:AnimationData = new AnimationData();
        animationData.name = animationObject[ConstValues.A_NAME];
        animationData.frameRate = frameRate;
        animationData.duration = Math.round((Std.parseFloat(animationObject[ConstValues.A_DURATION]) || 1) * 1000 / frameRate);
        animationData.playTimes = as3hx.Compat.parseInt(getNumber(animationObject, ConstValues.A_LOOP, 1));
        animationData.fadeTime = getNumber(animationObject, ConstValues.A_FADE_IN_TIME, 0) || 0;
        animationData.scale = getNumber(animationObject, ConstValues.A_SCALE, 1) || 0;
        //use frame tweenEase, NaN
        //overwrite frame tweenEase, [-1, 0):ease in, 0:line easing, (0, 1]:ease out, (1, 2]:ease in out
        animationData.tweenEasing = getNumber(animationObject, ConstValues.A_TWEEN_EASING, NaN);
        animationData.autoTween = getBoolean(animationObject, ConstValues.A_AUTO_TWEEN, true);
        
        for (frameObject/* AS3HX WARNING could not determine type for var: frameObject exp: EArray(EIdent(animationObject),EField(EIdent(ConstValues),FRAME)) type: Dynamic */ in animationObject[ConstValues.FRAME])
        {
            var frame:Frame = parseTransformFrame(frameObject, frameRate, isGlobalData);
            animationData.addFrame(frame);
        }
        
        parseTimeline(animationObject, animationData);
        
        var lastFrameDuration:Int = animationData.duration;
        for (timelineObject/* AS3HX WARNING could not determine type for var: timelineObject exp: EArray(EIdent(animationObject),EField(EIdent(ConstValues),TIMELINE)) type: Dynamic */ in animationObject[ConstValues.TIMELINE])
        {
            var timeline:TransformTimeline = parseTransformTimeline(timelineObject, animationData.duration, frameRate, isGlobalData);
            lastFrameDuration = Math.min(lastFrameDuration, timeline.frameList[timeline.frameList.length - 1].duration);
            animationData.addTimeline(timeline);
        }
        
        if (animationData.frameList.length > 0) 
        {
            lastFrameDuration = Math.min(lastFrameDuration, animationData.frameList[animationData.frameList.length - 1].duration);
        }
        animationData.lastFrameDuration = lastFrameDuration;
        
        DBDataUtil.addHideTimeline(animationData, armatureData);
        DBDataUtil.transformAnimationData(animationData, armatureData, isGlobalData);
        
        return animationData;
    }
    
    static function parseTransformTimeline(timelineObject:Dynamic, duration:Int, frameRate:Int, isGlobalData:Bool):TransformTimeline
    {
        var timeline:TransformTimeline = new TransformTimeline();
        timeline.name = timelineObject[ConstValues.A_NAME];
        timeline.scale = getNumber(timelineObject, ConstValues.A_SCALE, 1) || 0;
        timeline.offset = getNumber(timelineObject, ConstValues.A_OFFSET, 0) || 0;
        timeline.originPivot.x = getNumber(timelineObject, ConstValues.A_PIVOT_X, 0) || 0;
        timeline.originPivot.y = getNumber(timelineObject, ConstValues.A_PIVOT_Y, 0) || 0;
        timeline.duration = duration;
        
        for (frameObject/* AS3HX WARNING could not determine type for var: frameObject exp: EArray(EIdent(timelineObject),EField(EIdent(ConstValues),FRAME)) type: Dynamic */ in timelineObject[ConstValues.FRAME])
        {
            var frame:TransformFrame = parseTransformFrame(frameObject, frameRate, isGlobalData);
            timeline.addFrame(frame);
        }
        
        parseTimeline(timelineObject, timeline);
        
        return timeline;
    }
    
    static function parseMainFrame(frameObject:Dynamic, frameRate:Int):Frame
    {
        var frame:Frame = new Frame();
        parseFrame(frameObject, frame, frameRate);
        return frame;
    }
    
    static function parseTransformFrame(frameObject:Dynamic, frameRate:Int, isGlobalData:Bool):TransformFrame
    {
        var frame:TransformFrame = new TransformFrame();
        parseFrame(frameObject, frame, frameRate);
        
        frame.visible = !getBoolean(frameObject, ConstValues.A_HIDE, false);
        
        //NaN:no tween, 10:auto tween, [-1, 0):ease in, 0:line easing, (0, 1]:ease out, (1, 2]:ease in out
        frame.tweenEasing = getNumber(frameObject, ConstValues.A_TWEEN_EASING, 10);
        frame.tweenRotate = as3hx.Compat.parseInt(getNumber(frameObject, ConstValues.A_TWEEN_ROTATE, 0));
        frame.tweenScale = getBoolean(frameObject, ConstValues.A_TWEEN_SCALE, true);
        frame.displayIndex = as3hx.Compat.parseInt(getNumber(frameObject, ConstValues.A_DISPLAY_INDEX, 0));
        
        //如果为NaN，则说明没有改变过zOrder
        frame.zOrder = getNumber(frameObject, ConstValues.A_Z_ORDER, (isGlobalData) ? NaN:0);
        
        parseTransform(frameObject[ConstValues.TRANSFORM], frame.transform, frame.pivot);
        if (isGlobalData)   //绝对数据  
        {
            frame.global.copy(frame.transform);
        }
        
        frame.scaleOffset.x = getNumber(frameObject, ConstValues.A_SCALE_X_OFFSET, 0) || 0;
        frame.scaleOffset.y = getNumber(frameObject, ConstValues.A_SCALE_Y_OFFSET, 0) || 0;
        
        var colorTransformObject:Dynamic = frameObject[ConstValues.COLOR_TRANSFORM];
        if (colorTransformObject != null) 
        {
            frame.color = new ColorTransform();
            parseColorTransform(colorTransformObject, frame.color);
        }
        
        return frame;
    }
    
    static function parseTimeline(timelineObject:Dynamic, timeline:Timeline):Void
    {
        var position:Int = 0;
        var frame:Frame;
        for (frame/* AS3HX WARNING could not determine type for var: frame exp: EField(EIdent(timeline),frameList) type: null */ in timeline.frameList)
        {
            frame.position = position;
            position += frame.duration;
        }
        if (frame != null) 
        {
            frame.duration = timeline.duration - frame.position;
        }
    }
    
    static function parseFrame(frameObject:Dynamic, frame:Frame, frameRate:Int):Void
    {
        frame.duration = Math.round((Std.parseFloat(frameObject[ConstValues.A_DURATION]) || 1) * 1000 / frameRate);
        frame.action = frameObject[ConstValues.A_ACTION];
        frame.event = frameObject[ConstValues.A_EVENT];
        frame.sound = frameObject[ConstValues.A_SOUND];
    }
    
    static function parseTransform(transformObject:Dynamic, transform:DBTransform, pivot:Point = null):Void
    {
        if (transformObject != null) 
        {
            if (transform != null) 
            {
                transform.x = getNumber(transformObject, ConstValues.A_X, 0) || 0;
                transform.y = getNumber(transformObject, ConstValues.A_Y, 0) || 0;
                transform.skewX = getNumber(transformObject, ConstValues.A_SKEW_X, 0) * ConstValues.ANGLE_TO_RADIAN || 0;
                transform.skewY = getNumber(transformObject, ConstValues.A_SKEW_Y, 0) * ConstValues.ANGLE_TO_RADIAN || 0;
                transform.scaleX = getNumber(transformObject, ConstValues.A_SCALE_X, 1) || 0;
                transform.scaleY = getNumber(transformObject, ConstValues.A_SCALE_Y, 1) || 0;
            }
            if (pivot != null) 
            {
                pivot.x = getNumber(transformObject, ConstValues.A_PIVOT_X, 0) || 0;
                pivot.y = getNumber(transformObject, ConstValues.A_PIVOT_Y, 0) || 0;
            }
        }
    }
    
    static function parseColorTransform(colorTransformObject:Dynamic, colorTransform:ColorTransform):Void
    {
        if (colorTransformObject != null) 
        {
            if (colorTransform != null) 
            {
                colorTransform.alphaOffset = as3hx.Compat.parseInt(colorTransformObject[ConstValues.A_ALPHA_OFFSET]);
                colorTransform.redOffset = as3hx.Compat.parseInt(colorTransformObject[ConstValues.A_RED_OFFSET]);
                colorTransform.greenOffset = as3hx.Compat.parseInt(colorTransformObject[ConstValues.A_GREEN_OFFSET]);
                colorTransform.blueOffset = as3hx.Compat.parseInt(colorTransformObject[ConstValues.A_BLUE_OFFSET]);
                
                colorTransform.alphaMultiplier = as3hx.Compat.parseInt(getNumber(colorTransformObject, ConstValues.A_ALPHA_MULTIPLIER, 100) || 100) * 0.01;
                colorTransform.redMultiplier = as3hx.Compat.parseInt(getNumber(colorTransformObject, ConstValues.A_RED_MULTIPLIER, 100) || 100) * 0.01;
                colorTransform.greenMultiplier = as3hx.Compat.parseInt(getNumber(colorTransformObject, ConstValues.A_GREEN_MULTIPLIER, 100) || 100) * 0.01;
                colorTransform.blueMultiplier = as3hx.Compat.parseInt(getNumber(colorTransformObject, ConstValues.A_BLUE_MULTIPLIER, 100) || 100) * 0.01;
            }
        }
    }
    
    static function getBoolean(data:Dynamic, key:String, defaultValue:Bool):Bool
    {
        if (data != null && Lambda.has(data, key)) 
        {
            switch (Std.string(Reflect.field(data, key)))
            {
                case "0", "NaN", "", "false", "null", "undefined":
                    return false;
                case "1", "true":
                    return true;
                default:
                    return true;
            }
        }
        return defaultValue;
    }
    
    static function getNumber(data:Dynamic, key:String, defaultValue:Float):Float
    {
        if (data != null && Lambda.has(data, key)) 
        {
            switch (Std.string(Reflect.field(data, key)))
            {
                case "NaN", "", "false", "null", "undefined":
                    return NaN;
                
                default:
                    return Std.parseFloat(Reflect.field(data, key));
            }
        }
        return defaultValue;
    }

    public function new()
    {
    }
}
