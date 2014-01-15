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
		private var _buttonA:Armature;
		private var _buttonB:Armature;
		
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
			stage.alpha = 0.999999;
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
						
			function handleEnterFrame(ev:Event):void
			{
				WorldClock.clock.advanceTime(-1);
			}
			
			function handleDragonComplete():void
			{
				_buttonA = _factory.buildArmature("ButtonA");
				WorldClock.clock.add(_buttonA);
				(_buttonA.display as DisplayObject).scaleX = (_buttonA.display as DisplayObject).scaleY = 1.5;
				(_buttonA.display as DisplayObject).x = 320 - (_buttonA.display as DisplayObject).width/2;
				(_buttonA.display as DisplayObject).y = 200;
				self.addChild(_buttonA.display as DisplayObject);
				
				_buttonB = _factory.buildArmature("ButtonB");
				WorldClock.clock.add(_buttonB);
				(_buttonB.display as DisplayObject).x = 320;
				(_buttonB.display as DisplayObject).y = 550;
				self.addChild(_buttonB.display as DisplayObject);

								
				var btnA:ArmatureButton = new ArmatureButton(_buttonA);
				var btnB:ArmatureButton = new ArmatureButton(_buttonB);
				
				btnA.onTriggered = function():void
				{
					trace("A clicked");
					btnA.freeze = true;
					_starling.juggler.delayCall(function():void{
						btnA.freeze = false;
						btnA.reset();
					},4);
					
					btnB.disabled = !btnB.disabled;
					
				}
					
				btnB.onTriggered = function():void
				{
					trace("B clicked");
					
					btnA.disabled = !btnA.disabled;
					
				}
					
			}
			
			_factory.addEventListener(Event.COMPLETE, handleDragonComplete);
			_factory.parseData(_assetManager.getByteArray("buttonSetA"));
			
			stage.addEventListener(Event.ENTER_FRAME,handleEnterFrame);
			
		}
	}
}