package net.phantomnet.nio;

import java.net.Inet6Address;
import java.net.InetAddress;
import java.net.UnknownHostException;

public final class InetHandler {
	public static InetAddress getInetAddress(final String host, final boolean ipv6) {
		InetAddress[] addrList;
		try {
			addrList = InetAddress.getAllByName(host);
			for (InetAddress inetAddress : addrList) {
		    	if (ipv6) {
		    		if (inetAddress instanceof Inet6Address) {
		    			return inetAddress;
		    		}		    		
		    	} else {
		    		return inetAddress;
		    	}
		    }
		} catch (final UnknownHostException e) {}
		return null;
	}
}
