package org.vectra;

import java.util.regex.Pattern;

public class SysUtils 
{
	public static final Pattern v4Matcher = Pattern.compile("(?:(?:2[0-4]\\d|25[0-5]|[01]?\\d?\\d)\\.){3}(?:2[0-4]\\d|25[0-5]|[01]?\\d?\\d)") ;
    public static boolean validIPv4 (String address)
    {
    	return v4Matcher.matcher(address).matches() ; 
    }
    
    /**
     * A convenient method that accepts an IP address represented as a
     * long and returns an integer array of size 4 representing the same
     * IP address.
     * @param address the long value representing the IP address.
     * 
     * @return An int[] of size 4.
     */
    public static int[] longToIp(long address) 
    {
        int[] ip = new int[4];
        for (int i = 3; i >= 0; i--) 
        {
            ip[i] = (int) (address % 256);
            address = address / 256;
        }
        return ip;
    }

    
    /**
     * A convenient method that accepts an IP address represented by a byte[]
     * of size 4 and returns this as a long representation of the same IP
     * address.
     *
     * @param address the byte[] of size 4 representing the IP address.
     * 
     * @return a long representation of the IP address.
     */
    public static long ipToLong(byte[] address) {
        if (address.length != 4) {
            throw new IllegalArgumentException("byte array must be of length 4");
        }
        long ipNum = 0;
        long multiplier = 1;
        for (int i = 3; i >= 0; i--) {
            int byteVal = (address[i] + 256) % 256;
            ipNum += byteVal*multiplier;
            multiplier *= 256;
        }
        return ipNum;
    } 
    
	/**
	 * 
	 * @return The number of CPU cores available to the System
	 */
	public static final int getAvailableCPUcores()
	{
		return Runtime.getRuntime().availableProcessors() ;
	}
}
