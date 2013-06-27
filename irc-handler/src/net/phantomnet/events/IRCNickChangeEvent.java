package net.phantomnet.events;

import org.vectra.interfaces.Events;
import org.vectra.interfaces.Source;
import org.vectra.irc.IRCEvent;

public class IRCNickChangeEvent 
	extends IRCEvent
	implements Events, Source
{
	/**
	 * Unique ID
	 */
	private static final long serialVersionUID = -4728797638088754798L;

	public IRCNickChangeEvent(final IRCEvent event)
		throws IllegalArgumentException {
		super(event) ;
	}
}
