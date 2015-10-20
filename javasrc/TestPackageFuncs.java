package org.victor;

import java.util.*;
import org.zkoss.zk.ui.*;
import org.zkoss.zk.ui.event.Event;
import org.zkoss.zul.*;
import java.sql.*;
import groovy.sql.*;
import javax.sql.DataSource;

/*
Purpose: Test.Package related funcs
Written by : Victor Wong
Date : 7/7/2010
Ported byte-code : 27/03/2012

Notes:
-- Check ident value
 	dbcc checkident(tbl_mqb_data_templates)
 -- Reset ident value
 	dbcc checkident(tbl_mqb_data_templates, reseed, 0)
*/

public class TestPackageFuncs extends SqlFuncs
{

public TestPackageFuncs() {}

// Database func: create a new test-package record
public final void createNewTestPackage(String itodate, String iar_code, String iusername) throws SQLException
{
	Sql sql = als_mysoftsql();
	if(sql == null) return;
	Connection thecon = sql.getConnection();
	PreparedStatement pstmt = thecon.prepareStatement("insert into TestPackages (package_name,lastupdate,deleted,ar_code,username) values (?,?,?,?,?)");
	pstmt.setString(1,"");
	pstmt.setString(2,itodate);
	pstmt.setInt(3,0);
	pstmt.setString(4,iar_code);
	pstmt.setString(5,iusername);
	pstmt.executeUpdate();
	sql.close();
}

// Database func: create a new test-package record
public final void createNewTestPackage_packname(String itodate, String iar_code, String iusername, String packagename) throws SQLException
{
	Sql sql = als_mysoftsql();
	if(sql == null) return;
	Connection thecon = sql.getConnection();
	PreparedStatement pstmt = thecon.prepareStatement("insert into TestPackages (package_name,lastupdate,deleted,ar_code,username) values (?,?,?,?,?)");
	pstmt.setString(1,packagename);
	pstmt.setString(2,itodate);
	pstmt.setInt(3,0);
	pstmt.setString(4,iar_code);
	pstmt.setString(5,iusername);
	pstmt.executeUpdate();
	sql.close();
}

// Database func: check if test-package name is uniq
public final boolean isUniqTestPackageName(String ichk) throws SQLException
{
	boolean retval = true;
	Sql sql = als_mysoftsql();
	if(sql == null) return retval;
	String sqlst = "select package_name from TestPackages where package_name='" + ichk + "'";
	GroovyRowResult therec = (GroovyRowResult)sql.firstRow(sqlst);
	if(therec != null) retval = false;
	sql.close();
	return retval;
}

// Database func: update testpackage->item
// 13/9/2010: added 2 fields, LOR and BILL
// 15/9/2010: added units field
// 03/08/2011: unitprice in testpackage_items
public final void updateTestPackage_ItemRec(String iorigid, String imysoftc, String ilor, String ibill, String iunits, String iunitprice) throws SQLException
{
	Sql sql = als_mysoftsql();
	if(sql == null ) return;
	String sqlst = "update TestPackage_Items set mysoftcode=" + imysoftc + ",lor='" + ilor + "', bill='" + ibill + "', " + 
	"units='" + iunits + "', unitprice=" + iunitprice + " where origid=" + iorigid;
	sql.execute(sqlst);
	sql.close();
}

public final void createTestPackage_ItemRec(String ipackage_id, String isorter) throws SQLException
{
	if(ipackage_id.equals("")) return;
	Sql sql = als_mysoftsql();
	if(sql == null) return;
	String sqlstatem = "insert into TestPackage_Items (mysoftcode,testpackage_id,deleted,sorter,lor,bill,units) values " + 
	"(0," + ipackage_id + ",0," + isorter + ",'','YES','')";
	sql.execute(sqlstatem);
	sql.close();
}

public final void cTestPackage_ItemRec_mysoftcode(String ipackage_id, String isorter, String imysoftc) throws SQLException
{
	if(ipackage_id.equals("")) return;
	Sql sql = als_mysoftsql();
	if(sql == null) return;
	String sqlstatem = "insert into TestPackage_Items (mysoftcode,testpackage_id,deleted,sorter,lor,bill,units) values " + 
	"(" + imysoftc + "," + ipackage_id + ",0," + isorter + ",'','YES','')";
	sql.execute(sqlstatem);
	sql.close();
}

public final void deleteTestPackage_ItemRec(String iorigid) throws SQLException
{
	Sql sql = als_mysoftsql();
	if(sql == null) return;
	String sqlstatem = "delete from TestPackage_Items where origid=" + iorigid;
	sql.execute(sqlstatem);
	sql.close();
}

}

