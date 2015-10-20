package org.victor;

import java.util.*;
import java.io.*;
import java.sql.Connection;
import java.sql.DriverManager;
import javax.sql.DataSource;
import groovy.sql.*;
import org.zkoss.zk.ui.*;
import org.zkoss.zul.*;

/*
File: Listbox handler funcs - knock from alsglobal_guifuncs.zs
Written by: Victor Wong
Dated: 12/03/2012

String manis = (String)this.getDesktop().getPage("rndstuff_mod").getZScriptVariable("manis");
*/

public class ListboxHandler extends Generals
{

public final String trimListitemLabel(String istr, int maxleng)
{
	String retval = istr;
	if(istr.length() > maxleng) retval = istr.substring(0,maxleng);
	return retval;
}

/****************************************************************************
Populate a listbox with items. Create new listcell for each string passed.
listbox can have multiple columns then.

Parameter:
wlistbox = listbox to populate
toput = string array to use
istyle = style, default to "font-size:9px"
***************************************************************************
*/
public final Listitem insertListItems(Listbox wlistbox, String[] toput, String dragdropCode, String istyle)
{
	if(istyle.equals("")) istyle = "font-size:9px";

	// 18/01/2010 - dragdropCode = for drag-drop function, to match name-identifier when dropped.
	if(dragdropCode.equals("")) dragdropCode = "true";

	Listitem litem = new Listitem();
	int i = 0;

	for(String tstr : toput)
	{
		Listcell lcell = new Listcell();
        String tstr2 = tstr.trim();
		if(i == 0)
		{
			lcell.setDraggable(dragdropCode);
			i++;
		}
		
		lcell.setLabel(tstr2);
		// can modify
		lcell.setStyle(istyle);
		lcell.setParent(litem);
	}
    // litem.setDraggable("true");
	litem.setParent(wlistbox);
	return litem;
}

// Make a listbox with headers - headers stuff def in listboxHeaderObj
// mDiv = where to put the listbox
// listbox_headers = array of listboxHeaderObj
// ilistbox_id = listbox id
// numorows = how many rows to set for listbox
public final Listbox makeVWListbox(Div mDiv, Object[] listbox_headers, String ilistbox_id, int numorows)
{
	// if there's previously a listbox, remove before adding a new one
	Listbox oldlb = (Listbox)mDiv.getFellowIfAny(ilistbox_id);
	if(oldlb != null) oldlb.setParent(null);

	Listbox newlb = new Listbox();
	newlb.setId(ilistbox_id);
	newlb.setVflex(true);
	Listhead newhead = new Listhead();
	newhead.setSizable(true);
	newhead.setParent(newlb);

	for(int i=0; i < listbox_headers.length; i++)
	{
		listboxHeaderObj ilo = (listboxHeaderObj)listbox_headers[i];

	    Listheader mehd = new Listheader();
	    mehd.setLabel(ilo.header_str);
		mehd.setVisible(ilo.header_visible);
		mehd.setSort("auto");
		mehd.setParent(newhead);
	}
	newlb.setRows(numorows);
	newlb.setParent(mDiv);
	return newlb;
}

// 12/10/2011: modded func that take width string to form column - uses class listboxHeaderWidthObj
public final Listbox makeVWListbox_Width(Div mDiv, Object[] listbox_headers, String ilistbox_id, int numorows)
{
	// if there's previously a listbox, remove before adding a new one
	Listbox oldlb = (Listbox)mDiv.getFellowIfAny(ilistbox_id);
	if(oldlb != null) oldlb.setParent(null);
	Listbox newlb = new Listbox();
	newlb.setId(ilistbox_id);
	newlb.setVflex(true);
	Listhead newhead = new Listhead();
	newhead.setSizable(true);
	newhead.setParent(newlb);

	for(int i=0; i < listbox_headers.length; i++)
	{
		listboxHeaderWidthObj ilo = (listboxHeaderWidthObj)listbox_headers[i];
	    Listheader mehd = new Listheader();
	    mehd.setLabel(ilo.header_str);
		mehd.setVisible(ilo.header_visible);
		mehd.setSort("auto");
		if(!ilo.width.equals("")) mehd.setWidth(ilo.width);
		mehd.setParent(newhead);
	}
	newlb.setRows(numorows);
	newlb.setParent(mDiv);
	return newlb;
}

// Same as makeVWListbox but with footer string - to show number of recs or whatever
public final Listbox makeVWListboxWithFooter(Div mDiv, Object[] listbox_headers, String ilistbox_id, int numorows, String footstring)
{
	Listbox thelb = makeVWListbox(mDiv,listbox_headers,ilistbox_id,numorows);
	Listfoot newfooter = new Listfoot();
	newfooter.setParent(thelb);
	Listfooter fd1 = new Listfooter();
	fd1.setLabel("Found:");
	fd1.setParent(newfooter);
	Listfooter fd2 = new Listfooter();
	fd2.setLabel(footstring);
	fd2.setParent(newfooter);
	return thelb;
}

// GUI func: knockoff from makeVWListBox and with database access thing
// db fieldtype : 1=varchar, 2=int, 3=date
public final Listbox makeVWListbox_onDB(Div mDiv, Object[] listbox_headers, String ilistbox_id, int numorows, Sql isql, String isqlstm)
{
	//Generals kiboo = new Generals();
	List<GroovyRowResult> dbrecs = null;
	Listbox thelb = makeVWListbox(mDiv,listbox_headers,ilistbox_id,numorows);
	try
	{
		dbrecs = isql.rows(isqlstm);
	}
	catch (Exception e) { }

	if(dbrecs == null) return null;
	if(dbrecs.size() == 0) { return thelb; } // no recs, just return a blank listbox

	String tobeadded = "---";
	String ffname = "";
	Object thevalue = null;
	int ftyp;

	for(GroovyRowResult dpi : dbrecs)
	{
		ArrayList kabom = new ArrayList();
		for(int i=0; i < listbox_headers.length; i++)
		{
			dblb_HeaderObj ilo = (dblb_HeaderObj)listbox_headers[i];
			ftyp = (int)ilo.db_fieldtype;
			ffname = (String)ilo.db_fieldname;
			thevalue = dpi.get(ffname);

			if(thevalue != null)
			{
				switch(ftyp)
				{
					case 1:
						tobeadded = (String)thevalue;
						break;
					case 2:
						tobeadded = String.valueOf(thevalue);
						break;
					case 3:
						tobeadded = thevalue.toString().substring(0,10);
						break;
				}
			}
			kabom.add(tobeadded);
		}
		String[] strarray = convertArrayListToStringArray(kabom);
		insertListItems(thelb,strarray,"false","");
	}
	return thelb;
}

// 1/4/2010: insert item into listbox but with dragdrop set to certain column
// icolumn = icolumn - 1 ( 1 = start)
public final void insertListItems_DragDrop(Listbox wlistbox, String[] toput, String dragdropCode, int icolumn, String istyle)
{
	if(istyle.equals("")) istyle = "font-size:9px";
	if(dragdropCode.equals("")) dragdropCode = "true";

	Listitem litem = new Listitem();

	int i = 0;
	int iwcol = icolumn - 1;

	for(String tstr : toput)
	{
		Listcell lcell = new Listcell();
		String tstr2 = tstr.trim();
		if(i == iwcol) lcell.setDraggable(dragdropCode);
		lcell.setLabel(tstr2);
		lcell.setStyle(istyle);
		lcell.setParent(litem);
		i++;
	}
	litem.setParent(wlistbox);
}

/****************************************************************************
Global func to insert drop-down items into a Listbox type "select"
wlistb = listbox object
iarray = single-dim strings array
eg:
	<listbox mold="select" rows="1" id="wowo" />
	String[] mearr = { "this", "and", "that", "equals", "to", "nothing" };
	populateDropdownListbox(wowo, mearr);
****************************************************************************
*/
public final void populateDropdownListbox(Listbox wlistb, String[] iarray)
{
	String[] strarray = new String[1];
	for(int i=0; i < iarray.length; i++)
	{
		strarray[0] = iarray[i];
		insertListItems(wlistb,strarray,"true","");
	}
	// set selected-index for listbox to the first item
	// can recode this section to be able to select item which matches the one passed in arg.
	wlistb.setSelectedIndex(0);
}

// icolumn zero-start : 0 = column 1, 1 = column 2
// this one for listitem
public final String getListcellItemLabel(Listitem ilbitem, int icolumn)
{
	List prevrc = ilbitem.getChildren();
	Listcell prevrc_2 = (Listcell)prevrc.get(icolumn);
	return prevrc_2.getLabel();
}

// Set listitem -> listcell -> icolumn -> label
// icolumn: which column, 0 = column 1
public final void setListcellItemLabel(Listitem ilbitem, int icolumn, String iwhat)
{
	List prevrc = ilbitem.getChildren();
	Listcell prevrc_2 = (Listcell)prevrc.get(icolumn); // get the second column listcell
	prevrc_2.setLabel(iwhat);
}

// Match listbox item with iwhatstr on which icolumn, return Listitem so caller can get whichever column's label
public final Listitem matchListboxReturnListItem(Listbox ilb, String iwhatstr, int icolumn)
{
	Listitem retval = null;
	int icc = ilb.getItemCount();
	if(icc == 0) return null; // nothing.. return

	for(int i=0; i<icc; i++)
	{
		Listitem ilabel = ilb.getItemAtIndex(i);
		String kkk = getListcellItemLabel(ilabel, icolumn);
		if(kkk.equals(iwhatstr)) // if match found
		{
			retval = ilabel;
			break;
		}
	}
	return retval;
}

// Match item in listbox, set label for listitem
// iwhich = string to match in listbox
// cellpos = listcell position (starts 0)
// newlabel = label to set in this listcell
public final void matchItemUpdateLabel(Listbox ilistbox, String iwhich, int cellpos, String newlabel)
{
	for(int i=0; i<ilistbox.getItemCount(); i++)
	{
		Listitem kkk = ilistbox.getItemAtIndex(i);
		String kklbl = kkk.getLabel();
		
		if(kklbl.equals(iwhich))
		{
			List kkchild = kkk.getChildren();
			Listcell iwhere = (Listcell)kkchild.get(cellpos);
			iwhere.setLabel(newlabel);
		}
	
	}
}

// general purpose func to match string to listbox item and set selected index
public final void matchListboxItems(Listbox ilb, String iwhich)
{
	int icc = ilb.getItemCount();
	if(icc == 0) return; // nothing.. return
	// incase of no match found, set selected index to 0 - first item
	ilb.setSelectedIndex(0);
	boolean ifound = false;
	for(int i=0; i<icc; i++)
	{
		Listitem ilabel = ilb.getItemAtIndex(i);
		// if match found
		if(ilabel.getLabel().equals(iwhich))
		{
			ilb.setSelectedIndex(i);
			ifound = true;
			break;
		}
	}
}

public final void matchListboxItemsColumn(Listbox ilb, String iwhich, int icolumn)
{
	int icc = ilb.getItemCount();
	if(icc == 0) return; // nothing.. return
	// incase of no match found, set selected index to 0 - first item
	ilb.setSelectedIndex(0);
	boolean ifound = false;
	for(int i=0; i<icc; i++)
	{
		Listitem ilabel = ilb.getItemAtIndex(i);
		String kkk = getListcellItemLabel(ilabel, icolumn);
		if(kkk.equals(iwhich)) // if match found
		{
			ilb.setSelectedIndex(i);
			ifound = true;
			break;
		}
	}
}

// 1/4/2010: check if iwhich is in ilb , can do column using icolumn (zero-start, check getListcellItem())
public final boolean ExistInListbox(Listbox ilb, String iwhich, int icolumn)
{
	int icc = ilb.getItemCount();
	if(icc == 0) return false; // nothing.. return
	boolean ifound = false;
	for(int i=0; i<icc; i++)
	{
		Listitem ilabel = ilb.getItemAtIndex(i);
		String kkk = getListcellItemLabel(ilabel, icolumn);
		if(kkk.equals(iwhich))
		{
			ifound = true;
			break;
		}
	}
	return ifound;
}

// 1/4/2010: remove an item from the listbox, iwhich = string to match, icolumn = which column to check iwhich (zero-start)
public final void removeItemFromListBox(Listbox ilb, String iwhich, int icolumn)
{
	int icc = ilb.getItemCount();
	if(icc == 0) return; // nothing.. return

	for(int i=0; i<icc; i++)
	{
		Listitem ilabel = ilb.getItemAtIndex(i);
		String kkk = getListcellItemLabel(ilabel, icolumn);
		if(kkk.equals(iwhich))
		{
			// remove from listbox
			ilb.removeItemAt(i);
			break;
		}
	}
}

// 26/8/2010: GUI funcs: make all listitems to accept
public final void setDoubleClick_ListItems(Listbox wlistbox, org.zkoss.zk.ui.event.EventListener eventfunc)
{
	int itmc = wlistbox.getItemCount();
	if(itmc == 0) return;
	for(int i=0; i<itmc; i++)
	{
		Listitem woki = (Listitem)wlistbox.getItemAtIndex(i);
		woki.addEventListener("onDoubleClick", eventfunc);
	}
}

// 17/9/2010: GUI func: check if listbox exist in DIV and selected item in listbox
public final boolean check_ListboxExist_SelectItem(Div idiv, String lbid)
{
	boolean retval = false;
	if(idiv.getFellowIfAny(lbid) != null)
	{
		Listbox kkb = (Listbox)idiv.getFellowIfAny(lbid);
		if(kkb.getSelectedIndex() != -1) retval = true;
	}
	return retval;
}

}

