package org.vectra;


import net.phantomnet.sql.pool.MySQLPool;
//import net.phantomnet.sql.pool.MySQLPoolHandler;

//import org.vectra.Config;
import org.vectra.SysUtils;
import org.vectra.irc.IRCIgnoreList;
import org.vectra.irc.IRCUserList;

import java.io.File;
import java.net.MalformedURLException;
import java.net.URL;
//import java.sql.SQLException;
import java.util.concurrent.BlockingQueue;
import java.util.concurrent.LinkedBlockingQueue ;
import java.util.concurrent.TimeUnit ;
import java.util.concurrent.ThreadFactory ; 
import java.util.concurrent.ThreadPoolExecutor ;
import java.util.logging.Level;
import java.util.logging.Logger;

public final class Core 
{
	private static boolean isRunning = true ;
	
	private static Object lock = new Object() ;
	
	public static final IRCIgnoreList ignoreList = new IRCIgnoreList () ;
	
	public final static String[] modules = {
		"AutoModeOnConnect",
		"NickServAutoJoin",
		"NickServAuthModule",
		"StatusModule",
		"ChannelStatusModule",
		"OperOnConnect"
	} ;
	
	public static String[] getModules() {
		return modules;
	}

	public static Thread moduleManager = null ;

	public static ConnectionHandler connectionManager = null;
	public static Thread connectionManagerThread = null;
	
	public static IRCUserList internalUserList = null;
	
	public static SystemConfig configuration = null;
	
	public static final SystemConfig getConfiguration() {
		return configuration;
	}
	
	static {
		try {
			internalUserList = new IRCUserList(new File(rootDirectory()+File.separator+"conf"+File.separator+"staff.txt"));
		} catch (final Exception e) {
			System.out.println(e);
			System.exit(0);
		}
	}
	
	private final static ThreadPoolExecutor moduleExecutor = new ThreadPoolExecutor(
			6 * SysUtils.getAvailableCPUcores(), // coreSize 
			6 * SysUtils.getAvailableCPUcores(), // maxPoolSize
			15, // KeepAlive time 
			TimeUnit.SECONDS, // TImeUnit 
			new LinkedBlockingQueue<Runnable>(), // Storage device for BlockingQueue 
			new ThreadFactory() { // Factory used for creating new threads 
				public Thread newThread(Runnable thread) {
					Thread newThread = new Thread(thread, "Module Thread [Startup]");
					newThread.setDaemon(true);
					return newThread;
				}
			});
	
	private static MySQLPool sqlPool ;
	
	/*static {
		try {
			sqlPool = new MySQLPool(
					10, // maxPool
					Config.getMySQLConfig(),
					new MySQLPoolHandler() // handler
				) ;
			Logger.getLogger("net.phantomnet.mysql").log(Level.INFO, "Successfully created the MySQL Pool.") ;
		} catch (SQLException e) {
			sqlPool = null ;
			Logger.getLogger("net.phantomnet.mysql").log(Level.SEVERE, e.getMessage(), e) ;
			System.exit(0);
		} 
	}*/
	
	public static final MySQLPool getMySQLPool() {
		return sqlPool;
	}
	
	private static final BlockingQueue<Runnable> coreQueue = new LinkedBlockingQueue<Runnable>() ;
	
	public static final String commandHandlerJar = "command-handler.jar" ;
	
	public static final String moduleHandlerClass = "org.vectra.ModuleHandler" ;
	
	public static final String modulePackage = "org.vectra.modules" ;
	
	public static URL[] moduleHandlerJars ;
	
	public static final String rootDirectory ()
	{
	    String dir = "."+File.separator ;
		try {
			final String dotSeparator = (File.separator.equals("/")) ? ".." : ".";
			final String parentDir = new String(dotSeparator+File.separator);
			dir = new String(new File(parentDir).getCanonicalPath()).trim() ; 
			dir = dir.substring(0, dir.lastIndexOf(File.separator))+File.separator ;
		}
		catch (Exception e) {}
		return dir ;
	}
	
	public static final String fileDir () {
	    return rootDirectory()+"command-handler"+File.separator+"data"+File.separator;
	}
	
	public final static String logDirectory() {
		return rootDirectory()+File.separator+"logs"+File.separator;
	}
	
	static {
		try {
			moduleHandlerJars = new URL[] { new File(((File.separator.equals("/")) ? "./" : rootDirectory()), Core.commandHandlerJar).toURI().toURL() };
		} catch (final MalformedURLException e) {
			Logger.getLogger("net.phantomnet").log(Level.SEVERE, e.getMessage(), e);
			System.exit(0);
		}
		
		moduleExecutor.allowCoreThreadTimeOut(true) ;
	}
	
	public static final BlockingQueue<Runnable> getCoreQueue () {
		return coreQueue ;
	}
	
	public static boolean isRunning ()
	{
		synchronized (lock) {
			return isRunning ;
		}		
	}
	
	public static void setStatus (final boolean status)
	{
		synchronized (lock)	{
			isRunning = status ;
		}		
	}
	
	public static final void passEvent (final Runnable event) {
		moduleExecutor.execute(event) ;
	}
}
