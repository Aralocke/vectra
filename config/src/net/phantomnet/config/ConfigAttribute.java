package net.phantomnet.config;

import java.io.File;

import net.phantomnet.config.interfaces.Named;
import net.phantomnet.config.interfaces.Source;

public class ConfigAttribute
	implements Named, Source {
	
	private final String name ;
	private final String source;
	private final String value ;
	
	public ConfigAttribute(final String name, final String value, final String source) 
		throws IllegalArgumentException {
		if (name == null || name.isEmpty())
			throw new IllegalArgumentException("Supplied element name is null or length zero");
		if (value == null || value.isEmpty())
			throw new IllegalArgumentException("Supplied element value is null or length zero");
		if (source == null || source.isEmpty())
			throw new IllegalArgumentException("Supplied element source is null or length zero");
		
		this.name = name.trim();
		this.value = value.trim();
		this.source = source.trim();
	}
	
	public String getFileName() {
		return new File(getSource()).getName();
	}
	
	public String getName() {
		return this.name;
	}

	public String getSource() {
		return this.source;
	}	
	
	public String getValue() {
		return this.value;
	}
}
