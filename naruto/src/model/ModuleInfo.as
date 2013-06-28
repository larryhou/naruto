package model 
{
	
	/**
	 * 编译项配置
	 * @author larryhou
	 * @createTime 2013/6/27 10:40
	 */
	public class ModuleInfo 
	{
		/**
		 * 模块输出文件名
		 */
		public var name:String;
		
		/**
		 * 编译配置本地路劲
		 */
		public var config:String;
		
		/**
		 * 编译输出本地路劲
		 */
		public var output:String;
		
		/**
		 * 对应服务器相对路径
		 */
		public var server:String;
		
		/**
		 * 是否被选中
		 */
		public var selected:Boolean;
	}

}