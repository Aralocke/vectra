package net.phantomnet.events;

import org.vectra.interfaces.Events;
import org.vectra.interfaces.Source;
import org.vectra.irc.IRCChannel;
import org.vectra.irc.IRCEvent;

public class IRCChannelEvent 
	extends IRCEvent
	implements Events, Source {

	private static final long serialVersionUID = -1304724313178362677L;
	
	private final IRCChannel channel;

	public IRCChannelEvent(final IRCEvent event, final IRCChannel channel)
		throws IllegalArgumentException {
		super(event) ;
		this.channel = channel;
	}
	
	public IRCChannel getChannel () {
		return this.channel ;
	}
}
