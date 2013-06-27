package org.vectra;

import java.util.ArrayList;
import java.util.List;

public class StrUtils 
{
	/**
	 * Case insensitive matching flag
	 */
	public static final byte CASE_INSENSITIVE = 1 ;
	
	/**
	 * Case sensitive matching flag
	 */
	public static final byte CASE_SENSITIVE = 2 ;	
	
	public static List<String> split(final String input, final char delimiter)
	{
		return split(input, delimiter, false) ;
	}
	
	public static List<String> split(final String input, final char delimiter, final boolean emptyTokens) 
	{
		final ArrayList<String> list = new ArrayList<String>() ;
		if (input == null || input.length() < 1)
			return list ;
		
		int currentChar = 0;
		int nextChar = input.indexOf(delimiter) ;
		while (nextChar > 0)
		{
			if (input.charAt(currentChar) != delimiter)
				list.add(input.substring(currentChar, nextChar));
			else if (emptyTokens)
				list.add("");
			currentChar = nextChar;
			currentChar++;
			nextChar = input.indexOf(delimiter, currentChar);
		}
		if (emptyTokens && currentChar == input.length()) 			
			list.add("");
    	else
			list.add(input.substring(currentChar));
		return list ;
	}
	
	public static List<String> split(final String input, final char delimiter, final int maxTokens) 
	{
		return split(input, delimiter, maxTokens, false) ;
	}
	
	public static List<String> split(final String input, final char delimiter, final int maxTokens, final boolean emptyTokens) 
	{
		if (maxTokens <= 0)
			return split(input, delimiter, emptyTokens) ;

		final ArrayList<String> list = new ArrayList<String>() ;
		if (input == null || input.length() < 1)
			return list ;
		
		int currentChar = 0;
		int nextChar = input.indexOf(delimiter) ;
		while (nextChar > 0)
		{
			if (input.charAt(currentChar) != delimiter)
			{
				if (list.size() == maxTokens - 1) {
					list.add(input.substring(currentChar));
					return list;
				}
				list.add(input.substring(currentChar, nextChar));
			}
			else if (emptyTokens)
			{
				if (list.size() == maxTokens - 1) {
					list.add(input.substring(currentChar));
					return list;
				}
				list.add("");
			}
			currentChar = nextChar;
			currentChar++;
			nextChar = input.indexOf(delimiter, currentChar);
		}
		if (emptyTokens && currentChar == input.length()) 			
			list.add("");
    	else
			list.add(input.substring(currentChar));
		return list ;
	}
}
