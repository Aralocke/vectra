package net.phantomnet.events;

import org.vectra.irc.IRCChannel;
import org.vectra.irc.IRCEvent;

public class IRCTopicEvent
	extends IRCChannelEvent {

	private static final long serialVersionUID = -1174850783395135692L;

	public IRCTopicEvent(final IRCEvent event, final IRCChannel channel) {
		super(event, channel);
	}
}
