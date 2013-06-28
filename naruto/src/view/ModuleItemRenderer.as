package view 
{
	import com.larrio.controls.interfaces.IRenderer;
	import fl.controls.CheckBox;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import model.ModuleInfo;
	
	/**
	 * 模块项目渲染器
	 * @author larryhou
	 * @createTime 2013/6/27 16:08
	 */
	public class ModuleItemRenderer extends Sprite implements IRenderer
	{
		private var _data:ModuleInfo;
		
		private var _checker:CheckBox;
		private var _label:TextField;
		
		private var _config:TextField;
		
		
		/**
		 * 构造函数
		 * create a [ModuleItemRenderer] object
		 */
		public function ModuleItemRenderer() 
		{
			init();
		}
		
		/**
		 * 初始化界面
		 */
		private function init():void 
		{
			_checker = new CheckBox();
			_checker.label = "";
			_checker.width = 30;
			_checker.height = 30;
			_checker.y = -5;
			addChild(_checker);
			
			_label = new TextField();
			_label.defaultTextFormat = new TextFormat("Lucida Console", 16, 0x000000);
			_label.width = 250;
			_label.height = _checker.width;
			_label.x = _checker.x + _checker.width + 5;
			_label.selectable = false;
			addChild(_label);
			
			_config = new TextField();
			_config.defaultTextFormat = _label.defaultTextFormat;
			_config.width = 600;
			_config.height = _label.height;
			_config.x = _label.x + _label.width + 5;
			_config.selectable = false;
			addChild(_config);
			
			graphics.beginFill(0, 0);
			graphics.drawRect(0, 0, _config.x + _config.width, 30);
			
			_checker.addEventListener(MouseEvent.CLICK, selectHandler);
		}
		
		private function selectHandler(e:MouseEvent):void 
		{
			_data.selected = _checker.selected;
			dispatchEvent(new Event(Event.SELECT, true));
		}
		
		/**
		 * 渲染数据
		 */
		private function render():void
		{
			_checker.selected = _data.selected;
			
			_label.text = _data.name;
			_config.text = _data.config;
		}
		
		/* INTERFACE com.larrio.controls.interfaces.IRenderer */
		
		public function get data():Object { return _data; }
		public function set data(value:Object):void 
		{
			_data = value as ModuleInfo;
			_data && render();
		}
		
		override public function get height():Number { return 30; }
	}

}