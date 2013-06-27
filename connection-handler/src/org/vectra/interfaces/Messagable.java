package org.vectra.interfaces;

import org.vectra.interfaces.Destination ;

public interface Messagable
	extends Destination
{
	public void sendMessage (final String message) 
		throws IllegalArgumentException;    
    
    public void sendMessage (final String message, final byte priority) 
		throws IllegalArgumentException;
    
    public void sendMessage (final String message, final String encoding, final byte priority) 
		throws IllegalArgumentException;
}
