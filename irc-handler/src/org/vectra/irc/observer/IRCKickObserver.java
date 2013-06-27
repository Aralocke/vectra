package org.vectra.irc.observer;

import net.phantomnet.events.IRCKickEvent;
import org.vectra.irc.observer.IRCPartObserver;

public interface IRCKickObserver
	extends IRCPartObserver {
	
	public void observeKick(final IRCKickEvent event) throws Exception;
}
