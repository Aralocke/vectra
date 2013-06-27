package org.vectra.irc.observer;

import net.phantomnet.events.IRCInviteEvent;
import net.phantomnet.observer.Observer;

public interface IRCInviteObserver
	extends Observer {
	
	public void observeInvite(final IRCInviteEvent event) throws Exception;
}
