package org.vectra.irc;

import java.util.concurrent.locks.ReadWriteLock;
import java.util.concurrent.locks.ReentrantReadWriteLock;

import org.vectra.exceptions.UnknownUserException;

public class IRCChannelUser
	extends IRCUser {

	private static final long serialVersionUID = 7235641089973848940L;
	
	private String modeList = "";	
	
	private final IRCChannel parent ;
	
	private final ReadWriteLock lock = new ReentrantReadWriteLock(true);
	
	public IRCChannelUser(final IRCUser user, final IRCChannel channel) 
			throws IllegalArgumentException, UnknownUserException {
		this(user.getAddress(5), channel);
	}

	public IRCChannelUser(final String address, final IRCChannel parent)
			throws UnknownUserException, IllegalArgumentException {
		this(address, "", parent);
	}
	
	public IRCChannelUser(final String address, final String modes, final IRCChannel parent)
			throws UnknownUserException, IllegalArgumentException {
		super(address, parent.getConnection());
		
		if (modes == null)
			throw new IllegalArgumentException("Supplied mode string may be an empty String, but not null");
		this.parent = parent;
		this.modeList = modes;
	}
	
	public IRCChannel getChannel() {
		return this.parent;
	}
	
	public String getModes() {
		this.lock.readLock().lock();
		try {
			return this.modeList;
		} finally {
			this.lock.readLock().unlock();
		}
	}
	
	public boolean isOp() {
		return isModeOver('o');
	}
	
	public boolean isVoice() {
		return isModeOver('v');
	}
	
	public boolean isHalfop() {
		return isModeOver('h');
	}
	
	public boolean isAdmin() {
		return isModeOver('a');
	}
	
	public boolean isOwner() {
		return isModeOver('q');
	}
	
	public boolean isModeOver(final char mode) {
		final String channelModes = getModes();
		
		if (channelModes == null || channelModes.length() == 0)
			return false;
		final String modes = getConnection().getIRCConfig().getChannelStatusModes();
		for (int i = 0; i < modes.length(); i++) {
			if (channelModes.indexOf(modes.charAt(i)) != -1)
				return true;
			if (modes.charAt(i) == mode)
				return false;
		}
		return false;
	}
	
	public void setModes(final String modes) {
		getLock().writeLock().lock();
		try {
			this.modeList = modes.trim();
		} finally {
			getLock().writeLock().unlock();
		}
	}
	
	public String statusPrefix() {
		final String channelModes = getModes();
		if (channelModes == null || channelModes.length() == 0)
			return "";
		return getConnection().getIRCConfig().parseChannelStatusPrefixes(channelModes);
	}
}
