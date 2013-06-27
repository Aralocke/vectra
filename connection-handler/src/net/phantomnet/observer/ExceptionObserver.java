package net.phantomnet.observer;

import net.phantomnet.events.ExceptionEvent;
import net.phantomnet.observer.Observer;

/**
 * Interface for classes wishing to receive notifications about Exceptions
 * by a Connection object
 * 
 * @author Danny
 *
 */

public interface ExceptionObserver 
	extends Observer {
	
	public void observeException (final ExceptionEvent event) ;
}