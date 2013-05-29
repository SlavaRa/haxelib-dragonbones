package dragonbones.factorys;

/**
 * @author SlavaRa
 */
#if (flash11 && starling)
typedef ArmatureFactory = StarlingFactory;
#else
typedef ArmatureFactory = BaseFactory;
#end
