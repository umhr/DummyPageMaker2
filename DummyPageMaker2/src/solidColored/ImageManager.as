package solidColored
{
	import by.blooddy.crypto.image.PNGEncoder;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.JPEGEncoderOptions;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.utils.ByteArray;
	import flickr.PhotoManager;
	import nochump.util.zip.ZipEntry;
	import nochump.util.zip.ZipOutput;
	import ui.ShieldManager;
	/**
	 * ...
	 * @author umhr
	 */
	public class ImageManager extends Sprite
	{
		private static var _instance:ImageManager;
		public function ImageManager(block:Block){init();};
		public static function getInstance():ImageManager{
			if ( _instance == null ) {_instance = new ImageManager(new Block());};
			return _instance;
		}
		
		public var byteArrayList:Array/*ByteArray*/ = [];// new ByteArray();
		private var _count:int;
		private var _width:int;
		private var _height:int;
		private var _rgb:int;
		private var _format:String;
		private var _keyword:String;
		private var _isGuide:Boolean;
		private var _isPhoto:Boolean;
		static public const FORMAT_JPG:String = "jpg";
		static public const FORMAT_PNG:String = "png";
		public var previewBitmap:Bitmap;
		private var _photoManager:PhotoManager = PhotoManager.getInstance();
		
		private function init():void
		{
		}
		
		public function setImage(count:int, format:String, keyword:String, width:int, height:int, rgb:int, isGuide:Boolean, isPhoto:Boolean):void {
			byteArrayList = [];
			_count = count;
			_rgb = rgb;
			_isGuide = isGuide;
			_format = format;
			_width = width;
			_height = height;
			_isPhoto = isPhoto;
			
			if (isPhoto) {
				_photoManager.loadPhoto(keyword, count, width, height);
				_photoManager.addEventListener(Event.COMPLETE, photoManager_complete);
				_photoManager.addEventListener(ProgressEvent.PROGRESS, progress);
			}else {
				start();
			}
		}
		private function progress(e:Event):void 
		{
			var text:String = "Loading images:" + _photoManager.itemsLoaded + " / " + _photoManager.itemsTotal;
			ShieldManager.getInstance().text = text;
		}
		private function photoManager_complete(e:Event):void 
		{
			_photoManager.removeEventListener(Event.COMPLETE, photoManager_complete);
			_photoManager.removeEventListener(ProgressEvent.PROGRESS, progress);
			
			start();
		}
		
		private function start():void {
			previewBitmap = null;
			addEventListener(Event.ENTER_FRAME, enterFrame);
		}
		
		private function enterFrame(e:Event):void 
		{
			var text:String = "Image Format Converting:" + byteArrayList.length + " / " + (byteArrayList.length + _count);
			ShieldManager.getInstance().text = text;
			if (_count > 0) {
				gene();
				dispatchEvent(new Event(ProgressEvent.PROGRESS));
			}else {
				comp();
			}
		}
		private function gene():void {
			var a:int = 1 + (50000000 / (_width * _height));
			var n:int = Math.min(20, _count, a);
			for (var i:int = 0; i < n; i++) 
			{
				var index:int = byteArrayList.length;
				var text:String = _width + " x " + _height;
				var bitmapData:BitmapData;
				if (_isPhoto) {
					bitmapData = PhotoManager.getInstance().getImage(index, _width, _height, text, _isGuide);
				}else {
					bitmapData = ImageGenerator.getInstance().getImage(index, _width, _height, text, _rgb, _isGuide);
				}
				
				var byteArray:ByteArray = new ByteArray();
				if (_format == FORMAT_JPG) {
					byteArray = bitmapData.encode(bitmapData.rect, new flash.display.JPEGEncoderOptions(90));
				}else {
					byteArray = by.blooddy.crypto.image.PNGEncoder.encode(bitmapData);
				}
				if(byteArrayList.length == 0){
					previewBitmap = new Bitmap(bitmapData.clone());
				}
				
				byteArrayList.push(byteArray);
				bitmapData = null;
			}
			
			_count -= n;
		}
		
		private function comp():void 
		{
			removeEventListener(Event.ENTER_FRAME, enterFrame);
			PhotoManager.getInstance().removeAll();
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		public function get format():String 
		{
			return _format;
		}
		
		public function get count():int 
		{
			return _count;
		}
		
	}
	
}
class Block { };