package org.vectra.loggers;

import java.util.logging.ErrorManager;
import java.util.logging.Handler;
import java.util.logging.LogRecord;

import org.vectra.interfaces.IRCEvents;
import org.vectra.interfaces.Source;
import org.vectra.irc.IRCChannel;
import org.vectra.irc.IRCConnection;
import org.vectra.irc.IRCEvent;
import org.vectra.irc.IRCUser;

public class ConnectionStatusLog
	extends Handler
	implements IRCEvents {

	private boolean active ;
	
	public ConnectionStatusLog() 
	{
		this.active = true;
	}
	
	@Override
	public void publish(final LogRecord record) {
		try {
			if (isLoggable(record) && active)
			{
				final Object[] params = record.getParameters();
				if (params.length == 0)
					return;
				final IRCEvent event = (IRCEvent)params[0];
				final IRCConnection connection = event.getConnection();
				
				if (!(event instanceof Source) || (connection == null)) 
					return; // get out of dodge fast
				if (record.getMessage() != null && record.getMessage().startsWith("CHECKPERM")) {
					// we're attempting to rejoin a permanent channel
					final String channel = (String)params[1];
					final String message = "["+connection.getConfig().getNick()+"] "+
							"** (PERM CHECK): Attempting to rejoin permanent channel "+channel+" on "+connection.getConfig().getNetwork()+".";
					AdministratorMessage.send(channel, message);
				} else if (event.getType() == E_JOIN) {
					final IRCChannel channel = (IRCChannel)params[1];
					final String message = "["+connection.getConfig().getNick()+"] "+
							"** (JOIN): I have joined "+channel.getName()+" on "+connection.getConfig().getNetwork()+".";
					AdministratorMessage.send(message);
				} else if (event.getType() == E_PART) {
					final IRCChannel channel = (IRCChannel)params[1];
					final String message = "["+connection.getConfig().getNick()+"] "+
							"** (PART): I have parted "+channel.getName()+" on "+connection.getConfig().getNetwork()+".";
					AdministratorMessage.send(message);					
				} else if (event.getType() == E_KICK) {
					final IRCChannel channel = (IRCChannel)params[1];
					final String eventMsg = event.getMessage();
					String kickReason;
					if (eventMsg.indexOf(':') > 0)
						kickReason = eventMsg.substring(eventMsg.indexOf(' ') + 1).trim();
					else 
						kickReason = "No reason";
					final String message = "["+connection.getConfig().getNick()+"] "+
							"** (KICK): I have been kicked from "+channel.getName()+" on "+connection.getConfig().getNetwork()+
							". Reason: "+kickReason.trim()+((kickReason.endsWith("."))?"":'.');
					AdministratorMessage.send(message);
				} else if (event.getType() == E_INVITE) {
					final IRCChannel channel = (IRCChannel)params[1];
					final IRCUser user = event.getUser();
					final String message = "["+connection.getConfig().getNick()+"] "+
							"** (INVITE): I have been invited to "+channel.getName()+" on "+connection.getConfig().getNetwork()+
							". Invited by "+user.getNick()+" ("+user.getIdent()+'@'+user.getAddress()+").";
					AdministratorMessage.send(message);
				} else {
					AdministratorMessage.send(Levels.toString(record.getLevel())+" "+record.getMessage());
				}				
			}
		} catch (final Exception e) {
			reportError(e.getMessage(), e, ErrorManager.WRITE_FAILURE) ;
		}
	}

	@Override
	public void flush() {
		
	}

	@Override
	public synchronized void close() throws SecurityException {
		this.active = false;
	}

}
