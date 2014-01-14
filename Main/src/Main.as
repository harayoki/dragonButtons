package
{
	import flash.display.Sprite;
	
	import harayoki.MainSprite;
	
	//[SWF(width='320', height='480', backgroundColor='#333333', frameRate='60')] 
	[SWF(width='640', height='960', backgroundColor='#333333', frameRate='60')] 
	public class Main extends Sprite
	{
		public function Main()
		{
			MainSprite.main(stage);
		}
	}
}