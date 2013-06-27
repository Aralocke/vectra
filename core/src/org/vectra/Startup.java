package org.vectra;

import java.lang.reflect.Constructor;
import java.lang.reflect.InvocationTargetException;
import java.net.URLClassLoader;
import java.util.logging.Level;
import java.util.logging.Logger;

public class Startup
	implements Runnable
{
	public void run () 
	{
		Logger.getLogger("net.phantomnet").log(Level.INFO, "Beginning thread startup sequence") ;
		
		// Start the connection Manager
		// Maintain the bot list as well as making sure that dead bots reconnect
		Core.connectionManager = new ConnectionHandler();
		Core.connectionManagerThread = new Thread(Core.connectionManager) ;
	    Core.connectionManagerThread.start();
	    
    	// create a class loader
    	final ClassLoader classLoader = new URLClassLoader(Core.moduleHandlerJars, this.getClass().getClassLoader());
	    try
	    {
	    	// load the class
	    	final Class<?> loaded = classLoader.loadClass(Core.moduleHandlerClass);
	    	// modules we want the manager to load
	    	final String[] modules = Core.getModules() ;
	    	// save a list off the types we are passing to the constructor
	    	final Class<?>[] types = new Class<?>[] {modules.getClass()} ;
	    	// load the constructor
	    	final Constructor<?> constructor = loaded.getConstructor(types);	    	
	    	// create a new instance of the object
			final Runnable moduleHandler = (Runnable) constructor.newInstance(new Object[] {modules});
			// build the runnable objects
			Core.moduleManager = new Thread(moduleHandler, "moduleHandler thread") ;
			// save the new class loader to be the class loader used by that class
			// to load all new modules. Reflection requires a new class loader to
			// reload any new code so one is created each reload
			Core.moduleManager.setContextClassLoader(classLoader);
			// start the thread
			Core.moduleManager.start();
	    } catch (final ClassNotFoundException e) {
	    	Logger.getLogger("net.phantomnet").log(Level.SEVERE, "Class " + Core.moduleHandlerClass + 
	    			" not found in the command handler JAR" + (Core.moduleHandlerJars.length != 1 ? "s" : "") + "; no thread started");
		} catch (final SecurityException e) {
			Logger.getLogger("net.phantomnet").log(Level.SEVERE, "Insufficient permissions to create a required class loader; command handler not started");
		} catch (final NoSuchMethodException e) {
			Logger.getLogger("net.phantomnet").log(Level.SEVERE, "Class " + Core.moduleHandlerClass + " in the command handler JAR" + 
					(Core.moduleHandlerJars.length != 1 ? "s" : "") + " has no parameterless constructor; no thread started");
		} catch (final InstantiationException e) {
			Logger.getLogger("net.phantomnet").log(Level.SEVERE, "Class " + Core.moduleHandlerClass + " in the command handler JAR" + 
					(Core.moduleHandlerJars.length != 1 ? "s" : "") + " is abstract; no thread started");
		} catch (final IllegalAccessException e) {
			Logger.getLogger("net.phantomnet").log(Level.SEVERE, "Class " + Core.moduleHandlerClass + " in the command handler JAR" + 
					(Core.moduleHandlerJars.length != 1 ? "s" : "") + " cannot be accessed; no thread started");
		} catch (final InvocationTargetException e) {
			Logger.getLogger("net.phantomnet").log(Level.SEVERE, "Class " + Core.moduleHandlerClass + " in the command handler JAR" + 
					(Core.moduleHandlerJars.length != 1 ? "s" : "") + " threw an exception when initialised; no thread started");
		} catch (final ClassCastException e) {
			Logger.getLogger("net.phantomnet").log(Level.SEVERE, "Class " + Core.moduleHandlerClass + " in the command handler JAR" + 
					(Core.moduleHandlerJars.length != 1 ? "s" : "") + " is not a Runnable subclass; no thread started");
		}
	}
}