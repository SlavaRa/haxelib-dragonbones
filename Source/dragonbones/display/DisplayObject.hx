package dragonbones.display;

#if (flash11 && starling)
typedef DisplayObject = starling.display.DisplayObject;
#elseif gm2d
typedef DisplayObject = gm2d.display.DisplayObject;
#else
typedef DisplayObject = flash.display.DisplayObject
#end