package harayoki.dragonbones
{
	import dragonBones.Armature;
	import dragonBones.animation.Animation;
	
	import starling.display.DisplayObject;
	import starling.display.DisplayObjectContainer;

	public class DragonUIView
	{
		
		private static const DEFAULT_ANIM:String = "start";
		private static const ROOT_KEY:String = "__root__";
		private static const LONG_TIME:int = 99;
		
		private static const _instances:Vector.<DragonUIView> = new Vector.<DragonUIView>();
		
		public static function getView(armature:Armature):DragonUIView
		{
			var ui:DragonUIView;
			if(_instances.length>0)
			{
				ui = _instances.pop();
				ui.applyArmature(armature);
			}
			else
			{
				ui = new DragonUIView(armature);
			}
			return ui;
		}
		
		public static function storeView(ui:DragonUIView):void
		{
			if(ui)
			{
				ui.clear();
				_instances.push(ui);
			}
		}
		
		public var userData:*;
		
		private var _dQuery:DQuery;
		private var _armature:Armature;
		private var _props:Object;
		
		public function DragonUIView(armature:Armature)
		{
			if(armature)
			{
				applyArmature(armature);
			}
		}
		
		public function applyArmature(armature:Armature):void
		{
			_props = {};
			_armature = armature;
			_dQuery = DQuery.getDQuery(_armature);
			if(_armature.animation.animationList.indexOf(DEFAULT_ANIM)>=0)
			{
				_armature.animation.gotoAndPlay(DEFAULT_ANIM);
				_armature.animation.advanceTime(LONG_TIME);
			}
			else
			{
				_armature.animation.stop();
			}
		}
		
		//再利用準備
		public function clear():void
		{
			_armature = null;
			DQuery.restoreDquery(_dQuery);
			_dQuery = null;
			_props = null;
			userData = null;
		}
		
		public function dispose():void
		{
			clear();
		}
		
		public function get armature():Armature
		{
			return _armature;
		}
		
		public function get display():DisplayObjectContainer
		{
			if(_armature)
			{
				return _armature.display as DisplayObjectContainer;
			}
			return null;
		}
		
		public function get dQuery():DQuery
		{
			return _dQuery;
		}
		
		public function playRootAnimation(animationName:String,immediate:Boolean=false):void
		{
			_playSingleAnimation(_armature,animationName,immediate);
		}
		
		public function playAnimationRecursive(animationName:String,immediate:Boolean=false,rootPlay:Boolean=true):void
		{
			if(rootPlay) _playSingleAnimation(_armature,animationName,immediate);
			_playAnimation(_getArmatures(""),animationName,immediate);
		}
		
		public function setProperty(key:String,value:String,noAnimarion:Boolean=false):void
		{
			if(!_armature) return;
			_playAnimation(_getArmatures(key),value,noAnimarion);
			_props[key ? key : ROOT_KEY] = value;
		}
		
		public function getProperty(key:String):String
		{
			return _props[key ? key : ROOT_KEY];
		}
		
		public function setDisplayObjectsTouchable(key:String,touchable:Boolean):void
		{
			if(!_armature) return;
			var v:Vector.<DisplayObject> = _getDisplayObjects(key);
			for each(var d:DisplayObject in v)
			{
				d.touchable = touchable;
			}
		}
		
		public function move(xx:Number,yy:Number):void
		{
			var disp:DisplayObject = display;
			if(disp)
			{
				disp.x = xx;
				disp.y = yy;
			}
		}
        
        public function setScaleXandY(scale:Number):void
        {
            var disp:DisplayObject = display;
            if(disp)
            {
                disp.scaleX = scale;
                disp.scaleY = scale;
            }
        }
		
        public function getCursorPosX():Number
        {
            var disp:DisplayObject = display;
            if(disp)
            {
                return disp.x;
            }
            return -1;
        }
        
        public function getCursorPosY():Number
        {
            var disp:DisplayObject = display;
            if(disp)
            {
                return disp.y;
            }
            return -1;
        }
        
		/**
		 * 一番階層の浅い位置にある指定レイヤーのdisplayObjectContainerを返す
		 */
		public function getDisplayObjectContainer(key:String):DisplayObjectContainer
		{
			if(_dQuery)
			{
				var v:Vector.<DisplayObject> = _dQuery.getDisplayObjects(key);
				var len:int = v.length;
				for(var i:int=0;i<len;i++)
				{
					var d:DisplayObjectContainer = v[i] as DisplayObjectContainer;
					if(d)
					{
						return d;
					}
				}
			}
			return null;
		}
		
		private function _getArmatures(key:String):Vector.<Armature>
		{
			var v:Vector.<Armature>;
			v = _dQuery.getDescendantArmatures(key);
			if(!key)
			{
				v = v.slice();
				v.unshift(_armature);
			}
			return v;
		}
		
		private function _getDisplayObjects(key:String):Vector.<DisplayObject>
		{
			var v:Vector.<DisplayObject> = _dQuery.getDisplayObjects(key);
			if(!key)
			{
				if(_armature && _armature.display)
				{
					v.unshift(_armature.display as DisplayObject);
				}
			}
			return v;
		}
		
		private function _playAnimation(v:Vector.<Armature>,baseAnimName:String,immediate:Boolean):void
		{
			if(!v || v.length==0) return;
			var len:int = v.length;
			for(var i:int=0;i<len;i++)
			{
				var armature:Armature = v[i];
				_playSingleAnimation(armature,baseAnimName,immediate);
			}
		}
		
		private function _playSingleAnimation(armature:Armature,baseAnimName:String,immediate:Boolean):void
		{
			var animName:String = baseAnimName + (immediate ? "" : "_show");
			var animation:Animation = armature.animation;
            var animList:Vector.<String> = animation.animationList;
			if(animList.indexOf(animName)>=0)
			{
                //trace("play",animName,"@"+armature.name);
				animation.gotoAndPlay(animName);
				if(immediate)
				{
					//animation.advanceTime(LONG_TIME);//次のアニメーションが出てしまう事が！
				}
			}
			else if(!immediate)
			{
				if(animList.indexOf(baseAnimName)>=0)
				{
                    //trace("play",baseAnimName,"@"+armature.name);
					animation.gotoAndPlay(baseAnimName);
				}
			}
		}
	}
}
