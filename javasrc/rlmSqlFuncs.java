package org.victor;
import java.util.*;
import java.sql.*;
import groovy.sql.*;
import org.zkoss.zk.ui.*;
import org.victor.*;
import com.mysql.jdbc.Driver;

public class rlmSqlFuncs extends GlobalDefs
{
	public final Sql rlm_Sql()
	{
		/*
			String dbstring = "jdbc:jtds:sqlserver://192.168.100.201:1433/Focus50J1";
			return(Sql.newInstance(dbstring, "testme", "9090", "net.sourceforge.jtds.jdbc.Driver"));
		 */
		String dbstring = "jdbc:mysql://localhost:3306/wms";
		try { return Sql.newInstance(dbstring, "wmsuser", "1qaz", "com.mysql.jdbc.Driver"); } catch (Exception e) { return null; }
	}
}