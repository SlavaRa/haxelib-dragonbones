package dragonbones.animation;
import dragonbones.animation.AnimationState;
import dragonbones.Armature;
import dragonbones.objects.AnimationData;
import dragonbones.Slot;

/**
 * An Animation instance is used to control the animation state of an Armature.
 * @see dragonBones.Armature
 * @see dragonBones.animation.Animation
 * @see dragonBones.animation.AnimationState
 */
class Animation
{
    public var movementList(get, never):Array<String>;
    public var movementID(get, never):String;
    public var lastAnimationState(get, never):AnimationState;
    public var lastAnimationName(get, never):String;
    public var animationList(get, never):Array<String>;
    public var isPlaying(get, never):Bool;
    public var isComplete(get, never):Bool;
    public var timeScale(get, set):Float;
    public var animationDataList(get, set):Array<AnimationData>;

    public static inline var NONE:String = "none";
    public static inline var SAME_LAYER:String = "sameLayer";
    public static inline var SAME_GROUP:String = "sameGroup";
    public static inline var SAME_LAYER_AND_GROUP:String = "sameLayerAndGroup";
    public static inline var ALL:String = "all";
    
    /**
	* Unrecommended API. Recommend use animationList.
	*/
    function get_MovementList():Array<String>
    {
        return _animationList;
    }
    
    /**
	* Unrecommended API. Recommend use lastAnimationName.
	*/
    function get_MovementID():String
    {
        return lastAnimationName;
    }
    
    
    /**
	 * Whether animation tweening is enabled or not.
	 */
    public var tweenEnabled:Bool;
    
    var _armature:Armature;
    var _animationStateList:Array<AnimationState>;
    var _lastAnimationState:AnimationState;
    var _isFading:Bool;
    var _animationStateCount:Int;
    
    /**
	 * The last AnimationState this Animation played.
	 * @see dragonBones.objects.AnimationData.
	 */
    function get_LastAnimationState():AnimationState
    {
        return _lastAnimationState;
    }
	
    /**
	 * The name of the last AnimationData played.
	 * @see dragonBones.objects.AnimationData.
	 */
	function get_LastAnimationName():String
    {
        return (_lastAnimationState != null) ? _lastAnimationState.name:null;
    }
    
    var _animationList:Array<String>;
	
    /**
	 * An vector containing all AnimationData names the Animation can play.
	 * @see dragonBones.objects.AnimationData.
	 */
    function get_AnimationList():Array<String>
    {
        return _animationList;
    }
    
    var _isPlaying:Bool;
	
    /**
	 * Is the animation playing.
	 * @see dragonBones.animation.AnimationState.
	 */
    function get_IsPlaying():Bool
    {
        return _isPlaying && !isComplete;
    }
    
    /**
	 * Is animation complete.
	 * @see dragonBones.animation.AnimationState.
	 */
    function get_IsComplete():Bool
    {
        if (_lastAnimationState != null) 
        {
            if (!_lastAnimationState.isComplete) 
            {
                return false;
            }
            var i:Int = _animationStateList.length;
            while (i-->0)
            {
                if (!_animationStateList[i].isComplete) 
                {
                    return false;
                }
            }
            return true;
        }
        return true;
    }
    
    var _timeScale:Float;
    /**
	 * The amount by which passed time should be scaled. Used to slow down or speed up animations. Defaults to 1.
	 */
    function get_TimeScale():Float
    {
        return _timeScale;
    }
	
    function set_TimeScale(value:Float):Float
    {
        if (Math.isNaN(value) || value < 0) 
        {
            value = 1;
        }
        _timeScale = value;
        return value;
    }
    
    var _animationDataList:Array<AnimationData>;
	
    /**
	 * The AnimationData list associated with this Animation instance.
	 * @see dragonBones.objects.AnimationData.
	 */
    function get_AnimationDataList():Array<AnimationData>
    {
        return _animationDataList;
    }
	
    function set_AnimationDataList(value:Array<AnimationData>):Array<AnimationData>
    {
        _animationDataList = value;
        _animationList.length = 0;
        for (animationData in _animationDataList)
        {
            _animationList[_animationList.length] = animationData.name;
        }
        return value;
    }
    
    /**
	 * Creates a new Animation instance and attaches it to the passed Armature.
	 * @param An Armature to attach this Animation instance to.
	 */
	public function new(armature:Armature)
    {
        _armature = armature;
        _animationList = new Array<String>();
        _animationStateList = new Array<AnimationState>();
        
        _timeScale = 1;
        _isPlaying = false;
        
        tweenEnabled = true;
    }
    
