package org.vectra.irc.casemapping;

import java.io.Serializable;
import java.util.Comparator;

public class CasemappingStrictRFC1459 implements Comparator<String>, Serializable {
	private static final long serialVersionUID = 1L;

	public int compare(final String s1, final String s2) {
		final int n1 = s1.length();
		final int n2 = s2.length();
		final int min = Math.min(n1, n2);
		for (int i = 0; i < min; i++) {
			char c1 = s1.charAt(i), c2 = s2.charAt(i);
			if (c1 != c2) {
				c1 = Character.toLowerCase(c1);
				c2 = Character.toLowerCase(c2);
				if (c1 != c2) {
					c1 = additionalLowerCase(c1);
					c2 = additionalLowerCase(c2);
					if (c1 != c2) {
						return c1 - c2;
					}
				}
			}
		}
		return n1 - n2;
	}

	private static char additionalLowerCase(final char c) {
		switch (c) {
		case '[':
			return '{';
		case ']':
			return '}';
		case '\\':
			return '|';
		default:
			return c;
		}
	}
}