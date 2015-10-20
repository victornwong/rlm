package org.victor;
import java.util.*;
import java.text.*;
import java.sql.*;
import java.lang.*;
import groovy.sql.*;
import org.zkoss.zul.*;
import org.zkoss.zk.ui.*;

public class RWMS_sql extends GlobalDefs
{
	private SqlFuncs sqlhand = new SqlFuncs();

public final GroovyRowResult getGCO_rec(String iwhat) throws SQLException
{
	String sqlstm = "select * from rw_goodscollection where origid=" + iwhat;
	return sqlhand.gpSqlFirstRow(sqlstm);
}

public final GroovyRowResult getGRN_rec(String iwhat) throws SQLException
{
	String sqlstm = "select * from tblgrnmaster where id=" + iwhat;
	return sqlhand.gpSqlFirstRow(sqlstm);
}

public final GroovyRowResult getHelpTicket_rec(String iwhat) throws SQLException
{
	String sqlstm = "select * from rw_helptickets where origid=" + iwhat;
	return sqlhand.gpSqlFirstRow(sqlstm);
}

public final GroovyRowResult getLocalRMA_rec(String iwhat) throws SQLException
{
	String sqlstm = "select * from rw_localrma where origid=" + iwhat;
	return sqlhand.gpSqlFirstRow(sqlstm);
}

public final GroovyRowResult getLocalRMAItem_rec(String iwhat) throws SQLException
{
	String sqlstm = "select * from rw_localrma_items where origid=" + iwhat;
	return sqlhand.gpSqlFirstRow(sqlstm);
}

public final GroovyRowResult getLC_rec(String iwhat) throws SQLException
{
	String sqlstm = "select * from rw_leasingcontract where origid=" + iwhat;
	return sqlhand.gpSqlFirstRow(sqlstm);
}

public final GroovyRowResult getLCAsset_rec(String iwhat) throws SQLException
{
	String sqlstm = "select * from rw_leaseequipments where origid=" + iwhat;
	return sqlhand.gpSqlFirstRow(sqlstm);
}

public final GroovyRowResult getLCEquips_rec(String iwhat) throws SQLException
{
	String sqlstm = "select * from rw_lc_equips where origid=" + iwhat;
	return sqlhand.gpSqlFirstRow(sqlstm);
}

public final GroovyRowResult getLCNew_rec(String iwhat) throws SQLException
{
	String sqlstm = "select * from rw_lc_records where origid=" + iwhat;
	return sqlhand.gpSqlFirstRow(sqlstm);
}

public final GroovyRowResult getRentalItems_build(String iwhat) throws SQLException
{
	String sqlstm = "select * from stockrentalitems_det where origid=" + iwhat;
	return sqlhand.gpSqlFirstRow(sqlstm);
}

public final GroovyRowResult getPickPack_rec(String iwhat) throws SQLException
{
	String sqlstm = "select * from rw_pickpack where origid=" + iwhat;
	return sqlhand.gpSqlFirstRow(sqlstm);
}

public final GroovyRowResult getRWJob_rec(String iwhat) throws SQLException
{
	String sqlstm = "select * from rw_jobs where origid=" + iwhat;
	return sqlhand.gpSqlFirstRow(sqlstm);
}

public final GroovyRowResult getBOM_rec(String iwhat) throws SQLException
{
	String sqlstm = "select * from stockrentalitems where origid=" + iwhat;
	return sqlhand.gpSqlFirstRow(sqlstm);
}

public final GroovyRowResult getDO_rec(String iwhat) throws SQLException
{
	String sqlstm = "select * from rw_deliveryorder where origid=" + iwhat;
	return sqlhand.gpSqlFirstRow(sqlstm);
}

public final GroovyRowResult getDispatchManifest_rec(String iwhat) throws SQLException
{
	String sqlstm = "select * from rw_dispatchmanif where origid=" + iwhat;
	return sqlhand.gpSqlFirstRow(sqlstm);
}

public final GroovyRowResult getOfficeItem_rec(String iwhat) throws SQLException
{
	String sqlstm = "select * from rw_officeitems where origid=" + iwhat;
	return sqlhand.gpSqlFirstRow(sqlstm);
}

public final GroovyRowResult getSoftwareLesen_rec(String iid) throws SQLException
{
	String sqlstm = "select * from rw_clientswlicenses where origid=" + iid;
	return sqlhand.gpSqlFirstRow(sqlstm);
}

public final GroovyRowResult getPR_rec(String iwhat) throws SQLException
{
	String sqlstm = "select * from purchaserequisition where origid=" + iwhat;
	return sqlhand.gpSqlFirstRow(sqlstm);
}

public final GroovyRowResult getSendout_rec(String iwhat) throws SQLException
{
	String sqlstm = "select * from rw_sendouttracker where origid=" + iwhat;
	return sqlhand.gpSqlFirstRow(sqlstm);
}

public final GroovyRowResult getQuotation_rec(String iwhat) throws SQLException
{
	String sqlstm = "select * from rw_quotations where origid=" + iwhat;
	return sqlhand.gpSqlFirstRow(sqlstm);
}

public final GroovyRowResult getCheqRecv_rec(String iwhat) throws SQLException
{
	String sqlstm = "select * from rw_cheqrecv where origid=" + iwhat;
	return sqlhand.gpSqlFirstRow(sqlstm);
}

public final GroovyRowResult getDrawdownAssignment_rec(String iwhat) throws SQLException
{
	String sqlstm = "select * from rw_assigned_rwi where origid=" + iwhat;
	return sqlhand.gpSqlFirstRow(sqlstm);
}

public final GroovyRowResult getActivitiesContact_rec(String iwhat) throws SQLException
{
	String sqlstm = "select * from rw_activities_contacts where origid=" + iwhat;
	return sqlhand.gpSqlFirstRow(sqlstm);
}

public final GroovyRowResult getActivity_rec(String iwhat) throws SQLException
{
	String sqlstm = "select * from rw_activities where origid=" + iwhat;
	return sqlhand.gpSqlFirstRow(sqlstm);
}

public final GroovyRowResult getReservation_Rec(String iwhat) throws SQLException
{
	String sqlstm = "select * from rw_stockreservation where origid=" + iwhat;
	return sqlhand.gpSqlFirstRow(sqlstm);
}

public final GroovyRowResult getEqReqStat_rec(String iwhat) throws SQLException
{
	String sqlstm = "select * from reqthings_stat where parent_id='"+ iwhat + "'";
	return sqlhand.rws_gpSqlFirstRow(sqlstm);
}

public final GroovyRowResult getFC_indta_rec(String iwhat) throws SQLException
{
	String sqlstm = "select * from indta where salesid=" + iwhat;
	return sqlhand.rws_gpSqlFirstRow(sqlstm);
}

public final GroovyRowResult getFC6DO_rec(String iwhat) throws SQLException
{
	String sqlstm = "select convert(datetime, dbo.ConvertFocusDate(d.date_), 112) as vdate, d.voucherno, " +
	"c.name as customer_name, k.deliverystatusyh, k.deliverydateyh, k.transporteryh, k.deliveryrefyh," +
	"k.narrationyh, k.referenceyh from data d " +
	"left join mr000 c on c.masterid = d.bookno " +
	"left join u001c k on k.extraid = d.extraheaderoff " +
	"where d.vouchertype=6144 " +
	"and d.voucherno='" + iwhat + "'";

	return sqlhand.rws_gpSqlFirstRow(sqlstm);
}

public final GroovyRowResult getFocus_CustomerRec(String icustid) throws SQLException
{
	String sqlstm = "select cust.name,cust.code,cust.code2, " +
	"custd.address1yh, custd.address2yh, custd.address3yh, custd.address4yh, " +
	"custd.telyh, custd.faxyh, custd.contactyh, custd.deliverytoyh, " +
	"custd.manumberyh, custd.rentaltermyh, custd.interestayh, " +
	"custd.credit4yh, custd.credit5yh, custd.creditlimityh, " +
	"custd.salesrepyh,custd.interestayh,custd.emailyh, cust.type from mr000 cust " +
	"left join u0000 custd on custd.extraid = cust.masterid " +
	"where cust.masterid=" + icustid;
	return sqlhand.rws_gpSqlFirstRow(sqlstm);
}

String getFocus_CustomerName(String icustid) throws SQLException
{
	String retv = "NEW";
	if(icustid.equals("")) return "NEW";

	String sqlstm = "select cust.name from mr000 cust where cust.masterid=" + icustid;
	GroovyRowResult kk = sqlhand.rws_gpSqlFirstRow(sqlstm);

	if(kk != null) retv = (String)kk.get("name");
	return retv;
}

// DOs link to bom/picklist link to job - can be used for other mods to comma-string something
// itype: 1=picklist, 2=boms, 3=PR, 4=GRN(iorigids=PR), 5=ADT->GCO
String getDOLinkToJob(int itype, String iorigids) throws SQLException
{
	String retv = ""; String sqlstm = "";
	if(iorigids.equals("")) return "";

	switch(itype)
	{
		case 1:
		sqlstm = "select distinct do.origid as doid from rw_deliveryorder do " +
		"left join rw_pickpack ppl on ppl.do_id = do.origid " +
		"where ppl.origid in (" + iorigids + ")";
		break;

		case 2:
		sqlstm = "select distinct do.origid as doid from rw_deliveryorder do " +
		"left join stockrentalitems sri on sri.do_id = do.origid " +
		"where sri.origid in (" + iorigids + ")";
		break;

		case 3:
		sqlstm = "select distinct pr.origid as doid from purchaserequisition pr " +
		"where pr.pr_status in ('APPROVE','APPROVED') and pr.job_id=" + iorigids;
		break;

		case 4:
		sqlstm = "select temp_grn as doid from purchaserequisition where origid in (" + iorigids + ")";
		//alert(sqlstm);
		break;

		case 5: // get GCO from ADT table
		sqlstm = "select origid as doid from rw_qcaudit where gcn_no=" + iorigids;
		break;
	}

	if(!sqlstm.equals(""))
	{
		ArrayList rcs = sqlhand.gpSqlGetRows(sqlstm);
		GroovyRowResult kk;
		if(rcs.size() > 0)
		{
			for(Object d : rcs)
			{
				kk = (GroovyRowResult)d;
				if(kk.get("doid") != null) retv += kk.get("doid") + ",";	
			}

			try { retv = retv.substring(0,retv.length()-1); } catch (Exception e) {}
		}
	}
	return retv;
}

// FC6: Get MRN linked to T.GRN. iwhat=T.GRNs
public final ArrayList grnGetMRN(String iwhat) throws SQLException
{
/*
	sqlstm = "select voucherno from v_link4 where vouchertype=1280 and sortlinkid=" + 
	"(select top 1 links1 from data where vouchertype=1281 and voucherno='" + iwhat + "')";
	return sqlhand.rws_gpSqlFirstRow(sqlstm);
*/
	String sqlstm = "select distinct voucherno from v_link4 where vouchertype=1280 and sortlinkid in " + 
	"(select links1 from data where vouchertype=1281 and voucherno in (" + iwhat + "))";

	return sqlhand.rws_gpSqlGetRows(sqlstm);
}

// Get MRNs from GRNs. iwhat: GRNs - split and put quotes to be used in grnGetMRN()
public final String grnToMRN_str(String iwhat) throws SQLException
{
	if(iwhat.equals("")) return "";
	String[] ks = iwhat.split(",");
	if(ks.length < 1) return "";
	String wps = "";
	for(int i=0;i<ks.length;i++)
	{
		wps += "'" + ks[i] + "',";
	}
	try { wps = wps.substring(0,wps.length()-1); } catch (Exception e) {}
	ArrayList mrns = grnGetMRN(wps);
	wps = "";
	GroovyRowResult kk;
	if(mrns.size() > 0)
	{
		for(Object d : mrns)
		{
			kk = (GroovyRowResult)d;
			wps += kk.get("voucherno") + ",";
		}
		try { wps = wps.substring(0,wps.length()-1); } catch (Exception e) {}
	}
	return wps;
}

// General purpose to return string of other things with linking job-id (ijid)
public final String getLinkingJobID_others(int itype, String ijid) throws SQLException
{
	String retv = ""; String tablen = ""; String sqlstm = "";
	String lnkid = "job_id";

	switch(itype)
	{
		case BOM_JOBID :
		case BOM_DOID :
			tablen = "stockrentalitems";
			break;
		case PICKLIST_JOBID :
		case PICKLIST_DOID :
			tablen = "rw_pickpack";
			break;
		case DO_MANIFESTID :
			tablen = "rw_deliveryorder";
			lnkid = "manif_id";
			break;
	}

	if(itype == BOM_DOID || itype == PICKLIST_DOID) lnkid = "do_id";

	if(!tablen.equals(""))
	{
		sqlstm = "select origid from " + tablen + " where " + lnkid + "=" + ijid;
		ArrayList krs = sqlhand.gpSqlGetRows(sqlstm);
		if(krs.size() != 0)
		{
			for(Object d : krs)
			{
				GroovyRowResult kk = (GroovyRowResult)d;
				retv += kk.get("origid").toString() + ",";
			}
			try {
			retv = retv.substring(0,retv.length()-1);
			} catch (Exception e) {}
		}
	}

	return retv;
}

// Populate a listbox with usernames from portaluser
public final void populateUsernames(Listbox ilb, String discardname) throws SQLException
{
	Generals kiboo = new Generals();
	ListboxHandler lbhand = new ListboxHandler();
	String sqlstm = "select username from portaluser where username<>'" + discardname + "' and deleted=0 and locked=0 order by username";
	ArrayList recs = sqlhand.gpSqlGetRows(sqlstm);
	if(recs.size() == 0) return;
	ArrayList kabom = new ArrayList();
	for( Object d : recs)
	{
		GroovyRowResult kk = (GroovyRowResult)d;
		kabom.add( kiboo.checkNullString( (String)kk.get("username")) );
		lbhand.insertListItems(ilb,kiboo.convertArrayListToStringArray(kabom),"false","");
		kabom.clear();
	}
	ilb.setSelectedIndex(0);
}

public final void populateUsernames_check(Listbox ilb, String discardname) throws SQLException
{
	Generals kiboo = new Generals();
	ListboxHandler lbhand = new ListboxHandler();

	String sqlstm = "select username from portaluser where username<>'" + discardname + "' and deleted=0 and locked=0 order by username";
	ArrayList recs = sqlhand.gpSqlGetRows(sqlstm);
	if(recs.size() == 0) return;
	ArrayList kabom = new ArrayList();
	for( Object d : recs)
	{
		GroovyRowResult kk = (GroovyRowResult)d;
		kabom.add( kiboo.checkNullString( (String)kk.get("username")) );
		lbhand.insertListItems(ilb,kiboo.convertArrayListToStringArray(kabom),"false","");
		kabom.clear();
	}

	ilb.setMultiple(true);
	ilb.setCheckmark(true);
}

public final GroovyRowResult getStockItem_rec(String istkcode) throws SQLException
{
	String sqlstm = "select * from stockmasterdetails where stock_code='" + istkcode + "'";
	return sqlhand.gpSqlFirstRow(sqlstm);
}

public final boolean checkStockExist(String istkc) throws SQLException
{
	String sqlstm = "select id from stockmasterdetails where stock_code='" + istkc + "'";
	GroovyRowResult krr = sqlhand.gpSqlFirstRow(sqlstm);
	return (krr != null) ? true : false;
}

public final GroovyRowResult getJobPicklist_rec(String iwhat) throws SQLException
{
	String sqlstm = "select * from rw_jobpicklist where origid=" + iwhat;
	return sqlhand.gpSqlFirstRow(sqlstm);
}


} // ENDOF class RWMS_sql
