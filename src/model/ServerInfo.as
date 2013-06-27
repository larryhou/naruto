package model 
{
	/**
	 * 服务器信息
	 * @author larryhou
	 * @createTime 2013/6/27 11:14
	 */
	public class ServerInfo 
	{
		/**
		 * 服务器素材根路径
		 */
		public var root:String;
		
		/**
		 * 服务器域名列表
		 */
		public var domains:Vector.<String>;
		
		/**
		 * 服务器列表
		 */
		public var items:Vector.<ServerItemInfo>;
		
		/**
		 * 当前服务器信息
		 */
		public var currentItem:ServerItemInfo;
	}

}