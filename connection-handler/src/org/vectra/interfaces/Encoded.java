package org.vectra.interfaces;

import java.io.Serializable;

public interface Encoded
	extends Serializable {
	
	public final static String DEFAULT_ENCODING = "UTF-8" ;
	
	public String getEncoding() ;
}
