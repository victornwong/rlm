package org.victor;

import java.util.*;
import java.sql.*;
import groovy.sql.*;
import org.zkoss.zk.ui.*;
import org.zkoss.zul.*;
import org.victor.*;

public class LookupFuncs extends SqlFuncs
{
	private ListboxHandler lbhand;
	private GridHandler gridhand;
	private Generals kiboo;

	public LookupFuncs()
	{
		lbhand = new ListboxHandler();
		gridhand = new GridHandler();
		kiboo = new Generals();
	}

// Make sure the code entered is unique.
// cannot have duplicates else the whole system will break.
public final boolean isUniqueCode(String thecode)
{
	boolean retval = false;

	Sql sql = als_mysoftsql();
	if(sql == null) return retval;
	String sqlstatement = "select name from lookups where name='" + thecode + "'";
	GroovyRowResult subchild = null;

	try
	{
		subchild = (GroovyRowResult)sql.firstRow(sqlstatement);
		sql.close();
	}
	catch (java.sql.SQLException e) {}

	if(subchild == null) retval = true;
	return retval;
}

public final GroovyRowResult getLookup_Rec(String iname)
{
	Sql sql = als_mysoftsql();
	if(sql == null) return null;
	String sqlstatem = "select top 1 * from lookups where name='" + iname + "'";
	GroovyRowResult therec = null;
	try
	{
		therec = (GroovyRowResult)sql.firstRow(sqlstatem);
		sql.close();
	}
	catch (java.sql.SQLException e) {}
	return therec;
}

// Return the selected item's parent. Should be unique and be used for inserting new
// items under the parent.
public final String getSelectedParent(String whichone)
{
	Sql sql = als_mysoftsql();
	if(sql == null) return "";
	String sqlstatem = "select top 1 * from lookups where name='" + whichone + "'";
	GroovyRowResult therec = null;
	try
	{
		therec = (GroovyRowResult)sql.firstRow(sqlstatem);
		sql.close();
	}
	catch (java.sql.SQLException e) {}
	return (String)therec.get("myparent");
}

// Database func: insert a rec into Lookups w/o using the tree-structure-input-boxes
public final void insertLookups_Rec(String iname, String idisptext, String imyparent)
{
	GuiFuncs guihand = new GuiFuncs();
	try
	{
		SqlFuncs sqlhand = new SqlFuncs();
		String sqlstm = "insert into lookups (name,disptext,myparent,expired) values ('" + iname + "','" + idisptext + "','" + imyparent + "',0)";
		sqlhand.gpSqlExecuter(sqlstm);
	} catch (java.sql.SQLException e) { String k = e.toString(); guihand.showMessageBox(k); }
}

// Database func: get lookup rec by idlookups
public final GroovyRowResult getLookupRec_ByID(String theid)
{
	GroovyRowResult therec = null;
	Sql sql = als_mysoftsql();
	if(sql == null) return therec;
	String sqlstatem = "select * from lookups where idlookups=" + theid;
	try
	{
		therec = (GroovyRowResult)sql.firstRow(sqlstatem);
		sql.close();
	}
	catch (java.sql.SQLException e) {}

	return therec;
}

// Get the whole-list of lookups by myparent
public final List<GroovyRowResult> getLookups_ByParent(String imyparent) throws SQLException
{
	List<GroovyRowResult> retvs = null;
	Sql sql = als_mysoftsql();
	if(sql == null ) return retvs;

	String sqlstm = "select * from lookups where " + 
	"myparent = cast((select idlookups from lookups where name='" + imyparent + "') as char) " +
	"and expired=0 order by idlookups";

	retvs = sql.rows(sqlstm);
	sql.close();
	return retvs;
}

// Convert lookups found by myparent to string delimited by char - useful for email-addrs and other concat
// itype: 1=return names found, 2=return disptext
// idelim: the delimiter
public final String getLookups_ConvertToStr(String imyparent, int itype, String idelim) throws SQLException
{
	String retval = "", kahi;
	List<GroovyRowResult> retvs = getLookups_ByParent(imyparent);
	if(retvs == null) return retval;
	
	for(GroovyRowResult dpi : retvs)
	{
		kahi = (itype == 1) ? (String)dpi.get("name") : (String)dpi.get("disptext");
		retval += kahi + idelim;
	}

	return retval.substring(0,retval.length()-1);
}

// get lookup child-items and return in String[] array
// itype: 1=return names, 2=disptext
public final String[] getLookupChildItems_StringArray(String imyparent, int itype) throws SQLException
{
	List<GroovyRowResult> retvs = getLookups_ByParent(imyparent);
	if(retvs == null) return null;

	String[] retval = new String[retvs.size()];
	String kahi;
	int i = 0;

	for(GroovyRowResult dpi : retvs)
	{
		kahi = (itype == 1) ? (String)dpi.get("name") : (String)dpi.get("disptext");
		retval[i] = kahi;
		i++;
	}

	return retval;
}

// 10/01/2012: lookup space-separated string to tick items
public final void findAndTick(Listbox ilistbox, String istring, String isepchar)
{
	String[] splito = istring.split(isepchar);
	String spitem,titem;
	Listitem lbitem;
	
	for(int i=0; i < splito.length; i++)
	{
		spitem = splito[i];
		
		for(int j=0; j < ilistbox.getItemCount(); j++)
		{
			lbitem = ilistbox.getItemAtIndex(j);
			titem = lbitem.getLabel();
			if(titem.equals(spitem)) ilistbox.toggleItemSelection(lbitem);
		}
	}
}

// 02/03/2012: grab name,disptext from lookups to populate listbox
// iwhich: 1=show names, 2=show disptext
public final void populateListbox_ByLookup(Object ilistbox, String ilookname, int iwhich) throws SQLException
{
	List<GroovyRowResult> retvs = getLookups_ByParent(ilookname);
	if(retvs == null) return;
	if(retvs.size() == 0) return;
	
	Component woli = (Component)ilistbox;

	// remove previous list-items
	if(woli.getChildren() != null)
	{
		Object[] woo = woli.getChildren().toArray();
		for(int i=0; i<woo.length; i++)
		{
			Component ike = (Component)woo[i];
			woli.removeChild(ike);
		}
	}

	String[] strarray = new String[1];
	Listbox aki = (Listbox)woli;

	for(GroovyRowResult dpi : retvs)
	{
		strarray[0] = (iwhich == 1) ? (String)dpi.get("name") : (String)dpi.get("disptext");
		
		lbhand.insertListItems(aki,strarray,"true","");
	}

	aki.setSelectedIndex(0);
}

// 01/10/2012: knockoff from populateListbox_ByLookup()
// 07/03/2013: ivalwhich = 20:take lookupname as hidden-ret-val, else take disptext
// icomp=listbox, ilookname=lookup to get stuff, iwhich=1:name,2:disptext
// ivalwhich=which VALUE[1-8] field as hidden-value
public final void populateListBox_ValueSelection(Object ilistbox, String ilookname, int iwhich, int ivalwhich) throws SQLException
{
	List<GroovyRowResult> retvs =  getLookups_ByParent(ilookname);
	if(retvs == null) return;
	if(retvs.size() == 0) return;
	
	Component woli = (Component)ilistbox;

	// remove previous list-items
	if(woli.getChildren() != null)
	{
		Object[] woo = woli.getChildren().toArray();
		for(int i=0; i<woo.length; i++)
		{
			Component ike = (Component)woo[i];
			woli.removeChild(ike);
		}
	}

	String[] strarray = new String[2];
	Listbox aki = (Listbox)woli;
	String valtoget;

	for(GroovyRowResult dpi : retvs)
	{
		strarray[0] = (iwhich == 1) ? (String)dpi.get("name") : (String)dpi.get("disptext");
		
		if(ivalwhich <= 8)
		{
			valtoget = "value" + Integer.toString(ivalwhich);
			strarray[1] = kiboo.checkNullString((String)dpi.get(valtoget));
		}
		else
		{
			strarray[1] = (ivalwhich == 20) ? (String)dpi.get("name") : (String)dpi.get("disptext");
		}

		lbhand.insertListItems(aki,strarray,"false","");
	}

	aki.setSelectedIndex(0);
}

// 06/03/2012: grab name,disptext from lookups to populate checkboxes
// iwhich: 1=show names, 2=show disptext
public final void populateCheckbox_ByLookup(Object iboxholder, String ilookname, String istyle, int iwhich) throws SQLException
{
	List<GroovyRowResult> retvs = getLookups_ByParent(ilookname);
	if(retvs == null) return;
	if(retvs.size() == 0) return;

	Component woli = (Component)iboxholder;

	// remove previous items
	if(woli.getChildren() != null)
	{
		Object[] woo = woli.getChildren().toArray();
		for(int i=0; i<woo.length; i++)
		{
			Component ike = (Component)woo[i];
			woli.removeChild(ike);
		}
	}

	String chkboxstr;
	Checkbox chkbox;

	for(GroovyRowResult dpi : retvs)
	{
		chkboxstr = (iwhich == 1) ? (String)dpi.get("name") : (String)dpi.get("disptext");
		chkbox = new Checkbox(chkboxstr);
		chkbox.setStyle(istyle);
		chkbox.setParent(woli);
	}
}


// 06/03/2012: Save checkboxes in holder which are ticked into string, separated by ~
public final String saveCheckboxTicked(Component iholder)
{
	String ett = "";
	Object[] woo = iholder.getChildren().toArray();
	Checkbox ike;
	for(int i=0; i<woo.length; i++)
	{
		if(woo[i] instanceof Checkbox)
		{
			ike = (Checkbox)woo[i];
			if(ike.isChecked()) ett += ike.getLabel() + "~";
		}
	}

	if(ett.equals("")) return "";
	return ett.substring(0,ett.length()-1);
}

// 06/03/2012: Untick whatever checkboxes in holder
public final void clearCheckboxTicked(Component iholder)
{
	Object[] woo = iholder.getChildren().toArray();
	Checkbox ike;
	for(int i=0; i<woo.length; i++)
	{
		if(woo[i] instanceof Checkbox)
		{
			ike = (Checkbox)woo[i];
			ike.setChecked(false);
		}
	}
}

// 06/03/2012: Tick checkboxes in holder by itickstring, eg "kaka~kiki" produced by saveCheckboxTicked()
public final void tickCheckboxes(Component iholder, String itickstring)
{
	Object[] woo = iholder.getChildren().toArray();
	Checkbox ike;
	for(int i=0; i<woo.length; i++)
	{
		if(woo[i] instanceof Checkbox)
		{
			ike = (Checkbox)woo[i];
			if(itickstring.indexOf(ike.getLabel()) != -1) ike.setChecked(true);
		}
	}
}

// 06/03/2012: toggle disabled flag for whatever checkboxes in holder
public final void disableCheckboxTicked(Component iholder, boolean iwhat)
{
	Object[] woo = iholder.getChildren().toArray();
	Checkbox ike;
	for(int i=0; i<woo.length; i++)
	{
		if(woo[i] instanceof Checkbox)
		{
			ike = (Checkbox)woo[i];
			ike.setDisabled(iwhat);
		}
	}
}

public final void tickRadioButton(Component iholder, String itickstring)
{
	Object[] woo = iholder.getChildren().toArray();
	Radio ike;
	for(int i=0; i<woo.length; i++)
	{
		if(woo[i] instanceof Radio)
		{
			ike = (Radio)woo[i];
			if(itickstring.indexOf(ike.getLabel()) != -1) ike.setChecked(true);
		}
	}
}

// get lookups.idlookups by lookups.name
public final String getRec_Origid(String iname)
{
	GroovyRowResult rtrec = getLookup_Rec(iname);
	if(rtrec == null) return "";
	String retval = String.valueOf(rtrec.get("idlookups"));
	return retval;
}

// Match ichkstr to name or disptext
// itype: 1= ichkstr against name, returns disptext
// 2= ichkstr against disptext, returns name
public final String matchLookup_ReturnStr(String ilookname, String ichkstr, int itype) throws SQLException
{
	String retval = "", rtocheckstr;
	List<GroovyRowResult> retvs = getLookups_ByParent(ilookname);
	if(retvs == null) return retval;
	for(GroovyRowResult dpi : retvs)
	{
		rtocheckstr = (itype == 1) ?  (String)dpi.get("name") : (String)dpi.get("disptext");
		if(rtocheckstr.equals(ichkstr))
		{
			retval = (itype == 1) ? (String)dpi.get("disptext") : (String)dpi.get("name");
			break;
		}
	}
	return retval;
}

// Get extra-fields label defs
public final GroovyRowResult getFieldsDef_Rec(String iorigid) throws SQLException
{
	GroovyRowResult retval = null;
	String sqlstm = "select * from lookups_fieldslabel where origid=" + iorigid;
	Sql sql = als_mysoftsql();
	if(sql == null) return retval;
	retval = (GroovyRowResult)sql.firstRow(sqlstm);
	sql.close();
	return retval;
}

/*
Hardcode some of the listbox/dropdowns population used in e-labman - uses MySoft tables
listbox-headers are hardcoded too
itype:
0 = terms distinct extracted from customer.credit_period - can be used for other mods - populateTerms_dropdown(Div idiv)
*/

private Object[] terms_lb_headers = {
	new dblb_HeaderObj("terms",true,"credit_period",1),
};

private Object[] sm_lb_headers = {
	new dblb_HeaderObj("SM.Name",true,"username",1),
};

private Object[] smsale_lb_headers = {
	new dblb_HeaderObj("SM.Name",true,"salesman_name",1),
	new dblb_HeaderObj("SM.Code",false,"salesman_code",1),
};

private Object[] smgroup_lb_headers = {
	new dblb_HeaderObj("groupcode",true,"groupcode",1),
};

private Object[] smstockcat_lb_headers = {
	new dblb_HeaderObj("stockcat",true,"stock_cat",1),
};

private Object[] custcat_lb_headers = {
	new dblb_HeaderObj("category",true,"category",1),
};

private Object[] dumaHeaders = {
terms_lb_headers,
sm_lb_headers,
smsale_lb_headers,
smgroup_lb_headers,
smstockcat_lb_headers,
custcat_lb_headers,

};

private String[] dumaLBId = {
"qt_terms",
"quoteuser_lb",
"qt_salesperson",
"groupcode_lb",
"stockcategory_lb",
"custcat_lb",

};

private String[] sqlstms = {
"select distinct credit_period from customer order by credit_period", // 0
"select distinct username from elb_quotations where username not in ('nadiah','chen','wongev','suiyee','yclim','metest')" , // 1
"select salesman_code,salesman_name from salesman", // 2
"select distinct groupcode from stockmasterdetails order by groupcode", // 3
"select distinct stock_cat from stockmasterdetails order by stock_cat", // 4
"select distinct category from customer where category is not null order by category", // 5

};

// hardcoded using sqlstsm - ref-header defined in repeatstuff.zs
public final void populateDynamic_Mysoft(int itype, Div idiv, String ilb_name, String istyle) throws SQLException
{
	Sql sql = als_mysoftsql();
	if(sql == null) return;
	String sqlstm = sqlstms[itype];

	String lbid = dumaLBId[itype];
	if(!ilb_name.equals("")) lbid = ilb_name; // use passed ID instead of predef

	Object[] lbheads = (Object[])dumaHeaders[itype];
	Listbox newlb = lbhand.makeVWListbox_onDB(idiv,lbheads,lbid,1,sql,sqlstm);
	sql.close();
	newlb.setMold("select");
	newlb.setStyle(istyle);
	newlb.setSelectedIndex(0); // def selected
}

public final void drawMultiColumnTickboxes(String iparentstr, Div iholder, String igridid, int ihowmanycol, String ichkstyle) throws SQLException
{
	List<GroovyRowResult> thedaa = getLookups_ByParent(iparentstr);
	if(thedaa == null) return;

	// remove previous
	if(iholder.getFellowIfAny(igridid) != null)
	{
		Component oldgrid = iholder.getFellow(igridid);
		oldgrid.setParent(null);
	}

	Grid newgrid = new Grid();
	newgrid.setId(igridid);
	Rows gridrows = new Rows();
	gridrows.setParent(newgrid);

	Row the_row = null;
	Checkbox chkbox;
	int colct = 0;
	boolean rowstart = false;

	for(GroovyRowResult dpi : thedaa)
	{
		if((colct % ihowmanycol) == 0)
		{
			the_row = gridhand.gridMakeRow("","","",gridrows);
		}

		String tickstr = (String)dpi.get("disptext");

		chkbox = new Checkbox(tickstr);
		chkbox.setStyle(ichkstyle);
		chkbox.setParent(the_row);

		colct++;
	}

	newgrid.setParent(iholder);
}

// 01/08/2012: knockoff from above but with title and title-style
public final void drawMultiColumnTickboxes_2(String iparentstr, Div iholder, String igridid,
int ihowmanycol, String ichkstyle, String ititle, String ititlestyle) throws SQLException
{
	List<GroovyRowResult> thedaa = getLookups_ByParent(iparentstr);
	if(thedaa == null) return;

	// remove previous
	if(iholder.getFellowIfAny(igridid) != null)
	{
		Component oldgrid = iholder.getFellow(igridid);
		oldgrid.setParent(null);
	}

	Grid newgrid = new Grid();
	newgrid.setId(igridid);
	Rows gridrows = new Rows();
	gridrows.setParent(newgrid);

	Row the_row = null;
	Checkbox chkbox;
	int colct = 0;
	boolean rowstart = false;

	if(!ititle.equals(""))
	{
		Row titrow = new Row();
		String spnst = String.valueOf(ihowmanycol);
		titrow.setSpans(spnst);
		titrow.setStyle(ititlestyle);
		Label titlabel = new Label();
		titlabel.setValue(ititle);
		titlabel.setParent(titrow);
		titrow.setParent(gridrows);
	}

	for(GroovyRowResult dpi : thedaa)
	{
		if((colct % ihowmanycol) == 0)
		{
			the_row = gridhand.gridMakeRow("","","",gridrows);
		}

		String tickstr = (String)dpi.get("disptext");

		chkbox = new Checkbox(tickstr);
		chkbox.setStyle(ichkstyle);
		chkbox.setParent(the_row);

		colct++;
	}

	newgrid.setParent(iholder);
}


// 01/08/2012: added to do multi-column radio-butts - holder is a Radiogroup instead of Div
public final void drawMultiColumnRadios(String iparentstr, Radiogroup iholder, String iradgid, 
int ihowmanycol, String ichkstyle, String ititle, String ititlestyle) throws SQLException
{
	List<GroovyRowResult> thedaa = getLookups_ByParent(iparentstr);
	if(thedaa == null) return;

	// remove previous
	if(iholder.getFellowIfAny(iradgid) != null)
	{
		Component oldrg = iholder.getFellow(iradgid);
		oldrg.setParent(null);
	}
	
	Grid newgrid = new Grid();
	newgrid.setId(iradgid);
	Rows gridrows = new Rows();
	gridrows.setParent(newgrid);

	Row the_row = null;
	Radio radiome;
	int colct = 0;
	boolean rowstart = false;
	
	if(!ititle.equals(""))
	{
		Row titrow = new Row();
		String spnst = String.valueOf(ihowmanycol);
		titrow.setSpans(spnst);
		titrow.setStyle(ititlestyle);
		Label titlabel = new Label();
		titlabel.setValue(ititle);
		titlabel.setParent(titrow);
		titrow.setParent(gridrows);
	}

	for(GroovyRowResult dpi : thedaa)
	{
		if((colct % ihowmanycol) == 0)
		{
			the_row = gridhand.gridMakeRow("","","",gridrows);
		}

		String tickstr = (String)dpi.get("disptext");

		radiome = new Radio(tickstr);
		radiome.setStyle(ichkstyle);
		radiome.setParent(the_row);

		colct++;
	}

	newgrid.setParent(iholder);
}

// Lookup-func: get value1-value8 from lookup table by parent-name
public final String getFieldsCommaString(String iparents, int icol) throws SQLException
{
	Generals kiboo = new Generals();
	List<GroovyRowResult> aprs = getLookups_ByParent(iparents);
	GroovyRowResult kk;
	String retv = ""; String tpm;
	String fld = "value" + Integer.toString(icol);
	for(Object di : aprs)
	{
		kk = (GroovyRowResult)di;
		tpm = kiboo.checkNullString((String)kk.get(fld));
		retv += tpm + ",";
	}

	retv = retv.replaceAll(",,",",");
	try {
	retv = retv.substring(0,retv.length()-1);
	} catch (Exception e) {}

	return retv;
}


}

