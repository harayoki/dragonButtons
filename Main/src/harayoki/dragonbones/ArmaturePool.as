package harayoki.dragonbones
{
	import dragonBones.Armature;
	import dragonBones.animation.WorldClock;
	import dragonBones.factorys.StarlingFactory;
	
	import starling.display.BlendMode;
	import starling.display.DisplayObject;
	import starling.display.Image;
	
	public class ArmaturePool
	{
		private var _factory:StarlingFactory;
		
		public var verbose:Boolean = false;
		public var autoRemovalFromWorldClock:Boolean = false;
		
		public function ArmaturePool(factory:StarlingFactory,verbose:Boolean=false)
		{
			_factory = factory;
			this.verbose = verbose;
		}
		
		public function get factory():StarlingFactory
		{
			return _factory;
		}
		
		public function set factory(value:StarlingFactory):void
		{
			if(_factory == value) return;
			clean();
			_factory = value;
		}
		
		public function clean():void
		{
			Pool.disposeAll();
		}
		
		public function dispose():void
		{
			Pool.disposeAll();
			_factory = null;
		}
		
		public function getArmature(armatureName:String):Armature
		{
			var pool:Pool = Pool.getPool(armatureName);
			
			var a:Armature = pool.getOne();
			if(a)
			{
				if(verbose) trace("resuse "+armatureName);
				return a;
			}
			else
			{
				if(verbose) trace("new "+armatureName);
				return _factory.buildArmature(armatureName);
			}
		}
		
		public function createAndStore(armatureName:String,amount:int):void
		{
			while(amount--)
			{
				store(_factory.buildArmature(armatureName));
			}
		}
		
		public function store(armature:Armature):void
		{
			if(autoRemovalFromWorldClock)
			{
				WorldClock.clock.remove(armature);
			}
			armature.animation.stop();
			var dobj:DisplayObject = armature.display as DisplayObject;
			_resetTransform(dobj);
			dobj.removeFromParent();
			var pool:Pool = Pool.getPool(armature.name);
			pool.store(armature);
		}
		
		private function _resetTransform(dobj:DisplayObject):void
		{
			dobj.visible = true;
			dobj.alpha = 1.0;
			dobj.blendMode = BlendMode.AUTO;
			if(dobj is Image)
			{
				Image(dobj).color = 0xffffff;
				Image(dobj).filter = null;
			}
			
			//dobj.transformationMatrix.identity();//この処理を行うとその後x,yの更新が反映されない現象があったのでパラメータをそれぞれ個別で直す
			dobj.x = dobj.y = 0;
			dobj.pivotX = dobj.pivotY = 0;
			dobj.rotation = 0;
			dobj.scaleX = dobj.scaleY = 1.0;
			dobj.skewX = dobj.skewY = 0.0;
		}
	}
}
import dragonBones.Armature;

import starling.display.DisplayObject;

internal class Pool
{
	private static var _pools:Object = {};
	public static function getPool(name:String):Pool
	{
		var pool:Pool = _pools[name];
		if(!pool)
		{
			pool = _pools[name] = new Pool(name);
		}
		return pool;
	}
	
	public static function disposeAll():void
	{
		for each(var p:Pool in _pools)
		{
			p.dispose();
		}
	}
	
	private var _name:String;
	private var _pool:Vector.<Armature>;
	
	public function Pool(name:String)
	{
		_name = name;
		_pool = new Vector.<Armature>();
	}
	
	
	public function dispose():void
	{
		for each(var a:Armature in _pool)
		{
			var dobj:DisplayObject = a.display as starling.display.DisplayObject;
			dobj.removeFromParent(true);
			a.dispose();
		}
		_pool = null;
		delete _pools[_name];
	}
	
	public function getOne():Armature
	{
		if(_pool.length>0)
		{
			return _pool.pop();
		}
		return null;
	}
	
	public function store(a:Armature):void
	{
		_pool.push(a);
	}
	
}