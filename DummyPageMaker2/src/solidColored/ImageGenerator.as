package solidColored
{
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.geom.Matrix;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	/**
	 * ...
	 * @author umhr
	 */
	public class ImageGenerator 
	{
		private static var _instance:ImageGenerator;
		public function ImageGenerator(block:Block){init();};
		public static function getInstance():ImageGenerator{
			if ( _instance == null ) {_instance = new ImageGenerator(new Block());};
			return _instance;
		}
		
		private function init():void
		{
			
		}
		
		private function getTextRGB(baseRGB:int):int {
			baseRGB = (baseRGB == -1)?int(Math.random() * 0xFFFFFF):baseRGB;
			
			var r:int = baseRGB >> 16 & 0xFF;
			var g:int = baseRGB >> 8 & 0xFF;
			var b:int = baseRGB & 0xFF;
			
			var result:int;
			if ((r + g + b) > 0xFF * 1.5) {
				result = 0x000000;
			}else {
				result = 0xFFFFFF;
			}
			return result;
		}
		
		public function getBitmapData(width:int, height:int, rgb:int = -1):BitmapData {
			rgb = (rgb == -1)?int(Math.random() * 0xFFFFFF):rgb;
			return new BitmapData(width, height, false, 0xFF000000 | rgb);
		}
		
		public function getImage(index:int, width:int, height:int, text:String, rgb:int = -1, isGuide:Boolean = true):BitmapData {
			rgb = (rgb == -1)?randomRGB():rgb;
			var result:BitmapData = getBitmapData(width, height, rgb);
			
			if (isGuide) {
				var textRGB:int = 0xFFFFFF;
				var fontSize:int = Math.min(width / 2.5, height);
				
				if (fontSize < 30) {
					fontSize *= (0.4 + 0.6 * ((30 - fontSize) / 30));
				}else {
					fontSize *= 0.4;
				}
				
				var textField:TextField = new TextField();
				textField.defaultTextFormat = new TextFormat("_sans", fontSize, textRGB, null, null, null, null, null, TextFormatAlign.CENTER);
				textField.text = index.toString();
				textField.width = width;
				textField.height = textField.textHeight + 8;
				
				var scale:Number = 1;
				
				var shape:Shape = new Shape();
				shape.graphics.lineStyle(0, Utils.rgbBrightness(rgb, 1.25));
				shape.graphics.moveTo(0, 0);
				shape.graphics.lineTo(width - 1, height - 1);
				shape.graphics.moveTo(width - 1, 0);
				shape.graphics.lineTo(0, height - 1);
				result.draw(shape);
				
				var ty:int = (height - textField.height * scale) * 0.5;
				result.draw(textField, new Matrix(scale, 0, 0, scale, 0, ty));
				
				fontSize = Math.max(9, fontSize * 0.4);
				
				var title:TextField = new TextField();
				title.defaultTextFormat = new TextFormat("_sans", fontSize, textRGB);
				title.text = text;
				title.width = width;
				title.height = textField.textHeight + 8;
				result.draw(title);
			}
			
			return result;
		}
		
		private function randomRGB():int {
			var r:int = Math.random() * 0x99 + 0x33;
			var g:int = Math.random() * 0x99 + 0x33;
			var b:int = Math.random() * 0x99 + 0x33;
			return r << 16 | g << 8 | b;
		}
		
	}	
}
class Block { };