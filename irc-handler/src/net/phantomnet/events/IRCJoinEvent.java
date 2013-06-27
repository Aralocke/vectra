package net.phantomnet.events;

import net.phantomnet.events.IRCChannelEvent;
import org.vectra.irc.IRCChannel;
import org.vectra.irc.IRCEvent;

public class IRCJoinEvent 
	extends IRCChannelEvent
{
	
    /**
	 * Unique ID
	 */
	private static final long serialVersionUID = -6227965675644520341L;

	public IRCJoinEvent(final IRCEvent event, final IRCChannel channel)
		throws IllegalArgumentException 
	{
		super(event, channel) ;
	}
	
}