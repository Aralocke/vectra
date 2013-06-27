package org.vectra;

import java.util.logging.Level;
import java.util.logging.Logger;


import org.vectra.loggers.ConnectionErrorLog;
import org.vectra.loggers.ConnectionStatusLog;
import org.vectra.loggers.ErrorLog;
import org.vectra.loggers.ModuleLog;
import org.vectra.loggers.MySQLLog;
import org.vectra.loggers.StatusLog;

public class SystemLog {
	
	@SuppressWarnings("unused")
	private static final Logger[] loggers = {
		Logger.getLogger("net.phantomnet"),
		Logger.getLogger("org.vectra.connectionerror"),
		Logger.getLogger("org.vectra.connectionstatus"),
		Logger.getLogger("net.phantomnet.error"),
		Logger.getLogger("net.phantomnet.mysql"),
		Logger.getLogger("org.vectra.module")
	};
	
	public static final void startup() 
	{
		/*
		 * This is the default status logger
		 * Any message that doesn't fit in the logging 
		 * area of another handler goes here
		 */
		Logger.getLogger("net.phantomnet").setLevel(Level.CONFIG);
		Logger.getLogger("net.phantomnet").addHandler(new StatusLog());
		
		/*
		 * This log handler handles all event based information
		 * for the connections. This includes any specific logging 
		 * events, however it does not include errors.
		 */
		Logger.getLogger("org.vectra.connectionstatus").setLevel(Level.CONFIG);
		Logger.getLogger("org.vectra.connectionstatus").addHandler(new ConnectionStatusLog());
		
		/*
		 * This log handler will handle all connection errors.
		 * This can include kills, timeouts, etc
		 */
		Logger.getLogger("org.vectra.connectionerror").setLevel(Level.WARNING);
		Logger.getLogger("org.vectra.connectionerror").addHandler(new ConnectionErrorLog());
		
		/*
		 * Global error log
		 * Handlers and Managers will use this to report issues
		 */
		Logger.getLogger("net.phantomnet.error").setLevel(Level.WARNING);
		Logger.getLogger("net.phantomnet.error").addHandler(new ErrorLog());
		
		/*
		 * The MySQL Log, logs all relevant status information about
		 * the active MySQL connections if they are being used
		 */
		Logger.getLogger("net.phantomnet.mysql").setLevel(Level.INFO);
		Logger.getLogger("net.phantomnet.mysql").addHandler(new MySQLLog());
		
		/*
		 * The module log will contain all logging information from 
		 * the individual modules and any output that might be produced
		 * during, before, or after execution
		 */
		Logger.getLogger("org.vectra.module").setLevel(Level.FINE);
		Logger.getLogger("org.vectra.module").addHandler(new ModuleLog());
	}
}
