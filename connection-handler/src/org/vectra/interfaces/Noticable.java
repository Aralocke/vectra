package org.vectra.interfaces;

import org.vectra.interfaces.Destination;

public interface Noticable
	extends Destination
{
	public void sendNotice (final String message) 
		throws IllegalArgumentException;
    
    public void sendNotice (final String message, final byte priority) 
		throws IllegalArgumentException;
    
    public void sendNotice (final String message, final String encoding, final byte priority) 
		throws IllegalArgumentException;
}
