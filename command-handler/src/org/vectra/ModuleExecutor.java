package org.vectra;

import java.util.logging.Level;
import java.util.logging.Logger;

public class ModuleExecutor 
	implements Runnable
{
	private final Event event ;
    private final Module module ;
    
	public ModuleExecutor (final Event event, final Module module)
	{
		this.event = event ;
        this.module = module ;
	}
	
	public void run () 
		throws IllegalStateException
	{
		Thread.currentThread().setName(this.toString()) ;
		try
        {
			if (this.event == null)
				throw new IllegalStateException("Captured event cannot be null") ;
			else if (this.module == null) 
				throw new IllegalStateException("Module found to trigger for event is null") ;
			else
			{
				// Logger.getLogger("org.vectra.module").log(Level.INFO, "[EXECUTOR]: Before");
	            // Call the startup method for the module
	            this.module.beforeExecution(this.event) ;
	            // Logger.getLogger("org.vectra.module").log(Level.INFO, "[EXECUTOR]: During");
	            // Call the execution method
	            this.module.execute(this.event) ;
	            // Logger.getLogger("org.vectra.module").log(Level.INFO, "[EXECUTOR]: After");
	            // call the cleanup module
	            this.module.afterExecution(this.event) ;
			}
        } // try
        catch (Exception e) { 
        	Logger.getLogger("org.vectra.module").log(Level.SEVERE, "Exception caught in EventExecutor run(): "+e, e) ; 
        } finally  {
        	Thread.currentThread().setName("[EventExecutor Thread currently not running]") ;
        }
	}
	
	public String toString ()
    {
    	return "[EventExecutor executing module "+this.module.getName()+"(#"+this.module.getID()+")]" ;
    }
}
