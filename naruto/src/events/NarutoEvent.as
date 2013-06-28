package events 
{
	import flash.events.Event;
	
	/**
	 * 工具事件类
	 * @author larryhou
	 * @createTime 2013/6/27 10:53
	 */
	public class NarutoEvent extends Event 
	{
		/**
		 * 命令行输出数据时派发
		 */
		public static const OUTPUT_DATA:String = "output_data";
		
		/**
		 * 完成时派发
		 */
		public static const COMPLETE:String = "complete";
		
		/**
		 * 数据模型重置时派发
		 */
		public static const RESET:String = "reset";
		
		
		private var _data:*;
		
		/**
		 * 构造函数
		 * create a [NarutoEvent] object
		 * @param data 用户自定义数据
		 */
		public function NarutoEvent(type:String, data:* = null, bubbles:Boolean = false) 
		{ 
			_data = data;
			super(type, bubbles, false);
			
		} 
		
		/**
		 * 克隆事件
		 */
		public override function clone():Event 
		{ 
			return new NarutoEvent(type, _data, bubbles);
		} 
		
		/**
		 * 格式化文本输出
		 */
		public override function toString():String 
		{ 
			return formatToString("NarutoEvent", "type", "data", "bubbles", "cancelable", "eventPhase"); 
		}
		
		/**
		 * 用户自定义数据
		 */
		public function get data():* { return _data; }
		
	}
	
}