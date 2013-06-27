package org.vectra.loggers;

import java.util.logging.ErrorManager;
import java.util.logging.Handler;
import java.util.logging.LogRecord;

public class ModuleLog
	extends Handler {

	private boolean active ;
	
	public ModuleLog() 
	{
		this.active = true;
	}
	
	@Override
	public void publish(final LogRecord record) {
		try {			
			if (isLoggable(record) && active) {
				//final Object[] params = record.getParameters();
				//if (params == null || params.length < 1)
				//	return;
				
				AdministratorMessage.send(Levels.toString(record.getLevel())+" "+record.getMessage());
				//System.out.println("[MODULE] :: "+((params == null) ? 0 : params.length)+" :: "+record.getMessage()) ;	
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
