package ui
{
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.geom.Matrix;
	
	/**
	 * ...
	 * @author umhr
	 */
	public class Ichimatsu extends Shape 
	{
		
		public function Ichimatsu(width:int, height:int) 
		{
			drawIchimatsu(width, height);
		}
		public function drawIchimatsu(width:int, height:int):void {
			if (width == this.width && height == this.height) {
				return;
			}
			
			var bitmapData:BitmapData = new BitmapData(2, 2, false);
			bitmapData.setPixel(0, 0, 0xCCCCCC);
			bitmapData.setPixel(1, 1, 0xCCCCCC);
			
			this.graphics.clear();
			this.graphics.beginBitmapFill(bitmapData, new Matrix(8, 0, 0, 8));
			this.graphics.drawRect(0, 0, width, height);
			this.graphics.endFill();
			bitmapData = null;
		}
	}

}