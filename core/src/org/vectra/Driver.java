package org.vectra;

import java.io.File;
import java.util.logging.Level;
import java.util.logging.Logger;

import org.vectra.Config;
import org.vectra.ConnectionManager;
import org.vectra.IRCConnectionMaker;
import org.vectra.irc.IRCConnection;

public class Driver 
{
	public static void main (String[] args)
    {
		// make sure that the log directory exists
		new File(Core.logDirectory()).mkdir();
		
		// initialize the Loggers
		SystemLog.startup();
		
		// This sends all uncaught exceptions in the thread's 
		// to an exception handler that we actually do watch
		// so that it can be logged and handled appropriately
		Thread.setDefaultUncaughtExceptionHandler(new ExceptionHandler());		
		
		
		final long start = System.currentTimeMillis();		
		try {
			final SystemConfig s = new SystemConfig();
			s.rehash();
		} catch (final Exception e) {
			System.out.println(e);
		}
		final long stop = System.currentTimeMillis();
		System.out.println("Complete rehashing of the configuration took: "+
			(stop - start)+"ms");
		System.exit(0);
		
		// IdentServer.startup(); 
		
		try {
        	for (final BotConfig config : Config.getBotConfigs()) {        		
				@SuppressWarnings("unused")
				final IRCConnection bot = IRCConnectionMaker.makeConnection(config) ;
        	}
        } catch (Exception e) {
        	Logger.getLogger("net.phantomnet").log(Level.SEVERE, "[INIT]: Error loading new Bots: "+e);
        }
        
		try {
        	// final SystemStartup startup = new SystemStartup() ;
			Core.getCoreQueue().put(new Startup()) ;
		} catch (final InterruptedException e) {
			Logger.getLogger("net.phantomnet").log(Level.SEVERE, "Failed to run Startup threads.", e) ;
			System.exit(0) ;
		}		
    
        // this is the actual meat of the system
        // Without this the Daemon would just die
        while (Core.isRunning())                              
            try {                           
                // no sense continuing to run if all the bots are gone
                if (ConnectionManager.getConnections().size() == 0)
                   Core.setStatus(false) ;
                
                // We call this to execute CoreModules 
                // Reloads, rehashes, shutdowns, etc
                Core.getCoreQueue().take().run() ;
            } catch (InterruptedException e) {
                // we don't care what happens here
            }
        
        
        Logger.getLogger("net.phantomnet").log(Level.SEVERE, "System is now shutting down.") ;
        System.exit(0) ;
	}
}
