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

public class StatusModule
	extends Module 
{

	public StatusModule(final Integer id) {
		super("StatusModule", id, E_PRIVMSG, PACK_CORE_COMMANDS, "^[!@.~`]status", true);
	}

	@Override
	public StatusModule getInstance() {
		return new StatusModule(getID());
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
			
			final StringBuilder string = new StringBuilder("[STATUS]: ");
			// Connection name
			string.append("IRCConnection ("+connection.getConfig().getConnID()+") ");
			// Nick
			string.append(":: "+connection.getConfig().getNick());
			// Modes
			string.append(" :: Modes: +"+connection.getConfig().getModes());
			// Channels
			string.append(" :: Channels: "+connection.getChannelCount());
			// IAL Size
			string.append(" :: IAL: "+connection.getIAL().values().size());
			
			if (target != null) {
				target.sendMessage(string.toString(), ircEvent.getEncoding()) ;
			} else {
				ircEvent.getUser().sendMessage(string.toString(), ircEvent.getEncoding(), PRIORITY_NORMAL);
			}
			
			string.delete(0, string.length());
			string.append("Channel Info: ");
			final String me = connection.getConfig().getNick();
			for (final IRCChannel channel : connection.getChannelMap().values()) {
				final IRCChannelUser user = channel.getUserByNick(me);
				if (user == null)
					string.append(channel.getName()+" ");
				else
					string.append(user.statusPrefix()+channel.getName()+" ");
			}				
			
			if (target != null) {
				target.sendMessage(string.toString(), ircEvent.getEncoding()) ;
			} else {
				ircEvent.getUser().sendMessage(string.toString(), ircEvent.getEncoding(), PRIORITY_NORMAL);
			}
		}
	}

	@Override
	public void afterExecution(Event event) {
		
	}

}
