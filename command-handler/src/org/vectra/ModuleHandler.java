package org.vectra ;
import java.lang.reflect.Constructor;
import java.lang.reflect.InvocationTargetException;
import java.net.URLClassLoader;
import java.util.ArrayList;
import java.util.Collection;
import java.util.logging.Level;
import java.util.logging.Logger;

import org.vectra.Core;
import org.vectra.Event ;
import org.vectra.EventQueue;
import org.vectra.Module ;
import org.vectra.ModuleManager ;
import org.vectra.interfaces.Events;
import org.vectra.interfaces.IRCd;

import org.vectra.modules.* ;
@SuppressWarnings("unused")

public class ModuleHandler 
	implements IRCd, Events, Runnable
{
    public ModuleHandler (final String[] modules)
	{	
		// load the classes here
		for (final String name : modules)
		{
			try {
				// create the module instance
				final Module module = loadModule(name) ;
				// add the module to the manager
				ModuleManager.addModule(module) ;				
				Logger.getLogger("org.vectra.module").log(Level.INFO, "[MODLOAD]: Successfully loaded "+name) ;
			} catch (SecurityException e) {
				Logger.getLogger("org.vectra.module").log(Level.SEVERE, "[MODLOAD]: "+e, e) ;
			} catch (IllegalArgumentException e) {
				Logger.getLogger("org.vectra.module").log(Level.SEVERE, "[MODLOAD]: "+e, e) ;
			} catch (ClassNotFoundException e) {
				Logger.getLogger("org.vectra.module").log(Level.SEVERE, "[MODLOAD]: "+e, e) ;
			} catch (NoSuchMethodException e) {
				Logger.getLogger("org.vectra.module").log(Level.SEVERE, "[MODLOAD]: "+e, e) ;
			} catch (InstantiationException e) {
				Logger.getLogger("org.vectra.module").log(Level.SEVERE, "[MODLOAD]: "+e, e) ;
			} catch (IllegalAccessException e) {
				Logger.getLogger("org.vectra.module").log(Level.SEVERE, "[MODLOAD]: "+e, e) ;
			} catch (InvocationTargetException e) {
				Logger.getLogger("org.vectra.module").log(Level.SEVERE, "[MODLOAD]: "+e, e) ;
			} // end try/catch
		} // for (final...
	}
	
    
    public Module loadModule (final String moduleName) 
    	throws ClassNotFoundException, IllegalArgumentException, IllegalStateException, 
    	       SecurityException, NoSuchMethodException, IllegalArgumentException, 
    	       InstantiationException, IllegalAccessException, InvocationTargetException
    {
    	if (moduleName == null || moduleName.length() == 0)
    		throw new IllegalStateException("Module names cannot be null") ;
    	
    	// obtain a unique ID
    	final int moduleId = ModuleManager.getNewID() ; ;
    	// call the overloaded method instead
    	return loadModule(moduleName, moduleId) ;
    }
    
    public Module loadModule(final String moduleName, final int id)
    	throws ClassNotFoundException, IllegalArgumentException, IllegalStateException, 
 	       SecurityException, NoSuchMethodException, IllegalArgumentException, 
 	       InstantiationException, IllegalAccessException, InvocationTargetException
    {
    	if (moduleName == null || moduleName.length() == 0)
    		throw new IllegalStateException("Module names cannot be null") ;
    	if (id < 0)
    		throw new IllegalArgumentException("Module ID's will never be less than zero") ;
    	// Create a class wrapper for the new ID
    	// this is needed for pass-by-type to the reflection constructor
    	// when the module is dynamically loaded
    	final Integer intID = new Integer(id) ;
    	// create a new URLClassloader
    	final URLClassLoader classloader = new URLClassLoader(Core.moduleHandlerJars, this.getClass().getClassLoader()) ; 
    	// create a new instance of the module 
    	final Class<?> loaded = classloader.loadClass(Core.modulePackage+"."+moduleName) ;
    	// create the type array to be sent to the constructor
    	final Class<?>[] types = new Class<?>[] {intID.getClass()} ;
    	// create the constructor used to instantiate an object
    	final Constructor<?> constructor = loaded.getConstructor(types) ;
    	// instantiate a new module
    	// we pass the module ID in the constructor
    	final Module module = (Module) constructor.newInstance(new Object[] {intID}) ;
    	// proceed to return the object 
    	// if nothing was thrown it was properly instantiated
    	return module ;
    }
    
    public boolean rehashModule (final Module module)
    	throws IllegalStateException
    {
    	final Module existingModule = ModuleManager.getModule(module) ;
    	if (existingModule == null)
    		throw new IllegalStateException("Module does not exist or it has not yet been loaded") ;
    	
    	try {
			final Module newModule = loadModule(existingModule.getName(), existingModule.getID()) ;	
			
			if (newModule == null)
				throw new IllegalStateException("Failed to reload the module: "+existingModule.getName()) ;
			
			// remove the module from the Manager
			ModuleManager.removeModule(existingModule) ;
			// re-add the module
			ModuleManager.addModule(newModule) ;
			// return successful reload because no error was thrown
			return true ;
		} catch (SecurityException e) {
			Logger.getLogger("org.vectra.module").log(Level.SEVERE, "[REHASH]: "+e, e) ;
		} catch (IllegalArgumentException e) {
			Logger.getLogger("org.vectra.module").log(Level.SEVERE, "[REHASH]: "+e, e) ;
		} catch (ClassNotFoundException e) {
			Logger.getLogger("org.vectra.module").log(Level.SEVERE, "[REHASH]: "+e, e) ;
		} catch (NoSuchMethodException e) {
			Logger.getLogger("org.vectra.module").log(Level.SEVERE, "[REHASH]: "+e, e) ;
		} catch (InstantiationException e) {
			Logger.getLogger("org.vectra.module").log(Level.SEVERE, "[REHASH]: "+e, e) ;
		} catch (IllegalAccessException e) {
			Logger.getLogger("org.vectra.module").log(Level.SEVERE, "[REHASH]: "+e, e) ;
		} catch (InvocationTargetException e) {
			Logger.getLogger("org.vectra.module").log(Level.SEVERE, "[REHASH]: "+e, e) ;
		} 
    	return false ;
    }
	
	public void run () 
	{
		final int THRESHOLD = (6 * SysUtils.getAvailableCPUcores());
		int count = 0;
		try
		{
			while (true) {
				if (count++ >= THRESHOLD) {
					count = 0;
					System.gc();
				}
				// the queue will block until an event enters the queue
				final Event event = EventQueue.getEvent();
				// retrieve a list of all events of this type
                final Collection<Module> moduleList = ModuleManager.getModules() ;                
                // skip processing if there are no modules matching this event type
                if (moduleList.size() == 0)
                    continue ;         
                //try { 
                //	Logger.getLogger("org.vectra.module").log(Level.CONFIG, "[ModuleManager ["+moduleList.size()+"] Event::"+event.getEvent()+" | Message: "+event.getMessage()+"]") ;
                //} catch (UnsupportedOperationException e) {
                //	Logger.getLogger("org.vectra.module").log(Level.CONFIG, "[ModuleManager ["+moduleList.size()+"] Event::"+event.getEvent()+"]") ;
                //}
                // loop through the supplied modules - check if any match
                for (final Module module : moduleList)
                {
                	if (event.getType() != module.getType())
                		continue;
                	// Logger.getLogger("org.vectra.module").log(Level.INFO, "[DEBUG]: Trigerable="+((module.isTriggerable())?"Yes":"No")+" | Matches="+(module.matches(event)?"Yes":"No")) ;
                	// if we found a module, pass it to the thread pool
                    // and wrap it in an ModuleExecutor                	
                	if (module.isTriggerable() && module.matches(event)) {
                		final Connection connection = event.getConnection();
                		if (connection.getConfig().checkModule(module.getName()))
                			Core.passEvent(new ModuleExecutor(event, module.getInstance())) ;	
                	}
                } // for
			} // while (true)
		} catch (InterruptedException e) {			
		} finally {
			for (final Module module : ModuleManager.getModules())
				ModuleManager.removeModule(module) ;
		}
	}
}