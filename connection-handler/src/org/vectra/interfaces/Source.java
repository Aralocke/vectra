package org.vectra.interfaces;

import java.io.Serializable;

import org.vectra.Connection;

public interface Source 
	extends Serializable
{
	public Connection getConnection () ;
}
