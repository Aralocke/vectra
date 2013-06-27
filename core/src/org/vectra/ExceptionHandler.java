package org.vectra;

import java.util.logging.Level;
import java.util.logging.Logger;

public class ExceptionHandler 
	implements Thread.UncaughtExceptionHandler 
{
	public void uncaughtException(final Thread t, final Throwable e) {
		if (e instanceof Error) {
			Logger.getLogger("net.phantomnet").log(Level.SEVERE, "Thread \"" + t.getName() + "\" died after an exception", e);
		} else {
			Logger.getLogger("net.phantomnet").log(Level.WARNING, "Thread \"" + t.getName() + "\" died after an exception", e);
		}
	}
}