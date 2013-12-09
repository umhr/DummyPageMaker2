package  
{
	import com.adobe.images.PNGEncoder;
	import flash.display.BitmapData;
	import flash.display.JPEGEncoderOptions;
	import flash.utils.ByteArray;
	import nochump.util.zip.ZipEntry;
	import nochump.util.zip.ZipOutput;
	/**
	 * ...
	 * @author umhr
	 */
	public class Zipper 
	{
		private var _zipOutput:ZipOutput = new ZipOutput();
		private var _count:int = 0;
		static public const FORMAT_JPG:String = "jpg";
		static public const FORMAT_PNG:String = "png";
		public function Zipper() 
		{
			
		}
		public function setBitmapData(bitmapData:BitmapData, format:String):void {
			_zipOutput.putNextEntry(new ZipEntry("img" + _count + "." + format));
			if(format == FORMAT_PNG){
				_zipOutput.write(bitmapData.encode(bitmapData.rect, new PNGEncoder()));
				
			}else {
				_zipOutput.write(bitmapData.encode(bitmapData.rect, new JPEGEncoderOptions(90)));
			}
			_zipOutput.closeEntry();
			_count ++;
		}
		public function getByteArray():ByteArray {
			_zipOutput.finish();
			return _zipOutput.byteArray;
		}
		public function clear():void {
			_zipOutput.byteArray.clear();
			_zipOutput = new ZipOutput();
			_count = 0;
		}
		public function get count():int {
			return _count;
		}
	}

}