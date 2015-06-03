package dragonbones.objects;
import dragonbones.objects.DecompressedData;
import dragonbones.objects.SkeletonData;
import dragonbones.utils.BytesType;
import dragonbones.utils.ConstValues;
import haxe.xml.Fast;
import openfl.errors.Error;
import openfl.utils.ByteArray;
import openfl.utils.Dictionary;

class DataParser
{
    /**
	 * Compress all data into a ByteArray for serialization.
	 * @param The DragonBones data.
	 * @param The TextureAtlas data.
	 * @param The ByteArray representing the map.
	 * @return ByteArray. A DragonBones compatible ByteArray.
	 */
    public static function compressData(dragonBonesData:Dynamic, textureAtlasData:Dynamic, textureDataBytes:ByteArray):ByteArray
    {
        var retult:ByteArray = new ByteArray();
        retult.writeBytes(textureDataBytes);
        
        var dataBytes:ByteArray = new ByteArray();
        dataBytes.writeObject(textureAtlasData);
        dataBytes.compress();
        
        retult.position = retult.length;
        retult.writeBytes(dataBytes);
        retult.writeInt(dataBytes.length);
        
        dataBytes.length = 0;
        dataBytes.writeObject(dragonBonesData);
        dataBytes.compress();
        
        retult.position = retult.length;
        retult.writeBytes(dataBytes);
        retult.writeInt(dataBytes.length);
        
        return retult;
    }
    
    /**
	 * Decompress a compatible DragonBones data.
	 * @param compressedByteArray The ByteArray to decompress.
	 * @return A DecompressedData instance.
	 */
    public static function decompressData(bytes:ByteArray):DecompressedData
    {
        var dataType:String = BytesType.getType(bytes);
        switch (dataType)
        {
            case BytesType.SWF, BytesType.PNG, BytesType.JPG, BytesType.ATF:
                var dragonBonesData:Dynamic;
                var textureAtlasData:Dynamic;
                try
                {
                    var bytesCopy:ByteArray = new ByteArray();
                    bytesCopy.writeBytes(bytes);
                    bytes = bytesCopy;
                    
                    bytes.position = bytes.length - 4;
                    var strSize:Int = bytes.readInt();
                    var position:Int = bytes.length - 4 - strSize;
                    
                    var dataBytes:ByteArray = new ByteArray();
                    dataBytes.writeBytes(bytes, position, strSize);
                    dataBytes.uncompress();
                    bytes.length = position;
                    
                    dragonBonesData = dataBytes.readObject();
                    
                    bytes.position = bytes.length - 4;
                    strSize = bytes.readInt();
                    position = bytes.length - 4 - strSize;
                    
                    dataBytes.length = 0;
                    dataBytes.writeBytes(bytes, position, strSize);
                    dataBytes.uncompress();
                    bytes.length = position;
                    
                    textureAtlasData = dataBytes.readObject();
                }                catch (e:Error)
                {
                    throw new Error("Data error!");
                }
                
                var decompressedData:DecompressedData = new DecompressedData(dragonBonesData, textureAtlasData, bytes);
                decompressedData.textureBytesDataType = dataType;
                return decompressedData;
            
            case BytesType.ZIP:
                throw new Error("Can not decompress zip!");
                throw new Error("Nonsupport data!");
            
            default:
                throw new Error("Nonsupport data!");
        }
        return null;
    }
    
    public static function parseTextureAtlas(rawData:Dynamic, scale:Float = 1):Dynamic
    {
        if (Std.is(rawData, Fast)) 
        {
            return XMLDataParser.parseTextureAtlasData(cast(rawData, Fast), scale);
        }
        else 
        {
            return ObjectDataParser.parseTextureAtlasData(rawData, scale);
        }
        return null;
    }
    
    public static function parseData(rawData:Dynamic, ifSkipAnimationData:Bool = false, outputAnimationDictionary:Dictionary = null):SkeletonData
    {
        if (Std.is(rawData, Fast)) 
        {
            return XMLDataParser.parseSkeletonData(try cast(rawData, Fast) catch(e:Dynamic) null, ifSkipAnimationData, outputAnimationDictionary);
        }
        else 
        {
            return ObjectDataParser.parseSkeletonData(rawData, ifSkipAnimationData, outputAnimationDictionary);
        }
        return null;
    }
    
    public static function parseAnimationDataByAnimationRawData(animationRawData:Dynamic, armatureData:ArmatureData, isGlobalData:Bool = false):AnimationData
    {
        var animationData:AnimationData = armatureData.animationDataList[0];
        
        if (Std.is(animationRawData, Fast)) 
        {
            return XMLDataParser.parseAnimationData(cast(animationRawData, Fast), armatureData, animationData.frameRate, isGlobalData);
        }
        else 
        {
            return ObjectDataParser.parseAnimationData(animationRawData, armatureData, animationData.frameRate, isGlobalData);
        }
    }
    
    public static function parseFrameRate(rawData:Dynamic):Int
    {
        if (Std.is(rawData, Fast)) 
        {
            return Std.parseInt(cast((rawData), Fast).attribute(ConstValues.A_FRAME_RATE));
        }
        else return Std.parseInt(rawData[ConstValues.A_FRAME_RATE]);
    }
}