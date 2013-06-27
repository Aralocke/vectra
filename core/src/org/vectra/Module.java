package org.vectra;

import org.vectra.interfaces.Color;
import org.vectra.interfaces.IRCEvents;
import org.vectra.interfaces.IRCd;
import org.vectra.interfaces.ModuleTypes;
import org.vectra.interfaces.Priority;

import java.util.regex.Pattern ;

public abstract class Module 
    implements Color, IRCEvents, IRCd, ModuleTypes, Priority
{
    /** 
     * Unique module ID to identify this module 
     **/
    protected final int moduleID ;
    
    /** 
     * Package ID that this module belongs to 
     **/
    protected final int packageID ;
    
    /** 
     * The type of event that this module represents PRIVMSG, NOTICE, etc 
     **/
    protected final int moduleType ;
    
    /** 
     * For modules answering RAW's save the numeric ID 
     **/
    protected final int numeric ;
    
    /** 
     * final and unique module name 
     **/
    protected final String moduleName ;
    
    /** 
     * wild card text match 
     **/
    protected final String textMatch ;
    
    /** 
     * regex based text match for the module 
     **/
    protected final Pattern trigger ;       
    
    public Module (String name, int id, int type, int packageId, int rawNumeric)
    {
        this.moduleName = name.trim() ;
        this.moduleID = id ;
        this.moduleType = type ;
        this.packageID = packageId ;
        this.numeric = rawNumeric ;
        
        this.textMatch = null ;
        this.trigger = null ;
    }
    
    public Module (String name, int id, int type, int packageId, String matcher, boolean regex)
    {
        this.moduleName = name.trim() ;
        this.moduleID = id ;
        this.moduleType = type ;
        this.packageID = packageId ;
        this.numeric = 0 ;
       
        if (regex)
        {
                this.trigger = Pattern.compile(matcher.trim()) ;
                this.textMatch = null ;
        }
        else
        {
                this.textMatch = matcher.trim() ;
                this.trigger = null ;
        }
    }
    
    public abstract boolean matches (final Event event) ;
    public abstract void beforeExecution (Event event) ;
    public abstract void execute (Event event) ;
    public abstract void afterExecution (Event event) ;
    
    public final String getTextMatch ()
    {
    	return this.textMatch ;
    }
    
    public final Pattern getTrigger()
    {
        if (this.trigger == null)
            return null ;
        return this.trigger ;
    }
    
    public final String getName ()
    {
        return this.moduleName ;
    }
    
    public final int getID ()
    {
        return this.moduleID ;
    }
    
    public final int getNumeric ()
    {
        return this.numeric ;
    }
    
    public final int getType ()
    {
        return this.moduleType ;
    }
    
    public final boolean isTriggerable ()
    {
        return (this.trigger != null || this.textMatch != null) ;
    }
    
    public final boolean isRegexMatch ()
    {
        return (this.trigger == null) ;
    }
    
    public abstract Module getInstance() ;
}