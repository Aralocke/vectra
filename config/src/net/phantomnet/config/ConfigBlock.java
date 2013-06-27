package net.phantomnet.config;

import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

import org.vectra.ArrayUtils;
import org.w3c.dom.Element;
import org.w3c.dom.Node;

import net.phantomnet.config.interfaces.Named;
import net.phantomnet.config.interfaces.Parent;
import net.phantomnet.config.interfaces.Source;

public class ConfigBlock
	implements Named, Parent, Source 
{
	
	private final String name ;
	
	private final ConfigFile config ;
	
	private final ConfigBlock parent ;
	
	private final Map<String, ConfigAttribute> attributes = new HashMap<String, ConfigAttribute>();
	
	private final Collection<ConfigBlock> blocks = new LinkedList<ConfigBlock>();
	
	private final Collection<ConfigProperty> properties = new LinkedList<ConfigProperty>();
	
	public ConfigBlock(final Element root, final ConfigFile config) 
			throws IllegalArgumentException {
		this(root, null, config);
	}
	
	public ConfigBlock(final Element element, final ConfigBlock parent, final ConfigFile config) {
		if (element == null)
			throw new IllegalArgumentException("root element cannot be null");
		if (!(element.getNodeType() == Node.ELEMENT_NODE))
			throw new IllegalArgumentException("root node must be an element node ["+Node.ELEMENT_NODE+"]");
		if (config == null)
			throw new IllegalArgumentException("parent configuration cannot be null");
		this.config = config;
		// we don't check parent here because when it is null
		// it signifies that this is the root Block
		this.parent = parent;		
		this.name = element.getNodeName();
		// below here we recursively parse the config block
		// and its properties
		if (element.hasAttributes()) {
			this.attributes.putAll(ConfigFile.getAttributes(element, getSource()));
		}
		
    	// quick exit if root has no child nodes
        if (element.getChildNodes().getLength() == 0)
        	return ;
		
		 for (Node node = element.getFirstChild(); node != null;) {
        	Node nextNode = node.getNextSibling() ;
        	try {
        		if (node.getNodeType() == Node.ELEMENT_NODE) {    
        		    // check for nodes named include or define 
                    if (ConfigFile.getChildCount(node.getChildNodes()) == 0) {
                    	this.properties.add(new ConfigProperty(node, this)) ;
                    } else {
                    	this.blocks.add(new ConfigBlock((Element)node, this, config)) ;
                    }
            	}
        	} catch (final ConfigurationException e) {
        		Logger.getLogger("net.phantomnet").log(Level.WARNING, e.getMessage(), e);
        	}
        	node = nextNode ;
        }
	}
	
	public boolean containsBlock(final String name) {
		if (name == null || name.isEmpty())
			return false;
		for (final ConfigBlock block : this.blocks) 
			if (block.getName().equalsIgnoreCase(name))
				return true;
		return false;
	}
	
	public ConfigAttribute getAttribute(final String attribute) {
		if (attribute == null || attribute.isEmpty())
			return null;
		if (!hasAttributes())
			return null;
		return this.attributes.get(attribute);
	}
	
	public List<ConfigBlock> getBlocksByName(final String name) {
		final List<ConfigBlock> list = new LinkedList<ConfigBlock>();
		if (name == null || name.isEmpty())
			return list;
		for (final ConfigBlock block : this.blocks) 
			if (block.getName().equals(name))
				list.add(block);
		return list;
	}
	
	public ConfigFile getConfigFile() {
		return this.config;
	}
	
	public String getName() {
		return this.name;
	}
	
	public ConfigBlock getParent() {
		return this.parent;
	}
	
	public List<ConfigProperty> getProperties() {
		return new ArrayList<ConfigProperty>(this.properties);
	}
	
	public ConfigProperty getProperty(final String name) {
		if (name == null || name.isEmpty())
			return null;
		if (!hasProperties())
			return null;
		for (final ConfigProperty property : this.properties)
			if (property.getName().equalsIgnoreCase(name.trim()))
				return property;
		return null;
	}
	
	public String getPropertyValue(final String name) {
		final ConfigProperty property = getProperty(name);
		return (property == null) ? null : property.getValue();			
	}
	
	public String getSource() {		
		return getConfigFile().getSource();
	}
	
	public Map<String, String> getVariables() {
		return getConfigFile().getVariables();
	}
	
	public boolean hasAttributes() {
		return !(this.attributes.size() == 0);
	}
	
	public boolean hasBlocks() {
		return !(this.blocks.size() == 0);
	}
	
	public boolean hasChildren() {
		return hasBlocks();
	}
	
	public boolean hasProperties() {
		return !(this.properties.size() == 0);
	}
	
	public String toString() {
		final StringBuilder builder = new StringBuilder("[ConfigBlock ");
		builder.append(getName()+" :: ");
		if (hasAttributes()) {
			builder.append("Attributes("+this.attributes.size()+"): ");
			builder.append(ArrayUtils.implode(",", this.attributes.keySet()));
			builder.append(" ");
		}
		if (hasBlocks()) {
			builder.append("Blocks("+this.blocks.size()+"): ");
			builder.append(ArrayUtils.implode(",", this.blocks));
			builder.append(" ");
		}
		if (hasProperties()) {
			builder.append("Properties("+this.properties.size()+"): ");
			builder.append(ArrayUtils.implode(",", this.properties));
			builder.append(" ");
		}
		return builder.append("]").toString();
	}
	
	public String getString(String key) {
		if (key == null || key.isEmpty())
			return null;
		return "";
	}
	
	public int getInteger(String key) {
		if (key == null || key.isEmpty())
			return -1;
		return 0;
	}
	
	public double getDouble(String key) {
		if (key == null || key.isEmpty())
			return -1;
		return 0.0;
	}
}
