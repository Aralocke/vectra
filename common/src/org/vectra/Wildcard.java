package org.vectra;

import java.util.regex.Pattern;

public final class Wildcard 
{
	private static final int CASE_SENSITIVE = 0 ;
	
	private static final int CASE_INSENSITIVE = Pattern.CASE_INSENSITIVE ;
	
	private boolean caseInsensitive ;
	
	private Pattern expression ;
	
	private String pattern ;
	
	public static final String REGEX_CONSTANTS = "\\^$()[]|{}.+" ;
	
	public static boolean matches (final String wildcard, final String haystack)
	{
		final Wildcard w = Wildcard.compile(wildcard) ;
		return w.matches(haystack) ;
	}
	
	public static boolean matchesIgnoreCase (final String wildcard, final String haystack)
	{
		final Wildcard w = Wildcard.compileIgnoreCase(wildcard) ;
		return w.matches(haystack) ;
	}
	
	public static Wildcard compile (final String wildcard)
	{
		final Wildcard result = new Wildcard() ;
		result.pattern = wildcard ;
		result.compile();
		return result ;
	}
	
	public static Wildcard compileIgnoreCase(final String wildcard) 
	{
		final Wildcard result = new Wildcard();
		result.pattern = wildcard;
		result.caseInsensitive = true;
		result.compile();
		return result;
	}
	
	public boolean matches (final String input)
	{
		return getExpression().matcher(input).find() ;
	}
	
	private void compile ()
	{
		// if the expression is empty, assume it will
		if (getWildcardExpression().length() == 0)
		{
			expression = Pattern.compile("^$") ;
			return ;
		}
		// We use the StringBuilder to concatenate the final
		// regex expression that will be compiled into the
		// class instance
		final StringBuilder regex = new StringBuilder() ;
		
		// starting counter
		int start = 0;
		// ending counter
		int end = getWildcardExpression().length() - 1;
		
		if (getWildcardExpression().charAt(start) == '*')
		{ // scan through finding the first non wildcard character
			for (; start < getWildcardExpression().length() && getWildcardExpression().charAt(start) == '*'; start++) ;
		} else { 
			// the first char is not a wildcard
			// therefore add a regex carrot to start the expression
			regex.append('^') ;
 		}
		
		// if the last char is not a wildcard
		// proceed to find the next one moving 
		// right to left
		if (getWildcardExpression().charAt(end) == '*') 
			for (; end >= start && getWildcardExpression().charAt(end) == '*'; end--) ;
		
		// begin parsing the input string and sanitizing it
		boolean previous = false ; // flags that the last character was a wildcard
		for (int i = start; i <= end; i++)
		{
			final char c = getWildcardExpression().charAt(i) ;
			if (c == '*') {
				if (!previous)
					regex.append(".*") ;
				previous = true ;
			} else {
				if (c == '?') {
					if (previous)
						regex.setCharAt(regex.length() - 1, '+');
					else
						regex.append('.');
				} else {
					if (REGEX_CONSTANTS.indexOf(c) != -1)
						regex.append('\\');
					regex.append(c);
				}
				previous = false;
			}
		}
		
		if ((getWildcardExpression().length() - 1) == end)
			regex.append('$');
		
		final String pattern = regex.toString() ;
		expression = Pattern.compile(pattern, getFlags()) ;
	}
	
	public Pattern getExpression()
	{
		return expression ;
	}
	
	public int getFlags ()
	{
		return (isCaseSensitive()) ? CASE_SENSITIVE : CASE_INSENSITIVE ;
	}
	
	public String getWildcardExpression()
	{
		return pattern ;
	}
	
	public boolean isCaseSensitive ()
	{
		return !caseInsensitive ;
	}
}
