package dragonbones.display;

#if (flash11 && starling)
typedef Sprite = starling.display.Sprite;
#elseif gm2d
typedef Sprite = gm2d.display.Sprite;
#else
typedef Sprite = nme.display.Sprite;
#end