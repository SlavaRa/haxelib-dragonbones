package dragonbones;
import dragonbones.core.DBObject;
import dragonbones.objects.DisplayData;
import dragonbones.objects.FrameCached;
import dragonbones.objects.TimelineCached;
import openfl.errors.ArgumentError;
import openfl.errors.IllegalOperationError;
import openfl.geom.ColorTransform;
import openfl.geom.Matrix;

class Slot extends DBObject
{
    public var zOrder(get, set):Float;
    public var blendMode(get, set):String;
    public var display(get, set):Dynamic;
    public var childArmature(get, set):Armature;
    public var displayList(get, set):Array<Dynamic>;

    /** @Need to keep the reference of DisplayData. When slot switch displayObject, it need to restore the display obect's origional pivot. */
    var _displayDataList:Array<DisplayData>;
    var _originZOrder:Float;
    var _tweenZOrder:Float;
    var _isShowDisplay:Bool;
    var _timelineCached:TimelineCached;
    var _offsetZOrder:Float;
    var _displayIndex:Int;
    var _colorTransform:ColorTransform;
    
    /**
		 * zOrder. Support decimal for ensure dynamically added slot work toghther with animation controled slot.  
		 * @return zOrder.
		 */
    function get_ZOrder():Float
    {
        return _originZOrder + _tweenZOrder + _offsetZOrder;
    }
    function set_ZOrder(value:Float):Float
    {
        if (zOrder != value) 
        {
            _offsetZOrder = value - _originZOrder - _tweenZOrder;
            if (this._armature) 
            {
                this._armature._slotsZOrderChanged = true;
            }
        }
        return value;
    }
    
    var _blendMode:String;
    /**
		 * blendMode
		 * @return blendMode.
		 */
    function get_BlendMode():String
    {
        return _blendMode;
    }
    function set_BlendMode(value:String):String
    {
        if (_blendMode != value) 
        {
            _blendMode = value;
            updateDisplayBlendMode(_blendMode);
        }
        return value;
    }
    
    var _display:Dynamic;
    /**
		 * The DisplayObject belonging to this Slot instance. Instance type of this object varies from openfl.display.DisplayObject to startling.display.DisplayObject and subclasses.
		 */
    function get_Display():Dynamic
    {
        return _display;
    }
    function set_Display(value:Dynamic):Dynamic
    {
        if (_displayIndex < 0) 
        {
            _displayIndex = 0;
        }
        if (_displayList[_displayIndex] == value) 
        {
            return;
        }
        _displayList[_displayIndex] = value;
        updateSlotDisplay();
        updateChildArmatureAnimation();
        updateTransform();
        return value;
    }
    
    var _childArmature:Armature;
    /**
		 * The sub-armature of this Slot instance.
		 */
    function get_ChildArmature():Armature
    {
        return _childArmature;
    }
    function set_ChildArmature(value:Armature):Armature
    {
        display = value;
        return value;
    }
    
    //
    var _displayList:Array<Dynamic>;
    /**
		 * The DisplayObject list belonging to this Slot instance (display or armature). Replace it to implement switch texture.
		 */
    function get_DisplayList():Array<Dynamic>
    {
        return _displayList;
    }
    function set_DisplayList(value:Array<Dynamic>):Array<Dynamic>
    {
        if (value == null) 
        {
            throw new ArgumentError();
        }
        if (_displayIndex < 0) 
        {
            _displayIndex = 0;
        }
        var i:Int = _displayList.length = value.length;
        while (i-->0)
        {
            _displayList[i] = value[i];
        }
        
        var displayIndexBackup:Int = _displayIndex;
        _displayIndex = -1;
        changeDisplay(displayIndexBackup);
        return value;
    }
    
    
    override function set_Visible(value:Bool):Bool
    {
        if (this._visible != value) 
        {
            this._visible = value;
            updateDisplayVisible(this._visible);
        }
        return value;
    }
    
    
    override function setArmature(value:Armature):Void
    {
        super.setArmature(value);
        if (this._armature) 
        {
            this._armature._slotsZOrderChanged = true;
            addDisplayToContainer(this._armature.display);
        }
        else 
        {
            removeDisplayFromContainer();
        }
    }
    
