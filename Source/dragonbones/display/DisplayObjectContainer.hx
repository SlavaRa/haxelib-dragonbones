package dragonbones.display;

#if (flash11 && starling)
typedef DisplayObjectContainer = starling.display.DisplayObjectContainer;
#elseif gm2d
typedef DisplayObjectContainer = gm2d.display.DisplayObjectContainer;
#else
typedef DisplayObjectContainer = flash.display.DisplayObjectContainer;
#end