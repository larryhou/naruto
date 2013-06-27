package  
{
	import com.larrio.controls.layout.VDragLayout;
	import events.NarutoEvent;
	import fl.controls.ComboBox;
	import fl.data.DataProvider;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import model.ModuleInfo;
	import model.NarutoModel;
	import model.ServerItemInfo;
	import view.ModuleItemRenderer;
	import view.NarutoView;
	
	/**
	 * 界面处理
	 * @author larryhou
	 * @createTime 2013/6/27 15:21
	 */
	public class CompilerMain extends Sprite
	{
		private var _model:NarutoModel;
		private var _view:NarutoView;
		
		private var _layout:VDragLayout;
		private var _provider:Array;
		
		/**
		 * 构造函数
		 * create a [CompilerMain] object
		 */
		public function CompilerMain(model:NarutoModel) 
		{
			_model = model;
			_model.addEventListener(NarutoEvent.RESET, reset);
			_model.addEventListener(NarutoEvent.OUTPUT_DATA, outputHandler);
			
			addEventListener(Event.ADDED_TO_STAGE, function(e:Event):void
			{
				e.currentTarget.removeEventListener(e.type, arguments.callee);
				
				init();
			});
		}
		
		/**
		 * 编译输出信息
		 */
		private function outputHandler(e:NarutoEvent):void 
		{
			var console:TextField = _view.console;
			
			console.appendText("\n" + e.data);
			console.scrollV = console.maxScrollV;
		}
		
		/**
		 * 刷新数据
		 */
		private function reset(e:NarutoEvent = null):void 
		{
			_provider = [];
			
			var list:Vector.<ModuleInfo> = _model.rsl.concat();
			while (list.length) _provider.push(list.shift());
			
			list = _model.core.concat();
			while (list.length) _provider.push(list.shift());
			
			list = _model.plugin.concat();
			while (list.length) _provider.push(list.shift());
			
			_layout.dataProvider = _provider;
			
			var servers:DataProvider = new DataProvider();
			
			var item:ServerItemInfo;
			for (var i:int = 0; i < _model.server.items.length; i++)
			{
				item = _model.server.items[i];
				servers.addItem( { label: item.name + "#" + item.ip, value:item, index:i } );
			}
			
			_view.serverlist.dataProvider = servers;
		}
		
		/**
		 * 初始化界面
		 */
		private function init():void 
		{
			addChild(_view = new NarutoView());
			
			_view.init();
			_view.selectAllBtn.addEventListener(MouseEvent.CLICK, selectAllHandler);
			_view.compileBtn.addEventListener(MouseEvent.CLICK, compileHandler);
			
			_layout = new VDragLayout(18, 1, 0, 5);
			_layout.itemRenderClass = ModuleItemRenderer;
			_layout.enabled = true;
			_layout.y = _view.compileBtn.y + _view.compileBtn.height + 5;
			addChild(_layout);
			
			_layout.addEventListener(Event.SELECT, selectHandler);
			if (_provider) 
			{
				_layout.dataProvider = _provider;
			}
			else
			{
				reset();
			}
			
			_view.serverlist.addEventListener(Event.CHANGE, serverHandler);
		}
		
		/**
		 * 服务器选择发生变化处理
		 */
		private function serverHandler(e:Event):void 
		{
			var servers:ComboBox = _view.serverlist;
			
			_model.serverUpdate(servers.selectedIndex);
			
			trace(servers.selectedIndex);
		}
		
		/**
		 * 选项发生变化时派发
		 */
		private function selectHandler(e:Event):void 
		{
			
		}
		
		/**
		 * 编译处理
		 */
		private function compileHandler(e:MouseEvent):void 
		{
			var list:Vector.<ModuleInfo> = new Vector.<ModuleInfo>();
			for (var i:int = 0; i < _provider.length; i++)
			{
				if (_provider[i].selected) list.push(_provider[i]);
			}
			
			_model.compile(list);
		}
		
		/**
		 * 全选处理
		 */
		private function selectAllHandler(e:MouseEvent):void 
		{
			for (var i:int = 0; i < _provider.length; i++)
			{
				(_provider[i] as ModuleInfo).selected = _view.selectAllBtn.selected;
			}
			
			_layout.dataProvider = _provider;
		}
	}

}