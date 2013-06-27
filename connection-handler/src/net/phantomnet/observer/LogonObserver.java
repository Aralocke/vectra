package net.phantomnet.observer;

import net.phantomnet.events.LogonEvent;
import net.phantomnet.observer.Observer;

/**
 * Interface for classes wishing to receive notifications about disconnects
 * to a server by a Connection object
 * 
 * @author Danny
 *
 */

public interface LogonObserver 
	extends Observer {

	public void observeLogon (final LogonEvent event) ;
}