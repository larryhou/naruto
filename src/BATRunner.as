package  
{
	import events.NarutoEvent;
	
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.NativeProcessExitEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.utils.IDataInput;
	
	/**
	 * 命令行有输出时派发
	 */
	[Event(name = "output_data", type = "events.NarutoEvent")]
	
	/**
	 * 批处理执行完毕时派发
	 */
	[Event(name = "complete", type = "events.NarutoEvent")]
	
	/**
	 * 批处理运行器
	 * @author larryhou
	 * @createTime 2013/6/27 10:47
	 */		
	public class BATRunner extends EventDispatcher
	{
		private var _executable:File;
		private var _process:NativeProcess;
		
		/**
		 * 构造函数
		 * create a [BATRunner] object
		 */
		public function BATRunner(executable:File) 
		{
			_executable = executable;
		}
		
		/**
		 * 运行批处理
		 * @param	bat	批处理File对象
		 */
		public function execute(bat:File):void
		{			
			var params:Vector.<String> = new Vector.<String>;
			params.push("/c");
			params.push(bat.nativePath);
			
			var info:NativeProcessStartupInfo = new NativeProcessStartupInfo();
			info.executable = _executable;
			info.arguments = params;				
			
			_process = new NativeProcess();
			_process.addEventListener(Event.STANDARD_OUTPUT_CLOSE, completeHandler);
			_process.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, outputHandler);
			_process.addEventListener(NativeProcessExitEvent.EXIT, exitHandler);			
			_process.start(info);
		}
		
		/**
		 * 命令行程序退出时处理
		 */
		private function exitHandler(e:NativeProcessExitEvent):void 
		{
			_process.removeEventListener(Event.STANDARD_OUTPUT_CLOSE, completeHandler);
			_process.removeEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, outputHandler);
			_process.removeEventListener(NativeProcessExitEvent.EXIT, exitHandler);
			_process = null;
			
			dispatchEvent(new NarutoEvent(NarutoEvent.COMPLETE));
		}
		
		/**
		 * 有输出数据时处理
		 */
		private function outputHandler(e:ProgressEvent):void 
		{
			var output:IDataInput = _process.standardOutput;
			var data:String = output.readMultiByte(output.bytesAvailable, "gb2312").replace(/\r\n/gm, "");
			dispatchEvent(new NarutoEvent(NarutoEvent.OUTPUT_DATA, data));
		}
		
		/**
		 * 输出结束时处理
		 */
		private function completeHandler(e:Event):void 
		{
			_process.exit(true);
		}
		
	}

}