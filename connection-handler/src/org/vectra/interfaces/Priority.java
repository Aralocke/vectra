package org.vectra.interfaces;

/**
 * This class provides numeric constants for priorities
 * to send messages to teh IRC servers. Each Connection
 * will maintain an internal Prioritized queue of messages
 * that need to be sent to the IRC server. This class 
 * provides some constants with which to use in dynamically
 * sorting that queue.
 * 
 * @author Danny
 *
 */
public interface Priority 
{
	/**
	 * Low message priority
	 * These messages will be sent to the server last followed
	 * by any messages that do not follow the following conventions
	 */
	public static final byte PRIORITY_LOW = (byte) 10 ;
	
	/**
	 * Medium message priority
	 * These messages will traditionally be used for non-important
	 * messages to an IRC server such as topic changes or mode 
	 * changes
	 */
	public static final byte PRIORITY_MEDIUM = (byte) 20 ;
	
	/**
	 * Normal message priority
	 * These messages are traditionally command responses to the
	 * built-in modules and some to the server types of messages
	 */
	public static final byte PRIORITY_NORMAL = (byte) 80 ;
	
	/**
	 * High Priority messages
	 * These messages are reserved for event responses. In 
	 * particular the responses to events like joins, parts, etc
	 * where as a message to the IRC server is more important
	 * than module responses.
	 */
	public static final byte PRIORITY_HIGH = (byte) 100 ;
	
	/**
	 * Emergency Priority messages
	 * This will be sent first. The highest priority message to the 
	 * server. This is reserved exclusively for responses to the PING
	 * and other events that must be sent to the server with no delay
	 */
	public static final byte PRIORITY_EMERGENCY = (byte) 127 ;
}
