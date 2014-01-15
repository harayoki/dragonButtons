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
		private var _armatureB:Armature;

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
						
			function handleEnterFrame(ev:Event):void
			{
				WorldClock.clock.advanceTime(-1);
			}
			
			function handleDragonComplete():void
			{
				_armatureA = _factory.buildArmature("ButtonA");
				WorldClock.clock.add(_armatureA);
				(_armatureA.display as DisplayObject).scaleX = (_armatureA.display as DisplayObject).scaleY = 1.5;
				(_armatureA.display as DisplayObject).x = 320 - (_armatureA.display as DisplayObject).width/2;
				(_armatureA.display as DisplayObject).y = 200;
				self.addChild(_armatureA.display as DisplayObject);
				
				_armatureB = _factory.buildArmature("ButtonB");
				(_armatureB.display as DisplayObject).scaleX = (_armatureB.display as DisplayObject).scaleY = 1.5;
				WorldClock.clock.add(_armatureB);
				(_armatureB.display as DisplayObject).x = 320;
				(_armatureB.display as DisplayObject).y = 550;
				self.addChild(_armatureB.display as DisplayObject);

								
				var btnA:ArmatureButton = new ArmatureButton(_armatureA);
				var btnB:ArmatureButton = new ArmatureButton(_armatureB);				
				btnA.debugHitArea = false;
				btnB.debugHitArea = false;
				
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