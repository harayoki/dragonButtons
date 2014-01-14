package harayoki
{
	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.geom.Rectangle;
	
	import dragonBones.Armature;
	import dragonBones.animation.WorldClock;
	import dragonBones.factorys.StarlingFactory;
	
	import starling.core.Starling;
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
		private var _bg:Armature;
		
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
			//_assetManager.enqueue("assets/hoge.dbswf");
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
//				_bg = _factory.buildArmature("ANIM_ALL");
//				DragonBonesUtil.traceArmature(_bg);
//				WorldClock.clock.add(_bg);
//				_bg.animation.gotoAndPlay("main");
//				self.addChild(_bg.display as DisplayObject);
			}
			
			_factory.addEventListener(Event.COMPLETE, handleDragonComplete);
			//_factory.parseData(_assetManager.getByteArray("hoge"));
			
			stage.addEventListener(Event.ENTER_FRAME,handleEnterFrame);
			
		}
	}
}