package org.vectra.irc.observer;

import net.phantomnet.events.IRCTopicEvent;
import net.phantomnet.observer.Observer;

public interface IRCTopicObserver
	extends Observer {
	
	public void observeTopicChange(final IRCTopicEvent event) throws Exception;
}
