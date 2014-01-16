package harayoki.dragonbones
{
	import dragonBones.Armature;
	import dragonBones.Bone;
	import dragonBones.Slot;

	public class DragonBonesUtil
	{
		/**
		 * アーマーチャーの内部構成をtraceする
		 * @param a 対象アーマーチャー
		 */
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
		
		/**
		 * アーマーチャーから名前をキーに内部に保持するアーマーチャーの一覧を得る
		 * @param armature 対象アーマーチャー
		 * @param slotNamePattern 名前がマッチするパターン String型またはRegExp型
		 * @param vec 任意の引数 あらたにVectorをインスタンス化したく無い時などに使う
		 * @return アーマーチャーの参照が詰まったベクター
		 * ※子孫のクエリが重いと思われるので、乱用はしない事
		 */
		public static function queryDescendantArmaturesByName(armature:Armature,slotNamePattern:*,vec:Vector.<Armature>=null):Vector.<Armature>
		{
			
			if(!vec) vec = new Vector.<Armature>();
			
			var re:RegExp = slotNamePattern is RegExp ? slotNamePattern as RegExp : new RegExp(slotNamePattern+"");
			
			function q(a:Armature,v:Vector.<Armature>,tab:String=""):void
			{
				var slots:Vector.<Slot> = a.getSlots();
				var child:Armature;
				for each(var slot:Slot in slots)
				{
					if(slot.childArmature)
					{
						//trace(tab+slot.name);
						child = slot.childArmature;
						if(re.test(slot.name))
						{
							v.push(child);
						}
						q(child,v,tab+" ");
					}
				}
			}
			
			q(armature,vec);
			
			return vec;
		}
		
		/**
		 * patternにマッチするボタン内部の子孫Armatureをまとめてアニメさせる
		 * @param slotNamePattern 名前パターン String型またはRegExp型
		 * @param animationName 移動するアニメーション名
		 * @param vec 任意の引数 あらたにVectorをインスタンス化したく無い時などに使う
		 */
		public static function gotoAndPlayBySlotName(armature:Armature,slotNamePattern:*,animationName:String,vec:Vector.<Armature>=null):void
		{
			if(!armature) return;
			
			if(!vec)
			{
				vec = new Vector.<Armature>();
			}
			vec.length = 0;
			DragonBonesUtil.queryDescendantArmaturesByName(armature,slotNamePattern,vec);
			for each(var a:Armature in vec)
			{
				a.animation && a.animation.gotoAndPlay(animationName);
			}			
		}		
		
		/**
		 * patternにマッチするボタン内部の子孫ArmatureのアニメをまとめてStopさせる
		 * @param pattern 名前パターン String型またはRegExp型
		 * @param animationName 移動するアニメーション名
		 * @param vec 任意の引数 あらたにVectorをインスタンス化したく無い時などに使う
		 */
		public static function stopAnimationBySlotName(armature:Armature,pattern:*,vec:Vector.<Armature>=null):void
		{
			if(!armature) return;
			
			if(!vec)
			{
				vec = new Vector.<Armature>();
			}
			vec.length = 0;
			DragonBonesUtil.queryDescendantArmaturesByName(armature,pattern,vec);
			for each(var a:Armature in vec)
			{
				a.animation && a.animation.stop();
			}			
		}	
	}
}