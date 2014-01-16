package harayoki
{
	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.geom.Rectangle;
	
	import dragonBones.Armature;
	import dragonBones.animation.WorldClock;
	import dragonBones.factorys.StarlingFactory;
	
	import harayoki.dragonbones.ArmatureButton;
	
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.utils.AssetManager;
	import starling.utils.RectangleUtil;
	import starling.utils.ScaleMode;
	
	/**
	 * リスト動作サンプル メイン
	 * _startメソッド内がサンプルとして主となる箇所
	 * @author haruyuki.imai
	 */
	public class MainSprite extends Sprite
	{
		private static const CONTENTS_WIDTH:int = 640;
		private static const CONTENTS_HEIGHT:int = 960;
		private static var _starling:Starling;
		private static var _flashStage:Stage;
		
		private var _assetManager:AssetManager;
		private var _factory:StarlingFactory;
		private var _armatureA:Armature;
		private var _armatureB1:Armature;
		private var _armatureB2:Armature;

		/**
		 * ここから動作スタート
		 */
		public static function main(stage:Stage):void
		{
			_flashStage = stage;
			
			_flashStage.align = StageAlign.TOP_LEFT;
			_flashStage.scaleMode = StageScaleMode.NO_SCALE;
			Starling.handleLostContext = true;
			
			_starling = new Starling(MainSprite,_flashStage,new Rectangle(0,0,CONTENTS_WIDTH,CONTENTS_HEIGHT));
			_starling.showStats = true;
			_starling.showStatsAt("right","top",2);		
		}
		
		public function MainSprite()
		{
			
			_factory = new StarlingFactory();			
			addEventListener(Event.ADDED_TO_STAGE,_handleAddedToStage);
		}
		
		private function _handleAddedToStage():void
		{
			stage.color = _flashStage.color;
			stage.alpha = 0.999999;//for paerformance
			stage.addEventListener(Event.RESIZE,_handleStageResize);
			_starling.start();		
			
			_loadAssets();
		}
		
		private function _handleStageResize(ev:Event):void
		{
			var w:int = _flashStage.stageWidth;
			var h:int = _flashStage.stageHeight
			_starling.viewPort = RectangleUtil.fit(
				new Rectangle(0, 0, CONTENTS_WIDTH, CONTENTS_HEIGHT),
				new Rectangle(0, 0, w,h),
				ScaleMode.SHOW_ALL);			
		}
		
		private function _loadAssets():void
		{
			_assetManager = new AssetManager();
			_assetManager.verbose = true;
			_assetManager.enqueue("assets/textures.png");
			_assetManager.enqueue("assets/textures.xml");
			_assetManager.enqueue("assets/buttonSetA.dbswf");
			_assetManager.loadQueue(function(num:Number):void{
				if(num==1.0)
				{
					_start();
				}
			});
		}
		
		private function _start():void
		{
	
			var self:MainSprite = this;
			
			_factory.addEventListener(Event.COMPLETE, handleDragonComplete);
			_factory.parseData(_assetManager.getByteArray("buttonSetA"));
			stage.addEventListener(Event.ENTER_FRAME,handleEnterFrame);
			
			function handleEnterFrame(ev:Event):void
			{
				WorldClock.clock.advanceTime(-1);
			}
			
			function handleDragonComplete():void
			{
								
				function locateArmature(arm:Armature,xx:int,yy:int,scale:Number=0):void
				{
					var dobj:DisplayObject = arm.display as DisplayObject;
					WorldClock.clock.add(arm);
					dobj.scaleX = dobj.scaleY = scale;
					dobj.x = xx;
					dobj.y = yy;
					self.addChild(dobj);
				}
				
				_armatureA = _factory.buildArmature("ButtonA");
				locateArmature(_armatureA,320,350,1.5);
				
				_armatureB1 = _factory.buildArmature("ButtonB");
				locateArmature(_armatureB1,320,600,2.0);
				
				_armatureB2 = _factory.buildArmature("ButtonB");
				locateArmature(_armatureB2,320,700,2.0);
				
				_armatureB2.getSlot("text").childArmature.getSlot("text").childArmature.animation.gotoAndPlay("no");
								
				var btnA:ArmatureButton = new ArmatureButton(_armatureA,true,"カボチャ");
				var btnB1:ArmatureButton = new ArmatureButton(_armatureB1,true,"yes");				
				var btnB2:ArmatureButton = new ArmatureButton(_armatureB2,true,"no");				
				
				//タッチがボタンからはみ出た時にdownStateのままでいるか？ デフォルト:false
				btnA.keepDownStateOnRollOut = false;
				btnB1.keepDownStateOnRollOut = true;
				btnB2.keepDownStateOnRollOut = true;
				
				btnA.onTriggered = function():void
				{
					trace(btnA.userData+" clicked");					
					btnA.freeze = true;
					_starling.juggler.delayCall(function():void{
						btnA.freeze = false;
						btnA.resetButton();
						btnB1.disabled = false;
						btnB2.disabled = false;
					},4);
					
					btnB1.disabled = true;
					btnB2.disabled = true;	
				}
					
				btnB1.onTriggered = function():void
				{
					trace(btnB1.userData+" clicked");					
					btnA.disabled = false;
				}
				btnB2.onTriggered = function():void
				{
					trace(btnB2.userData+" clicked");					
					//btnA.disabled = true;					
				}
					
			}

			
		}
	}
}