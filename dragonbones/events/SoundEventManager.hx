package dragonbones.events;


import openfl.errors.IllegalOperationError;
import openfl.events.EventDispatcher;

@:meta(Event(name="sound",type="dragonBones.events.SoundEvent"))


/**
	 * 全局声音管理，通过监听SoundEventManager的SoundEvent事件得到动画的声音触发时间和声音的名字
	 */
@:final class SoundEventManager extends EventDispatcher
{
    static var _instance:SoundEventManager;
    
    public static function getInstance():SoundEventManager
    {
        if (_instance == null) 
        {
            _instance = new SoundEventManager();
        }
        return _instance;
    }
    
    public function new()
    {
        super();
        if (_instance != null) 
        {
            throw new IllegalOperationError("Singleton already constructed!");
        }
    }
}
