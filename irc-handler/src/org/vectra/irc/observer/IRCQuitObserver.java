package org.vectra.irc.observer;

import net.phantomnet.events.IRCQuitEvent;
import net.phantomnet.observer.Observer;

public interface IRCQuitObserver
	extends Observer {
	
	public void observeQuit(final IRCQuitEvent event) throws Exception;
}
