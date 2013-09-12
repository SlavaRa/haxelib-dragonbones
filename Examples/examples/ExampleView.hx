package examples;

/**
 * @author SlavaRa
 */
#if (flash11 && starling)
typedef ExampleView = examples.starling.StarlingView;
#elseif gm2d
typedef ExampleView = examples.gm2d.GM2DView;
#elseif flixel
typedef ExampleView = examples.flixel.FlixelView;
#else
typedef ExampleView = examples.openfl.OpenFLView;
#end