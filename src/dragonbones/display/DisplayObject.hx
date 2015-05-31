package dragonbones.display;

#if (flash11 && starling)
typedef DisplayBridge = StarlingDisplayBridge;
#else
typedef DisplayBridge = NativeDisplayBridge;
#end

#if (flash11 && starling)
typedef Sprite = starling.display.Sprite;
typedef DisplayObjectContainer = starling.display.DisplayObjectContainer;
typedef DisplayObject = starling.display.DisplayObject;
#elseif gm2d
typedef Sprite = gm2d.display.Sprite;
typedef DisplayObjectContainer = gm2d.display.DisplayObjectContainer;
typedef DisplayObject = gm2d.display.DisplayObject;
#else
typedef Sprite = flash.display.Sprite;
typedef DisplayObjectContainer = flash.display.DisplayObjectContainer;
typedef DisplayObject = flash.display.DisplayObject;
#end