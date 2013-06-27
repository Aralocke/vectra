package org.vectra.irc.observer;

import net.phantomnet.events.IRCRawEvent;
import net.phantomnet.observer.Observer;

public interface IRCRawNumericObserver 
	extends Observer {
	
	public void observeRaw(final IRCRawEvent event) throws Exception;
}
