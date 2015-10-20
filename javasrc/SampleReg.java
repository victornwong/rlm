package org.victor;

import java.util.*;
import java.text.*;
import java.io.*;
import org.zkoss.zk.ui.*;
import org.zkoss.zul.*;
import java.sql.*;
import javax.sql.*;
import groovy.sql.*;
import org.victor.*;

/*
Purpose: Sample registration general purpose funcs
Written by : Victor Wong
Date : 11/08/2009

Notes:
29/6/2010: JOBFOLDERS_TABLE , JOBSAMPLES_TABLE and others def in alsglobal_sqlfuncs.zs

Chop off ALSM(def in alsglobaldefs.zs) from the folder/job ID, eg ALSMXXXXX
It will return from position 4 till end. Do not use this for full sample ID, eg ALSM0000100010 , it will return 0000100010
use the other function

16/03/2012: ported to be compiled into byte-codes

*/

public class SampleReg extends GlobalDefs
{
	private SqlFuncs sqlhand;
	private Generals kiboo;
	private ListboxHandler lbhandler;

public SampleReg()
{
	sqlhand = new SqlFuncs();
	kiboo = new Generals();
	lbhandler = new ListboxHandler();
}

public final String extractFolderNo(String iwhich)
{
	String retval = "";
	if(!iwhich.equals("")) retval = iwhich.substring(4,9);
	return retval;
}

// ALSM0000100010 -> returns 00001
public final String extractFolderNo_FromSampleID(String iwhich)
{
	String retval = "";
	if(!iwhich.equals("") && iwhich.length() == 14) retval = iwhich.substring(4,9);
	return retval;
}

// ALSM000010010 -> returns ALSM00001
public final String extractFolderString_FromSampleID(String iwhich)
{
	String retval = "";
	if(!iwhich.equals("") && iwhich.length() > 8) retval = iwhich.substring(0,9);
	return retval;
}

// chop out sample number . eg. ALSM0000100001 -> last 00001
// NOTES: if sample number increase to 6 digits.. change accordingly for substring(9,15) = 100000
public final String extractSampleNo(String iwhich)
{
	String retval = "";
	//if(!iwhich.equals("")) retval = Integer.parseInt(iwhich.substring(9,14)).toString();
	if(!iwhich.equals(""))
	{
		// 10/03/2011: to cater for 6 digits sample-id
		if(iwhich.length() > 14)
			retval = String.valueOf(iwhich.substring(9,15));
		else
			retval = String.valueOf(iwhich.substring(9,14));
	}
	return retval;
}

public final int convertSampleNoToInteger(String iwhich)
{
	int retval = 0;
	String wopi = extractSampleNo(iwhich);
	if(!wopi.equals("")) retval = Integer.parseInt(wopi);
	return retval;
}

public final int convertFolderNoToInteger(String iwhich)
{
	int retval = 0;
	String wopi = extractFolderNo(iwhich);
	if(!wopi.equals("")) retval = Integer.parseInt(wopi);
	return retval;
}

// Get rec from database - mysoft.JobSamples
// iwhich = origid
public final GroovyRowResult getFolderSampleRec(String iwhich)
{
	Sql sql = sqlhand.als_mysoftsql();
	if(sql == null) return null;
	GroovyRowResult retval = null;
	String sqlstatem = "select * from JobSamples where origid=" + iwhich;

	try
	{
		retval = (GroovyRowResult)sql.firstRow(sqlstatem);
		sql.close();
	}
	catch (SQLException e) {}

	return retval;

} // end of getFolderSampleRec()

// get rec from mysoft.jobfolders - iwhich = origid
public final GroovyRowResult getFolderJobRec(String iwhich)
{
	Sql sql = sqlhand.als_mysoftsql();
	if(sql == null) return null;
	GroovyRowResult retval = null;
	String sqlstatem = "select * from JobFolders where origid=" + iwhich;
	try
	{
		retval = (GroovyRowResult)sql.firstRow(sqlstatem);
		sql.close();
	}
	catch (SQLException e) {}
	return retval;
}

public final void updateJobFolder_COADate(String theorigid, String thedate)
{
	Sql sql = sqlhand.als_mysoftsql();
	if(sql == null) return;
	String sqlstm = "update JobFolders set coadate='" + thedate + "' where origid=" + theorigid;
	try
	{
		sql.execute(sqlstm);
		sql.close();
	}
	catch (SQLException e) {}
}

public final void updateJobFolder_labfolderstatus(String theorigid, String thestatus)
{
	Sql sql = sqlhand.als_mysoftsql();
	if(sql == null) return;
	String sqlstm = "update JobFolders set labfolderstatus='" + thestatus + "' where origid=" + theorigid;
	try
	{
		sql.execute(sqlstm);
		sql.close();
	}
	catch (SQLException e) {}
}

public final void updateJobFolder_COAPrintoutDate(String theorigid, String thedate)
{
	Sql sql = sqlhand.als_mysoftsql();
	if(sql == null) return;
	String sqlstm = "update JobFolders set coaprintdate='" + thedate + "' where origid=" + theorigid;
	try
	{
		sql.execute(sqlstm);
		sql.close();
	}
	catch (SQLException e) {}
}

/*
Actually insert rec into database - refer to mysoft.jobsamples table
origid, sampleid_str, samplemarking, matrix, extranotes, jobfolders_id, uploadToLIMS, uploadToMYSOFT, deleted, status
16/4/2010: added fields : releasedby, releaseddate
25/11/2010: change iwhich to folder's origid instead of full folder string
*/
public final void createNewSampleRec(String iwhich)
{
	int ifolderno = convertFolderNoToInteger(iwhich);
	if(ifolderno == 0) return;

	Sql sql = sqlhand.als_mysoftsql();
	if(sql == null) return;
	String sqlstatem = "insert into JobSamples (sampleid_str,samplemarking,matrix,extranotes,jobfolders_id,uploadtolims,uploadtomysoft,deleted,status,releasedby,releaseddate) " + 
	"values ('','','',''," + String.valueOf(ifolderno) + ",0,0,0,'','','')";
	try
	{
		sql.execute(sqlstatem);
		sql.close();
	}
	catch (SQLException e) {}

} // end of createNewSamples()

public final void createNewSampleRec2(String iwhich)
{
	// ifolderno = convertFolderNoToInteger(iwhich);
	// if(ifolderno == 0) return;

	Sql sql = sqlhand.als_mysoftsql();
	if(sql == null) return;
	String sqlstatem = "insert into JobSamples (sampleid_str,samplemarking,matrix,extranotes,jobfolders_id,uploadtolims,uploadtomysoft,deleted,status,releasedby,releaseddate) " + 
	"values ('','','',''," + iwhich + ",0,0,0,'','','')";
	try
	{
		sql.execute(sqlstatem);
		sql.close();
	}
	catch (SQLException e) {}

} // end of createNewSamples()

public final void toggleSampleDeleteFlag(String iwhich, String iwhat)
{
	Sql sql = sqlhand.als_mysoftsql();
	if(sql == null) return;
	String sqlstatem = "update JobSamples set deleted=" + iwhat + " where origid=" + iwhich;
	try
	{
		sql.execute(sqlstatem);
		sql.close();
	}
	catch (SQLException e) {}
}

/*
DONE- MUST MOD THIS ONE -- 29/6/2010
Refer to mysoft.jobfolders for field names. First field, origid, no need to insert, it's auto-inc
02/02/2010: jobfolders -> fields
10/2/2010: added 2 more fields
29/3/2010: added branch field
origid,ar_code,datecreated,uploadToLIMS,uploadToMYSOFT,duedate,tat,extranotes,folderstatus,deleted, folderno_str,deliverymode
securityseal,noboxes,temperature,custreqdate,customerpo,customercoc,allgoodorder,paperworknot,paperworksamplesnot,samplesdamaged,attention,
priority, exportReportTemplate,branch, labfolderstatus, releasedby
16/04/2010: added labfolderstatus = WIP, RELEASED, RETEST
	added releasedby = username who released the folder
	added releaseddate = date of which folder is released
01/06/2010: added new field - JobFolders.coadate
03/06/2010: added new field - JobFolders.coaprintdate
13/01/2013: added new field - JobFolders.createdby - to show who owns the folder during registration

*/
public final void createNewFolderJob(Datebox ihiddendatebox, String ibranch, String iusername)
{
	String todaysdate = kiboo.getDateFromDatebox(ihiddendatebox);
	Sql sql = sqlhand.als_mysoftsql();
	if(sql == null) return;
	
	try
	{
	Connection thecon = sql.getConnection();
	
	PreparedStatement pstmt = thecon.prepareStatement("insert into JobFolders " +
	" (ar_code,datecreated,uploadToLIMS,uploadToMYSOFT,duedate, tat,extranotes,folderstatus,deleted,folderno_str," + 
	"deliverymode,securityseal,noboxes,temperature,custreqdate, customerpo,customercoc,allgoodorder,paperworknot," + 
	"paperworksamplesnot, samplesdamaged,attention,priority,exportReportTemplate,branch,labfolderstatus,releasedby," + 
	"releaseddate,coadate,coaprintdate, jobnotes,lastjobnotesdate,share_sample,createdby) values " + 
	"(?,?,?,?,?,?,?,?,?,?, ?,?,?,?,?,?,?,?,?,?, ?,?,?,?,?,?,?,?,?,?, ?,?,?,?)");

	pstmt.setString(1,"");
	pstmt.setString(2,todaysdate);
	pstmt.setInt(3,0);
	pstmt.setInt(4,0);
	pstmt.setString(5,todaysdate);

	pstmt.setInt(6,7);
	pstmt.setString(7,"");
	pstmt.setString(8,FOLDERDRAFT);
	pstmt.setInt(9,0);
	pstmt.setString(10,"");

	pstmt.setString(11,"");
	pstmt.setString(12,"");
	pstmt.setString(13,"");
	pstmt.setString(14,"");
	pstmt.setString(15,todaysdate);

	pstmt.setString(16,"");
	pstmt.setString(17,"");
	pstmt.setInt(18,0);
	pstmt.setInt(19,0);
	pstmt.setInt(20,0);

	pstmt.setInt(21,0);
	pstmt.setString(22,"");
	pstmt.setString(23,"NORMAL");
	pstmt.setInt(24,0);
	pstmt.setString(25,ibranch);

	pstmt.setString(26,"WIP");
	pstmt.setString(27,"");
	pstmt.setString(28,"");
	pstmt.setString(29,"");
	pstmt.setString(30,"");

	pstmt.setString(31,"");
	pstmt.setString(32,"");
	pstmt.setString(33,"");
	pstmt.setString(34,iusername);

	pstmt.executeUpdate();
	sql.close();
	}
	catch (SQLException e) {}

}

// 09/04/2013: same as createNewFolderJob() but uses general.todayISODateTimeString() to get date-time string
public final void createNewFolderJob2(Datebox ihiddendatebox, String ibranch, String iusername)
{
	//String todaysdate = kiboo.getDateFromDatebox(ihiddendatebox);
	String todaysdate = kiboo.todayISODateTimeString();
	Sql sql = sqlhand.als_mysoftsql();
	if(sql == null) return;
	
	try
	{
	Connection thecon = sql.getConnection();
	
	PreparedStatement pstmt = thecon.prepareStatement("insert into JobFolders " +
	" (ar_code,datecreated,uploadToLIMS,uploadToMYSOFT,duedate, tat,extranotes,folderstatus,deleted,folderno_str," + 
	"deliverymode,securityseal,noboxes,temperature,custreqdate, customerpo,customercoc,allgoodorder,paperworknot," + 
	"paperworksamplesnot, samplesdamaged,attention,priority,exportReportTemplate,branch,labfolderstatus,releasedby," + 
	"releaseddate,coadate,coaprintdate, jobnotes,lastjobnotesdate,share_sample,createdby) values " + 
	"(?,?,?,?,?,?,?,?,?,?, ?,?,?,?,?,?,?,?,?,?, ?,?,?,?,?,?,?,?,?,?, ?,?,?,?)");

	pstmt.setString(1,"");
	pstmt.setString(2,todaysdate);
	pstmt.setInt(3,0);
	pstmt.setInt(4,0);
	pstmt.setString(5,todaysdate);

	pstmt.setInt(6,7);
	pstmt.setString(7,"");
	pstmt.setString(8,FOLDERDRAFT);
	pstmt.setInt(9,0);
	pstmt.setString(10,"");

	pstmt.setString(11,"");
	pstmt.setString(12,"");
	pstmt.setString(13,"");
	pstmt.setString(14,"");
	pstmt.setString(15,todaysdate);

	pstmt.setString(16,"");
	pstmt.setString(17,"");
	pstmt.setInt(18,0);
	pstmt.setInt(19,0);
	pstmt.setInt(20,0);

	pstmt.setInt(21,0);
	pstmt.setString(22,"");
	pstmt.setString(23,"NORMAL");
	pstmt.setInt(24,0);
	pstmt.setString(25,ibranch);

	pstmt.setString(26,"WIP");
	pstmt.setString(27,"");
	pstmt.setString(28,"");
	pstmt.setString(29,"");
	pstmt.setString(30,"");

	pstmt.setString(31,"");
	pstmt.setString(32,"");
	pstmt.setString(33,"");
	pstmt.setString(34,iusername);

	pstmt.executeUpdate();
	sql.close();
	}
	catch (SQLException e) {}
}

// get the full rec from database -> JobTestParameters
// iwhich = which origid id
public final GroovyRowResult getJobTestParametersRec(String iwhich)
{
	Sql sql = sqlhand.als_mysoftsql();
	if(sql == null) return null;
	GroovyRowResult retval = null;
	String sqlstatem = "select * from JobTestParameters where origid=" + iwhich;
	try
	{
		retval = (GroovyRowResult)sql.firstRow(sqlstatem);
		sql.close();
	}
	catch (SQLException e) {}
	return retval;
}

// get a rec from StockMasterDetails based on which ID/iwhich
public final GroovyRowResult getStockMasterDetails(String iwhich)
{
	Sql sql = sqlhand.als_mysoftsql();
	if(sql == null) return null;
	GroovyRowResult retval = null;
	String sqlstatem = "select * from stockmasterdetails where id=" + iwhich;
	try
	{
		retval = (GroovyRowResult)sql.firstRow(sqlstatem);
		sql.close();
	}
	catch (SQLException e) {}
	return retval;
}

// To save folder->samples full id string..
// isamplb = samples listbox to go thru
public final void saveFolderSamplesNo_Main(Listbox isamplb)
{
	// go through the isamplb
	int numrec = isamplb.getItemCount();
	if(numrec == 0) return; // nothing, return lo

	Sql sql = sqlhand.als_mysoftsql();
	if(sql == null) return;
	
	try
	{
		for(int i=0; i<numrec; i++)
		{
			// get the sample-id
			String yobo = isamplb.getItemAtIndex(i).getLabel();
			int iorigid = convertSampleNoToInteger(yobo);
			String sqlstatem = "update JobSamples set sampleid_str='" + yobo + "' where origid=" + String.valueOf(iorigid);
			sql.execute(sqlstatem);
		}

		sql.close();
	}
	catch (SQLException e) {}
}

public final void saveFolderSamplesNo_Main2(Listbox isamplb)
{
	// go through the isamplb
	int numrec = isamplb.getItemCount();
	if(numrec == 0) return; // nothing, return lo

	Sql sql = sqlhand.als_mysoftsql();
	if(sql == null) return;

	try
	{
		for(int i=0; i<numrec; i++)
		{
			// get the sample-id
			Listitem selitem = isamplb.getItemAtIndex(i);
			String iorigid = lbhandler.getListcellItemLabel(selitem,0);
			String yobo = lbhandler.getListcellItemLabel(selitem,2);
			//iorigid = convertSampleNoToInteger(yobo);
			String sqlstatem = "update JobSamples set sampleid_str='" + yobo + "' where origid=" + iorigid;
			sql.execute(sqlstatem);
		}
		sql.close();
	}
	catch (SQLException e) {}
}

public final int getNumberOfSamples_InFolder(int ifolderno)
{
	Sql sql = sqlhand.als_mysoftsql();
	if(sql == null) return 0;
	int retval = 0;
	String sqlstatem = "select count(origid) as samplecount from JobSamples where deleted=0 and jobfolders_id=" + String.valueOf(ifolderno);
	GroovyRowResult merec = null;
	try
	{
		merec = (GroovyRowResult)sql.firstRow(sqlstatem);
		sql.close();
		if(merec != null) retval = (Integer)merec.get("samplecount");
	}
	catch (SQLException e) {}

	return retval;
}

// Update JobTestParameters.uploadToLIMS flaggy
// params: iorigid = which jtp origid
//		iwhat = flaggy, 0 or 1 or whatever if needed later
public final void updateJTP_uploadtolims_flag(String iorigid, int iwhat)
{
	Sql sql = sqlhand.als_mysoftsql();
	if(sql == null) return;
	String sqlst2 = "update JobTestParameters set uploadToLIMS=" + String.valueOf(iwhat) + " where origid=" + iorigid;
	try
	{
	sql.execute(sqlst2);
	sql.close();
	}
	catch (SQLException e) {}
}

// 11/6/2010: get rec from CashSales_CustomerInfo by iwhich=folderno_str
public final GroovyRowResult getCashSalesCustomerInfo_Rec(String iwhich)
{
	GroovyRowResult retval = null;
	Sql sql = sqlhand.als_mysoftsql();
	if(sql == null) return retval;
	String sqlstm = "select * from CashSales_CustomerInfo where folderno_str='" + iwhich + "'";
	try
	{
	retval = (GroovyRowResult)sql.firstRow(sqlstm);
	sql.close();
	}
	catch (SQLException e) {}
	return retval;
}

public final void deleteCashSalesCustomerInfo_Rec(String iwhich)
{
	Sql sql = sqlhand.als_mysoftsql();
	if(sql == null) return;
	String sqlstm = "delete from CashSales_CustomerInfo where folderno_str='" + iwhich + "'";
	try
	{
	sql.execute(sqlstm);
	sql.close();
	}
	catch (SQLException e) {}
}

// Database func: insert a test into JobTestParameters table
// later need to add more stuff, LOR and shit like that
public final void insertJobTestParameters_Rec(String iorigid, String imysoftcode)
{
	Sql sql = sqlhand.als_mysoftsql();
	if(sql == null) return;
	try
	{
		Connection thecon = sql.getConnection();
		PreparedStatement pstmt = thecon.prepareStatement("insert into JobTestParameters (jobsamples_id,mysoftcode,starlimscode,status,uploadToMYSOFT,uploadToLIMS) values (?,?,?,?,?,?)");
		pstmt.setInt(1,Integer.parseInt(iorigid));
		pstmt.setInt(2,Integer.parseInt(imysoftcode));
		pstmt.setInt(3,0);
		pstmt.setString(4,"");
		pstmt.setInt(5,0);
		pstmt.setInt(6,0);
		pstmt.executeUpdate();
		sql.close();
	}
	catch (SQLException e) {}
}

// Database func: remove a rec from JobTestParameters table based on origid passed
public final void deleteJobTestParameters_Rec(String iorigid)
{
	if(iorigid.equals("")) return;
	Sql sql = sqlhand.als_mysoftsql();
	if(sql == null) return;
	String sqlstm = "delete from JobTestParameters where origid=" + iorigid;
	try
	{
		sql.execute(sqlstm);
		sql.close();
	}
	catch (SQLException e) {}
}

// Database func: insert new rec into JobNotes_History
public final void insertJobNotesHistory_Rec(String ifolderorigid, String ioldjobnotes, String inewjobnotes, String ithedate, String iusername)
{
	Sql sql = sqlhand.als_mysoftsql();
	if(sql == null ) return;
	try
	{
	Connection thecon = sql.getConnection();
	PreparedStatement pstmt = thecon.prepareStatement("insert into JobNotes_History (jobfolders_id,oldjobnotes,newjobnotes,change_date,user_changed) values (?,?,?,?,?)");
	pstmt.setInt(1,Integer.parseInt(ifolderorigid));
	pstmt.setString(2,ioldjobnotes);
	pstmt.setString(3,inewjobnotes);
	pstmt.setString(4,ithedate);
	pstmt.setString(5,iusername);
	pstmt.executeUpdate();
	sql.close();
	}
	catch (SQLException e) {}
}

// Database func: read a rec from JobNotes_History
public final GroovyRowResult getJobNotesHistory_Rec(String iorigid)
{
	GroovyRowResult retval = null;
	Sql sql = sqlhand.als_mysoftsql();
	if(sql == null) return retval;
	String sqlstm = "select * from JobNotes_History where origid=" + iorigid;
	try
	{
		retval = (GroovyRowResult)sql.firstRow(sqlstm);
		sql.close();
	}
	catch (SQLException e) {}
	return retval;
}

}


