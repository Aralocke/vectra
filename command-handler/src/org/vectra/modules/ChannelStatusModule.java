package org.vectra.modules;

import java.util.List;
import java.util.regex.Pattern;

import org.vectra.Connection;
import org.vectra.Event;
import org.vectra.Module;
import org.vectra.StrUtils;
import org.vectra.irc.IRCChannel;
import org.vectra.irc.IRCChannelUser;
import org.vectra.irc.IRCConnection;
import org.vectra.irc.IRCEvent;

public class ChannelStatusModule
	extends Module 
{

	public ChannelStatusModule(final Integer id) {
		super("ChannelStatusModule", id, E_PRIVMSG, PACK_CORE_COMMANDS, "^[!@.~`]chan(nel)?status", true);
	}
	
	@Override
	public ChannelStatusModule getInstance() {
		return new ChannelStatusModule(getID());
	}

	@Override
	public boolean matches(final Event event) {
		final IRCEvent ircEvent = (IRCEvent) event;
		if (!ircEvent.getUser().getNick().equals("Danny"))
			return false ;
		
		final List<String> tokens = StrUtils.split(event.getMessage(), ' ');
		final Pattern p = getTrigger();
		if (p instanceof Pattern) {
			final String token = tokens.get(0);
			if (token != null)
				return p.matcher(token.trim()).matches();
		}
		return false;
	}

	@Override
	public void beforeExecution(Event event) {
		
	}

	@Override
	public void execute(final Event event) {
		final IRCConnection connection = (IRCConnection) event.getConnection();
		final IRCEvent ircEvent = (IRCEvent) event;
		if ((connection instanceof Connection) && (ircEvent instanceof Event)) {
			IRCChannel target = null;
			if (IRCChannel.validChannel.matcher(ircEvent.getTarget()).matches()) {
				target = connection.getChannelByName(ircEvent.getTarget().trim());
			} 
			
			if (target == null)
				ircEvent.getUser().sendMessage("Command may only be executed in a channel.", ircEvent.getEncoding(), PRIORITY_NORMAL);
			
			StringBuilder string = new StringBuilder("[STATUS]: ");
			// Connection name
			string.append("IRCChannel "+target.getName()+" ("+target.getModes()+") ");
			// Users
			string.append(" :: Users: "+target.getUsers().size()) ;
			// Nick
			string.append(" :: Topic: "+((target.getTopic().isEmpty())?"None":target.getTopic())+" (Set By: "+target.getTopicSetter()+")");

			target.sendMessage(string.toString(), ircEvent.getEncoding()) ;	

			string.delete(0, string.length());
			string.append("Channel Info: ");
			for (final IRCChannelUser user : target.getUsers()) 
				string.append(user.statusPrefix()+user.getNick()+" ");
				//string.append('('+user.getModes()+')'+user.getNick()+" ");
			target.sendMessage(string.toString(), ircEvent.getEncoding()) ;
    	}
	}

	@Override
	public void afterExecution(Event event) {
		
	}
}
