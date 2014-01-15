package harayoki.dragonbones
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	import dragonBones.Armature;
	import dragonBones.Slot;
	
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;

	public class ArmatureButton
	{
		
		protected static const STATE_NORMAL:String = "_normal";
		protected static const STATE_UP:String = "_up";
		protected static const STATE_DOWN:String = "_down";
		protected static const STATE_OVER:String = "_over";
		protected static const STATE_DISABLED:String = "_disabled";
		
		protected static const HELPER_POINT:Point = new Point();
		
		protected var _armature:Armature;
		protected var _freeze:Boolean = false;
		protected var _disabled:Boolean = false;
		protected var _lastAnimationName:String = null;
		protected var _animationInfo:Object;
		protected var _triggered:Boolean = false;
		protected var _currentState:String = null;
		protected var _invalidateId:uint = 0;		
		protected var _hitAreaObject:DisplayObject;		
		protected var _debugHitArea:Boolean;

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
		
		public function ArmatureButton(armature:Armature=null)
		{			
			_animationInfo = {};
			if(armature)
			{
				applyArmature(armature);
			}
		}
		
		/**
		 * 廃棄処理 
		 */
		public function destruct():void
		{
			_cleanArmature();
			_animationInfo = null;
			_armature = null;
			onTriggered = null;
			onChange = null;
			onLongPress = null;
			_hitAreaObject = null;
			if(_invalidateId!=0)
			{
				flash.utils.clearTimeout(_invalidateId);
				_invalidateId = 0;
			}
		}
		
		
		/**
		 * ボタン処理が有効か？
		 */
		public function get freeze():Boolean
		{
			return _freeze;
		}
		
		public function set freeze(value:Boolean):void
		{
			if(_freeze == value) return;
			_freeze = value;			
			var sp:DisplayObject = hitAreaObject;
			if(sp)
			{
				_resetTouchable();
			}
		}
		
		public function get disabled():Boolean
		{
			return _disabled;
		}
		
		public function set disabled(value:Boolean):void
		{
			if(_disabled == value)
			{
				return;
			}
			_disabled = value;
			_resetTouchable();
			currentState = _disabled ? STATE_DISABLED : STATE_NORMAL;
			invalidate();
		}
		
		public function get debugHitArea():Boolean
		{
			return _debugHitArea;
		}
		
		public function set debugHitArea(value:Boolean):void
		{
			if(_debugHitArea == value) return;
			_debugHitArea = value;
			invalidate();
		}		

		protected var _stateNames:Vector.<String> = new <String> [ STATE_NORMAL, STATE_UP, STATE_DOWN, STATE_OVER, STATE_DISABLED ];
		
		protected function get stateNames():Vector.<String>
		{
			return this._stateNames;
		}		
		
		/**
		 * @private
		 */
		
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
			if(_currentState == STATE_UP && value == STATE_OVER)
			{
				//認めない
				return;
			}
			_currentState = value;
			invalidate();
		}
		
		
		protected function invalidate():void
		{
			if(!_armature) return;			
			
			if(_invalidateId==0)
			{
				_invalidateId = flash.utils.setTimeout(function():void{
					_invalidateId = 0;
					var animationName:String = _animationInfo[_currentState];
					DisplayObject(_armature.display).alpha = 1.0;
					if(_currentState == STATE_DISABLED && !animationName)
					{
						//STATE_DISABLEDのアニメが用意されていない場合は半透明にする
						DisplayObject(_armature.display).alpha = 0.5;
						_armature.animation.stop();
					}
					else if(animationName != _lastAnimationName)
					{
						_lastAnimationName = animationName;
						//trace(_lastAnimationName);
						_armature.animation.gotoAndPlay(_lastAnimationName);
					}
					
					if(_hitAreaObject && _hitAreaObject != _armature.display)
					{
						_hitAreaObject.alpha = _debugHitArea ? 0.5 : 0.0;
					}
					
				},0);
			}
			
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
		
		public function reset():void
		{
			currentState = STATE_NORMAL;
		}
		
		protected function get hitAreaObject():DisplayObject
		{
			if(_hitAreaObject) return _hitAreaObject;			
			if(!_armature) return null;
			
			_hitAreaObject = _armature.display as Sprite;			
			
			var slot:Slot = _armature.getSlot("hitArea");
			if(!slot)
			{
				return _hitAreaObject;
			}
			var dobj:DisplayObject = slot.display as DisplayObject;
			if(dobj)
			{				
				//hitAreaオブジェクトが見つかったので最前面に持ってくる
				//他の物はタッチに反応させない
				_hitAreaObject = dobj;
				var slots:Vector.<Slot> = _armature.getSlots();
				var len:int = slots.length;
				for(var i:int=0; i<len;i++)
				{
					var theSlot:Slot = slots[i];
					(theSlot.display as DisplayObject).touchable = false;
				}
				slot.zOrder = len -1 ;
				(slot.display as DisplayObject).touchable = true;
				if(_hitAreaObject as Image) 
				{
					(_hitAreaObject as Image).color = 0xff00ff;
				}
			}
			return _hitAreaObject;
		}
		
		protected function _initArmature():void
		{
			if(!hitAreaObject) return;
			hitAreaObject.addEventListener(TouchEvent.TOUCH,_handleTouch);
			_resetTouchable();
			var animations:Vector.<String> = _armature.animation.animationList;
			for(var i:int=0;i<animations.length;i++)
			{
				var animation:String = animations[i];
				_animationInfo[animation] = animation;
				//trace(animation);
			}
			
			//STATE_NORMALが基本ですが、FlasherにとってMovieClipButtonは"_up"ラベルが基本になるので、STATE_NORMALが無い場合はUPを使います
			
			//upが見当たらない場合は最初のラベルを使う
			if(!_animationInfo[STATE_UP])
			{
				_animationInfo[STATE_UP] = animations[0];
			}
			//normalが見当たらない場合はupを使う
			if(!_animationInfo[STATE_NORMAL])
			{
				_animationInfo[STATE_NORMAL] = _animationInfo[STATE_UP]
			}
			//overが見当たらない場合はnormalを使う
			if(!_animationInfo[STATE_OVER])
			{
				_animationInfo[STATE_OVER] = _animationInfo[STATE_NORMAL]
			}
			//downが見当たらない場合はnormalを使う
			if(!_animationInfo[STATE_DOWN])
			{
				_animationInfo[STATE_DOWN] = _animationInfo[STATE_NORMAL]
			}
			currentState = STATE_NORMAL;
		}
		
		protected function _resetTouchable():void
		{
			hitAreaObject.touchable = (!_freeze && !_disabled);
		}
		
		protected function _cleanArmature():void
		{
			_animationInfo = {};
			var sp:DisplayObject = hitAreaObject;
			if(!sp) return;
			sp.removeEventListener(TouchEvent.TOUCH,_handleTouch);
		}
		
		protected function _handleTouch(ev:TouchEvent):void
		{
			var touch:Touch = ev.getTouch(hitAreaObject);
			if(!touch)
			{
				currentState = STATE_NORMAL;
				return;
			}
			//trace(touch.phase);
			if(touch.phase == TouchPhase.BEGAN)
			{
				currentState = STATE_DOWN;
			}
			else if(touch.phase == TouchPhase.HOVER)
			{
				currentState = STATE_OVER;
			}
			else if(touch.phase == TouchPhase.MOVED)
			{
			}
			else if(touch.phase == TouchPhase.ENDED)
			{
				if(_hitTest(touch))
				{
					currentState = STATE_UP;
					onTriggered && onTriggered();
				}
				else
				{
					currentState = STATE_NORMAL;
				}
			}
		}
		
		protected function _hitTest(touch:Touch):Boolean
		{
			//stageが実際にクリックされる時まで存在するかわからないのと
			//対象DisplayObjectの大きさがどうもただしくとれないのでここで毎回rectを取得する スピード的には遅いかもしれないが hitAreaObjectの移動にも耐えられる。。
			var rect:Rectangle = hitAreaObject.getBounds(hitAreaObject.stage);
			touch.getLocation(hitAreaObject.stage,HELPER_POINT);
			//trace(rect,HELPER_POINT);
			return rect.containsPoint(HELPER_POINT);
		}

	}
}