package harayoki.dragonbones
{
	import dragonBones.Armature;
	
	import starling.display.DisplayObject;
	import starling.display.Sprite;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;

	public class ArmatureButton
	{
		
		private static const STATE_UP:String = "_up";
		private static const STATE_DOWN:String = "_down";
		private static const STATE_OVER:String = "_over";
		private static const STATE_DISABLED:String = "_disabled";
		
		private var _armature:Armature;
		private var _enabled:Boolean = true;
		private var _lastAnimationState:String = null;
		private var _animationStateInfo:Object;
		private var _hitTestObject:DisplayObject;
		
		/**
		 * クリック時のハンドラ 
		 */
		public var onTriggered:Function;
		
		/**
		 * トグル時のハンドラ 
		 */
		public var onChange:Function;
		
		/**
		 * 長押し時のハンドラ
		 */
		public var onLongPress:Function;		
		
		public function ArmatureButton()
		{			
			_animationStateInfo = {};
		}
		
		/**
		 * 廃棄処理 
		 */
		public function destruct():void
		{
			_cleanArmature();
			_armature = null;
			onTriggered = null;
			onChange = null;
			onLongPress = null;
			_animationStateInfo = null;
		}
		
		
		/**
		 * ボタン処理が有効か？
		 */
		public function get enabled():Boolean
		{
			return _enabled;
		}
		
		/**
		 * @private
		 */
		public function set enabled(value:Boolean):void
		{
			if(_enabled == value) return;
			_enabled = value;			
			var sp:Sprite = armatureSprite;
			if(sp)
			{
				sp.touchable = _enabled;
			}
		}
		
		
		/**
		 * @private
		 */
		protected var _stateNames:Vector.<String> = new <String> [ STATE_UP, STATE_DOWN, STATE_OVER, STATE_DISABLED ];
		
		protected function get stateNames():Vector.<String>
		{
			return this._stateNames;
		}		
		
		/**
		 * @private
		 */
		protected var _currentState:String = STATE_UP;
		
		protected function get currentState():String
		{
			return _currentState;
		}
		
		protected function set currentState(value:String):void
		{
			if(_currentState == value)
			{
				return;
			}
			if(stateNames.indexOf(value) < 0)
			{
				throw new ArgumentError("Invalid state: " + value + ".");
			}
			_currentState = value;
			invalidate();//INVALIDATION_FLAG_STATE
		}
		
		
		protected function invalidate():void
		{
			if(!_armature) return;			
			//var animationState:String = this._currentState;
			trace(_currentState);
			_armature.animation.gotoAndPlay(_currentState);
			
		}
		
		
		/**
		 * @param armature アーマーチャーを登録する
		 */
		public function applyArmature(armature:Armature):void
		{
			_cleanArmature();
			_armature = armature;
			_initArmature();
		}
		
		protected function get armatureSprite():Sprite
		{
			if(!_armature) return null;
			var sp:Sprite = _armature.display as Sprite;
			return sp;
		}
		
		protected function _initArmature():void
		{
			var sp:Sprite = armatureSprite;
			if(!sp) return;
			sp.addEventListener(TouchEvent.TOUCH,_handleTouch);
			sp.touchable = _enabled;
			var animations:Vector.<String> = _armature.animation.animationList;
			for(var i:int=0;i<animations.length;i++)
			{
				var animation:String = animations[i];
				_animationStateInfo[animation] = true;
			}
			currentState = STATE_UP;
		}
		
		protected function _cleanArmature():void
		{
			_animationStateInfo = {};
			var sp:Sprite = armatureSprite;
			if(!sp) return;
			sp.removeEventListener(TouchEvent.TOUCH,_handleTouch);
		}
		
		private var _pressed:Boolean = false;
		
		private function _handleTouch(ev:TouchEvent):void
		{
			var touch:Touch = ev.getTouch(armatureSprite);
			trace(touch);
			if(!touch)
			{
				_pressed = false;
				currentState = STATE_UP;
				return;
			}
			if(touch.phase == TouchPhase.BEGAN)
			{
				_pressed = true;
				currentState = STATE_DOWN;
			}
			else if(touch.phase == TouchPhase.HOVER)
			{
				if(!_pressed)
				{
					currentState = STATE_OVER;
				}
			}
			else if(touch.phase == TouchPhase.MOVED)
			{
				//currentState = STATE_UP;				
			}
			else if(touch.phase == TouchPhase.ENDED)
			{
				_pressed = false;
				currentState = STATE_UP;
			}
		}

	}
}