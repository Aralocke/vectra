package net.phantomnet.events;

import org.vectra.irc.IRCChannel;
import org.vectra.irc.IRCEvent;

public class IRCKickEvent
	extends IRCPartEvent {

	private static final long serialVersionUID = -4287045122356960907L;

	public IRCKickEvent(final IRCEvent event, final IRCChannel channel)
			throws IllegalArgumentException {
		super(event, channel);
	}

}
