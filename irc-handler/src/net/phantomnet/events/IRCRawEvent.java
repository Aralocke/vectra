package net.phantomnet.events;

import org.vectra.irc.IRCEvent;

public class IRCRawEvent
	extends IRCEvent {

	private static final long serialVersionUID = 7502159168571287231L;

	public IRCRawEvent(final IRCEvent event) {
		super(event);
	}

}
