package model 
{
	import events.NarutoEvent;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.SharedObject;
	import flash.utils.ByteArray;
	
	/**
	 * 模型重置时派发
	 */
	[Event(name = "reset", type = "events.NarutoEvent")]
	
	/**
	 * 命令行输出信息时派发
	 */
	[Event(name = "output_data", type = "events.NarutoEvent")]
	
	/**
	 * 数据模型
	 * @author larryhou
	 * @createTime 2013/6/27 10:39
	 */		
	public class NarutoModel extends EventDispatcher
	{	
		private var _root:String;
		
		private var _kernel:File;
		private var _executable:File;
		
		private var _server:ServerInfo;
		
		private var _core:Vector.<ModuleInfo>;
		private var _rsl:Vector.<ModuleInfo>;
		private var _plugin:Vector.<ModuleInfo>;
		
		private var _cookie:SharedObject;
		
		/**
		 * 构造函数
		 * create a [NarutoModel] object
		 */
		public function NarutoModel() 
		{
			init();
		}
		
		/**
		 * 初始化模块
		 */
		private function init():void 
		{
			_cookie = SharedObject.getLocal("tool.com.morefun.naruto");
			if (_cookie.data.config)
			{
				reset(new File(_cookie.data.config));
			}
		}
		
		/**
		 * 重置数据模型
		 * @param	file	工具配置文件路径
		 */
		public function reset(file:File):void
		{
			_cookie.data.config = file.nativePath;
			_cookie.flush();
			
			_root = file.nativePath.replace(/\\/g, "/").split("compiler/").shift();
			
			var bytes:ByteArray;
			var stream:FileStream = new FileStream();
			
			bytes = new ByteArray();
			stream.open(file, FileMode.READ);
			stream.readBytes(bytes);
			stream.close();
			
			var config:XML = new XML(bytes);
			var server:XML = config.server[0];
			
			_executable = new File(config.cmd[0].@path);
			_kernel = new File(_root + "compiler/kernel.bat");
			
			_server = new ServerInfo();
			_server.root = server.@root;
			
			_server.domains = new Vector.<String>;
			var domains:Array = String(server.@domain).split(/\s*,\s*/g);
			while (domains.length) _server.domains.push(domains.shift());
			
			_server.items = new Vector.<ServerItemInfo>();
			
			var item:ServerItemInfo;
			for each(var node:XML in server.item)
			{
				item = new ServerItemInfo();
				item.name = node.@name;
				item.ip = node.@ip;
				
				_server.items.push(item);
				if (!_server.currentItem)
				{
					_server.currentItem = item;
				}
			}
			
			resetModules();
			
			dispatchEvent(new NarutoEvent(NarutoEvent.RESET));
		}
		
		/**
		 * 重置模型数据
		 */
		private function resetModules():void
		{
			var folder:File, file:File;
			
			_core = new Vector.<ModuleInfo>();
			
			folder = new File(_root + "compiler/core/");
			
			var list:Array = folder.getDirectoryListing();
			for each(file in list)
			{
				if (!file.isDirectory)
				{
					_core.push(convertNative(file));
				}
			}
			
			_rsl = new Vector.<ModuleInfo>();
			
			folder = new File(_root + "compiler/rsl/");
			list = folder.getDirectoryListing();
			for each(file in list)
			{
				if (!file.isDirectory)
				{
					_rsl.push(convertNative(file));
				}
			}
			
			_plugin = new Vector.<ModuleInfo>;
			
			folder = new File(_root + "compiler/plugins/");
			list = folder.getDirectoryListing();
			for each(file in list)
			{
				if (!file.isDirectory)
				{
					_plugin.push(convertNative(file));
				}
			}
		}
		
		/**
		 * 把本机路径转换成相对路径
		 * @param	path	本机路径
		 * @return	相对于compiler的路径
		 */
		private function convertNative(file:File):ModuleInfo
		{
			var path:String = file.url.split("compiler/").pop();
			var info:ModuleInfo = new ModuleInfo();
			
			var bytes:ByteArray;
			var stream:FileStream = new FileStream();
			
			bytes = new ByteArray();
			stream.open(file, FileMode.READ);
			stream.readBytes(bytes);
			stream.close();
			
			var config:XML = new XML(bytes);
			var output:String = config..output[0].toString();
			output = output.replace(/\\/g, "/").split("bin-debug/").pop();
			
			info.name = output.match(/[^\/]+$/)[0];
			info.config = _root + "compiler/" + path;
			info.output = _root + "src/bin-debug/" + output;
			info.server = _server.root + "/" + output;
			
			return info;
		}
		
		/**
		 * 选择服务器
		 * @param	index	服务器索引
		 */
		public function serverUpdate(index:uint):void
		{
			var list:Vector.<ServerItemInfo> = _server.items;
			if (index > list.length) return;
			
			_server.currentItem = _server.items[index];
		}
		
		/**
		 * 批量编译模块
		 * @param	modules	模块列表
		 */
		public function compile(modules:Vector.<ModuleInfo>):void
		{
			log("running...");
			
			var scripts:Array = [];
			scripts.push("@echo off");
			scripts.push("svn update " + _root);
			scripts.push("set kernel=" + _kernel.nativePath);
			
			var info:ModuleInfo;
			for (var i:int = 0; i < modules.length; i++)
			{
				info = modules[i];
				scripts.push("call %kernel% " + info.config);
			}
			
			scripts.push("exit");
			try
			{
				execute(scripts.join("\r\n"), transfer, [modules]);
			} 
			catch(error:Error) 
			{
				log(error.toString());
			}
		}
		
		/**
		 * 输出日志信息
		 * @param	msg	输出文本内容
		 */
		public function log(msg:String):void
		{
			var date:Date = new Date();
			
			var timestamp:Array = [];
			timestamp.push(date.fullYear + "/" + format(date.month + 1) + "/" + format(date.date));
			timestamp.push(format(date.hours) + ":" + format(date.minutes) + ":" + format(date.seconds));
			
			dispatchEvent(new NarutoEvent(NarutoEvent.OUTPUT_DATA, "[" + timestamp.join(" ") + "]" + msg));
		}
		
		// 输出固定长度的数值
		private function format(value:*, len:uint = 2):String
		{
			var result:String = String(value);
			while (result.length < len) result = "0" + result;
			return result;
		}
		
		/**
		 * 执行脚本BAT脚本
		 * @param	script		BAT脚本文本
		 * @param	callback	执行完毕时回调
		 * @param	params		回调函数传参
		 */
		private function execute(script:String, callback:Function, params:Array = null):void
		{
			var bat:File = new File(File.userDirectory.url + "/naruto.bat");
			
			var stream:FileStream = new FileStream();
			stream.open(bat, FileMode.WRITE);
			stream.writeMultiByte(script, "gb2312");
			stream.close();
			
			var runner:BATRunner = new BATRunner(_executable);
			runner.addEventListener(NarutoEvent.OUTPUT_DATA, outputHandler);
			runner.addEventListener(NarutoEvent.COMPLETE, function(e:NarutoEvent):void
			{
				bat.deleteFile();
				runner.removeEventListener(NarutoEvent.OUTPUT_DATA, outputHandler);
				runner.removeEventListener(NarutoEvent.COMPLETE, arguments.callee);
				callback && callback.apply(null, params);
			});
			
			runner.execute(bat);
		}
		
		/**
		 * 把本地编译文件上传到服务器
		 * @param	modules	模块列表
		 */
		private function transfer(modules:Vector.<ModuleInfo>):void
		{
			var scripts:Array = [];
			scripts.push("@echo off");
			
			var info:ModuleInfo, line:String;
			for (var i:int = 0; i < modules.length; i++)
			{
				info = modules[i];
				line = info.output + " " + "//" + _server.currentItem.ip + "/" + info.server;
				line = "copy /y /v " + line.replace(/\//g, "\\")
				scripts.push("echo " + line);
				scripts.push(line);
			}
			
			scripts.push("echo -----------------------------------------------------------------------------");
			execute(scripts.join("\r\n"), null);
		}
		
		/**
		 * 命令行消息统一处理
		 */
		private function outputHandler(e:NarutoEvent):void 
		{
			trace(e.data);
			dispatchEvent(new NarutoEvent(NarutoEvent.OUTPUT_DATA, e.data));
		}
		
		/**
		 * 命令提示符程序
		 */
		public function get executable():File { return _executable; }
		
		/**
		 * 服务器信息
		 */
		public function get server():ServerInfo { return _server; }
		
		/**
		 * 项目compiler目录
		 */
		public function get root():String { return _root; }
		
		/**
		 * 核心模块列表
		 */
		public function get core():Vector.<ModuleInfo> { return _core; }
		
		/**
		 * 运行时共享库模块列表
		 */
		public function get rsl():Vector.<ModuleInfo> { return _rsl; }
		
		/**
		 * 插件模块列表
		 */
		public function get plugin():Vector.<ModuleInfo> { return _plugin; }
	}

}