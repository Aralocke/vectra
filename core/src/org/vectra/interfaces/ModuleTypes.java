package org.vectra.interfaces;
/**
 * Interface provides core constants used in packaging loaded modules into
 * associated groups based on functionality
 */
public interface ModuleTypes
{
	/**
	 * Type "Unknown" 
	 * Use only when a module should not be grouped into any other
	 * set. This is a catch-all group for module packaging. By default,
	 * any un-specified module will be set in this group.
	 */
	public static final int PACK_UNKNOWN = -2 ;
	
	/**
	 * Type "Test"
	 * Use when actively developing a test module. Not for use 
	 * on any active deployment of the Daemon system.
	 */
	public static final int PACK_TEST = -1 ;
	
	/**
	 * Type "Core"
	 * Used for any module to provide core functionality. An example
	 * would be for "AutoIdentify"
	 */
	public static final int PACK_CORE = 0 ;
	
	public static final int PACK_CORE_COMMANDS = 1 ;
}