    /**
		 * Creates a Slot blank instance.
		 */
    public function new(self:Slot)
    {
        super();
        
        if (self != this) 
        {
            throw new IllegalOperationError("Abstract class can not be instantiated!");
        }
        
        _displayList = [];
        _displayIndex = -1;
        
        _originZOrder = 0;
        _tweenZOrder = 0;
        _offsetZOrder = 0;
        _isShowDisplay = false;
        
        _colorTransform = new ColorTransform();
        
        _displayDataList = null;
        _childArmature = null;
        _display = null;
        
        this.inheritRotation = true;
        this.inheritScale = true;
    }
    
    /**
		 * @inheritDoc
		 */
    public override function dispose():Void
    {
        if (_displayList == null) 
        {
            return;
        }
        
        super.dispose();
        
        _displayList.length = 0;
        
        _displayDataList = null;
        _displayList = null;
        _display = null;
        _childArmature = null;
        
        _timelineCached = null;
    }
    
    
    function update():Void
    {
        if (this._parent._needUpdate <= 0) 
        {
            return;
        }
        
        var frameCachedPosition:Int = this._parent._frameCachedPosition;
        var frameCachedDuration:Int = this._parent._frameCachedDuration;
        
        if (frameCachedPosition >= 0 && frameCachedDuration <= 0) 
        {
            var frameCached:FrameCached = _timelineCached.timeline[frameCachedPosition];
            
            var matrix:Matrix = frameCached.matrix;
            this._globalTransformMatrix.a = matrix.a;
            this._globalTransformMatrix.b = matrix.b;
            this._globalTransformMatrix.c = matrix.c;
            this._globalTransformMatrix.d = matrix.d;
            this._globalTransformMatrix.tx = matrix.tx;
            this._globalTransformMatrix.ty = matrix.ty;
            //this._globalTransformMatrix.copyFrom(_frameCached.matrix);
            
            updateTransform();
            return;
        }
        
        updateGlobal();
        
        if (frameCachedDuration > 0)   // && frameCachedPosition >= 0  
        {
            _timelineCached.addFrame(null, this._globalTransformMatrix, frameCachedPosition, frameCachedDuration);
        }
        
        updateTransform();
    }
    
    override function calculateRelativeParentTransform():Void
    {
        _global.scaleX = this._origin.scaleX * this._offset.scaleX;
        _global.scaleY = this._origin.scaleY * this._offset.scaleY;
        _global.skewX = this._origin.skewX + this._offset.skewX;
        _global.skewY = this._origin.skewY + this._offset.skewY;
        _global.x = this._origin.x + this._offset.x + this._parent._tweenPivot.x;
        _global.y = this._origin.y + this._offset.y + this._parent._tweenPivot.y;
    }
    
    function updateChildArmatureAnimation():Void
    {
        if (_childArmature != null) 
        {
            if (_isShowDisplay) 
            {
                if (
                    this._armature &&
                    this._armature.animation.lastAnimationState &&
                    _childArmature.animation.hasAnimation(this._armature.animation.lastAnimationState.name)) 
                {
                    _childArmature.animation.gotoAndPlay(this._armature.animation.lastAnimationState.name);
                }
                else 
                {
                    _childArmature.animation.play();
                }
            }
            else 
            {
                _childArmature.animation.stop();
                _childArmature.animation._lastAnimationState = null;
            }
        }
    }
    
    
    function changeDisplay(displayIndex:Int):Void
    {
        if (displayIndex < 0) 
        {
            if (_isShowDisplay) 
            {
                _isShowDisplay = false;
                removeDisplayFromContainer();
                updateChildArmatureAnimation();
            }
        }
        else if (_displayList.length > 0) 
        {
            var length:Int = _displayList.length;
            if (displayIndex >= length) 
            {
                displayIndex = length - 1;
            }
            
            if (_displayIndex != displayIndex) 
            {
                _isShowDisplay = true;
                _displayIndex = displayIndex;
                updateSlotDisplay();
                updateChildArmatureAnimation();
                if (
                    _displayDataList != null &&
                    _displayDataList.length > 0 &&
                    _displayIndex < _displayDataList.length) 
                {
                    this._origin.copy(_displayDataList[_displayIndex].transform);
                }
            }
            else if (!_isShowDisplay) 
            {
                _isShowDisplay = true;
                if (this._armature) 
                {
                    this._armature._slotsZOrderChanged = true;
                    addDisplayToContainer(this._armature.display);
                }
                updateChildArmatureAnimation();
            }
        }
    }
    
