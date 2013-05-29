package dragonbones.display;

/**
 * @author SlavaRa
 */
#if (flash11 && starling)
typedef DisplayBridge = StarlingDisplayBridge;
#else
typedef DisplayBridge = NativeDisplayBridge;
#end
