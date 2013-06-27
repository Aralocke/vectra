package org.vectra.interfaces;

/**
 * Numerical definitions for IRC events
 */
public interface IRCEvents
	extends Events
{
    /**
     * Action Event
     */
    public static final int E_ACTION = 0 ;
    
    /**
     * Ban Event
     */
    public static final int E_BAN = 1 ;    
    
    /**
     * CTCP Event
     */
    public static final int E_CTCP = 4194304 ;
        
    /**
     * Invite Event
     */
    public static final int E_INVITE = 8 ;
        
    /**
     * Join Event
     */
    public static final int E_JOIN = 16 ;
        
    /**
     * Kick Event
     */
    public static final int E_KICK = 32 ;
        
    /**
     * Mode Event
     */
    public static final int E_MODE = 64 ;
        
    /**
     * Nick change Event
     */
    public static final int E_NICK = 128 ;
        
    /**
     * Notice Event
     */
    public static final int E_NOTICE = 256 ;
        
    /**
     * Notify Event
     */
    public static final int E_NOTIFY = 512 ;
        
    /**
     * Part Event
     */
    public static final int E_PART = 1024 ;   
    
    /**
     * QUIT Event
     */
    public static final int E_QUIT = 2097152 ;    
        
    /**
     * Server Mode Event
     */
    public static final int E_SERVERMODE = 16384 ;    
        
    /**
     * Server Notice Event
     */
    public static final int E_SNOTICE = 65536 ;
        
    /**
     * Topic Event
     */
    public static final int E_TOPIC = 131072 ;
        
    /**
     * Unban Event
     */
    public static final int E_UNBAN = 262144 ;
        
    /**
     * Un-notify Event
     */
    public static final int E_UNOTIFY = 524288 ;
        
    /**
     * User Mode Event
     */
    public static final int E_USERMODE = 1048576 ;
    
}