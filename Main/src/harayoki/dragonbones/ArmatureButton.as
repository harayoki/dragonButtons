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
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;

	public class ArmatureButton
	{
		
		//protected static const GRAY_FILTER:ColorMatrixFilter = new ColorMatrixFilter();
		
		protected static const HELPER_POINT:Point = new Point();
		protected static const HELPER_ARMATURE_VECTOR:Vector.<Armature> = new Vector.<Armature>();
		protected static const HIT_AREA_DISPLAYOBJECT_NAME:String = "hitArea";
		
		protected static const STATE_UP:String = "_up";
		protected static const STATE_OVER:String = "_over";
		protected static const STATE_DOWN:String = "_down";
		protected static const STATE_DISABLED:String = "_disabled";
		protected static const STATE_TRIGGER:String = "_trigger";
		protected static const STATE_LONGPRESS:String = "_longpress";
	
		protected var _stateNames:Vector.<String> = new <String> [ STATE_UP, STATE_TRIGGER, STATE_DOWN, STATE_OVER, STATE_DISABLED, STATE_LONGPRESS ];		
		protected var _armature:Armature;
		protected var _animationInfo:Object;
		protected var _hitAreaObject:DisplayObject;		
		protected var _freeze:Boolean = false;
		protected var _disabled:Boolean = false;
		protected var _lastAnimationName:String = null;
		protected var _triggered:Boolean = false;
		protected var _currentState:String = null;
		protected var _invalidateId:uint = 0;		
		protected var _debugHitArea:Boolean;
		protected var _touchPointID:int = -1;
		protected var _autoDestruct:Boolean = false;
		protected var _isSelected:Boolean = false;		
		protected var _isLongPressEnabled:Boolean = false;
		protected var _touchBeginTime:int;
		protected var _hasLongPressed:Boolean;
				
		/**
		 * ユーザが自由に使えるデータ
		 */
		public var userData:*;

		/**
		 * ボタンを押したままロールアウトしたらupStateに戻すか？
		 */
		public var keepDownStateOnRollOut:Boolean = false;
		
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
		 * (未実装)
		 */
		public var onLongPress:Function;		
		
		/**
		 * トグルモードで動かすか 
		 */
		public var isToggle:Boolean = false;
		
		/**
		 * 長押しと判定される秒数
		 */
		public var longPressDuration:Number = 0.3;
				
		/**
		 * @param armature ボタン化するアーマーチャー
		 * @param autoDestruct armatureのdisplayObjectがStageから離れた際にこのボタンも廃棄するか
		 * @param userData 任意のユーザが自由に使えるデータ
		 */
		public function ArmatureButton(armature:Armature=null,autoDestruct:Boolean=false,userData:*=null)
		{			
			_animationInfo = {};
			if(armature)
			{
				applyArmature(armature,autoDestruct);
			}
			this.userData = userData;
		}
		
		/**
		 * 廃棄処理 
		 * armature
		 */
		public function destruct():void
		{
			trace("ArmatureButton#destruct");
			_cleanArmature();
			_animationInfo = null;
			_armature = null;
			onTriggered = null;
			onChange = null;
			onLongPress = null;
			_hitAreaObject = null;
			_stateNames = null;
			if(_invalidateId!=0)
			{
				flash.utils.clearTimeout(_invalidateId);
				_invalidateId = 0;
			}
			userData = null;
		}
		
		
		//取りうるボタンState
		protected function get stateNames():Vector.<String>
		{
			return this._stateNames;
		}		

		/**
		 * ボタン処理を無効化する
		 * disabledと異なり見た目に変化は無いので、
		 * アニメーション再生の間ボタンを無効化したい時等に使う
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
		
		/**
		 * ボタン処理を無効化する
		 * ボタンの見た目も変化する
		 */
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
			currentState = _disabled ? STATE_DISABLED : STATE_UP;
			_draw();
		}
		
		/**
		 * デバッグ用にhitAreaを表示するか
		 * (hitAreaが指定されていない場合は何も起こらない)
		 */
		public function get debugHitArea():Boolean
		{
			return _debugHitArea;
		}
		
		public function set debugHitArea(value:Boolean):void
		{
			if(_debugHitArea == value) return;
			_debugHitArea = value;
			_draw();
		}		
		
		/**
		 * 現在選択中か(トグルモードでのみ有効)
		 */
		public function get isSelected():Boolean
		{
			return _isSelected;
		}
		
		public function set isSelected(value:Boolean):void
		{
			if(_isSelected == value) return;
			_isSelected = value;
			onChange && onChange();
		}

		/**
		 * ボタン長押しを
		 */
		public function get isLongPressEnabled():Boolean
		{
			return _isLongPressEnabled;
		}
		
		/**
		 * @private
		 */
		public function set isLongPressEnabled(value:Boolean):void
		{
			_isLongPressEnabled = value;
			if(!value && hitAreaObject)
			{
				hitAreaObject.removeEventListener(Event.ENTER_FRAME, _handleLongPressEnterFrame);
			}
		}		
		
		//現在のState
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
			if(_currentState == STATE_TRIGGER && value == STATE_OVER)
			{
				//trrigerの演出がありうるのでこの遷移は認めない
				return;
			}
			_currentState = value;
			_draw();
		}
		
		//描画し直す (1フレームに１回だけの処理にまとめられる)
		protected function _draw():void
		{
			if(!_armature) return;			
			
			if(_invalidateId==0)
			{
				_invalidateId = flash.utils.setTimeout(function():void{
					_invalidateId = 0;
					var animationName:String;
					animationName = _animationInfo[_currentState];
					
					if(isSelected && (animationName == _animationInfo[STATE_TRIGGER] || animationName == _animationInfo[STATE_UP]))
					{
						animationName =  _animationInfo[STATE_DOWN];
					}
					
					DisplayObject(_armature.display).alpha = 1.0;
					if(_currentState == STATE_DISABLED && !animationName)
					{
						//STATE_DISABLEDのアニメが用意されていない場合は半透明にする
						DisplayObject(_armature.display).alpha = 0.5;
						_armature.animation.stop();
						_lastAnimationName = "";//こうしておかないと別のStateに変化した際に止まったままになる
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
		 * アーマーチャーを登録する
		 * @param armature ボタン化するアーマーチャー
		 * @param autoDestruct armatureのdisplayObjectがStageから離れた際にこのボタンも廃棄するか
		 */
		public function applyArmature(armature:Armature,autoDestruct:Boolean):void
		{
			_cleanArmature();
			_armature = armature;
			_autoDestruct = autoDestruct;
			_initArmature();
			
		}
		
		/**
		 * ボタンの状態をデフォルトに戻す 
		 * 外部で直接アニメーション処理を制御した際等に使う
		 */
		public function resetButton():void
		{
			_touchPointID = -1;
			isSelected = false;
			currentState = STATE_UP;
		}
		
		protected function _resetTouchState():void
		{
			_touchPointID = -1;
			if(hitAreaObject) hitAreaObject.removeEventListener(Event.ENTER_FRAME,_handleLongPressEnterFrame);
		}
		
		/**
		 * patternにマッチするボタン内部の子孫Armatureをまとめてアニメさせる
		 * @param slotNamePattern 名前パターン String型またはRegExp型
		 * @param animationName 移動するアニメーション名
		 * 主にテキストラベルを切り替えるような用途で使う事を想定
		 * ※子孫のクエリが重いと思われるので、乱用はしない事
		 */
		public function gotoAndPlayBySlotName(slotNamePattern:*,animationName:String):void
		{
			if(!_armature) return;

			HELPER_ARMATURE_VECTOR.length = 0;
			DragonBonesUtil.gotoAndPlayBySlotName(_armature,slotNamePattern,animationName,HELPER_ARMATURE_VECTOR);
		}
		
		//hit判定に使うdisplayObjectを返す
		protected function get hitAreaObject():DisplayObject
		{
			//計算済みの物があればそれを使う
			if(_hitAreaObject) return _hitAreaObject;
				
			if(!_armature) return null;
			
			_hitAreaObject = _armature.display as Sprite;			
			
			//特別な名前のdisplayObjectがあれば、それをヒット領域に使う
			var slot:Slot = _armature.getSlot(HIT_AREA_DISPLAYOBJECT_NAME);
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
				
				//デバッグ処理用に最前面に持ってきておく
				slot.zOrder = len -1 ;
				
				(slot.display as DisplayObject).touchable = true;
				_hitAreaObject.alpha = 0.0;//validateに透明度制御を任せるだけだと一瞬見えてしまうので、ここでいったん消す
				if(_hitAreaObject as Image) 
				{
					//デバッグ処理用に赤くしておく
					(_hitAreaObject as Image).color = 0xff00ff;
				}
			}
			return _hitAreaObject;
		}
		
		protected function _initArmature():void
		{
			var dobj:DisplayObject = hitAreaObject;//ここでhitAreaObjectが作られる
			if(!dobj) return;
			
			dobj.addEventListener(TouchEvent.TOUCH,_handleTouch);
			_resetTouchable();
			
			if(_autoDestruct)
			{
				dobj.addEventListener(Event.REMOVED_FROM_STAGE,_handleRemoveFromStage);
			}
			
			//アニメーションラベルを解析して、足りない物は良い感じに割り当てる
			var animations:Vector.<String> = _armature.animation.animationList;
			for(var i:int=0;i<animations.length;i++)
			{
				var animation:String = animations[i];
				_animationInfo[animation] = animation;
				//trace("--",animation);
			}
						
			//upが見当たらない場合は最初のラベルを使う
			if(!_animationInfo[STATE_UP])
			{
				_animationInfo[STATE_UP] = animations[0];
			}
			//triggerが見当たらない場合はupを使う
			if(!_animationInfo[STATE_TRIGGER])
			{
				_animationInfo[STATE_TRIGGER] = _animationInfo[STATE_UP]
			}
			//overが見当たらない場合はnormalを使う
			if(!_animationInfo[STATE_OVER])
			{
				_animationInfo[STATE_OVER] = _animationInfo[STATE_UP]
			}
			//downが見当たらない場合はnormalを使う
			if(!_animationInfo[STATE_DOWN])
			{
				_animationInfo[STATE_DOWN] = _animationInfo[STATE_UP]
			}
			//longpressが見当たらない場合はdownを使う
			if(!_animationInfo[STATE_LONGPRESS])
			{
				_animationInfo[STATE_LONGPRESS] = _animationInfo[STATE_DOWN];
			}
			
			resetButton();
			
		}
		
		protected function _handleRemoveFromStage(ev:Event):void
		{
			destruct();
		}
		
		protected function _handleLongPressEnterFrame(ev:Event):void
		{
			var accumulatedTime:Number = (flash.utils.getTimer() - _touchBeginTime) / 1000;
			if(accumulatedTime >= longPressDuration)
			{
				hitAreaObject.removeEventListener(Event.ENTER_FRAME, _handleLongPressEnterFrame);
				_hasLongPressed = true;
				onLongPress && onLongPress();
				currentState = STATE_LONGPRESS;
			}
		}
		
		protected function _resetTouchable():void
		{
			_touchPointID = -1;
			hitAreaObject.touchable = (!_freeze && !_disabled);
		}
		
		protected function _cleanArmature():void
		{
			_animationInfo = {};
			if(_armature)
			{
				if(_autoDestruct) DisplayObject(_armature.display).removeEventListener(Event.REMOVED_FROM_STAGE,_handleRemoveFromStage);				
				hitAreaObject.removeEventListener(TouchEvent.TOUCH,_handleTouch);
				hitAreaObject.removeEventListener(Event.ENTER_FRAME, _handleLongPressEnterFrame);
			}			
		}

		protected function _handleTouch(ev:TouchEvent):void
		{
			var touch:Touch;
			if(_touchPointID<0)
			{
				touch = ev.getTouch(hitAreaObject, TouchPhase.BEGAN);
				if(touch)
				{
					currentState = STATE_DOWN;
					_touchPointID = touch.id;
					if(_isLongPressEnabled)
					{
						_touchBeginTime = flash.utils.getTimer();
						_hasLongPressed = false;
						hitAreaObject.addEventListener(Event.ENTER_FRAME, _handleLongPressEnterFrame);
					}
					return;
				}
				touch = ev.getTouch(hitAreaObject, TouchPhase.HOVER);
				if(touch)
				{
					currentState = STATE_OVER;
					return;
				}
				
				currentState = STATE_UP;
				
				return;
				
			}
			
			touch = ev.getTouch(hitAreaObject, null, _touchPointID);
			if(!touch)
			{
				//起こりえる
				return;
			}
			//trace(touch.phase);
			const isHit:Boolean = _hitTest(touch);
			if(touch.phase == TouchPhase.MOVED)
			{
				if(isHit || keepDownStateOnRollOut)
				{
					this.currentState = STATE_DOWN;
				}
				else
				{
					this.currentState = STATE_UP;
				}
			}
			else if(touch.phase == TouchPhase.ENDED)
			{
				_resetTouchState();
				if(!_hasLongPressed && isHit)
				{
					if(isToggle)
					{
						isSelected = !isSelected;
					}
					currentState = _isLongPressEnabled ? STATE_UP : STATE_TRIGGER;
					onTriggered && onTriggered();
				}
				else
				{
					currentState = STATE_UP;
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