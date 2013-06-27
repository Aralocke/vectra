package net.phantomnet.observer;

import net.phantomnet.events.ConnectEvent;
import net.phantomnet.observer.Observer;

/**
 * Interface for classes wishing to receive notifications about connections
 * to a server by a Connection object
 * 
 * @author Danny
 *
 */

public interface ConnectionObserver 
	extends Observer {
	
	public void observeConnection (final ConnectEvent event) ;
}
