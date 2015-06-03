package dragonbones.utils;
import openfl.geom.Matrix;
import dragonbones.objects.DBTransform;

class TransformUtil
{
    static var HALF_PI = Math.PI * 0.5;
    static var DOUBLE_PI = Math.PI * 2;
    //static const _helpMatrix:Matrix = new Matrix();
    static var _helpTransformMatrix = new Matrix();
    static var _helpParentTransformMatrix = new Matrix();
    
    /*
		public static function transformPointWithParent(transform:DBTransform, parent:DBTransform):void
		{
			transformToMatrix(parent, _helpMatrix, true);
			_helpMatrix.invert();
			
			var x:Number = transform.x;
			var y:Number = transform.y;
			
			transform.x = _helpMatrix.a * x + _helpMatrix.c * y + _helpMatrix.tx;
			transform.y = _helpMatrix.d * y + _helpMatrix.b * x + _helpMatrix.ty;
			
			transform.skewX = formatRadian(transform.skewX - parent.skewX);
			transform.skewY = formatRadian(transform.skewY - parent.skewY);
		}
		*/
    public static function transformToMatrix(transform:DBTransform, matrix:Matrix, keepScale:Bool = false):Void
    {
        if (keepScale) 
        {
            matrix.a = transform.scaleX * Math.cos(transform.skewY);
            matrix.b = transform.scaleX * Math.sin(transform.skewY);
            matrix.c = -transform.scaleY * Math.sin(transform.skewX);
            matrix.d = transform.scaleY * Math.cos(transform.skewX);
            matrix.tx = transform.x;
            matrix.ty = transform.y;
        }
        else 
        {
            matrix.a = Math.cos(transform.skewY);
            matrix.b = Math.sin(transform.skewY);
            matrix.c = -Math.sin(transform.skewX);
            matrix.d = Math.cos(transform.skewX);
            matrix.tx = transform.x;
            matrix.ty = transform.y;
        }
    }
    
    public static function formatRadian(radian:Float):Float
    {
        if (radian > Math.PI) radian -= DOUBLE_PI;
        if (radian < -Math.PI) radian += DOUBLE_PI;
        return radian;
    }
    
    public static function globalToLocal(transform:DBTransform, parent:DBTransform):Void
    {
        transformToMatrix(transform, _helpTransformMatrix, true);
        transformToMatrix(parent, _helpParentTransformMatrix, true);
        _helpParentTransformMatrix.invert();
        _helpTransformMatrix.concat(_helpParentTransformMatrix);
        matrixToTransform(_helpTransformMatrix, transform, transform.scaleX * parent.scaleX >= 0, transform.scaleY * parent.scaleY >= 0);
    }
    
    public static function matrixToTransform(matrix:Matrix, transform:DBTransform, scaleXF:Bool, scaleYF:Bool):Void
    {
        transform.x = matrix.tx;
        transform.y = matrix.ty;
        transform.scaleX = Math.sqrt(matrix.a * matrix.a + matrix.b * matrix.b) * (scaleXF ? 1 : -1);
        transform.scaleY = Math.sqrt(matrix.d * matrix.d + matrix.c * matrix.c) * (scaleYF ? 1 : -1);
        
        var skewX0 = Math.acos(matrix.d / transform.scaleY);
        var skewX1 = -skewX0;
        var skewX2 = Math.asin(-matrix.c / transform.scaleY);
        var skewX3 = skewX2 >= 0 ? Math.PI - skewX2 : skewX2 - Math.PI;
        
        if (toFixed(skewX0, 4) == toFixed(skewX2, 4) || toFixed(skewX0, 4) == toFixed(skewX3, 4))
        {
            transform.skewX = skewX0;
        }
        else 
        {
            transform.skewX = skewX1;
        }
        
        var skewY0 = Math.acos(matrix.a / transform.scaleX);
        var skewY1 = -skewY0;
        var skewY2 = Math.asin(matrix.b / transform.scaleX);
        var skewY3 = skewY2 >= (0) ? Math.PI - skewY2 : skewY2 - Math.PI;
        if (toFixed(skewY0, 4) == toFixed(skewY2, 4) || toFixed(skewY0, 4) == toFixed(skewY3, 4)) 
        {
            transform.skewY = skewY0;
        }
        else 
        {
            transform.skewY = skewY1;
        }
    }

	static function toFixed(v:Float, decimalPlaces:Int):Float {
		decimalPlaces *= 10;
		return Std.int(v * decimalPlaces) / decimalPlaces;
	}
}