    /**
	 * Qualifies all resources used by this Animation instance for garbage collection.
	 */
    public function dispose():Void
    {
        if (_armature == null) 
        {
            return;
        }
        var i:Int = _animationStateList.length;
        while (i-->0)
        {
            AnimationState.returnObject(_animationStateList[i]);
        }
        _animationList.length = 0;
        _animationStateList.length = 0;
        
        _armature = null;
        _animationDataList = null;
        _animationList = null;
        _animationStateList = null;
    }
    
    /**
	 * Fades the animation with name animation in over a period of time seconds and fades other animations out.
	 * @param animationName The name of the AnimationData to play.
	 * @param fadeInTime A fade time to apply (>= 0), -1 means use xml data's fadeInTime. 
	 * @param duration The duration of that Animation. -1 means use xml data's duration.
	 * @param playTimes Play times(0:loop forever, >=1:play times, -1~-∞:will fade animation after play complete), 默认使用AnimationData.loop.
	 * @param layer The layer of the animation.
	 * @param group The group of the animation.
	 * @param fadeOutMode Fade out mode (none, sameLayer, sameGroup, sameLayerAndGroup, all).
	 * @param pauseFadeOut Pause other animation playing.
	 * @param pauseFadeIn Pause this animation playing before fade in complete.
	 * @return AnimationState.
	 * @see dragonBones.objects.AnimationData.
	 * @see dragonBones.animation.AnimationState.
	 */
    public function gotoAndPlay(
            animationName:String,
            fadeInTime:Float = -1,
            duration:Float = -1,
            playTimes:Float = Math.Nan,
            layer:Int = 0,
            group:String = null,
            fadeOutMode:String = SAME_LAYER_AND_GROUP,
            pauseFadeOut:Bool = true,
            pauseFadeIn:Bool = true):AnimationState
    {
        if (_animationDataList == null) 
        {
            return null;
        }
        var i:Int = _animationDataList.length;
        var animationData:AnimationData;
        while (i-->0)
        {
            if (_animationDataList[i].name == animationName) 
            {
                animationData = _animationDataList[i];
                break;
            }
        }
        if (animationData == null) 
        {
            return null;
        }
        _isPlaying = true;
        _isFading = true;
        
        //
        fadeInTime = fadeInTime < (0) ? (animationData.fadeTime < (0) ? 0.3:animationData.fadeTime):fadeInTime;
        var durationScale:Float;
        if (duration < 0) 
        {
            durationScale = animationData.scale < (0) ? 1:animationData.scale;
        }
        else 
        {
            durationScale = duration * 1000 / animationData.duration;
        }
        
        playTimes = (Math.isNaN(playTimes)) ? animationData.playTimes:playTimes;
        
        var animationState:AnimationState;
        switch (fadeOutMode)
        {
            case NONE:
            case SAME_LAYER:
                i = _animationStateList.length;
                while (i-->0)
                {
                    animationState = _animationStateList[i];
                    if (animationState.layer == layer) 
                    {
                        animationState.fadeOut(fadeInTime, pauseFadeOut);
                    }
                }
            case SAME_GROUP:
                i = _animationStateList.length;
                while (i-->0)
                {
                    animationState = _animationStateList[i];
                    if (animationState.group == group) 
                    {
                        animationState.fadeOut(fadeInTime, pauseFadeOut);
                    }
                }
            case ALL:
                i = _animationStateList.length;
                while (i-->0)
                {
                    animationState = _animationStateList[i];
                    animationState.fadeOut(fadeInTime, pauseFadeOut);
                }
            case SAME_LAYER_AND_GROUP:
                i = _animationStateList.length;
                while (i-->0)
                {
                    animationState = _animationStateList[i];
                    if (animationState.layer == layer && animationState.group == group) 
                    {
                        animationState.fadeOut(fadeInTime, pauseFadeOut);
                    }
                }
            default:
                i = _animationStateList.length;
                while (i-->0)
                {
                    animationState = _animationStateList[i];
                    if (animationState.layer == layer && animationState.group == group) 
                    {
                        animationState.fadeOut(fadeInTime, pauseFadeOut);
                    }
                }
        }
        
        _lastAnimationState = AnimationState.borrowObject();
        _lastAnimationState._layer = layer;
        _lastAnimationState._group = group;
        _lastAnimationState.autoTween = tweenEnabled;
        _lastAnimationState.fadeIn(_armature, animationData, fadeInTime, 1 / durationScale, playTimes, pauseFadeIn);
        
        addState(_lastAnimationState);
        
        var slotList:Array<Slot> = _armature.getSlots(false);
        i = slotList.length;
        while (i-->0)
        {
            var slot:Slot = slotList[i];
            if (slot.childArmature) 
            {
                slot.childArmature.animation.gotoAndPlay(animationName, fadeInTime);
            }
        }
        
        return _lastAnimationState;
    }
    
