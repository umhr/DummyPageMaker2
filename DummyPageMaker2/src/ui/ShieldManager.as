package ui
{
	import com.bit101.components.Label;
	import com.bit101.components.PushButton;
	import flash.display.Sprite;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author umhr
	 */
	public class ShieldManager extends Sprite 
	{
		private static var _instance:ShieldManager;
		public function ShieldManager(block:Block){init();};
		public static function getInstance():ShieldManager{
			if ( _instance == null ) {_instance = new ShieldManager(new Block());};
			return _instance;
		}
		
		
		[Event(name = "save", type = "Shield")]
		static public const SAVE:String = "save";
		private var _sheeldLabel:Label;
		private var _saveBtn:PushButton;
		private function init():void
		{
			if (stage) onInit();
			else addEventListener(Event.ADDED_TO_STAGE, onInit);
		}

		private function onInit(event:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, onInit);
			// entry point
			
			visible = false;
			
			_sheeldLabel = new Label(this, 0, 0, "Progress: 0 / 100");
			_saveBtn = new PushButton(this, 0, 0, "Save As...", onSave);
		}
		
		private function onSave(e:Event):void 
		{
			dispatchEvent(new Event(SAVE));
		}
		public function setSheeld():void 
		{
			graphics.clear();
			graphics.beginFill(0xFFFFFF, 0.7);
			graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
			graphics.endFill();
			
			//_sheeldLabel.x = int((stage.stageWidth - _sheeldLabel.width) * 0.5);
			_sheeldLabel.y = int((stage.stageHeight - _sheeldLabel.height) * 0.5);
			_saveBtn.x = int((stage.stageWidth - _saveBtn.width) * 0.5);
			_saveBtn.y = _sheeldLabel.y + 25;
			_saveBtn.visible = false;
			
			visible = true;
		}
		public function set text(text:String):void 
		{
			_sheeldLabel.text = text;
			_sheeldLabel.x = int((stage.stageWidth - _sheeldLabel.width) * 0.5);
		}
		public function set saveBtnEnabled(value:Boolean):void {
			_saveBtn.visible = value;
		}
	}
	
}
class Block { };