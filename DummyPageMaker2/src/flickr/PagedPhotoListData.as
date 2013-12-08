package flickr
{
	import br.com.stimuli.loading.BulkLoader;
	import br.com.stimuli.loading.BulkProgressEvent;
	import com.adobe.webapis.flickr.PagedPhotoList;
	import com.adobe.webapis.flickr.Photo;
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	/**
	 * ...
	 * @author umhr
	 */
	public class PagedPhotoListData extends EventDispatcher
	{
		private var _pagedPhotoList:PagedPhotoList = new PagedPhotoList();
		private var _bulkLoader:BulkLoader;
		public function PagedPhotoListData() 
		{
			
		}
		
		public function setJSON(data:String):void {
			var obj:Object = JSON.parse(data);
			
			_pagedPhotoList.page = obj.page;
			_pagedPhotoList.pages = obj.pages;
			_pagedPhotoList.perPage = int(obj.perpage);
			_pagedPhotoList.total = obj.total;
			_pagedPhotoList.photos/*Photo*/ = [];
			
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
				photo.url = "http://farm" + photoList[i].farm + ".staticflickr.com/" + photo.server + "/" + photo.id + "_" + photo.secret;
				photo.url += "_b.jpg";
				_pagedPhotoList.photos.push(photo);
				//trace(photo.url);
			}
			
			trace(_pagedPhotoList.photos.length);
			
			_bulkLoader = new BulkLoader("theOne");
			_bulkLoader.addEventListener("complete", bulkLoader_complete);
			_bulkLoader.add(_pagedPhotoList.photos[0].url, { type:BulkLoader.TYPE_IMAGE } );
			_bulkLoader.start();
			
			//Square 75: _s
			//Square 150: _q
			//Thumbnail: _t
			//Small 240: _m
			//Small 320: _n
			//Medium 500: 
			//Medium 640: _z
			//Medium 800: _c
			//Large 1024: _b
			//Original: _o
		}
		
		public var bitmapList:Array/*Bitmap*/ = [];
		
		private function bulkLoader_complete(e:Event):void 
		{
			bitmapList.push(_bulkLoader.getBitmap(_pagedPhotoList.photos[0].url));
			
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		
	}

}