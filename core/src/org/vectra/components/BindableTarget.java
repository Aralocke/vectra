package org.vectra.components;

import java.io.Serializable;

import org.vectra.SystemConfig;

public final class BindableTarget
	implements Serializable {

	private static final long serialVersionUID = 7323270737880971758L;

	private final String iface;
	
	public BindableTarget(final String iface) {
		if (iface == null || iface.isEmpty())
			throw new IllegalArgumentException("interface cannot be null");
		this.iface = iface.trim();
	}
	
	public String getInterface() {
		return this.iface;
	}
	
	public boolean isValid() {
		return SystemConfig.getNetworkInterfaces().contains(this.iface);
	}
	
	public String toString() {
		return "[BindableTarget ("+(isValid()?"Usable":"Not Usable")+") "+this.iface+"]";
	}
}
