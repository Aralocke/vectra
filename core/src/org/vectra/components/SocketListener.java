package org.vectra.components;

import java.net.Socket;

public class SocketListener {
	private String listener;
	private Socket socket;
	
	public SocketListener(final Socket listener) {
		this.socket = listener;
	}
	
	public String getListener() {
		return this.listener;
	}
	
	public Socket getSocket() {
		return this.socket;
	}
}
