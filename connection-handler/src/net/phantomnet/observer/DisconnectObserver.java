package net.phantomnet.observer;

import net.phantomnet.events.DisconnectEvent;
import net.phantomnet.observer.Observer;

/**
 * Interface for classes wishing to receive notifications about disconnects
 * to a server by a Connection object
 * 
 * @author Danny
 *
 */

public interface DisconnectObserver 
	extends Observer {

	public void observeDisconnect (final DisconnectEvent event) ;
}