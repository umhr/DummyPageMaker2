package flickr 
{
	import br.com.stimuli.loading.BulkLoader;
	import br.com.stimuli.loading.BulkProgressEvent;
	import com.adobe.webapis.flickr.PagedPhotoList;
	import com.adobe.webapis.flickr.Photo;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.ProgressEvent;
	import flash.filters.DropShadowFilter;
	import flash.geom.Matrix;
	import flash.system.LoaderContext;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import ui.ShieldManager;
	/**
	 * ...
	 * @author umhr
	 */
	public class PhotoManager extends EventDispatcher
	{
		private static var _instance:PhotoManager;
		public function PhotoManager(block:Block){init();};
		public static function getInstance():PhotoManager{
			if ( _instance == null ) {_instance = new PhotoManager(new Block());};
			return _instance;
		}
		
		private const KEY:String = "f4aab81383aa79b398d13f57030d62ef";
		//private const Secret:String = "66db83035b4b6f16";
		private var _bulkLoader:BulkLoader = new BulkLoader("thePhoto");
		private var _pagedPhotoList:PagedPhotoList = new PagedPhotoList();
		private var _width:int;
		private var _height:int;
		private function init():void
		{
			// Flickr Services
			// http://www.flickr.com/services/api/
			//Flickr Services: Flickr API: flickr.photos.search
			//http://www.flickr.com/services/api/flickr.photos.search.html
			// マッシュアップ・ラボ - 第2回 JavaScriptからFlickr APIで画像検索：ITpro
			// http://itpro.nikkeibp.co.jp/article/COLUMN/20061101/252356/
		}
		
		public function loadPhoto(text:String, number:int, width:int, height:int):void {
			_width = width;
			_height = height;
			load(text, number);
		}
		
		private function getSizeOption(width_o:int, height_o:int):String {
			var sizeList:Array/*String*/ = ["_t", "_s", "_q", "_m", "_n", "", "_z", "_c", "_b"];
			
			var isOriginalLandscape:Boolean = width_o >= height_o;
			var isTargetLandscape:Boolean = _width >= _height;
			
			var num:Number = 1;
			if (isOriginalLandscape != isTargetLandscape) {
				num = Math.max(width_o / height_o, height_o / width_o);
			}
			
			var originalSize:int = sizeSelctor(width_o, height_o);
			var targetSize:int = sizeSelctor(_width * num, _height * num);
			
			var result:String;
			if (originalSize >= targetSize) {
				result = sizeList[targetSize];
			}else {
				result = "_o";// Original
			}
			return result;
		}
		
		private function sizeSelctor(width:int, height:int):int {
			var result:int;
			var num:int = Math.max(width, height);
			if (num <= 67) {
				result = 0;//result = "_t";//Thumbnail 67
			}else if (num <= 75) {
				result = 1;//result = "_s";//Square 75
			}else if (num <= 150) {
				result = 2;//result = "_q";//Square 150
			}else if (num <= 240) {
				result = 3;//result = "_m";//Small 240
			}else if (num <= 320) {
				result = 4;//result = "_n";//Small 320
			}else if (num <= 500) {
				result = 5;//result = "";//Medium 500
			}else if (num <= 640) {
				result = 6;//result = "_z";//Medium 640
			}else if (num <= 800) {
				result = 7;//result = "_c";//Medium 800
			}else {
				result = 8;//result = "_b";//Large 1024
			}
			return result;
		}
		private function requestSizeSelctor(width:int, height:int):int {
			var result:int;
			var num:int = Math.max(width, height);
			if (num <= 75) {
				result = 0;//sq
			}else if (num <= 100) {
				result = 1;//t
			}else if (num <= 150) {
				result = 2;//q
			}else if (num <= 240) {
				result = 3;//s
			}else if (num <= 256) {
				result = 4;//n
			}else if (num <= 500) {
				result = 5;//m
			}else if (num <= 640) {
				result = 6;//z
			}else {
				result = 7;//l 1024
			}
			return result;
		}
		
		private function getRequestSizeOption(width:int, height:int):String {
			var sizeList:Array/*String*/ = ["url_sq", "url_t", "url_q", "url_s", "url_n", "url_m", "url_z", "url_l"];
			return "," + sizeList.join(",");
			
			var size:int = requestSizeSelctor(width, height);
			var result:String = "";
			var n:int = 3 + Math.min(size, 1);
			for (var i:int = 0; i < n; i++) 
			{
				var s:int = size + i;
				if (n == 4) {
					s --;
				}
				if (sizeList.length > s) {
					result += sizeList[s] + ",";
				}
			}
			if (result.length > 0) {
				result = "," + result.substr(0, result.length - 1);
			}
			return result;
		}
		
		private function load(text:String, number:int):void {
			
			var url:String = "http://api.flickr.com/services/rest/?method=flickr.photos.search";
			url += "&api_key=" + KEY;
			url += "&sort=interestingness-desc";//人気の高い順
			url += "&text=" + encodeURIComponent(text);
			url += "&per_page=" + number;
			url += "&extras=owner_name,url_o";
			url += getRequestSizeOption(_width, _height);
			url += "&content_type=1&license=4&format=json&nojsoncallback=1";
			
			//trace(url);
			_bulkLoader.add(url, {id:"searchResult", type:BulkLoader.TYPE_TEXT, context:new LoaderContext(true) } );
			_bulkLoader.addEventListener(Event.COMPLETE, bulkLoader_complete);
			_bulkLoader.start();
			
			ShieldManager.getInstance().text = "Searching..."
		}
		
		private function bulkLoader_complete(e:Event):void 
		{
			_bulkLoader.removeEventListener(Event.COMPLETE, bulkLoader_complete);
			
			// JSON読み込み完了。JSONをパースします。
			var json:String = _bulkLoader.getText("searchResult", true);
			setJSON(json);
		}
		
		private function getPhotoURL(photoObject:Object):String {
			var result:String = "";
			var option:String = getSizeOption(photoObject.width_o, photoObject.height_o);
			
			var sizeList:Array/*String*/ = ["url_sq", "url_t", "url_q", "url_s", "url_n", "url_m", "url_z", "url_l", "url_o"];
			var urlList:Array = [];
			var n:int = sizeList.length;
			for (var i:int = 0; i < n; i++) 
			{
				if (photoObject[sizeList[i]]) {
					urlList.push(photoObject[sizeList[i]]);
				}
			}
			
			var url:String = "";
			// 該当のURLがある場合
			n = urlList.length;
			for (i = 0; i < n; i++) 
			{
				url = urlList[i];
				if (url.substr(url.length - 6,2) == option) {
					result = url;
				}else if (url.substr(url.length - 3) == "jpg" && option == "" && url.substr(url.length - 6,1) != "_") {
					result = url;
				}
			}
			
			// 該当のURLがない場合
			if (result == "") {
				var isOriginalLandscape:Boolean = photoObject.width_o >= photoObject.height_o;
				var isTargetLandscape:Boolean = _width >= _height;
				var num:Number = 1;
				if (isOriginalLandscape != isTargetLandscape) {
					num = Math.max(photoObject.width_o / photoObject.height_o, photoObject.height_o / photoObject.width_o);
				}
				var sizeList2:Array/*String*/ = ["_t", "_s", "_q", "_m", "_n", "", "_z", "_c", "_b", "_c", "_z", "", "_n", "_m", "_q", "_s", "_t"];
				n = sizeList2.length;
				var startIndex:int = sizeSelctor(_width * num, _height * num);
				loop:for (i = 0; i < n; i++)  
				{
					var index:int = (i + startIndex + 1) % n;
					var op:String = sizeList2[index];
					var m:int = urlList.length;
					for (var j:int = 0; j < m; j++) 
					{
						url = urlList[j];
						if (url.substr(url.length - 6,2) == op) {
							result = url;
						}else if (url.substr(url.length - 3) == "jpg" && op == "" && url.substr(url.length - 6,1) != "_") {
							result = url;
						}
						if (result != "") {
							break loop;
						}
					}
				}
			}
			
			//Utils.dump(photoObject);
			return result;
		}
		
		private function setJSON(data:String):void {
			// JSONをパースします。
			var obj:Object = JSON.parse(data);
			_pagedPhotoList.page = obj.photos.page;
			_pagedPhotoList.pages = obj.photos.pages;
			_pagedPhotoList.perPage = int(obj.photos.perpage);
			_pagedPhotoList.total = obj.photos.total;
			_pagedPhotoList.photos/*Photo*/ = [];
			
			if (_pagedPhotoList.total == 0) {
				onLoadPhoto(null);
				return;
			}
			
			var photoList:Array = obj["photos"]["photo"];
			var n:int = photoList.length;
			for (var i:int = 0; i < n; i++) 
			{
				var photo:Photo = new Photo();
				photo.id = photoList[i].id;
				photo.ownerId = photoList[i].owner;
				photo.secret = photoList[i].secret;
				photo.server = photoList[i].server;
				photo.title = photoList[i].title;
				photo.isPublic = photoList[i].ispublic;
				photo.isFriend = photoList[i].isFriend;
				photo.isFamily = photoList[i].isFamily;
				photo.ownerName = photoList[i].ownername;
				photo.url = getPhotoURL(photoList[i]);
				_pagedPhotoList.photos.push(photo);
			}
			
			for (i = 0; i < n; i++) 
			{
				_bulkLoader.add(_pagedPhotoList.photos[i].url, { type:BulkLoader.TYPE_IMAGE, context:new LoaderContext(true) } );
				//trace(_pagedPhotoList.photos[i].url);
			}
			_bulkLoader.addEventListener(ProgressEvent.PROGRESS, bulkLoader_progress);
			_bulkLoader.addEventListener(BulkLoader.ERROR, bulkLoader_error);
			_bulkLoader.addEventListener(Event.COMPLETE, onLoadPhoto);
			_bulkLoader.start();
			
		}
		
		private function bulkLoader_error(e:Event):void 
		{
			_bulkLoader.removeFailedItems();
			if (_bulkLoader.isRunning) {
				
			}else {
				onLoadPhoto(null);
			}
		}
		
		private function bulkLoader_progress(e:Event):void 
		{
			dispatchEvent(new Event(ProgressEvent.PROGRESS));
		}
		
		public function get loadedRatio():Number {
			return _bulkLoader.loadedRatio;
		}
		public function get itemsLoaded():int {
			return _bulkLoader.itemsLoaded;
		}
		public function get itemsTotal():int {
			return _bulkLoader.itemsTotal;
		}
		
		public var bitmapList:Array/*Bitmap*/ = [];
		
		private function onLoadPhoto(e:Event):void 
		{
			_bulkLoader.removeEventListener(ProgressEvent.PROGRESS, bulkLoader_progress);
			_bulkLoader.removeEventListener(Event.COMPLETE, onLoadPhoto);
			
			var n:int = _pagedPhotoList.photos.length;
			for (var i:int = 0; i < n; i++) 
			{
				if(_bulkLoader.hasItem(_pagedPhotoList.photos[i].url)){
					bitmapList.push(_bulkLoader.getBitmap(_pagedPhotoList.photos[i].url));
				}
			}
			
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		private function getBitmapData(index:int, width:int, height:int):BitmapData {
			var bitmapData:BitmapData = new BitmapData(width, height, false);
			var sozaiBitmap:Bitmap = new Bitmap(bitmapList[index].bitmapData, "auto", true);
			
			var scale:Number = Math.max(bitmapData.width / sozaiBitmap.width, bitmapData.height / sozaiBitmap.height);
			
			var tx:Number = (bitmapData.width - sozaiBitmap.width * scale) * 0.5;
			var ty:Number = (bitmapData.height - sozaiBitmap.height * scale) * 0.5;
			
			bitmapData.draw(sozaiBitmap, new Matrix(scale, 0, 0, scale, tx, ty), null, null, null, true);
			return bitmapData;
		}
		
		public function getImage(index:int, width:int, height:int, text:String, isGuide:Boolean):BitmapData {
			
			var photoIndex:int = index % bitmapList.length;
			var textRGB:int = 0xFFFFFF;
			
			var fontSize:int = Math.min(width / 2.5, height);
			if (fontSize < 30) {
				fontSize *= (0.4 + 0.6 * ((30 - fontSize) / 30));
			}else {
				fontSize *= 0.4;
			}
			
			var result:BitmapData;
			if(bitmapList.length > 0){
				result = getBitmapData(photoIndex, width, height);
			}else {
				result = new BitmapData(width, height, false,0xFF000000);
			}
			
			if(isGuide){
				var textField:TextField = new TextField();
				textField.defaultTextFormat = new TextFormat("_sans", fontSize, textRGB, null, null, null, null, null, TextFormatAlign.CENTER);
				textField.text = index.toString();//text;
				textField.width = width;
				textField.height = textField.textHeight + 8;
				var scale:Number = 1;
				var shape:Shape = new Shape();
				shape.graphics.lineStyle(0, 0xFFFFFF, 0.5);
				shape.graphics.moveTo(0, 0);
				shape.graphics.lineTo(width - 1, height - 1);
				shape.graphics.moveTo(width - 1, 0);
				shape.graphics.lineTo(0, height - 1);
				result.draw(shape);
				var ty:int = (height - textField.height * scale) * 0.5;
				result.draw(textField, new Matrix(scale, 0, 0, scale, 0, ty));
			}
			
			
			var text:String = (isGuide?String(width + " x " + height):"") + " ";
			if(bitmapList.length > 0){
				text += "Photo by " + _pagedPhotoList.photos[photoIndex].ownerName;
			}else {
				text += "Couldn't find anything matching your search";
			}
			
			fontSize = Math.max(9, fontSize * 0.2);
			var title:TextField = new TextField();
			title.defaultTextFormat = new TextFormat("_sans", fontSize, textRGB);
			title.text = text;
			title.width = width;
			title.height = title.textHeight + 10;
			title.filters = [new DropShadowFilter(0)];
			result.draw(title);
			
			return result;
		}
		
		public function removeAll():void {
			_pagedPhotoList.photos = [];
			bitmapList = [];
			_bulkLoader.removeAll();
		}
	}
	
}
class Block { };