package org.vectra.irc.observer;

import net.phantomnet.events.IRCJoinEvent;
import net.phantomnet.observer.Observer;

public interface IRCJoinObserver
	extends Observer {
	
	public void observeJoin(final IRCJoinEvent event) throws Exception;
}
