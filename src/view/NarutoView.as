package view 
{
	import fl.controls.Button;
	import fl.controls.CheckBox;
	import fl.controls.ComboBox;
	
	import flash.display.Sprite;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	/**
	 * 视图界面
	 * @author larryhou
	 * @createTime 2013/6/27 15:34
	 */
	public class NarutoView extends Sprite
	{
		private var _selectAllBtn:CheckBox;
		private var _compileBtn:Button;
		private var _console:TextField;
		
		private var _serverlist:ComboBox;
		private var _format:TextFormat;
		
		/**
		 * 构造函数
		 * create a [NarutoView] object
		 */
		public function NarutoView() 
		{
			_format = new TextFormat("微软雅黑", 20, 0x666666, false);
		}
		
		/**
		 * 初始化界面
		 */
		public function init():void 
		{
			const MARGIN:uint = 5;			
			
			_selectAllBtn = new CheckBox();
			_selectAllBtn.label = "全选";
			_selectAllBtn.setStyle("textFormat", _format);
			_selectAllBtn.width = 100;
			_selectAllBtn.height = 30;
			_selectAllBtn.x = 100;
			_selectAllBtn.y = MARGIN;
			addChild(_selectAllBtn);
			
			_serverlist = new ComboBox();
			_serverlist.textField.setStyle("textFormat", _format);
			_serverlist.dropdown.setRendererStyle("textFormat", _format);
			_serverlist.x = _selectAllBtn.x + _selectAllBtn.width + 5;
			_serverlist.y = _selectAllBtn.y;
			_serverlist.height = _selectAllBtn.height;
			_serverlist.dropdown.rowHeight = 35;
			_serverlist.width = 300;
			addChild(_serverlist);
			
			_compileBtn = new Button();
			_compileBtn.label = "编译并上传已选模块";			
			_compileBtn.setStyle("textFormat", format);
			_compileBtn.height = _selectAllBtn.height;
			_compileBtn.width = 210;
			_compileBtn.y = MARGIN;
			_compileBtn.x = stage.stageWidth - MARGIN - _compileBtn.width;
			addChild(_compileBtn);
			
			_console = new TextField();
			var fmt:TextFormat = new TextFormat("Lucida Console", 12, 0x006600);
			fmt.leading = 5;
			
			_console.defaultTextFormat = fmt;
			_console.multiline = true;
			_console.antiAliasType = AntiAliasType.ADVANCED;
			_console.width = stage.stageWidth;
			_console.height = 125;
			_console.y = stage.stageHeight - _console.height - MARGIN;
			_console.x = 0;
			_console.text = "Naruto Compiler Console V1.0";
			addChild(_console);
			
			graphics.lineStyle(1, 0xDDDDDD, 1);
			graphics.moveTo(MARGIN, _compileBtn.y + _compileBtn.height + MARGIN);
			graphics.lineTo(stage.stageWidth - MARGIN, _compileBtn.y + _compileBtn.height + MARGIN);
			
			graphics.moveTo(0, _console.y - MARGIN);
			graphics.lineTo(stage.stageWidth, _console.y - MARGIN);
			
		}
		
		/**
		 * 控制台输出
		 */
		public function get console():TextField { return _console; }
		
		/**
		 * 编译按钮
		 */
		public function get compileBtn():Button { return _compileBtn; }
		
		/**
		 * 全选按钮
		 */
		public function get selectAllBtn():CheckBox { return _selectAllBtn; }		
		
		/**
		 * 服务器列表
		 */
		public function get serverlist():ComboBox { return _serverlist; }

		public function get format():TextFormat
		{
			return _format;
		}

	}

}