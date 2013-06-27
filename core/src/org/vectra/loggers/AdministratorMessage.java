package org.vectra.loggers;

import org.vectra.ConnectionManager;
import org.vectra.interfaces.Priority;
import org.vectra.irc.IRCConnection;

public class AdministratorMessage
	implements Priority
{
	public static void send(final String message) 
	{
		final IRCConnection connection = (IRCConnection) ConnectionManager.getConnection("Administrator") ;		
		if (connection == null) {
			System.err.println("Failed to send a log to staff channel: Administrator connection does not exist");
			return;
		} 
		final String channel = connection.getConfig().getLogChannel();
		if (connection.onChannel(channel))
			AdministratorMessage.send(channel, message) ;
	}
	
	public static void send(final String channel, final String message) 
	{
		if (channel == null || channel.isEmpty())
			throw new IllegalArgumentException("The channel cannot be null in a log message");
		if (message == null || message.isEmpty())
			throw new IllegalArgumentException("The message cannot be null in a log message");
		
		final IRCConnection connection = (IRCConnection) ConnectionManager.getConnection("Administrator") ;
		if (connection == null) {
			System.err.println("Failed to send a log to "+channel.trim()+": Administrator connection does not exist");
		} else {
			try {				
				if (!connection.onChannel(channel))
					throw new IllegalStateException();				
				connection.send("PRIVMSG "+channel.trim()+" :"+message.trim(), PRIORITY_HIGH);
			} catch (final IllegalStateException e) {
				System.err.println("["+connection.getConfig().getNick()+"] "+
						"Failed to send a log message to " + channel + ": "+message);
			} // catch
		} // else
	} // function
}
