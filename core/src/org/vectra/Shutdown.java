package org.vectra;

public class Shutdown
	implements Runnable
{
	public void run () 
	{
		System.out.println("Beginning thread shutdown sequence") ;
	}
}