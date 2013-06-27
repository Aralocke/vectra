package org.vectra.irc.observer;

import net.phantomnet.events.IRCPartEvent;
import net.phantomnet.observer.Observer;

public interface IRCPartObserver
	extends Observer {

	public void observePart(final IRCPartEvent event) throws Exception;
}
