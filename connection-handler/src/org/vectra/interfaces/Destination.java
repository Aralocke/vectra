package org.vectra.interfaces;

import java.io.Serializable;

import org.vectra.Connection;

public interface Destination
	extends Serializable
{
	public Connection getConnection () ;
}
