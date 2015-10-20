package org.victor;
import java.util.*;
import java.sql.*;
import groovy.sql.*;
import org.zkoss.zk.ui.*;
import org.victor.*;
import com.mysql.jdbc.Driver;

/**
 * SQL functions
 * @author Victor Wong
 * @since 27/09/2015
 * @notes
 *
 * Modified to be used in RLM
 *
 * String dbstring = "jdbc:jtds:sqlserver://192.168.100.201:1433/Focus50J1";
 * return(Sql.newInstance(dbstring, "testme", "9090", "net.sourceforge.jtds.jdbc.Driver"));
 */

public class SqlFuncs extends GlobalDefs
{

public final Sql rws_Sql()
{
	String dbstring = "jdbc:mysql://localhost:3306/wms";
	try { return Sql.newInstance(dbstring, "wmsuser", "1qaz", "com.mysql.jdbc.Driver"); } catch (Exception e) { return null; }
}

public final Sql DMS_Sql()
{
	try
	{
		return null;
	}
	catch (Exception e)
	{
		return null;
	}
}

public final Sql sandb_Sql()
{
	try
	{
		return null;
	}
	catch (Exception e)
	{
		return null;
	}
}

public final Sql archivedocs_Sql()
{
	try
	{
		return null;
	}
	catch (Exception e)
	{
		return null;
	}
}

public final Sql als_mysoftsql()
{
	String dbstring = "jdbc:mysql://localhost:3306/wms";
	try { return Sql.newInstance(dbstring, "wmsuser", "1qaz", "com.mysql.jdbc.Driver"); } catch (Exception e) { return null; }
}

// TODO modif this to point to MYSQL database instead
public final Sql als_DocumentStorage()
{
	try
	{
		String dbstring = "jdbc:jtds:sqlserver://" + MYSOFTDATABASESERVER + "/" + DOCUMENTSTORAGE_DATABASE;
		return(Sql.newInstance(dbstring, "sa", "sa", "net.sourceforge.jtds.jdbc.Driver"));
	}
	catch (Exception e)
	{
		return null;
	}
}

public final void gpSqlExecuter(String isqlstm) throws SQLException
{
	Sql sql = als_mysoftsql();
	if(sql == null) return;
	sql.execute(isqlstm);
	sql.close();
}

public final ArrayList gpSqlGetRows(String isqlstm) throws SQLException
{
	Sql sql = als_mysoftsql();
	if(sql == null) return null;
	ArrayList retval = (ArrayList)sql.rows(isqlstm);
	sql.close();
	return retval;
}

public final GroovyRowResult gpSqlFirstRow(String isqlstm) throws SQLException
{
	Sql sql = als_mysoftsql();
	if(sql == null) return null;
	GroovyRowResult retval = (GroovyRowResult)sql.firstRow(isqlstm);
	sql.close();
	return retval;
}

public final void rws_gpSqlExecuter(String isqlstm) throws SQLException
{
	Sql sql = rws_Sql();
	if(sql == null) return;
	sql.execute(isqlstm);
	sql.close();
}

public final ArrayList rws_gpSqlGetRows(String isqlstm) throws SQLException
{
	Sql sql = rws_Sql();
	if(sql == null) return null;
	ArrayList retval = (ArrayList)sql.rows(isqlstm);
	sql.close();
	return retval;
}

public final GroovyRowResult rws_gpSqlFirstRow(String isqlstm) throws SQLException
{
	Sql sql = rws_Sql();
	if(sql == null) return null;
	GroovyRowResult retval = (GroovyRowResult)sql.firstRow(isqlstm);
	sql.close();
	return retval;
}

public final String clobToString(Clob iwhat) throws SQLException
{
	if(iwhat == null) return "";
	String retval = iwhat.getSubString(1L,(int)iwhat.length());
	return retval;
}

// get company name based on ar_code passed
public final String getCompanyName(String tar_code) throws SQLException
{
	String retval = "-Undefined-";
	String sqlstm = "select customer_name from Customer where ar_code='" + tar_code + "'";
	GroovyRowResult therec = gpSqlFirstRow(sqlstm);
	if(therec != null) retval = (String)therec.get("customer_name");
	return retval;
}

// get company customer record from mysoft.customer based on ar_code passed
public final Object getCompanyRecord(String tar_code) throws SQLException
{
	if(tar_code == null) return null;
	String sqlstm = "select * from Customer where ar_code='" + tar_code + "'";
	GroovyRowResult therec = gpSqlFirstRow(sqlstm);
	return therec;
}

public final GroovyRowResult getMySoftMasterProductRec(String iwhich) throws SQLException
{
	String sqlstm = "select * from StockMasterDetails where ID=" + iwhich;
	GroovyRowResult retval = gpSqlFirstRow(sqlstm);
	return retval;
}

// Database func: imagemap Mapper_Pos get a rec by origid
public final GroovyRowResult getMapperPos_Rec(String iorigid) throws SQLException
{
	String sqlstm = "select * from Mapper_Pos where origid=" + iorigid;
	GroovyRowResult retval = gpSqlFirstRow(sqlstm);
	return retval;
}

// Database func: add an audit-trail into elb_SystemAudit table
public final void addAuditTrail(String ilinkcode, String iaudit_notes, String iusername, String itodaydate)
{
	Generals kiboo = new Generals();
	Sql sql = als_mysoftsql();
	if(sql == null) return;

	ilinkcode = kiboo.replaceSingleQuotes(ilinkcode);
	iaudit_notes = kiboo.replaceSingleQuotes(iaudit_notes);

	String sqlstm = "insert into elb_SystemAudit (linking_code,audit_notes,username,datecreated,deleted) values " + 
	"('" + ilinkcode + "','" + iaudit_notes + "','" + iusername + "','" + itodaydate + "',0)";

	try
	{
		sql.execute(sqlstm);
		sql.close();
	}
	catch (java.sql.SQLException e) {}
}

// Database func: just toggle elb_SystemAudit.deleted flag
public final void toggleDelFlag_AuditTrail(String iorigid, String iwhat) throws SQLException
{
	String sqlstm = "update elb_SystemAudit set deleted=" + iwhat + " where origid=" + iorigid;
	gpSqlExecuter(sqlstm);
}

// Database func: get rec from customer_emails by origid
public final GroovyRowResult getCustomerEmails_Rec(String iorigid)
{
	GroovyRowResult retval = null;
	if(iorigid.equals("")) return retval;
	Sql sql = als_mysoftsql();
    if(sql == null) return retval;

	try
	{
		String sqlstm = "select * from customer_emails where origid=" + iorigid;
		retval = (GroovyRowResult)sql.firstRow(sqlstm);
		sql.close();
	}
	catch (java.sql.SQLException e) {}
	return retval;
}

// Database func: get rec from ZeroToleranceClients by origid
public final GroovyRowResult getZTC_Rec(String iorigid)
{
	GroovyRowResult retval = null;
	if(iorigid.equals("")) return retval;
	Sql sql = als_mysoftsql();
    if(sql == null) return retval;

	try
	{
		String sqlstm = "select * from zerotoleranceclients where origid=" + iorigid;
		retval = (GroovyRowResult)sql.firstRow(sqlstm);
		sql.close();
	}
	catch (java.sql.SQLException e) {}
	return retval;
}

public final GroovyRowResult getJobSchedule_Rec(String iorigid) throws SQLException
{
	Sql sql = als_mysoftsql();
	GroovyRowResult retval = null;
	if(sql == null ) return retval;
	String sqlstm = "select * from elb_jobschedules where origid=" + iorigid;
	retval = (GroovyRowResult)sql.firstRow(sqlstm);
	sql.close();
	return retval;
}

public final GroovyRowResult getChecklist_Rec(String iorigid) throws SQLException
{
	Sql sql = als_mysoftsql();
	GroovyRowResult retval = null;
	if(sql == null ) return retval;
	String sqlstm = "select * from elb_checklist where origid=" + iorigid;
	retval = (GroovyRowResult)sql.firstRow(sqlstm);
	sql.close();
	return retval;
}

public final GroovyRowResult getChecklistTemplate_Rec(String iorigid) throws SQLException
{
	String sqlstm = "select * from elb_checklist_templates where origid=" + iorigid;
	GroovyRowResult retval = gpSqlFirstRow(sqlstm);
	return retval;
}

public final GroovyRowResult getFormKeeper_rec(String iwhat) throws SQLException
{
	String sqlstm = "select * from elb_FormKeeper where origid=" + iwhat;
	GroovyRowResult retval = gpSqlFirstRow(sqlstm);
	return retval;
}

/*
public final int getWeekOfMonth(String thedate)
{
	String sqlstm = "SELECT CAST( (DATEPART(WEEK, '" + thedate + "') - DATEPART(WEEK, DATEADD(MM, " + 
	"DATEDIFF(MM,0,'" + thedate + "'), 0))+ 1) AS INT) AS WEEK_OF_MONTH";

	GroovyRowResult krr = gpSqlFirstRow(sqlstm);
	if(krr == null) return -1;
	int rt = krr.get("WEEK_OF_MONTH");

	return rt;
}
*/

}

