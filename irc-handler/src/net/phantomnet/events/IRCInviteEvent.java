package net.phantomnet.events;

import org.vectra.irc.IRCChannel;
import org.vectra.irc.IRCEvent;

public class IRCInviteEvent
	extends IRCChannelEvent {

	private static final long serialVersionUID = -767781280954620713L;

	public IRCInviteEvent(final IRCEvent event, final IRCChannel channel)
			throws IllegalArgumentException {
		super(event, channel);		
	}

}
