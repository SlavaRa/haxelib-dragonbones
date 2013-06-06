package dragonbones.utils;

import dragonbones.objects.Node;
import flash.geom.ColorTransform;
import flash.geom.Matrix;
import flash.geom.Point;

/**
 * @author SlavaRa
 */
class TransformUtils{
	
	static var _helpMatrix:Matrix = new Matrix();
	static var _helpPoint:Point = new Point();
	
	public static inline function transformPointWithParent(bone:HelpNode, parent:HelpNode) {
		nodeToMatrix(parent, _helpMatrix);
		
		_helpPoint.x = bone[Node.x];
		_helpPoint.y = bone[Node.y];
		
		_helpMatrix.invert();
		_helpPoint = _helpMatrix.transformPoint(_helpPoint);
		
		Node.setxy(bone, _helpPoint.x, _helpPoint.y);
		Node.setOffsetSkew(parent, bone);
	}
	
	public static inline function nodeToMatrix(node:HelpNode, resultMatrix:Matrix) {
		resultMatrix.a = resultMatrix.d = MathUtils.cos(node[Node.rotation]);
		resultMatrix.c = -(resultMatrix.b = MathUtils.sin(node[Node.rotation]));
		resultMatrix.a *= node[Node.scaleX];
		resultMatrix.b *= node[Node.scaleX];
		resultMatrix.c *= node[Node.scaleY];
		resultMatrix.d *= node[Node.scaleY];  
		resultMatrix.tx = node[Node.x];
		resultMatrix.ty = node[Node.y];  
	}
	
	public static inline function setOffSetColorTransform(from:ColorTransform, to:ColorTransform, offset:ColorTransform) {
		offset.alphaOffset 		= to.alphaOffset     - from.alphaOffset;
		offset.redOffset 		= to.redOffset       - from.redOffset;
		offset.greenOffset 		= to.greenOffset     - from.greenOffset;
		offset.blueOffset 		= to.blueOffset      - from.blueOffset;
		offset.alphaMultiplier 	= to.alphaMultiplier - from.alphaMultiplier;
		offset.redMultiplier 	= to.redMultiplier   - from.redMultiplier;
		offset.greenMultiplier 	= to.greenMultiplier - from.greenMultiplier;
		offset.blueMultiplier 	= to.blueMultiplier  - from.blueMultiplier;
	}
	
	public static inline function setTweenColorTransform(current:ColorTransform, offSet:ColorTransform, tween:ColorTransform, progress:Float) {
		tween.alphaOffset 		= current.alphaOffset     + offSet.alphaOffset     * progress;
		tween.redOffset 		= current.redOffset       + offSet.redOffset       * progress;
		tween.greenOffset 		= current.greenOffset     + offSet.greenOffset     * progress;
		tween.blueOffset 		= current.blueOffset      + offSet.blueOffset      * progress;
		tween.alphaMultiplier 	= current.alphaMultiplier + offSet.alphaMultiplier * progress;
		tween.redMultiplier 	= current.redMultiplier   + offSet.redMultiplier   * progress;
		tween.greenMultiplier 	= current.greenMultiplier + offSet.greenMultiplier * progress;
		tween.blueMultiplier 	= current.blueMultiplier  + offSet.blueMultiplier  * progress;
	}
	
	public static inline function setOffSetNode(from:HelpNode, to:HelpNode, offSet:HelpNode, tweenRotate:Int = 0) {
		offSet[Node.x] 		= to[Node.x]      - from[Node.x];
		offSet[Node.y] 		= to[Node.y]      - from[Node.y];
		offSet[Node.skewX] 	= to[Node.skewX]  - from[Node.skewX];
		offSet[Node.skewY] 	= to[Node.skewY]  - from[Node.skewY];
		offSet[Node.scaleX]	= to[Node.scaleX] - from[Node.scaleX];
		offSet[Node.scaleY]	= to[Node.scaleY] - from[Node.scaleY];
		offSet[Node.pivotX]	= to[Node.pivotX] - from[Node.pivotX];
		offSet[Node.pivotY]	= to[Node.pivotY] - from[Node.pivotY];
	}
	
	public static inline function setTweenNode(current:HelpNode, offSet:HelpNode, tween:HelpNode, progress:Float) {
		Node.setValues(tween,
			current[Node.x]      + offSet[Node.x]      * progress,
			current[Node.y]      + offSet[Node.y]      * progress,
			Std.int(tween[Node.z]),
			current[Node.skewX]  + offSet[Node.skewX]  * progress,
			current[Node.skewY]  + offSet[Node.skewY]  * progress,
			current[Node.scaleX] + offSet[Node.scaleX] * progress,
			current[Node.scaleY] + offSet[Node.scaleY] * progress,
			current[Node.pivotX] + offSet[Node.pivotX] * progress,
			current[Node.pivotY] + offSet[Node.pivotY] * progress
		);
	}

	public static inline function copyColorTransform(from:ColorTransform, to:ColorTransform) {
		to.alphaOffset 		= from.alphaOffset;
		to.redOffset 		= from.redOffset;
		to.greenOffset 		= from.greenOffset;
		to.blueOffset 		= from.blueOffset;
		to.alphaMultiplier 	= from.alphaMultiplier;
		to.redMultiplier 	= from.redMultiplier;
		to.greenMultiplier 	= from.greenMultiplier;
		to.blueMultiplier 	= from.blueMultiplier;
	}
	
}