package dragonbones.display;
import dragonbones.Slot;
import openfl.display.BlendMode;
import openfl.display.DisplayObject;
import openfl.display.DisplayObjectContainer;

class NativeSlot extends Slot
{
    var _nativeDisplay:DisplayObject;
    
    public function new()
    {
        super(this);
        _nativeDisplay = null;
    }
    
    public override function dispose():Void
    {
        super.dispose();
        _nativeDisplay = null;
    }
    
    override function updateDisplay(value:Dynamic):Void
    {
        _nativeDisplay = cast(value, DisplayObject);
    }
    
    override function getDisplayIndex():Int
    {
        if (_nativeDisplay != null && _nativeDisplay.parent != null) 
        {
            return _nativeDisplay.parent.getChildIndex(_nativeDisplay);
        }
        return -1;
    }
    
    override function addDisplayToContainer(container:Dynamic, index:Int = -1):Void
    {
        var nativeContainer:DisplayObjectContainer = try cast(container, DisplayObjectContainer) catch(e:Dynamic) null;
        if (_nativeDisplay != null && nativeContainer != null) 
        {
            if (index < 0) 
            {
                nativeContainer.addChild(_nativeDisplay);
            }
            else 
            {
                nativeContainer.addChildAt(_nativeDisplay, Math.min(index, nativeContainer.numChildren));
            }
        }
    }
    
    
    override function removeDisplayFromContainer():Void
    {
        if (_nativeDisplay != null && _nativeDisplay.parent != null) 
        {
            _nativeDisplay.parent.removeChild(_nativeDisplay);
        }
    }
    
    
    override function updateTransform():Void
    {
        if (_nativeDisplay != null) 
        {
            _nativeDisplay.transform.matrix = this._globalTransformMatrix;
        }
    }
    
    
    override function updateDisplayVisible(value:Bool):Void
    {
        if (_nativeDisplay != null) 
        {
            _nativeDisplay.visible = this._parent.visible && this._visible && value;
        }
    }
    
    
    override function updateDisplayColor(
            aOffset:Float,
            rOffset:Float,
            gOffset:Float,
            bOffset:Float,
            aMultiplier:Float,
            rMultiplier:Float,
            gMultiplier:Float,
            bMultiplier:Float):Void
    {
        if (_nativeDisplay != null) 
        {
            super.updateDisplayColor(aOffset, rOffset, gOffset, bOffset, aMultiplier, rMultiplier, gMultiplier, bMultiplier);
            _nativeDisplay.transform.colorTransform = _colorTransform;
        }
    }
    
    
    override function updateDisplayBlendMode(value:String):Void
    {
        if (_nativeDisplay != null) 
        {
            switch (blendMode)
            {
                case BlendMode.ADD, BlendMode.ALPHA, BlendMode.DARKEN, BlendMode.DIFFERENCE, BlendMode.ERASE, BlendMode.HARDLIGHT, BlendMode.INVERT, BlendMode.LAYER, BlendMode.LIGHTEN, BlendMode.MULTIPLY, BlendMode.NORMAL, BlendMode.OVERLAY, BlendMode.SCREEN, BlendMode.SHADER, BlendMode.SUBTRACT:
                    _nativeDisplay.blendMode = blendMode;
                
                default:
                    //_nativeDisplay.blendMode = BlendMode.NORMAL;
                    break;
            }
        }
    }
}
