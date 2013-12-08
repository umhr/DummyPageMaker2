package  
{
	import com.bit101.components.CheckBox;
	import com.bit101.components.ColorChooser;
	import com.bit101.components.ComboBox;
	import com.bit101.components.InputText;
	import com.bit101.components.Label;
	import com.bit101.components.NumericStepper;
	import com.bit101.components.PushButton;
	import com.bit101.components.RadioButton;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.ProgressEvent;
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	import nochump.util.zip.ZipEntry;
	import nochump.util.zip.ZipOutput;
	import solidColored.ImageManager;
	import ui.Ichimatsu;
	import ui.ShieldManager;
	import ui.SiONSound;
	/**
	 * ...
	 * @author umhr
	 */
	public class Canvas extends Sprite 
	{
		private var _uiStage:Sprite = new Sprite();
		private var _previewStage:Sprite = new Sprite();
		private var _counter:NumericStepper;
		private var _sizeWidth:NumericStepper;
		private var _sizeHeight:NumericStepper;
		private var _comboBox:ComboBox;
		private var _formatJPG:RadioButton;
		private var _currenPreviewParam:String;
		private var _ichimatsu:Ichimatsu;
		private var _colorChooser:ColorChooser;
		private var _randomCheckBox:CheckBox;
		private var _timeCount:int = -10;
		private var _keyword:InputText;
		private var _photoRB0:RadioButton;
		private var _photoRB1:RadioButton;
		private var _keywordLabel:Label;
		private var _guide:CheckBox;
		private var _SiONSound:SiONSound = new SiONSound();
		private var _isGenerate:Boolean;
		private var _generate:PushButton;
		public function Canvas() 
		{
			init();
		}
		private function init():void 
		{
			if (stage) onInit();
			else addEventListener(Event.ADDED_TO_STAGE, onInit);
		}

		private function onInit(event:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, onInit);
			// entry point
			
			//Style.embedFonts = false;
			//Style.fontName = "PF Ronda Seven";
			//Style.fontSize = 10; // デフォルトのサイズは8
			
			_ichimatsu = new Ichimatsu(0, 0);
			addChild(_ichimatsu);
			addChild(_previewStage);
			setUI();
			
			stage.addEventListener(Event.RESIZE, stage_resize);
			
			setPreview();
			reSize();
		}
		
		private function stage_resize(e:Event):void 
		{
			_timeCount = -60;
			//onCounterReset(null);
		}
		
		private function reSize():void 
		{
			if (_ichimatsu.width == stage.stageWidth && _ichimatsu.height == stage.stageHeight) {
				return;
			}
			
			if (_previewStage.numChildren > 0) {
				_previewStage.x = int((stage.stageWidth - _previewStage.getChildAt(0).width) * 0.5);
				_previewStage.y = int((stage.stageHeight - 70 - _previewStage.getChildAt(0).height) * 0.5);
			}
			
			_uiStage.x = int((stage.stageWidth - _uiStage.width) * 0.5);
			_uiStage.y = stage.stageHeight - 64;
			_ichimatsu.drawIchimatsu(stage.stageWidth, stage.stageHeight);
		}
		
		private function setPreview():void 
		{
			addEventListener(Event.ENTER_FRAME, enterFrame);
		}
		
		private function enterFrame(e:Event):void 
		{
			_timeCount++;
			if (_timeCount == 0) {
				onPreview();
				reSize();
			}
		}
		
		private function onPreview():void 
		{
			var width:int = _sizeWidth.value;
			var height:int = _sizeHeight.value;
			var count:int = _counter.value;
			var format:String = _formatJPG.selected?"jpg":"png";
			var rgb:int = _colorChooser.enabled?_colorChooser.value: -1;
			var isGuide:Boolean = _guide.selected;
			var isPhoto:Boolean = _photoRB0.selected;
			var keyword:String = _keyword.text;
			
			var previewParam:String = "" + width + "," + height + "," + rgb + "," + isGuide + "," + isPhoto + "," + keyword;
			
			if (isNaN(width) || isNaN(height) || isNaN(count) || isNaN(rgb)) {
				return;
			}
			if (width == 0 || height == 0 || count == 0) {
				return;
			}
			
			if (_currenPreviewParam == previewParam) {
				return;
			}
			_currenPreviewParam = previewParam;
			
			startgenerate(1, format, keyword, width, height, rgb, isGuide, isPhoto);
		}
		
		private function setUI():void {
			
			_uiStage.graphics.beginFill(0x333333, 1);
			_uiStage.graphics.drawRoundRect(0, 0, 570, 60, 8, 8);
			_uiStage.graphics.endFill();
			addChild(_uiStage);
			
			_formatJPG = new RadioButton(_uiStage, 16, 22, "jpg", true);
			var formatPNG:RadioButton = new RadioButton(_uiStage, 16, 38, "png", false);
			_formatJPG.groupName = formatPNG.groupName = "format";
			
			_sizeWidth = new NumericStepper(_uiStage, 100, 8, onCounterReset);
			_sizeWidth.value = 480;
			_sizeWidth.width = 70;
			_sizeHeight = new NumericStepper(_uiStage, 100, 34, onCounterReset);
			_sizeHeight.value = 320;
			_sizeHeight.width = 70;
			_counter = new NumericStepper(_uiStage, 365, 20);
			_counter.value = 50;
			_counter.width = 60;
			_guide = new CheckBox(_uiStage, _counter.x, 44, "Guide", onCounterReset);
			_guide.selected = true;
			
			_photoRB0 = new RadioButton(_uiStage, 180, 6, "Photo", true, onPhoto);
			_photoRB1 = new RadioButton(_uiStage, 180, 30, "Solid Color", false, onPhoto);
			_photoRB0.groupName = _photoRB1.groupName = "photo";
			
			_randomCheckBox = new CheckBox(_uiStage, 210, 44, "Rnadom", onCheckBox);
			_randomCheckBox.selected = true;
			_colorChooser = new ColorChooser(_uiStage, 270, 40, 0xFF9900, onCounterReset);
			_colorChooser.value = 0x787878;
			_colorChooser.enabled = false;
			
			_keyword = new InputText(_uiStage, 270, 10, "tokyo smile");
			_keyword.textField.addEventListener(KeyboardEvent.KEY_UP, onTextChange);
			_keyword.width = 80;
			
			_generate = new PushButton(_uiStage, 450, 20, "Generate", onGenerat);
			_generate.enabled = false;
			
			new Label(_uiStage, _formatJPG.x, 2, "Format");
			new Label(_uiStage, _sizeWidth.x-35, 4, "width");
			new Label(_uiStage, _sizeHeight.x-35, 30, "height");
			new Label(_uiStage, _counter.x, 2, "Number");
			_keywordLabel = new Label(_uiStage, _keyword.x-50, _keyword.y, "Keyword");
			
			onPhoto(null);
			
			addChild(ShieldManager.getInstance());
		}
		
		private function onPhoto(e:Event):void {
			_colorChooser.enabled = false;
			_randomCheckBox.enabled = false;
			_keyword.enabled = false;
			_keywordLabel.enabled = false;
			
			if (_photoRB0.selected) {
				_keyword.enabled = true;
				_keywordLabel.enabled = true;
			}else {
				_randomCheckBox.enabled = true;
				if (!_randomCheckBox.selected) {
					_colorChooser.enabled = true;
				}
			}
			onCounterReset(null);
		}
		
		private function onTextChange(e:Event):void 
		{
			_timeCount = -90;
			_generate.enabled = false;
		}
		private function onCounterReset(e:Event):void 
		{
			_timeCount = -60;
			_generate.enabled = false;
		}
		
		private function onCheckBox(e:MouseEvent):void 
		{
			_colorChooser.enabled = !_randomCheckBox.selected;
			onCounterReset(null);
		}
		
		private function onGenerat(e:MouseEvent):void {
			_isGenerate = true;
			var rgb:int = _colorChooser.enabled?_colorChooser.value: -1;
			var format:String = _formatJPG.selected?"jpg":"png";
			var count:int = _counter.value;
			var keyword:String = _keyword.text;
			var width:int = _sizeWidth.value;
			var height:int = _sizeHeight.value;
			var isGuide:Boolean = _guide.selected;
			var isPhoto:Boolean = _photoRB0.selected;
			startgenerate(count, format, keyword, width, height, rgb, isGuide, isPhoto);
		}
		
		private function startgenerate(count:int, format:String, keyword:String, width:int, height:int, rgb:int, isGuide:Boolean, isPhoto:Boolean):void {
			_generate.enabled = false;
			ShieldManager.getInstance().setSheeld();
			ImageManager.getInstance().setImage(count, format, keyword, width, height, rgb, isGuide, isPhoto);
			ImageManager.getInstance().addEventListener(Event.COMPLETE, complete);
		}
		
		private function complete(e:Event):void 
		{
			ShieldManager.getInstance().text = "";
			ImageManager.getInstance().removeEventListener(Event.COMPLETE, complete);
			if (_isGenerate) {
				ShieldManager.getInstance().addEventListener(ShieldManager.SAVE, onSave);
				ShieldManager.getInstance().saveBtnEnabled = true;
			}else {
				while (_previewStage.numChildren > 0) {
					_previewStage.removeChildAt(0);
				}
				var bitmap:Bitmap = ImageManager.getInstance().previewBitmap;
				_previewStage.x = int((stage.stageWidth - bitmap.width) * 0.5);
				_previewStage.y = int((stage.stageHeight - 70 - bitmap.height) * 0.5);
				_previewStage.addChild(bitmap);
				ShieldManager.getInstance().visible = false;
			}
			_generate.enabled = true;
		}
		
		private function onSave(e:Event):void 
		{
            //zip化
            var zipOut:ZipOutput = new ZipOutput();
            
			var byteArrayList:Array/*ByteArray*/ = ImageManager.getInstance().byteArrayList;
			
			var extention:String = ImageManager.getInstance().format;
			
			var n:int = byteArrayList.length;
			for (var i:int = 0; i < n; i++) 
			{
				var fileData:ByteArray = byteArrayList[i];
				zipOut.putNextEntry(new ZipEntry("image" + i + "." + extention));
				zipOut.write(fileData);
				zipOut.closeEntry();
				byteArrayList[i].clear();
			}
			
            zipOut.finish();
            
            //ファイルリファレンスで保存
			var defaultFileNames:String = extention + _sizeWidth.value + "x" + _sizeHeight.value + "x" + n;
			defaultFileNames += "_" + (_photoRB0.selected?_keyword.text:"SolidColored");
			defaultFileNames += ".zip";
            var fileRef:FileReference = new FileReference();
            fileRef.save(zipOut.byteArray, defaultFileNames );
			fileRef.addEventListener(Event.COMPLETE, fileRef_complete);
			fileRef.addEventListener(ProgressEvent.PROGRESS, fileRef_progress);
        }
		
		private function fileRef_progress(event:ProgressEvent):void 
		{
            var file:FileReference = FileReference(event.target);
			var text:String = "zipping:" + String(event.bytesLoaded / event.bytesTotal).substr(0, 5);
			ShieldManager.getInstance().text = text;
		}
		
		private function fileRef_complete(e:Event):void 
		{
			trace("fileRef_complete");
			_SiONSound.play();
			ShieldManager.getInstance().visible = false;
			_isGenerate = false;
		}
	}
	
}