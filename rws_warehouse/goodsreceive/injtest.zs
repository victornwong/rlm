
import java.util.*;
import java.text.*;
import java.sql.Connection;
import java.sql.DriverManager;
import javax.sql.DataSource;
import groovy.sql.Sql;
import org.zkoss.zk.ui.*;
import org.victor.*;

<<<<<<< HEAD
=======
/**
 * Extracted from SQL stored-functions
 * @param  dstr the date string to convert into FOCUS date format
 * @return      FOCUS int date format
 */
>>>>>>> a6b1f79d9714daf1f39e4dc0123982ab2764be5e
int calcFocusDate(String dstr)
{
	java.util.Calendar thedate = Calendar.getInstance();
	thedate.setTime(GlobalDefs.dtf2.parse(dstr));
	// ((2014-1950)*416) + ((9*32)+1) + (18 - 1);
<<<<<<< HEAD
	//alert("year=" + thedate.get(Calendar.YEAR).toString() + "\nmonth=" + thedate.get(Calendar.MONTH).toString() +
	//"\nday=" + thedate.get(Calendar.DAY_OF_MONTH).toString());
=======
>>>>>>> a6b1f79d9714daf1f39e4dc0123982ab2764be5e
	retval = ((thedate.get(Calendar.YEAR)-1950)*416) + ((thedate.get(Calendar.MONTH)+1)*32) + (thedate.get(Calendar.DAY_OF_MONTH));
	return retval;
}

Sql FC5030_Sql()
{
	try
	{
<<<<<<< HEAD
		String dbstring = "jdbc:jtds:sqlserver://192.168.100.201:1433/Focus5010";
=======
		String dbstring = "jdbc:jtds:sqlserver://192.168.100.201:1433/Focus50J0";
>>>>>>> a6b1f79d9714daf1f39e4dc0123982ab2764be5e
		return(Sql.newInstance(dbstring, "testme", "9090", "net.sourceforge.jtds.jdbc.Driver"));
	}
	catch (SQLException e)
	{
<<<<<<< HEAD
		alert("f5030 error!");
=======
		alert("f50J0 error!");
>>>>>>> a6b1f79d9714daf1f39e4dc0123982ab2764be5e
		return null;
	}
}

void f30_gpSqlExecuter(String isqlstm) throws SQLException
{
	Sql sql = FC5030_Sql();
	if(sql == null) return;
	sql.execute(isqlstm);
	sql.close();
}

ArrayList f30_gpSqlGetRows(String isqlstm) throws SQLException
{
	Sql sql = FC5030_Sql();
	if(sql == null) return null;
	ArrayList retval = (ArrayList)sql.rows(isqlstm);
	sql.close();
	return retval;
}

GroovyRowResult f30_gpSqlFirstRow(String isqlstm) throws SQLException
{
	Sql sql = FC5030_Sql();
	if(sql == null) return null;
	GroovyRowResult retval = (GroovyRowResult)sql.firstRow(isqlstm);
	sql.close();
	return retval;
}

//----SQL functions for 0J0 ------------------------

Sql FC50J0_Sql()
{
	try
	{
		String dbstring = "jdbc:jtds:sqlserver://192.168.100.201:1433/Focus50J0";
		return(Sql.newInstance(dbstring, "testme", "9090", "net.sourceforge.jtds.jdbc.Driver"));
	}
	catch (SQLException e)
	{
		alert("f50J0 error!");
		return null;
	}
}

void fj0_gpSqlExecuter(String isqlstm) throws SQLException
{
	Sql sql = FC50J0_Sql(); if(sql == null) return;
	sql.execute(isqlstm);
	sql.close();
}

ArrayList fj0_gpSqlGetRows(String isqlstm) throws SQLException
{
	Sql sql = FC50J0_Sql(); if(sql == null) return null;
	ArrayList retval = (ArrayList)sql.rows(isqlstm);
	sql.close();
	return retval;
}

GroovyRowResult fj0_gpSqlFirstRow(String isqlstm) throws SQLException
{
	Sql sql = FC50J0_Sql(); if(sql == null) return null;
	GroovyRowResult retval = (GroovyRowResult)sql.firstRow(isqlstm);
	sql.close();
	return retval;
}

