package dragonbones.objects;

typedef HelpNode = Array<Float>;

/**
 * @author SlavaRa
 */
class Node{

	public static inline var x:Int 		  = 0;
	public static inline var y:Int 		  = 1;
	public static inline var z:Int 		  = 2;
	public static inline var scaleX:Int   = 3;
	public static inline var scaleY:Int   = 4;
	public static inline var skewX:Int 	  = 5;
	public static inline var skewY:Int 	  = 6;
	public static inline var pivotX:Int   = 7;
	public static inline var pivotY:Int   = 8;
	public static inline var rotation:Int = 5;
	
	public static inline function create():HelpNode {
		var node:HelpNode = new HelpNode();
		node[0] = 0;
		node[1] = 0;
		node[2] = 0;
		node[3] = 0;
		node[4] = 0;
		node[5] = 0;
		node[6] = 0;
		node[7] = 0;
		node[8] = 0;
		return node;
	}
	
	public static inline function setValues(node:HelpNode, x:Float = 0, y:Float = 0, z:Float = 0, skewX:Float = 0, skewY:Float = 0, scaleX:Float = 0, scaleY:Float = 0, pivotX:Float = 0, pivotY:Float = 0) {
		node[0] = x == x ? x : 0;
		node[1] = y == y ? y : 0;
		node[2] = z == z ? Std.int(z) : 0;
		node[3] = scaleX == scaleX ? scaleX : 0;
		node[4] = scaleY == scaleY ? scaleY : 0;
		node[5] = skewX == skewX ? skewX : 0;
		node[6] = skewY == skewY ? skewY : 0;
		node[7] = pivotX == pivotX ? pivotX : 0;
		node[8] = pivotY == pivotY ? pivotY : 0;
	}
	
	public static inline function setxy(node:HelpNode, x:Float = 0, y:Float = 0) {
		node[0] = x;
		node[1] = y;
	}
	
	public static inline function setRotation(node:HelpNode, rotation:Float) {
		node[5] = rotation;
		node[6] = rotation;
	}
	
	public static inline function copy(from:HelpNode, to:HelpNode) {
		to[0] = from[0];
		to[1] = from[1];
		to[2] = from[2];
		to[3] = from[3];
		to[4] = from[4];
		to[5] = from[5];
		to[6] = from[6];
		to[7] = from[7];
		to[8] = from[8];
	}
	
	public static inline function setOffset(from:HelpNode, to:HelpNode) {
		to[0] -= from[0];
		to[1] -= from[1];
		to[2] -= from[2];
		to[3] -= from[3];
		to[4] -= from[4];
		to[5] -= from[5];
		to[6] -= from[6];
		to[7] -= from[7];
		to[8] -= from[8];
	}
	
	public static inline function setOffsetSkew(from:HelpNode, to:HelpNode) {
		to[5] -= from[5];
		to[6] -= from[6];
	}
}