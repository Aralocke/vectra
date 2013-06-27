package org.vectra;

import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.IdentityHashMap;
import java.util.Map;
import java.util.concurrent.atomic.AtomicInteger;

public class ModuleManager 
{
	private static final AtomicInteger id = new AtomicInteger() ;
	/**
     * Maps a Module to an ID
     */
    private static final Map<Module, Integer> modules = new IdentityHashMap<Module, Integer> () ;
    
    /**
     * Maps an ID to a Module
     */
    private static final Map<Integer,Module> ids = new HashMap<Integer,Module>() ;
    
    /**
     * Object to synchronize the class on
     */
    private static final Object lock = new Object() ;
    
    public static void addModule (final Module module)
    	throws IllegalArgumentException
    {
    	if (module == null)
    		throw new IllegalArgumentException("A module cannot be null") ;
    	
    	synchronized (lock)
    	{
    		if (modules.containsKey(module))
    			throw new IllegalArgumentException("This module is already active") ;
    		if (ids.containsKey(module.getID()))
    			throw new IllegalArgumentException("The module ID is not unique and already exists as "+ids.get(module.getID()).getName()) ;
    		
    		// register the module
    		modules.put(module, module.getID()) ;
    		// register the ID
    		ids.put(module.getID(), module) ;
    	}
    }
    
    public static Module getModule (final Module module)
    	throws IllegalArgumentException
    {
    	if (module == null)
    		throw new IllegalArgumentException("Modules cannot be null") ;
    	
    	synchronized (lock) {
    		return ids.get(module.getID()) ;
    	}
    }
    
    public static Collection<Integer> getModuleIDs ()
    {
    	synchronized (lock)
    	{
    		return new ArrayList<Integer>(ids.keySet()) ;
    	}
    }
    
    public static Collection<Module> getModules ()
    {
    	synchronized (lock)
    	{
    		return new ArrayList<Module>(modules.keySet()) ;
    	}
    }
    
    public static int getNewID ()
    {
    	synchronized (lock)
    	{
    		return id.getAndIncrement() ;
    	}
    }
    
    public static void removeModule (final int id)
    	throws IllegalArgumentException
    {
    	synchronized (lock)
    	{ 		
    		final Module module = ids.get(id) ;   		
    		if (module != null)
    			removeModule(module) ;   		
    	}
    }
    
    public static void removeModule (final Module module)
    	throws IllegalArgumentException
    {
    	synchronized (lock)
    	{
        	if (module == null)
        		throw new IllegalArgumentException("Modules cannot be null") ;
        	if (! modules.containsKey(module))
    			throw new IllegalArgumentException("This module is not active") ;
    		if (! ids.containsKey(module.getID()))
    			throw new IllegalArgumentException("The module ID does not exist") ;
    		
    		// remove the module
    		modules.remove(module) ;
    		// remove the ID
    		ids.remove(module.getID()) ;
    	}
    }
}
