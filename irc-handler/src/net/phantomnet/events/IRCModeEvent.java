package net.phantomnet.events;

import org.vectra.irc.IRCEvent;

public final class IRCModeEvent
	extends IRCEvent {

	private static final long serialVersionUID = -2206351530664741885L;
	
    public IRCModeEvent(final IRCEvent event) {
    	super(event);
	}
    
    public final String getMode() {
    	return getMessage();
    }
}
