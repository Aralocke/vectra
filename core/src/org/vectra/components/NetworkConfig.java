package org.vectra.components;

import java.net.Inet6Address;
import java.net.InetAddress;
import java.net.UnknownHostException;
import java.util.ArrayList;
import java.util.List;

import net.phantomnet.config.interfaces.Named;

public final class NetworkConfig
	implements Named {
	
	private final String name ;
	private short sessionLimit;
	private final ArrayList<String> servers = new ArrayList<String>(1);
	
	public NetworkConfig(final String name) {
		this(name, 3);
	}
	
	public NetworkConfig(final String name, final int sessionLimit) {
		if (name == null || name.isEmpty())
			throw new IllegalArgumentException("name cannot be null or empty");
		if (sessionLimit < 1 || sessionLimit > 10)
			throw new IllegalArgumentException("invalid session limit range");
		this.name = name.trim();
		this.sessionLimit = (short)sessionLimit;
	}
	
	public void addServer(final String server)
			throws IllegalArgumentException, UnknownHostException  {
		addServer(server, false);
	}
	
	public void addServer(final String server, final boolean ipv6)
			throws IllegalArgumentException, UnknownHostException {
		if (server == null || server.isEmpty())
			throw new IllegalArgumentException("server cannot be null or empty");
		
		final InetAddress address;
		if (ipv6) {
			address = Inet6Address.getByName(server);
		} else {
			address = InetAddress.getByName(server);
		}
		
		this.servers.add(address.getHostAddress());		
	}
	
	public String getName() {
		return this.name;
	}
	
	public List<String> getServers() {
		return new ArrayList<String>(this.servers);
	}
	
	public int getSessionLimit() {
		return this.sessionLimit;
	}	
}
