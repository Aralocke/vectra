package org.vectra.irc.observer;

import net.phantomnet.events.IRCNickChangeEvent;
import net.phantomnet.observer.Observer;

public interface IRCNickChangeObserver
	extends Observer {
	
	public void observeNicknameChange(final IRCNickChangeEvent event) throws Exception;
}
