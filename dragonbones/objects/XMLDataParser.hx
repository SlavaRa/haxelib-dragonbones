/**
 * Copyright 2012-2013. DragonBones. All Rights Reserved.
 */
package dragonbones.objects;
import dragonbones.core.DragonBones;
import dragonbones.textures.TextureData;
import dragonbones.utils.ConstValues;
import dragonbones.utils.DBDataUtil;
import haxe.xml.Fast;
import openfl.errors.ArgumentError;
import openfl.errors.Error;
import openfl.geom.ColorTransform;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import openfl.utils.Dictionary;

/**
 * The XMLDataParser class parses xml data from dragonBones generated maps.
 */
class XMLDataParser
{
    public static function parseTextureAtlasData(rawData:Fast, scale:Float = 1):Dynamic
    {
        var textureAtlasData:Dynamic = { };
        textureAtlasData.__name = rawData.node.attribute.innerData(ConstValues.A_NAME);
        var subTextureFrame:Rectangle;
        for (subTextureXML in rawData.get(ConstValues.SUB_TEXTURE))
        {
            var subTextureName:String = subTextureXML.node.attribute.innerData(ConstValues.A_NAME);
            
            var subTextureRegion:Rectangle = new Rectangle();
            subTextureRegion.x = as3hx.Compat.parseInt(subTextureXML.node.attribute.innerData(ConstValues.A_X)) / scale;
            subTextureRegion.y = as3hx.Compat.parseInt(subTextureXML.node.attribute.innerData(ConstValues.A_Y)) / scale;
            subTextureRegion.width = as3hx.Compat.parseInt(subTextureXML.node.attribute.innerData(ConstValues.A_WIDTH)) / scale;
            subTextureRegion.height = as3hx.Compat.parseInt(subTextureXML.node.attribute.innerData(ConstValues.A_HEIGHT)) / scale;
            var rotated:Bool = subTextureXML.node.attribute.innerData(ConstValues.A_ROTATED) == "true";
            
            var frameWidth:Float = as3hx.Compat.parseInt(subTextureXML.node.attribute.innerData(ConstValues.A_FRAME_WIDTH)) / scale;
            var frameHeight:Float = as3hx.Compat.parseInt(subTextureXML.node.attribute.innerData(ConstValues.A_FRAME_HEIGHT)) / scale;
            
            if (frameWidth > 0 && frameHeight > 0) 
            {
                subTextureFrame = new Rectangle();
                subTextureFrame.x = as3hx.Compat.parseInt(subTextureXML.node.attribute.innerData(ConstValues.A_FRAME_X)) / scale;
                subTextureFrame.y = as3hx.Compat.parseInt(subTextureXML.node.attribute.innerData(ConstValues.A_FRAME_Y)) / scale;
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
    
    /**
	 * Parse the SkeletonData.
	 * @param xml The SkeletonData xml to parse.
	 * @return A SkeletonData instance.
	 */
    public static function parseSkeletonData(rawData:Fast, ifSkipAnimationData:Bool = false, outputAnimationDictionary:Dictionary = null):SkeletonData
    {
        if (rawData == null) 
        {
            throw new ArgumentError();
        }
        var version:String = rawData.node.attribute.innerData(ConstValues.A_VERSION);
        switch (version)
        {
            
            case "2.3", "3.0", DragonBones.DATA_VERSION:
                switch (version)
                {
					case "3.0":
                    //Update2_3To3_0.format(rawData as XML);
                }
            default:
                throw new Error("Nonsupport version!");
        }
        
        var frameRate:Int = as3hx.Compat.parseInt(rawData.node.attribute.innerData(ConstValues.A_FRAME_RATE));
        
        var data:SkeletonData = new SkeletonData();
        data.name = rawData.node.attribute.innerData(ConstValues.A_NAME);
        var isGlobalData:Bool = rawData.node.attribute.innerData(ConstValues.A_IS_GLOBAL) == ("0") ? false:true;
        for (armatureXML in rawData.get(ConstValues.ARMATURE))
        {
            data.addArmatureData(parseArmatureData(armatureXML, data, frameRate, isGlobalData, ifSkipAnimationData, outputAnimationDictionary));
        }
        
        return data;
    }
    
    static function parseArmatureData(armatureXML:Fast, data:SkeletonData, frameRate:Int, isGlobalData:Bool, ifSkipAnimationData:Bool, outputAnimationDictionary:Dictionary):ArmatureData
    {
        var armatureData:ArmatureData = new ArmatureData();
        armatureData.name = armatureXML.node.attribute.innerData(ConstValues.A_NAME);
        
        for (boneXML in armatureXML.get(ConstValues.BONE))
        {
            armatureData.addBoneData(parseBoneData(boneXML, isGlobalData));
        }
        
        for (skinXML in armatureXML.get(ConstValues.SKIN))
        {
            armatureData.addSkinData(parseSkinData(skinXML, data));
        }
        
        if (isGlobalData) 
        {
            DBDataUtil.transformArmatureData(armatureData);
        }
        armatureData.sortBoneDataList();
        
        var animationXML:Fast;
        if (ifSkipAnimationData) 
        {
            if (outputAnimationDictionary != null) 
            {
                outputAnimationDictionary[armatureData.name] = new Dictionary();
            }
            
            var index:Int = 0;
            for (animationXML in armatureXML.get(ConstValues.ANIMATION))
            {
                if (index == 0) 
                {
                    armatureData.addAnimationData(parseAnimationData(animationXML, armatureData, frameRate, isGlobalData));
                }
                else if (outputAnimationDictionary != null) 
                {
                    outputAnimationDictionary[armatureData.name][animationXML.node.attribute.innerData(ConstValues.A_NAME)] = animationXML;
                }
                index++;
            }
        }
        else 
        {
            for (animationXML in armatureXML.get(ConstValues.ANIMATION))
            {
                armatureData.addAnimationData(parseAnimationData(animationXML, armatureData, frameRate, isGlobalData));
            }
        }
        
        for (rectangleXML in armatureXML.get(ConstValues.RECTANGLE))
        {
            armatureData.addAreaData(parseRectangleData(rectangleXML));
        }
        
        for (ellipseXML in armatureXML.get(ConstValues.ELLIPSE))
        {
            armatureData.addAreaData(parseEllipseData(ellipseXML));
        }
        
        return armatureData;
    }
    
    static function parseBoneData(boneXML:Fast, isGlobalData:Bool):BoneData
    {
        var boneData:BoneData = new BoneData();
        boneData.name = boneXML.node.attribute.innerData(ConstValues.A_NAME);
        boneData.parent = boneXML.node.attribute.innerData(ConstValues.A_PARENT);
        boneData.length = Std.parseFloat(boneXML.node.attribute.innerData(ConstValues.A_LENGTH));
        boneData.inheritRotation = getBoolean(boneXML, ConstValues.A_INHERIT_ROTATION, true);
        boneData.inheritScale = getBoolean(boneXML, ConstValues.A_INHERIT_SCALE, true);
        
        parseTransform(boneXML.get(ConstValues.TRANSFORM).get(0), boneData.transform);
        if (isGlobalData)   //绝对数据  
        {
            boneData.global.copy(boneData.transform);
        }
        
        for (rectangleXML in boneXML.get(ConstValues.RECTANGLE))
        {
            boneData.addAreaData(parseRectangleData(rectangleXML));
        }
        
        for (ellipseXML in boneXML.get(ConstValues.ELLIPSE))
        {
            boneData.addAreaData(parseEllipseData(ellipseXML));
        }
        
        return boneData;
    }
    
    static function parseRectangleData(rectangleXML:Fast):RectangleData
    {
        var rectangleData:RectangleData = new RectangleData();
        rectangleData.name = rectangleXML.node.attribute.innerData(ConstValues.A_NAME);
        rectangleData.width = Std.parseFloat(rectangleXML.node.attribute.innerData(ConstValues.A_WIDTH));
        rectangleData.height = Std.parseFloat(rectangleXML.node.attribute.innerData(ConstValues.A_HEIGHT));
        
        parseTransform(rectangleXML.get(ConstValues.TRANSFORM).get(0), rectangleData.transform, rectangleData.pivot);
        
        return rectangleData;
    }
    
    static function parseEllipseData(ellipseXML:Fast):EllipseData
    {
        var ellipseData:EllipseData = new EllipseData();
        ellipseData.name = ellipseXML.node.attribute.innerData(ConstValues.A_NAME);
        ellipseData.width = Std.parseFloat(ellipseXML.node.attribute.innerData(ConstValues.A_WIDTH));
        ellipseData.height = Std.parseFloat(ellipseXML.node.attribute.innerData(ConstValues.A_HEIGHT));
        
        parseTransform(ellipseXML.get(ConstValues.TRANSFORM).get(0), ellipseData.transform, ellipseData.pivot);
        
        return ellipseData;
    }
    
    static function parseSkinData(skinXML:Fast, data:SkeletonData):SkinData
    {
        var skinData:SkinData = new SkinData();
        skinData.name = skinXML.node.attribute.innerData(ConstValues.A_NAME);
        
        for (slotXML in skinXML.get(ConstValues.SLOT))
        {
            skinData.addSlotData(parseSlotData(slotXML, data));
        }
        
        return skinData;
    }
    
    static function parseSlotData(slotXML:Fast, data:SkeletonData):SlotData
    {
        var slotData:SlotData = new SlotData();
        slotData.name = slotXML.node.attribute.innerData(ConstValues.A_NAME);
        slotData.parent = slotXML.node.attribute.innerData(ConstValues.A_PARENT);
        slotData.zOrder = getNumber(slotXML, ConstValues.A_Z_ORDER, 0) || 0;
        slotData.blendMode = slotXML.node.attribute.innerData(ConstValues.A_BLENDMODE);
        for (displayXML in slotXML.get(ConstValues.DISPLAY))
        {
            slotData.addDisplayData(parseDisplayData(displayXML, data));
        }
        
        return slotData;
    }
    
    static function parseDisplayData(displayXML:Fast, data:SkeletonData):DisplayData
    {
        var displayData:DisplayData = new DisplayData();
        displayData.name = displayXML.node.attribute.innerData(ConstValues.A_NAME);
        displayData.type = displayXML.node.attribute.innerData(ConstValues.A_TYPE);
        
        displayData.pivot = data.addSubTexturePivot(
                        0,
                        0,
                        displayData.name
                        );
        
        parseTransform(displayXML.get(ConstValues.TRANSFORM).get(0), displayData.transform, displayData.pivot);
        
        return displayData;
    }
    
    
    static function parseAnimationData(animationXML:Fast, armatureData:ArmatureData, frameRate:Int, isGlobalData:Bool):AnimationData
    {
        var animationData:AnimationData = new AnimationData();
        animationData.name = animationXML.node.attribute.innerData(ConstValues.A_NAME);
        animationData.frameRate = frameRate;
        animationData.duration = Math.round((as3hx.Compat.parseInt(animationXML.node.attribute.innerData(ConstValues.A_DURATION)) || 1) * 1000 / frameRate);
        animationData.playTimes = as3hx.Compat.parseInt(getNumber(animationXML, ConstValues.A_LOOP, 1));
        animationData.fadeTime = getNumber(animationXML, ConstValues.A_FADE_IN_TIME, 0) || 0;
        animationData.scale = getNumber(animationXML, ConstValues.A_SCALE, 1) || 0;
        //use frame tweenEase, NaN
        //overwrite frame tweenEase, [-1, 0):ease in, 0:line easing, (0, 1]:ease out, (1, 2]:ease in out
        animationData.tweenEasing = getNumber(animationXML, ConstValues.A_TWEEN_EASING, NaN);
        animationData.autoTween = getBoolean(animationXML, ConstValues.A_AUTO_TWEEN, true);
        
        for (frameXML in animationXML.get(ConstValues.FRAME))
        {
            var frame:Frame = parseTransformFrame(frameXML, frameRate, isGlobalData);
            animationData.addFrame(frame);
        }
        
        parseTimeline(animationXML, animationData);
        
        var lastFrameDuration:Int = animationData.duration;
        for (timelineXML in animationXML.get(ConstValues.TIMELINE))
        {
            var timeline:TransformTimeline = parseTransformTimeline(timelineXML, animationData.duration, frameRate, isGlobalData);
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
    
    static function parseTransformTimeline(timelineXML:Fast, duration:Int, frameRate:Int, isGlobalData:Bool):TransformTimeline
    {
        var timeline:TransformTimeline = new TransformTimeline();
        timeline.name = timelineXML.node.attribute.innerData(ConstValues.A_NAME);
        timeline.scale = getNumber(timelineXML, ConstValues.A_SCALE, 1) || 0;
        timeline.offset = getNumber(timelineXML, ConstValues.A_OFFSET, 0) || 0;
        timeline.originPivot.x = getNumber(timelineXML, ConstValues.A_PIVOT_X, 0) || 0;
        timeline.originPivot.y = getNumber(timelineXML, ConstValues.A_PIVOT_Y, 0) || 0;
        timeline.duration = duration;
        
        for (frameXML in timelineXML.get(ConstValues.FRAME))
        {
            var frame:TransformFrame = parseTransformFrame(frameXML, frameRate, isGlobalData);
            timeline.addFrame(frame);
        }
        
        parseTimeline(timelineXML, timeline);
        
        return timeline;
    }
    
    static function parseMainFrame(frameXML:Fast, frameRate:Int):Frame
    {
        var frame:Frame = new Frame();
        parseFrame(frameXML, frame, frameRate);
        return frame;
    }
    
    static function parseTransformFrame(frameXML:Fast, frameRate:Int, isGlobalData:Bool):TransformFrame
    {
        var frame:TransformFrame = new TransformFrame();
        parseFrame(frameXML, frame, frameRate);
        
        frame.visible = !getBoolean(frameXML, ConstValues.A_HIDE, false);
        
        //NaN:no tween, 10:auto tween, [-1, 0):ease in, 0:line easing, (0, 1]:ease out, (1, 2]:ease in out
        frame.tweenEasing = getNumber(frameXML, ConstValues.A_TWEEN_EASING, 10);
        frame.tweenRotate = as3hx.Compat.parseInt(getNumber(frameXML, ConstValues.A_TWEEN_ROTATE, 0));
        frame.tweenScale = getBoolean(frameXML, ConstValues.A_TWEEN_SCALE, true);
        frame.displayIndex = as3hx.Compat.parseInt(getNumber(frameXML, ConstValues.A_DISPLAY_INDEX, 0));
        
        //如果为NaN，则说明没有改变过zOrder
        frame.zOrder = getNumber(frameXML, ConstValues.A_Z_ORDER, (isGlobalData) ? NaN:0);
        
        parseTransform(frameXML.get(ConstValues.TRANSFORM).get(0), frame.transform, frame.pivot);
        if (isGlobalData)   //绝对数据  
        {
            frame.global.copy(frame.transform);
        }
        
        frame.scaleOffset.x = getNumber(frameXML, ConstValues.A_SCALE_X_OFFSET, 0) || 0;
        frame.scaleOffset.y = getNumber(frameXML, ConstValues.A_SCALE_Y_OFFSET, 0) || 0;
        
        var colorTransformXML:Fast = frameXML.get(ConstValues.COLOR_TRANSFORM).get(0);
        if (colorTransformXML != null) 
        {
            frame.color = new ColorTransform();
            parseColorTransform(colorTransformXML, frame.color);
        }
        
        return frame;
    }
    
    static function parseTimeline(timelineXML:Fast, timeline:Timeline):Void
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
    
    static function parseFrame(frameXML:Fast, frame:Frame, frameRate:Int):Void
    {
        frame.duration = Math.round((as3hx.Compat.parseInt(frameXML.node.attribute.innerData(ConstValues.A_DURATION)) || 1) * 1000 / frameRate);
        frame.action = frameXML.node.attribute.innerData(ConstValues.A_ACTION);
        frame.event = frameXML.node.attribute.innerData(ConstValues.A_EVENT);
        frame.sound = frameXML.node.attribute.innerData(ConstValues.A_SOUND);
    }
    
    static function parseTransform(transformXML:Fast, transform:DBTransform, pivot:Point = null):Void
    {
        if (transformXML != null) 
        {
            if (transform != null) 
            {
                transform.x = getNumber(transformXML, ConstValues.A_X, 0) || 0;
                transform.y = getNumber(transformXML, ConstValues.A_Y, 0) || 0;
                transform.skewX = getNumber(transformXML, ConstValues.A_SKEW_X, 0) * ConstValues.ANGLE_TO_RADIAN || 0;
                transform.skewY = getNumber(transformXML, ConstValues.A_SKEW_Y, 0) * ConstValues.ANGLE_TO_RADIAN || 0;
                transform.scaleX = getNumber(transformXML, ConstValues.A_SCALE_X, 1) || 0;
                transform.scaleY = getNumber(transformXML, ConstValues.A_SCALE_Y, 1) || 0;
            }
            if (pivot != null) 
            {
                pivot.x = getNumber(transformXML, ConstValues.A_PIVOT_X, 0) || 0;
                pivot.y = getNumber(transformXML, ConstValues.A_PIVOT_Y, 0) || 0;
            }
        }
    }
    
    static function parseColorTransform(colorTransformXML:Fast, colorTransform:ColorTransform):Void
    {
        if (colorTransformXML != null) 
        {
            if (colorTransform != null) 
            {
                colorTransform.alphaOffset = as3hx.Compat.parseInt(colorTransformXML.node.attribute.innerData(ConstValues.A_ALPHA_OFFSET));
                colorTransform.redOffset = as3hx.Compat.parseInt(colorTransformXML.node.attribute.innerData(ConstValues.A_RED_OFFSET));
                colorTransform.greenOffset = as3hx.Compat.parseInt(colorTransformXML.node.attribute.innerData(ConstValues.A_GREEN_OFFSET));
                colorTransform.blueOffset = as3hx.Compat.parseInt(colorTransformXML.node.attribute.innerData(ConstValues.A_BLUE_OFFSET));
                
                colorTransform.alphaMultiplier = as3hx.Compat.parseInt(getNumber(colorTransformXML, ConstValues.A_ALPHA_MULTIPLIER, 100) || 100) * 0.01;
                colorTransform.redMultiplier = as3hx.Compat.parseInt(getNumber(colorTransformXML, ConstValues.A_RED_MULTIPLIER, 100) || 100) * 0.01;
                colorTransform.greenMultiplier = as3hx.Compat.parseInt(getNumber(colorTransformXML, ConstValues.A_GREEN_MULTIPLIER, 100) || 100) * 0.01;
                colorTransform.blueMultiplier = as3hx.Compat.parseInt(getNumber(colorTransformXML, ConstValues.A_BLUE_MULTIPLIER, 100) || 100) * 0.01;
            }
        }
    }
    
    static function getBoolean(data:Fast, key:String, defaultValue:Bool):Bool
    {
        if (data != null && data.node.attribute.innerData(key).length() > 0) 
        {
            switch (Std.string(data.node.attribute.innerData(key)))
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
    
    static function getNumber(data:Fast, key:String, defaultValue:Float):Float
    {
        if (data != null && data.node.attribute.innerData(key).length() > 0) 
        {
            switch (Std.string(data.node.attribute.innerData(key)))
            {
                case "NaN", "", "false", "null", "undefined":
                    return NaN;
                
                default:
                    return Std.parseFloat(data.node.attribute.innerData(key));
            }
        }
        return defaultValue;
    }
}
