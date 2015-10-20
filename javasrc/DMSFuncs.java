package org.victor;

import java.util.*;
import java.io.*;
import java.sql.*;
import groovy.sql.*;
import org.zkoss.zk.ui.*;
import org.zkoss.zul.*;
import org.zkoss.util.*;
import org.victor.*;

public class DMSFuncs extends SqlFuncs
{
	private GuiFuncs guihand;
	
	public DMSFuncs()
	{
		guihand = new GuiFuncs();
	}

// DBFunc: insert new directory into folderstructure
public final boolean insertNewDirectory(String iname, String imyparent, String idate, userAccessObj useraccessobj_tmp) throws SQLException
{
	Sql sql = DMS_Sql();
	if(sql == null) return false;
	String sqlstm = "insert into folderstructure (folderid,datecreated,folderstatus,folderparent,folder_desc," + 
	"username,minlevelaccess,deleted,search_keywords) " +
	"values ('" + iname + "','" + idate + "','ACTIVE'," + imyparent + ",'','" + useraccessobj_tmp.username + "',1,0,'')";
	sql.execute(sqlstm);
	sql.close();
	return true;
}

// DBFunc: get directory rec from folderstructure
public final GroovyRowResult getDirectoryRec(String iorigid) throws SQLException
{
	Sql sql = DMS_Sql();
	if(sql == null) return null;
	String sqlstm = "select * from folderstructure where origid=" + iorigid;
	GroovyRowResult retval = (GroovyRowResult)sql.firstRow(sqlstm);
	sql.close();
	return retval;
}

// DBFunc: check if there's a branch attached to folder-rec
public final boolean existBranch(String iorigid) throws SQLException
{
	boolean retval = false;
	Sql sql = DMS_Sql();
	if(sql == null) return retval;
	String sqlstm = "select top 1 origid from folderstructure where folderparent=" + iorigid;
	GroovyRowResult trec = (GroovyRowResult)sql.firstRow(sqlstm);
	sql.close();
	if(trec != null) retval = true;
	return retval;
}

// knockoff from doculink_funcs.zs - modded to work on different db
// To store uploaded file into database.
// params: iusername, ibranch - from useraccessobj, to have an owner to document
//		idocdate = document upload date - should be today
//		doculink_str = document id prefix + whatever
//		docustatus_str = active,expired or whatever.. can be def in drop-down
public final boolean uploadFile(String iusername, String ibranch, String idocdate, String doculink_str,
	String docustatus_str,String ftitle, String fdesc) throws SQLException,InterruptedException,IOException
{
	org.zkoss.util.media.Media uploaded_file = org.zkoss.zul.Fileupload.get(true);
	
	if(uploaded_file == null) return false;
	
	String formatstr = uploaded_file.getFormat();
	String contenttype = uploaded_file.getContentType();
	String ufilename = uploaded_file.getName();
	
	Object uploaded_data;
	int fileLength = 0;
	
	boolean f_inmemory = uploaded_file.inMemory();
	boolean f_isbinary = uploaded_file.isBinary();
	
	if(f_inmemory && f_isbinary)
	{
		byte[] tmp_uploaded_data = uploaded_file.getByteData();
		uploaded_data = tmp_uploaded_data;
	}
	else
	{
		InputStream tmp_uploaded_data = uploaded_file.getStreamData();
		fileLength = tmp_uploaded_data.available();
		uploaded_data = tmp_uploaded_data;
	}

	if(uploaded_data == null)
	{
		guihand.showMessageBox("Invalid file-type uploaded..");
		return false;
	}

	// alert("formatstr: " + formatstr + " | contenttype: " + contenttype + " | filename: " + ufilename);

	Sql ds_sql = DMS_Sql();
	if(ds_sql == null) return false;
	Connection thecon = ds_sql.getConnection();

	PreparedStatement pstmt = thecon.prepareStatement("insert into DocumentTable(file_title,file_description,docu_link,docu_status,username,datecreated,version," +
		"file_name,file_type,file_extension,file_data,deleted,branch) values (?,?,?,?,?,?,?,?,?,?,?,?,?)");

	pstmt.setString(1, ftitle);
	pstmt.setString(2, fdesc);
	pstmt.setString(3, doculink_str);
	pstmt.setString(4, docustatus_str);
	pstmt.setString(5, iusername);
	pstmt.setString(6,idocdate);
	pstmt.setInt(7,1);
	pstmt.setString(8,ufilename);
	pstmt.setString(9,contenttype);
	pstmt.setString(10,formatstr);

	if(f_inmemory && f_isbinary)
		pstmt.setBytes(11, (byte[])uploaded_data);
	else
		pstmt.setBinaryStream(11, (InputStream)uploaded_data, fileLength);

	pstmt.setInt(12,0); // deleted flag
	pstmt.setString(13, ibranch);

	pstmt.executeUpdate();
	ds_sql.close();

	return true;
}

public final void showSubdirectoryTree(String parentname, Tree thetree) throws SQLException
{
	// Clear any child attached to tree before updating new ones.
	Treechildren tocheck = thetree.getTreechildren();
	if(tocheck != null) tocheck.setParent(null);

	// create a new treechildren for the tree
	Treechildren mychildrens = new Treechildren();
	mychildrens.setParent(thetree);
	//subdirectory_tree.setRows(20);
	thetree.setRows(20);
	DirectoryTree incd_lookuptree = new DirectoryTree(mychildrens,parentname);
}

public final boolean directoryExistFiles(String iorigid) throws SQLException
{
	String doculink = "FS" + iorigid;
	Sql sql = DMS_Sql();
	if(sql == null) return false;
	String sqlstm = "select top 1 origid from DocumentTable where docu_link='" + doculink + "'";
	GroovyRowResult trec = (GroovyRowResult)sql.firstRow(sqlstm);
	sql.close();
	return (trec != null) ? true : false;
}

public final void dmsgpSqlExecuter(String isqlstm) throws SQLException
{
	Sql sql = DMS_Sql();
	if(sql == null) return;
	sql.execute(isqlstm);
	sql.close();
}

public final ArrayList dmsgpSqlGetRows(String isqlstm) throws SQLException
{
	Sql sql = DMS_Sql();
	if(sql == null) return null;
	ArrayList retval = (ArrayList)sql.rows(isqlstm);
	sql.close();
	return retval;
}

public final GroovyRowResult dmsgpSqlFirstRow(String isqlstm) throws SQLException
{
	Sql sql = DMS_Sql();
	if(sql == null) return null;
	GroovyRowResult retval = (GroovyRowResult)sql.firstRow(isqlstm);
	sql.close();
	return retval;
}


}

