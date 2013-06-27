package org.vectra.interfaces;

public interface Events 
{
	/**
     * Connect Event
     */
    public static final int E_CONNECT = 2 ;
    
    /**
     * Disconnect Event
     */
    public static final int E_DISCONNECT = 1 ;
    
    /**
     * Error Event
     */
    public static final int E_ERROR = 4 ;
    
    /**
     * Logon Event 
     */
    public static final int E_LOGON = 8388608 ;
    
    /**
     * Ping Event
     */
    public static final int E_PING = -2 ;
    
    /**
     * Pong Event
     */
    public static final int E_PONG = 2048 ;
        
    /**
     * Privmsg Event
     */
    public static final int E_PRIVMSG = 4096 ;
    
    /**
     * RAW Event
     */
    public static final int E_RAW = 8192 ;
    
    /**
     * Start Event
     */
    public static final int E_START = 32768 ;
}
