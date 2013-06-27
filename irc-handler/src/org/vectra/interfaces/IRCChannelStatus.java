package org.vectra.interfaces;

import java.io.Serializable;

public interface IRCChannelStatus
	extends Serializable 
{

	public static final char STATUS_ADMIN = '&' ;
	
	public static final char STATUS_HALFOP = '%' ;
	
	public static final char STATUS_OPERATOR = '@' ;
	
	public static final char STATUS_OWNER = '~' ;
	
	public static final char STATUS_REGULAR = ' ' ;
	
	public static final char STATUS_VOICE = '+' ;
}
