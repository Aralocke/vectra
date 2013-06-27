package org.vectra.modules;

import org.vectra.Event;
import org.vectra.Module;
import org.vectra.Wildcard;
import org.vectra.interfaces.Named;
import org.vectra.irc.IRCConnection;
import org.vectra.irc.IRCEvent;
import org.vectra.irc.IRCUser;

public class NickServAuthModule 
	extends Module 
{
	
	public NickServAuthModule (final Integer id)
	{
		super("NickServAuthModule", id.intValue(), E_NOTICE, PACK_CORE, "*registered and protected*", false) ;
	}
	
	@Override
	public NickServAuthModule getInstance() {
		return new NickServAuthModule(getID());
	}

	@Override
	public boolean matches(final Event event) 
	{
		final IRCEvent ircevent = (IRCEvent) event ;
		final IRCUser user = ircevent.getUser() ;
		if ((user instanceof Named) && (user.getConnection() instanceof IRCConnection))
		{
			// if the user is NickServ and wildcard match is accepted
			return (user.getNick().equals("NickServ") 
					&& Wildcard.matches(getTextMatch(), ircevent.getMessage())) ;
		}
		return false ;
	}

	@Override
	public void beforeExecution(final Event event) 
	{	
	}

	@Override
	public void execute(final Event event) 
	{	
		final IRCConnection connection = ((IRCEvent) event).getConnection() ;
		if (connection.getConfig().getPassword() == null)
			return ;
		final IRCUser user = ((IRCEvent) event).getUser() ;

		if (user instanceof Named) {
			user.sendMessage("IDENTIFY "+connection.getConfig().getPassword()) ;
		}		
	}

	@Override
	public void afterExecution(final Event event) 
	{	
	}
}
