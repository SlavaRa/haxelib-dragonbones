package dragonbones.display;

#if (flash11 && starling)
typedef DisplayObject = starling.display.DisplayObject;
#else
typedef DisplayObject = nme.display.DisplayObject
#end