    /** @
		 * Updates the display of the slot.
		 */
    function updateSlotDisplay():Void
    {
        var currentDisplayIndex:Int = -1;
        if (_display != null) 
        {
            currentDisplayIndex = getDisplayIndex();
            removeDisplayFromContainer();
        }
        var display:Dynamic = _displayList[_displayIndex];
        if (display != null) 
        {
            if (Std.is(display, Armature)) 
            {
                _childArmature = try cast(display, Armature) catch(e:Dynamic) null;
                _display = _childArmature.display;
            }
            else 
            {
                _childArmature = null;
                _display = display;
            }
        }
        else 
        {
            _display = null;
            _childArmature = null;
        }
        updateDisplay(_display);
        if (_display != null) 
        {
            if (this._armature && _isShowDisplay) 
            {
                if (currentDisplayIndex < 0) 
                {
                    this._armature._slotsZOrderChanged = true;
                    addDisplayToContainer(this._armature.display);
                }
                else 
                {
                    addDisplayToContainer(this._armature.display, currentDisplayIndex);
                }
            }
            updateDisplayBlendMode(_blendMode);
            updateDisplayColor(
                    _colorTransform.alphaOffset, _colorTransform.redOffset, _colorTransform.greenOffset, _colorTransform.blueOffset,
                    _colorTransform.alphaMultiplier, _colorTransform.redMultiplier, _colorTransform.greenMultiplier, _colorTransform.blueMultiplier
                    );
            updateDisplayVisible(_visible);
        }
    }
    
    /**
		 * @private
		 * Updates the color of the display object.
		 * @param a
		 * @param r
		 * @param g
		 * @param b
		 * @param aM
		 * @param rM
		 * @param gM
		 * @param bM
		 */
    function updateDisplayColor(
            aOffset:Float,
            rOffset:Float,
            gOffset:Float,
            bOffset:Float,
            aMultiplier:Float,
            rMultiplier:Float,
            gMultiplier:Float,
            bMultiplier:Float):Void
    {
        _colorTransform.alphaOffset = aOffset;
        _colorTransform.redOffset = rOffset;
        _colorTransform.greenOffset = gOffset;
        _colorTransform.blueOffset = bOffset;
        _colorTransform.alphaMultiplier = aMultiplier;
        _colorTransform.redMultiplier = rMultiplier;
        _colorTransform.greenMultiplier = gMultiplier;
        _colorTransform.blueMultiplier = bMultiplier;
    }
    
    
    //Abstract method
    
    /**
		 * @private
		 */
    function updateDisplay(value:Dynamic):Void
    {
        throw new IllegalOperationError("Abstract method needs to be implemented in subclass!");
    }
    
    /**
		 * @private
		 */
    function getDisplayIndex():Int
    {
        throw new IllegalOperationError("Abstract method needs to be implemented in subclass!");
    }
    
    /**
		 * @private
		 * Adds the original display object to another display object.
		 * @param container
		 * @param index
		 */
    function addDisplayToContainer(container:Dynamic, index:Int = -1):Void
    {
        throw new IllegalOperationError("Abstract method needs to be implemented in subclass!");
    }
    
    /**
		 * @private
		 * remove the original display object from its parent.
		 */
    function removeDisplayFromContainer():Void
    {
        throw new IllegalOperationError("Abstract method needs to be implemented in subclass!");
    }
    
    /**
		 * @private
		 * Updates the transform of the slot.
		 */
    function updateTransform():Void
    {
        throw new IllegalOperationError("Abstract method needs to be implemented in subclass!");
    }
    
    /**
		 * @private
		 */
    function updateDisplayVisible(value:Bool):Void
    {
        /**
			 * bone.visible && slot.visible && updateVisible
			 * this._parent.visible && this._visible && value;
			 */
        throw new IllegalOperationError("Abstract method needs to be implemented in subclass!");
    }
    
    /**
		 * @private
     * Update the blend mode of the display object.
     * @param value The blend mode to use. 
     */
    function updateDisplayBlendMode(value:String):Void
    {
        throw new IllegalOperationError("Abstract method needs to be implemented in subclass!");
    }
}
