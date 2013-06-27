package org.vectra.irc;

import java.security.MessageDigest;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.regex.Pattern ;

import net.phantomnet.groupings.Pair;

public final class IRCUtils 
{
	public char intToASCII (short s) {
		if (s > 255 || s <= 0)
			throw new IllegalArgumentException("ASCII chars are 1 to 255 inclusive.");
		return (char)s;
	}
	
	public static int time ()
	{
		return (int) (System.currentTimeMillis() / 1000) ;
	}
	
	public static Date asctime (int timestamp) {
		return new Date(timestamp * 1000) ;
	}
	
	public static Date asctime (long timestamp) {
		return new Date(timestamp * 1000) ;
	}
	
	public final static String md5(String value) {
		if (value == null)
			value = "";
		try {
			final MessageDigest digest = MessageDigest.getInstance("MD5");
			final byte[] buffer = value.getBytes("UTF-8");
			final byte[] digestBuffer = digest.digest(buffer);
			return new String(digestBuffer);
		} catch (final Exception e) {
			return null;
		} 
	}
	
	public static final ArrayList<Pair<String, String>> parseToPair (final String input)
	{
		final ArrayList<Pair<String, String>> list = new ArrayList<Pair<String, String>>() ;
		final String[] parts = input.split(" ") ;		
		for (final String component : parts)
		{
			final String[] grouping = component.split("=") ;
			
			if (grouping.length == 2)
				list.add(new Pair<String, String>(grouping[0], grouping[1])) ;
			else if (grouping.length == 1 && grouping[0].length() > 1)
				list.add(new Pair<String, String>(grouping[0], null)) ;
		}	
		return list ;
	}
	
	
	public static final byte STRIP_BOLD = 1 ;
	public static final byte STRIP_UNDERLINE = 2 ;
	public static final byte STRIP_REVERSE = 4 ;
	public static final byte STRIP_COLORS = 8 ;
	public static final byte STRIP_FORMAT_CLEAR = 16 ;
	public static final byte STRIP_ALL = STRIP_BOLD | STRIP_UNDERLINE | STRIP_REVERSE | STRIP_COLORS | STRIP_FORMAT_CLEAR;
	
	private static final Pattern allCodeRemover = Pattern.compile("[\u0002\u001F\u0016\u000F]|\u0003(?:\\d{1,2}(?:,\\d{1,2})?)?");
    private static final Pattern colorCodeRemover = Pattern.compile("\u0003(?:\\d{1,2}(?:,\\d{1,2})?)?");
    
    public static final Pattern modeOffsetMatcher = Pattern.compile("^(?:[+-][a-zA-Z]+)+$");
    
    public static final String changeModes(String modeString, String modeList) {
    	if (modeList.length() == 0)
			return modeString;
		if (!modeOffsetMatcher.matcher(modeList).find())
			throw new IllegalArgumentException("modeOffset must designate a valid IRC mode offset, in the form [+mode[mode...]][-mode[mode...]]");
		if (modeString == null)
			modeString = "";
		boolean isPlus = true;
		for (int i = 0; i < modeList.length(); i++) {
			final char cur = modeList.charAt(i);
			if (cur == '+')
				isPlus = true;
			else if (cur == '-')
				isPlus = false;
			else if (isPlus) {
				if (modeString.indexOf(cur) == -1)
					modeString += Character.toString(cur);
			} else {
				final int pos = modeString.indexOf(cur);
				if (pos != -1)
					modeString = modeString.substring(0, pos) + modeString.substring(pos + 1);
			}
		}
		return modeString;
    }
    
    public static String requiredModeOffset(final String currentMode, final String wantedMode) {
		final StringBuilder plusMode = new StringBuilder();
		final StringBuilder minusMode = new StringBuilder();
		// 1. Find the characters only present in wantedMode. Those are
		// the + modes.
		for (int i = 0; i < wantedMode.length(); i++) {
			final char cur = wantedMode.charAt(i);
			if (currentMode.indexOf(cur) == -1)
				plusMode.append(cur);
		}
		// 2. Find the characters only present in currentMode. Those are
		// the - modes.
		for (int i = 0; i < currentMode.length(); i++) {
			final char cur = currentMode.charAt(i);
			if (wantedMode.indexOf(cur) == -1)
				minusMode.append(cur);
		}
		final StringBuilder result = new StringBuilder();
		if (plusMode.length() > 0) {
			result.append('+');
			result.append(plusMode);
		}
		if (minusMode.length() > 0) {
			result.append('-');
			result.append(minusMode);
		}

		return result.toString();
	}
    
    public static final List<String> parseModes(String modeString, String userModes, String channelModes) {    	
    	final List<String> parsedList = new ArrayList<String>();
    	// modes must be at least 2 chars long (the quantifier +/-
    	// followed by the mode itself
    	if (modeOffsetMatcher.matcher(modeString).matches())
    		return parsedList;    	
    	// Save the value of the modifier +/-
    	// char quantifier = modeString.charAt(0) ;
    	for (int i = 1; i < modeString.length(); i++) {
    		
    	}
    	return parsedList;
    }
    
    public static String stripCodes (String message)
    {
    	return stripCodes(message, STRIP_ALL) ;
    }
    
    public static String stripCodes(String message, final byte what) 
    {
		if ((what & STRIP_ALL) == STRIP_ALL)
			return allCodeRemover.matcher(message).replaceAll("");

		if ((what & STRIP_BOLD) == STRIP_BOLD)
			message = message.replace("\u0002", "");
		if ((what & STRIP_UNDERLINE) == STRIP_UNDERLINE)
			message = message.replace("\u001F", "");
		if ((what & STRIP_REVERSE) == STRIP_REVERSE)
			message = message.replace("\u0016", "");
		if ((what & STRIP_COLORS) == STRIP_COLORS)
			message = colorCodeRemover.matcher(message).replaceAll("");
		if ((what & STRIP_FORMAT_CLEAR) == STRIP_FORMAT_CLEAR)
			message = message.replace("\u000F", "");
		
		return message;
	}    
}
