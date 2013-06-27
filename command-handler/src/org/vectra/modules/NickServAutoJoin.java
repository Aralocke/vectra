package org.vectra.modules;

import org.vectra.Event;
import org.vectra.Module;
import org.vectra.Wildcard;
import org.vectra.interfaces.Named;
import org.vectra.irc.IRCConnection;
import org.vectra.irc.IRCEvent;
import org.vectra.irc.IRCUser;

public class NickServAutoJoin 
	extends Module 
{	
	public NickServAutoJoin (final Integer id)
	{
		super("NickServAutoJoin", id.intValue(), E_NOTICE, PACK_CORE, "*Password accepted*recognized*", false) ;
		// super("NickServAutoJoin", id.intValue(), E_LOGON, PACK_CORE, null, false) ;
	}
	
	@Override
	public NickServAutoJoin getInstance()  {
		return new NickServAutoJoin(getID());
	}

	@Override
	public boolean matches(final Event event) 
	{
		final IRCEvent ircevent = (IRCEvent) event ;
		final IRCUser user = ircevent.getUser();
		if ((user instanceof Named) && (user.getConnection() instanceof IRCConnection))
		{
			// if the user is NickServ and wildcard match is accepted
			return (user.getNick().equals("NickServ") 
				&& Wildcard.matches(getTextMatch(), ircevent.getMessage())) ;
		}
		//final ConnectEvent connectionEvent = (ConnectEvent) event;
		//return ((connectionEvent instanceof Source) && (connectionEvent.getConnection() instanceof IRCConnection)) ;
		return false;
	}

	@Override
	public void beforeExecution(final Event event) 
	{	
	}

	@Override
	public void execute(final Event event) 
	{	
		// retrieve a viable IRCConnection
		final IRCConnection connection = ((IRCEvent) event).getConnection() ;
		// Grab the autoJoinChannels from the Config
		final String autoJoinChannels = connection.getConfig().getAutoJoin() ;
		// validate that we have to autojoin
		if (autoJoinChannels == null || autoJoinChannels.length() < 1)
			return ;
		
		connection.send("JOIN "+autoJoinChannels, event.getEncoding(), PRIORITY_HIGH) ;		
	}

	@Override
	public void afterExecution(final Event event) 
	{	
	}
}
