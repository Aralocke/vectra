package org.vectra.interfaces;

import org.vectra.interfaces.Destination;

public interface Actionable 
	extends Destination
{
    /**
     * Send an action to the user
     * 
     * @param action The message to be sent to the user
     * @throws IllegalArgumentException A message cannot be null or length zero
     */
    public void sendAction (final String action) 
    	throws IllegalArgumentException;
    
    /**
     * Sends an action to the user.
     *
     * @param action The action to send.
     * @param encoding String encoding type. This is supplied by the IRCevent
     *                 which triggered the calling of this method
     * @throws IllegalArgumentException
     */
    public void sendAction (final String action, final byte priority) 
		throws IllegalArgumentException;
    
    public void sendAction (final String action, final String encoding, final byte priority) 
    	throws IllegalArgumentException;
    
    /**
     * Sends a CTCP command to a channel or user.  (Client to client protocol).
     * 
     * Messages are sent at a default NORMAL priority
     * 
     * @param command The CTCP command to send.
     * @throws IllegalArgumentException
     */
    public void sendCTCPCommand (final String command) 
		throws IllegalArgumentException;
    
    /**
     * Sends a CTCP command to a channel or user.  (Client to client protocol).
     * 
     * @param command The CTCP command to send.
     * @param priority The priority with which a message is sent to the server
     * @throws IllegalArgumentException
     */
    public void sendCTCPCommand (final String command, final byte priority) 
		throws IllegalArgumentException;  
    
    public void sendCTCPCommand (final String command, final String encoding, final byte priority) 
    	throws IllegalArgumentException; 
}
