package harayoki.dragonbones
{
	import dragonBones.Armature;

	public class DragonBonesButtonUtil
	{
		public static function createButton(armature:Armature):ArmatureButton
		{
			var btn:ArmatureButton = new ArmatureButton();
			btn.applyArmature(armature);
			return btn;
		}
	}
}