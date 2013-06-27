package org.vectra;

import java.io.IOException;
import java.net.SocketException;

import org.vectra.ConnectionManager ;
import org.vectra.components.IdentServer;
import org.vectra.exceptions.ConnectionFailedException;
import org.vectra.irc.IRCBotConfig;
import org.vectra.irc.IRCConnection;

public final class IRCConnectionMaker 
{
	public static final IRCConnection makeConnection (final BotConfig config)
		throws IllegalStateException, IllegalArgumentException
	{
		if (config == null)
			throw new IllegalArgumentException("Supplied config is null or invalid") ;

		if (config.validate())
		{
			try
			{
				final IRCBotConfig cfg = (IRCBotConfig) config;
				// Create a new connection & pass the config
				final IRCConnection connection = new IRCConnection(cfg, Core.ignoreList, Core.internalUserList) ;
				// set a link to the connection inside of the configuration
				cfg.setConnection(connection) ;
				// connect the connection to an available server & port
				final String server = cfg.getAvailableServer() ;
				final short port = (short)cfg.getPort() ;
				// if we use identd - queue the identd server listener
				if (cfg.useIdentd()) {
					IdentServer.queue(connection, server, port);
				} else {
					// if we don't we identd connect automatically
					// TODO queue incase admin connection is waiting for identd
					connection.connect(server, port) ;
				}
				// add the connection to the manager
				ConnectionManager.addConnection(connection, cfg.getConnID()) ;
				// link the handler with the connection monitor
				connection.linkDisconnectObserver(Core.connectionManager);
				// return the resulting connection
				return connection ;
			} catch (SocketException e) {
                System.out.println("SocketException :: "+e) ;
            } catch (IOException e) {
                System.out.println("IOException :: "+e) ;
            } catch (IllegalStateException e) {
                System.out.println("IllegalStateException :: "+e) ;
                throw e ;
            } catch (ConnectionFailedException e) {
                System.out.println("ConnectionFailedException :: "+e) ;
            }
		}
		
		return null ;
	}
}
