package dragonbones.display;
import dragonbones.Armature;
import dragonbones.Slot;
import openfl.display.BlendMode;
import openfl.geom.Matrix;
import starling.display.BlendMode;
import starling.display.DisplayObject;
import starling.display.DisplayObjectContainer;
import starling.display.Quad;

class StarlingSlot extends Slot
{
    var _starlingDisplay:DisplayObject;
    
    public var updateMatrix:Bool;
    
    public function new()
    {
        super(this);
        
        _starlingDisplay = null;
        
        updateMatrix = false;
    }
    
    public override function dispose():Void
    {
        for (content/* AS3HX WARNING could not determine type for var: content exp: EField(EIdent(this),_displayList) type: null */ in this._displayList)
        {
            if (Std.is(content, Armature)) 
            {
                (try cast(content, Armature) catch(e:Dynamic) null).dispose();
            }
            else if (Std.is(content, DisplayObject)) 
            {
                (try cast(content, DisplayObject) catch(e:Dynamic) null).dispose();
            }
        }
        super.dispose();
        
        _starlingDisplay = null;
    }
    
    
    override function updateDisplay(value:Dynamic):Void
    {
        _starlingDisplay = try cast(value, DisplayObject) catch(e:Dynamic) null;
    }
    
    
    //Abstract method
    
    
    override function getDisplayIndex():Int
    {
        if (_starlingDisplay != null && _starlingDisplay.parent) 
        {
            return _starlingDisplay.parent.getChildIndex(_starlingDisplay);
        }
        return -1;
    }
    
    
    override function addDisplayToContainer(container:Dynamic, index:Int = -1):Void
    {
        var starlingContainer:DisplayObjectContainer = try cast(container, DisplayObjectContainer) catch(e:Dynamic) null;
        if (_starlingDisplay != null && starlingContainer != null) 
        {
            if (index < 0) 
            {
                starlingContainer.addChild(_starlingDisplay);
            }
            else 
            {
                starlingContainer.addChildAt(_starlingDisplay, Math.min(index, starlingContainer.numChildren));
            }
        }
    }
    
    
    override function removeDisplayFromContainer():Void
    {
        if (_starlingDisplay != null && _starlingDisplay.parent) 
        {
            _starlingDisplay.parent.removeChild(_starlingDisplay);
        }
    }
    
    
    override function updateTransform():Void
    {
        if (_starlingDisplay != null) 
        {
            var pivotX:Float = _starlingDisplay.pivotX;
            var pivotY:Float = _starlingDisplay.pivotY;
            
            if (updateMatrix) 
            {
                _starlingDisplay.transformationMatrix = _globalTransformMatrix;
                if (pivotX != 0 || pivotY != 0) 
                {
                    _starlingDisplay.pivotX = pivotX;
                    _starlingDisplay.pivotY = pivotY;
                }
            }
            else 
            {
                var displayMatrix:Matrix = _starlingDisplay.transformationMatrix;
                displayMatrix.a = _globalTransformMatrix.a;
                displayMatrix.b = _globalTransformMatrix.b;
                displayMatrix.c = _globalTransformMatrix.c;
                displayMatrix.d = _globalTransformMatrix.d;
                //displayMatrix.copyFrom(_globalTransformMatrix);
                if (pivotX != 0 || pivotY != 0) 
                {
                    displayMatrix.tx = _globalTransformMatrix.tx - (displayMatrix.a * pivotX + displayMatrix.c * pivotY);
                    displayMatrix.ty = _globalTransformMatrix.ty - (displayMatrix.b * pivotX + displayMatrix.d * pivotY);
                }
                else 
                {
                    displayMatrix.tx = _globalTransformMatrix.tx;
                    displayMatrix.ty = _globalTransformMatrix.ty;
                }
            }
        }
    }
    
    
    override function updateDisplayVisible(value:Bool):Void
    {
        if (_starlingDisplay != null && this._parent) 
        {
            _starlingDisplay.visible = this._parent.visible && this._visible && value;
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
        if (_starlingDisplay != null) 
        {
            super.updateDisplayColor(aOffset, rOffset, gOffset, bOffset, aMultiplier, rMultiplier, gMultiplier, bMultiplier);
            _starlingDisplay.alpha = aMultiplier;
            if (Std.is(_starlingDisplay, Quad)) 
            {
                (try cast(_starlingDisplay, Quad) catch(e:Dynamic) null).color = (Int(rMultiplier * 0xff) << 16) + (Int(gMultiplier * 0xff) << 8) + Int(bMultiplier * 0xff);
            }
        }
    }
    
    
    override function updateDisplayBlendMode(value:String):Void
    {
        if (_starlingDisplay != null) 
        {
            switch (blendMode)
            {
                case starling.display.BlendMode.NONE, starling.display.BlendMode.AUTO, starling.display.BlendMode.ADD, starling.display.BlendMode.ERASE, starling.display.BlendMode.MULTIPLY, starling.display.BlendMode.NORMAL, starling.display.BlendMode.SCREEN:
                    _starlingDisplay.blendMode = blendMode;
                
                case openfl.display.BlendMode.ADD:
                    _starlingDisplay.blendMode = starling.display.BlendMode.ADD;
                
                case openfl.display.BlendMode.ERASE:
                    _starlingDisplay.blendMode = starling.display.BlendMode.ERASE;
                
                case openfl.display.BlendMode.MULTIPLY:
                    _starlingDisplay.blendMode = starling.display.BlendMode.MULTIPLY;
                
                case openfl.display.BlendMode.NORMAL:
                    _starlingDisplay.blendMode = starling.display.BlendMode.NORMAL;
                
                case openfl.display.BlendMode.SCREEN:
                    _starlingDisplay.blendMode = starling.display.BlendMode.SCREEN;
                case openfl.display.BlendMode.ALPHA, openfl.display.BlendMode.DARKEN, openfl.display.BlendMode.DIFFERENCE, openfl.display.BlendMode.HARDLIGHT, openfl.display.BlendMode.INVERT, openfl.display.BlendMode.LAYER, openfl.display.BlendMode.LIGHTEN, openfl.display.BlendMode.OVERLAY, openfl.display.BlendMode.SHADER, openfl.display.BlendMode.SUBTRACT:
                
                default:
                    break;
            }
        }
    }
}
