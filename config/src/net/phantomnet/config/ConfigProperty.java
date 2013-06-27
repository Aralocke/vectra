package net.phantomnet.config;

import java.util.HashMap;
import java.util.Map;

import org.w3c.dom.Node;

import net.phantomnet.config.interfaces.Named;
import net.phantomnet.config.interfaces.Source;

public class ConfigProperty
	implements Named, Source {
	
	private final String name;
	private final ConfigBlock parent;
	private final Map<String, ConfigAttribute> attributes = new HashMap<String, ConfigAttribute>();
	private final String value;

	public ConfigProperty (final Node node, final ConfigBlock parent) 
			throws ConfigurationException 
	{
		if (node == null)
			throw new IllegalArgumentException("supplied node cannot be null");
		if (!(node.getNodeType() == Node.ELEMENT_NODE))
			throw new IllegalArgumentException("The supplied node must be an Element node");
		if (parent == null)
			throw new IllegalArgumentException("Supplied parent cannot be null");
		
		this.parent = parent;
		this.name = node.getNodeName();
		this.value = ConfigProperty.parse(ConfigFile.getNodeValue(node), parent.getVariables()) ;
		
		if (node.hasAttributes()) {
			this.attributes.putAll(ConfigFile.getAttributes(node, getSource()));
		}
	}
	
	public Map<String, ConfigAttribute> getAttributes() {
		return this.attributes;
	}
	
	public double getDouble() {
		try {
			return Double.parseDouble(getString());
		} catch (Exception e) {
			return 0.0;
		}
	}

	public int getInteger() {
		try {
			return Integer.parseInt(getString());
		} catch (Exception e) {
			return 0;
		}
	}

	public String getSource() {
		return getParent().getSource();
	}

	public String getName() {
		return this.name;
	}
	
	public ConfigBlock getParent() {
		return this.parent;
	}
	
	public String getString() {
		return getValue();
	}

	public String getValue() {
		return this.value;
	}

	public Map<String, String> getVariables() {
		return getParent().getVariables();
	}
	
	public String toString() {
		return getName();
	}
	
	public static final String parse(String value, final Map<String, String> variables) 
			throws ConfigurationException 
	{
		if (value == null)
			return "";
		if (variables.size() == 0)
			return value;
		final String originalValue = value.trim();
		final StringBuilder variableBuilder = new StringBuilder();
		boolean parsing = false;
		for (int i = 0; i < value.length(); i++) {
			final char c = value.charAt(i);
			// begin parsing
			if (c == '{') {
				if (parsing) {
					// we encountered a variable inside a variable
					throw new ConfigurationException("Unknown char '{' at position "+i+" for value "+originalValue);
				} else {
					parsing = true;
				}
			} else if (c == '}') {
				if (parsing) {
					parsing = false;
					// we're done parsing - check for a value
					// if so replace it with a variable reference
					final String variable = variableBuilder.toString();
					final String definition = variables.get(variable);
					if (definition == null) {
						// undefined variable
						// remove the {__VARIABLE__}
						value = value.substring(0, value.indexOf('{'))+value.substring(value.indexOf('}'));
					} else {
						// remove the {__VARIABLE__} and replace with the difinition
						value = value.substring(0, value.indexOf('{')).trim()+""+definition+""+value.substring(value.indexOf('}')+1);
					}
					// after wards clean the variable builder
					variableBuilder.delete(0, variable.length());
				} else {
					// we encountered an illegal char '}'
					throw new ConfigurationException("Unknown char '}' at position "+i+" for value "+originalValue);
				}
			} else {
				// not a '{' or '}'
				variableBuilder.append(c);
			}
		}
		return value;
	}
}
