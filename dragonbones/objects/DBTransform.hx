package dragonbones.objects;


/**
	* Copyright 2012-2013. DragonBones. All Rights Reserved.
	* @playerversion Flash 10.0
	* @langversion 3.0
	* @version 2.0
	*/
class DBTransform
{
    public var rotation(get, set):Float;

    /**
		 * Position on the x axis.
		 */
    public var x:Float;
    /**
		 * Position on the y axis.
		 */
    public var y:Float;
    /**
		 * Skew on the x axis.
		 */
    public var skewX:Float;
    /**
		 * skew on the y axis.
		 */
    public var skewY:Float;
    /**
		 * Scale on the x axis.
		 */
    public var scaleX:Float;
    /**
		 * Scale on the y axis.
		 */
    public var scaleY:Float;
    /**
		 * The rotation of that DBTransform instance.
		 */
    function get_Rotation():Float
    {
        return skewX;
    }
    function set_Rotation(value:Float):Float
    {
        skewX = skewY = value;
        return value;
    }
    /**
		 * Creat a new DBTransform instance.
		 */
    public function new()
    {
        x = 0;
        y = 0;
        skewX = 0;
        skewY = 0;
        scaleX = 1;
        scaleY = 1;
    }
    /**
		 * Copy all properties from this DBTransform instance to the passed DBTransform instance.
		 * @param node
		 */
    public function copy(transform:DBTransform):Void
    {
        x = transform.x;
        y = transform.y;
        skewX = transform.skewX;
        skewY = transform.skewY;
        scaleX = transform.scaleX;
        scaleY = transform.scaleY;
    }
    /**
		 * Get a string representing all DBTransform property values.
		 * @return String All property values in a formatted string.
		 */
    public function toString():String
    {
        var String:String = "x:" + x + " y:" + y + " skewX:" + skewX + " skewY:" + skewY + " scaleX:" + scaleX + " scaleY:" + scaleY;
        return String;
    }
}
