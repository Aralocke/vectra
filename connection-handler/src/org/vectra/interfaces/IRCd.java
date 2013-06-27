package org.vectra.interfaces;

public interface IRCd 
{
    /**
     * Use only when ircd doesn't matter
     * for example an on:text event for a module
     */
    public static final int IRCD_UNKNOWN = -1 ;
    /**
     * Unreal IRCd type server - version 3.2
     */
    public static final int UNREAL32 = 1 ;
}