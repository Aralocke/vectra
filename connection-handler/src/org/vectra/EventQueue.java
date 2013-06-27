package org.vectra;
import java.util.concurrent.BlockingQueue ;
import java.util.concurrent.LinkedBlockingQueue ;
import java.util.concurrent.TimeUnit;

import org.vectra.interfaces.Events;

import net.phantomnet.events.DisconnectEvent;
/**
 * The ModuleQueue stores the Events awaiting processing. These Events come from
 * any Connection object.
 * 
 * @author Danny
 *
 */
public class EventQueue 
	implements Events
{
	/**
	 * Stores events from connections regarding disconnects
	 */
	private static final LinkedBlockingQueue<DisconnectEvent> eventList = new LinkedBlockingQueue<DisconnectEvent>();
	
	public static final DisconnectEvent waitForDisconnectEvent (long timeout)
		throws InterruptedException {
		return eventList.poll(timeout, TimeUnit.MILLISECONDS);
	}
	
	/**
	 * The blocking queue holds all events processed by a COnnection class.
	 * The blocking mechanism in this class is used to hold a lock on the 
	 * ModulerManager class.
	 */
	public final static BlockingQueue<Event> eventQueue = new LinkedBlockingQueue<Event>() ;
	
	/**
	 * Pass an event into the BlockingQueue. These events will be processed 
	 * linearly through the ModuleManager class.
	 * 
	 * Event is an abstract class so the objects added to this queue will
	 * be designed to match the protocol used by that connection type.
	 * 
	 * @param event An event created by an extended class of the Connection 
	 * 		  series. The event contains a link to the actual parent event
	 *        that created and thus called this event.
	 * @throws InterruptedException
	 */
	public static final void addEvent (final Event event)
		throws InterruptedException
	{
		if (event.getType() == E_DISCONNECT)
			eventList.add((DisconnectEvent) event);
		eventQueue.offer(event) ;

	}
	
	/**
	 * Return the Event blocking queue that contains all of the Events that
	 * have been created by all of the COnnection classes known to this
	 * application
	 * @return The event BlockingQueue
	 */
	public static final BlockingQueue<Event> getQueue ()
	{
		return eventQueue ;
	}
	
	/**
	 * This method uses the blocking features of the blocking queue. It calls 
	 * the built-in take() method from a blocking queue.
	 * 
	 * @return an Event save din the BlockingQueue maintained by this manager
	 *         class. This method will block until an Event has been added 
	 *         to the queue.
	 * @throws InterruptedException
	 */
	public static final Event getEvent ()
		throws InterruptedException
	{
		return eventQueue.take() ;
	}
	
	/**
	 * @return The number of events awaiting execution by the ModuleManager
	 */
	public static int size ()
	{
		return eventQueue.size() ;
	}
}
