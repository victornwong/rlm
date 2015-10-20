package org.victor;

/*
File: Documents table funcs
Written by: Victor Wong
Dated: 03/04/2012
Notes: Ported funcs from doculink_funcs.zs - compile byte-codes

*/

import java.util.*;
import java.sql.*;
import groovy.sql.*;
import org.victor.*;

public class DocuFuncs extends SqlFuncs
{
// Database func: return the complete rec from DocumentTable - including blob
public final GroovyRowResult getLinkingDocumentRec(String iorigid) throws SQLException
{
	GroovyRowResult retval = null;
	Sql ds_sql = als_DocumentStorage();
	if(ds_sql == null) return retval;
	String sqlstat = "select * from DocumentTable where origid=" + iorigid;
	retval = (GroovyRowResult)ds_sql.firstRow(sqlstat);
	ds_sql.close();
	return retval;
}

// Database func: return the metadata from DocumentTable.. no need to return the blob
public final GroovyRowResult getLinkingDocumentMetadataRec(String iorigid) throws SQLException
{
	GroovyRowResult retval = null;
	Sql ds_sql = als_DocumentStorage();
	if(ds_sql == null) return retval;
	String sqlstat = "select origid,file_title,file_description,docu_link,docu_status,username,datecreated,version from DocumentTable where origid=" + iorigid;
	retval = (GroovyRowResult)ds_sql.firstRow(sqlstat);
	ds_sql.close();
	return retval;
}

public final void toggleDocument_DeleteFlag(String iorigid) throws SQLException
{
	GroovyRowResult docrec = getLinkingDocumentRec(iorigid);
	if(docrec == null) return;

	String delflag = ((Integer)docrec.get("deleted") == 0) ? "1" : "0";

	Sql ds_sql = als_DocumentStorage();
	if(ds_sql == null) return;

	String sqlst = "update DocumentTable set deleted=" + delflag + " where origid=" + iorigid;
	ds_sql.execute(sqlst);
	ds_sql.close();
}

public final void deleteDocument_Rec(String iorigid) throws SQLException
{
	Sql ds_sql = als_DocumentStorage();
	if(ds_sql == null) return;
	String sqlst = "delete from DocumentTable where origid=" + iorigid;
	ds_sql.execute(sqlst);
	ds_sql.close();
}

public final void updateDocument_Rec(String iorigid, String ifiletitle, String ifiledesc, String idocustatus) throws SQLException
{
	Sql ds_sql = als_DocumentStorage();
	if(ds_sql == null) return;

	Connection thecon = ds_sql.getConnection();
	PreparedStatement pstmt = thecon.prepareStatement("update DocumentTable set file_title=? , file_description=? , docu_status = ? where origid=?");

	pstmt.setString(1,ifiletitle);
	pstmt.setString(2,ifiledesc);
	pstmt.setString(3,idocustatus);
	pstmt.setString(4,iorigid);

	pstmt.executeUpdate();
	ds_sql.close();
}

}

