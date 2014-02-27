package harayoki.dragonbones
{
	import dragonBones.Armature;
	import dragonBones.Bone;
	import dragonBones.Slot;
	
	import starling.display.DisplayObject;

	/**
	 * Armatureの内部構成を取得しやすくする
	 * @author haruyuki.imai
	 */
	public class DQuery
	{
		
		private static const ALL_KEY:String = "__A_L_L_K_E_Y_";
        private static const HELPER_BONE_VECTOR:Vector.<Bone> = new Vector.<Bone>();
		
		private var _baseArmature:Armature;
		private var _slotCache:Cache;
		private var _boneCache:Cache;
		private var _dobjCache:Cache;
		private var _armCache:Cache;
        private var _armAndChildBoneCache:Cache;
        private var _boneAndChildBoneCache:Cache;
		
		private static var _instances:Vector.<DQuery> = new Vector.<DQuery>();
		
		public static function getDQuery(armature:Armature):DQuery
		{
			var dq:DQuery;
			
			if(_instances.length>0)
			{
				dq = _instances.pop();
				dq.baseArmature = armature;
			}
			else
			{
				dq = new DQuery(armature);
			}
			return dq;
		}
		
		public static function restoreDquery(dq:DQuery):void
		{
			if(dq)
			{
				dq.baseArmature = null;
				dq.clearQueryCache();
				_instances.push(dq);
			}
		}
		
		public function DQuery(armature:Armature)
		{
			_baseArmature = armature;
			_slotCache = new Cache();
			_boneCache = new Cache();
			_dobjCache = new Cache();
			_armCache = new Cache();
            _armAndChildBoneCache = new Cache();
            _boneAndChildBoneCache = new Cache();
		}
				
		public function get baseArmature():Armature
		{
			return _baseArmature;
		}

		public function set baseArmature(value:Armature):void
		{
			if(_baseArmature == value)
			{
				return;
			}
			_baseArmature = value;
			clearQueryCache();
		}

		public function dispose():void
		{
			_baseArmature = null;
			if(_slotCache)
			{
				_slotCache.dispose();
			}
			if(_boneCache)
			{
				_boneCache.dispose();
			}
			if(_dobjCache)
			{
				_dobjCache.dispose();
			}
			if(_armCache)
			{
				_armCache.dispose();
			}
            if(_armAndChildBoneCache)
            {
                _armAndChildBoneCache.dispose();
            }
            if(_boneAndChildBoneCache)
            {
                _boneAndChildBoneCache.dispose();
            }
			_slotCache = null;
			_boneCache = null;
			_dobjCache = null;
			_armCache = null;
            _armAndChildBoneCache = null;
            _boneAndChildBoneCache = null;
		}
		
		public function clearQueryCache():void
		{
			if(_slotCache)
			{
				_slotCache.clear();
			}
			if(_boneCache)
			{
				_boneCache.clear();
			}
			if(_dobjCache)
			{
				_dobjCache.clear();
			}
			if(_armCache)
			{
				_armCache.clear();
			}
            if(_armAndChildBoneCache)
            {
                _armAndChildBoneCache.clear();
            }
            if(_boneAndChildBoneCache)
            {
                _boneAndChildBoneCache.clear();
            }
		}
		
		public function getBone(name:String):Bone
		{
			var bones:Vector.<Bone> = getBones(name);
			return bones.length>0 ? bones[0] : null;
		}
		
		public function getBones(name:String):Vector.<Bone>
		{
			var selectAll:Boolean = (!name);
			if(selectAll) name = ALL_KEY;
			
			function q(a:Armature,v:Vector.<Bone>,tab:String="*"):void
			{
				var bones:Vector.<Bone> = a.getBones();
				for each(var bone:Bone in bones)
				{
					//if(tab) trace(tab+bone.name);
					if(selectAll || name == bone.name)
					{
						v.push(bone);
					}
					if(bone.childArmature)
					{
						q(bone.childArmature,v,tab+"*");
					}
				}
			}
			
			var v:Vector.<Bone> = _boneCache.gets(name) as Vector.<Bone>;
			if(v)
			{
				return v;
			}
			else
			{
				v = new Vector.<Bone>();
				q(_baseArmature,v);
				_boneCache.add(name,v);
				return  v;
			}
		}
		
		public function getSlot(name:String):Slot
		{
			var slots:Vector.<Slot> = getSlots(name);
			return slots.length>0 ? slots[0] : null;
		}
		
		public function getSlots(name:String):Vector.<Slot>
		{
			var selectAll:Boolean = (!name);
			if(selectAll) name = ALL_KEY;
			
			function q(a:Armature,v:Vector.<Slot>):void
			{
				var slots:Vector.<Slot> = a.getSlots();
				for each(var slot:Slot in slots)
				{
					if(selectAll || name == slot.name)
					{
						v.push(slot);
					}
					if(slot.childArmature)
					{
						q(slot.childArmature,v);
					}
				}
			}
			
			var v:Vector.<Slot> = _slotCache.gets(name) as Vector.<Slot>;
			if(v)
			{
				return v;
			}
			else
			{
				v = new Vector.<Slot>();
				q(_baseArmature,v);
				_slotCache.add(name,v);
				return  v;
			}
		}
		
		public function getDisplayObject(name:String):DisplayObject
		{
			var dobjs:Vector.<DisplayObject> = getDisplayObjects(name);
			return dobjs.length > 0 ? dobjs[0] : null;
		}
		
		public function getDisplayObjects(name:String):Vector.<DisplayObject>
		{
			
			var v:Vector.<DisplayObject> = _dobjCache.gets(name) as Vector.<DisplayObject>;
			if(v)
			{
				return v;
			}
			else
			{
				v = new Vector.<DisplayObject>();
				var slots:Vector.<Slot> = getSlots(name);
				var len:int = slots.length;
				for(var i:int=0;i<len;i++)
				{
					v.push(slots[i].display as DisplayObject);
				}				
				_dobjCache.add(name,v);
				return  v;
			}
		}
		
		public function getDescendantArmature(name:String):Armature
		{
			var arms:Vector.<Armature> = getDescendantArmatures(name);
			return arms.length > 0 ? arms[0] : null;
		}
		
		public function getDescendantArmatures(name:String):Vector.<Armature>
		{
			var v:Vector.<Armature> = _armCache.gets(name) as Vector.<Armature>;
			if(v)
			{
				return v;
			}
			else
			{
				v = new Vector.<Armature>();
				var slots:Vector.<Slot> = getSlots(name);
				var len:int = slots.length;
				var child:Armature;
				for(var i:int=0;i<len;i++)
				{
					child = slots[i].childArmature;
					if(child) v.push(child);
				}
				_armCache.add(name,v);
				return  v;
			}
		}
		
        /**
         * ある名前のboneを持ったArmatureの一覧を返します
         */
        public function getArmaturesHavingNamedBone(boneName:String):Vector.<Armature>
        {
            var name:String = boneName;
            var v:Vector.<Armature> = _armAndChildBoneCache.gets(name) as Vector.<Armature>;
            if(v)
            {
                return v;
            }
            function q(a:Armature,v:Vector.<Armature>):void
            {
                var bones:Vector.<Bone> = a.getBones();
                for each(var bone:Bone in bones)
                {
                    if(bone.name == name)
                    {
                        if(v.indexOf(a)==-1)
                        {
                            v.push(a);
                        }
                    }
                    if(bone.childArmature)
                    {
                        q(bone.childArmature,v);
                    }
                }
            }
            
            v = new Vector.<Armature>();
            q(_baseArmature,v);
            _armAndChildBoneCache.add(name,v);
            return  v;
       }
        
        /**
         * ある名前のboneを持ったArmatureの一覧をそのArmatureのdisplayの位置でソートして返します
         */
        public function getArmaturesHavingNamedBoneWithPositionSort(boneName:String,onlyBoneHavingChildArmature:Boolean=false,v:Vector.<Armature>=null):Vector.<Armature>
        {
            if(!v)
            {
                v = new Vector.<Armature>();
            }
            HELPER_BONE_VECTOR.length = 0;
            
            var bones:Vector.<Bone> = getBonesHavingNamedBone(boneName,onlyBoneHavingChildArmature);
            var i:int;
            var len:int;
            var bone:Bone;
            
            len = bones.length;
            for(i=0;i<len;i++)
            {
                bone = bones[i];
                if(bone.childArmature && bone.display)
                {
                    HELPER_BONE_VECTOR.push(bone);
                }
            }
            
            DragonBonesSortFunctions.sortBonesByGlobalPosition(HELPER_BONE_VECTOR);
            
            len = HELPER_BONE_VECTOR.length;
            for(i=0;i<len;i++)
            {
                bone = HELPER_BONE_VECTOR[i];
                v.push(bone.childArmature);
            }
            
            return  v;
        }
        
        /**
         * ある名前のBoneを持ったBoneの一覧を返します
         */
        public function getBonesHavingNamedBone(boneName:String,onlyBoneHavingChildArmature:Boolean=false):Vector.<Bone>
        {
            var name:String = boneName;
            var v:Vector.<Bone> = _boneAndChildBoneCache.gets(name) as Vector.<Bone>;
            if(v)
            {
                return v;
            }
            function q(parentBone:Bone,v:Vector.<Bone>):void
            {
                if(!parentBone.childArmature) return;
                var bones:Vector.<Bone> = parentBone.childArmature.getBones();
                for each(var bone:Bone in bones)
                {
                    if(bone.name == name)
                    {
                        if(!onlyBoneHavingChildArmature || (onlyBoneHavingChildArmature && bone.childArmature))
                        {
                            if(v.indexOf(parentBone)==-1)
                            {
                                v.push(parentBone);
                            }
                        }
                    }
                    if(bone.childArmature)
                    {
                        q(bone,v);
                    }
                }
            }
            v = new Vector.<Bone>();
            var rootBones:Vector.<Bone> = _baseArmature.getBones();
            for each(var bone:Bone in rootBones)
            {
                q(bone,v);
            }
            _boneAndChildBoneCache.add(name,v);
            return  v;
        }
	}
}

internal class Cache
{
	private var _cache:Object;
	public function Cache()
	{
		clear();
	}
	public function dispose():void
	{
		_cache = null;
	}
	public function clear():void
	{
		_cache = {};
	}
	
	public function add(name:String,value:*):void
	{
		_cache[name] = value;
	}
	
	public function gets(name:String):*
	{
		return _cache[name];
	}
	
	public function remove(name:String):void
	{
		delete _cache[name];
	}
	
}

