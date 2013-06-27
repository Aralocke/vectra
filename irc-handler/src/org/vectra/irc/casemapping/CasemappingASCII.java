package org.vectra.irc.casemapping;

import java.io.Serializable;
import java.util.Comparator;

public class CasemappingASCII
	implements Comparator<String>, Serializable
{
	private static final long serialVersionUID = 7546721930717212788L;

	public int compare(final String s1, final String s2) {
		final int n1 = s1.length(), n2 = s2.length();
		final int min = Math.min(n1,  n2) ;
		for (int i = 0; i < min; i++) {
			char c1 = s1.charAt(i), c2 = s2.charAt(i);
			if (c1 != c2) {
				c1 = Character.toLowerCase(c1);
				c2 = Character.toLowerCase(c2);
				if (c1 != c2) 
					return c1 - c2;				
			}
		}
		return n1 - n2;
	}	
}