    /**
	 * Control the animation to stop with a specified time. If related animationState haven't been created, then create a new animationState.
	 * @param animationName The name of the animationState.
	 * @param time 
	 * @param normalizedTime 
	 * @param fadeInTime A fade time to apply (>= 0), -1 means use xml data's fadeInTime. 
	 * @param duration The duration of that Animation. -1 means use xml data's duration.
	 * @param layer The layer of the animation.
	 * @param group The group of the animation.
	 * @param fadeOutMode Fade out mode (none, sameLayer, sameGroup, sameLayerAndGroup, all).
	 * @return AnimationState.
	 * @see dragonBones.objects.AnimationData.
	 * @see dragonBones.animation.AnimationState.
	 */
    public function gotoAndStop(
            animationName:String,
            time:Float,
            normalizedTime:Float = -1,
            fadeInTime:Float = 0,
            duration:Float = -1,
            layer:Int = 0,
            group:String = null,
            fadeOutMode:String = ALL):AnimationState
    {
        var animationState:AnimationState = getState(animationName, layer);
        if (animationState == null) 
        {
            animationState = gotoAndPlay(animationName, fadeInTime, duration, NaN, layer, group, fadeOutMode);
        }
        
        if (normalizedTime >= 0) 
        {
            animationState.setCurrentTime(animationState.totalTime * normalizedTime);
        }
        else 
        {
            animationState.setCurrentTime(time);
        }
        
        animationState.stop();
        
        return animationState;
    }
    
    /**
	 * Play the animation from the current position.
	 */
    public function play():Void
    {
        if (_animationDataList == null || _animationDataList.length == 0) 
        {
            return;
        }
        if (_lastAnimationState == null) 
        {
            gotoAndPlay(_animationDataList[0].name);
        }
        else if (!_isPlaying) 
        {
            _isPlaying = true;
        }
        else 
        {
            gotoAndPlay(_lastAnimationState.name);
        }
    }
    
    public function stop():Void
    {
        _isPlaying = false;
    }
    
    /**
		 * Returns the AnimationState named name.
		 * @return A AnimationState instance.
		 * @see dragonBones.animation.AnimationState.
		 */
    public function getState(name:String, layer:Int = 0):AnimationState
    {
        var i:Int = _animationStateList.length;
        while (i-->0)
        {
            var animationState:AnimationState = _animationStateList[i];
            if (animationState.name == name && animationState.layer == layer) 
            {
                return animationState;
            }
        }
        return null;
    }
    
    /**
	 * check if contains a AnimationData by name.
	 * @return Boolean.
	 * @see dragonBones.animation.AnimationData.
	 */
    public function hasAnimation(animationName:String):Bool
    {
        var i:Int = _animationDataList.length;
        while (i-->0)
        {
            if (_animationDataList[i].name == animationName) 
            {
                return true;
            }
        }
        
        return false;
    }
    
    function advanceTime(passedTime:Float):Void
    {
        if (!_isPlaying) 
        {
            return;
        }
        
        var isFading:Bool = false;
        
        passedTime *= _timeScale;
        var i:Int = _animationStateList.length;
        while (i-->0)
        {
            var animationState:AnimationState = _animationStateList[i];
            if (animationState.advanceTime(passedTime)) 
            {
                removeState(animationState);
            }
            else if (animationState.fadeState != 1) 
            {
                isFading = true;
            }
        }
        
        _isFading = isFading;
    }
    
    function updateAnimationStates():Void
    {
        var i:Int = _animationStateList.length;
        while (i-->0)
        {
            _animationStateList[i].updateTimelineStates();
        }
    }
    
    function addState(animationState:AnimationState):Void
    {
        if (Lambda.indexOf(_animationStateList, animationState) < 0) 
        {
            _animationStateList.unshift(animationState);
            
            _animationStateCount = _animationStateList.length;
        }
    }
    
    function removeState(animationState:AnimationState):Void
    {
        var index:Int = Lambda.indexOf(_animationStateList, animationState);
        if (index >= 0) 
        {
            _animationStateList.splice(index, 1);
            AnimationState.returnObject(animationState);
            
            if (_lastAnimationState == animationState) 
            {
                if (_animationStateList.length > 0) 
                {
                    _lastAnimationState = _animationStateList[0];
                }
                else 
                {
                    _lastAnimationState = null;
                }
            }
            
            _animationStateCount = _animationStateList.length;
        }
    }
}