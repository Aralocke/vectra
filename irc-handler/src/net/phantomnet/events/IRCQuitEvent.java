package net.phantomnet.events;

import org.vectra.interfaces.Events;
import org.vectra.interfaces.Source;
import org.vectra.irc.IRCEvent;

public class IRCQuitEvent 
	extends IRCEvent
	implements Events, Source
{
	private static final long serialVersionUID = 6787081353368912933L;

	public IRCQuitEvent(final IRCEvent event)
		throws IllegalArgumentException {
		super(event) ;
	}
	
}