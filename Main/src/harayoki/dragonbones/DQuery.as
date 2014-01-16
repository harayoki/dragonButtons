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
		private var _baseArmature:Armature;
		private var _slotCache:Cache;
		private var _boneCache:Cache;
		private var _dobjCache:Cache;
		private var _armCache:Cache;
		
		public function DQuery(armature:Armature)
		{
			_baseArmature = armature;
			_slotCache = new Cache();
			_boneCache = new Cache();
			_dobjCache = new Cache();
			_armCache = new Cache();
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
			_slotCache = null;
			_boneCache = null;
			_dobjCache = null;
			_armCache = null;
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
		}
		
		public function getBone(name:String):Bone
		{
			var bones:Vector.<Bone> = getBones(name);
			return bones.length>0 ? bones[0] : null;
		}
		
		public function getBones(name:String):Vector.<Bone>
		{
			function q(a:Armature,v:Vector.<Bone>):void
			{
				var bones:Vector.<Bone> = a.getBones();
				var child:Armature;
				for each(var bone:Bone in bones)
				{
					if(name == bone.name)
					{
						v.push(child);
					}
					if(bone.childArmature)
					{
						q(bone.childArmature,v);
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
						
			function q(a:Armature,v:Vector.<Slot>):void
			{
				var slots:Vector.<Slot> = a.getSlots();
				var child:Armature;
				for each(var slot:Slot in slots)
				{
					if(name == slot.name)
					{
						v.push(child);
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
				for(var i:int=0;i<len;i++)
				{
					v.push(slots[i].childArmature as Armature);				
				}				
				_armCache.add(name,v);
				return  v;
			}
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

