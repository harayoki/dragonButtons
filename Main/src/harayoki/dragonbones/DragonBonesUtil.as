package harayoki.dragonbones
{
	import dragonBones.Armature;
	import dragonBones.Bone;
	import dragonBones.Slot;

	public class DragonBonesUtil
	{
		public static function traceArmature(a:Armature):void
		{
			if(!a)
			{
				log("no armature : ",a);
				return;
			}
			
			log(a.name + "_________slots");
			var slots:Vector.<Slot> = a.getSlots(true);
			for each(var slot:Slot in slots)
			{
				log(slot.name);
			}
			
			log(a.name + "_________bones");
			var bones:Vector.<Bone> = a.getBones(true);
			for each(var bone:Bone in bones)
			{
				log(bone.name);
			}
			
			log(a.name + "________animations");
			var anims:Vector.<String> = a.animation.animationList
			for each(var anim:String in anims)
			{
				log(anim);
			}
			
		}
	}
}