package org.victor;

/*
File: General purpose GUI funcs put them here
Written by: Victor Wong
Dated: 16/03/2012
Notes: Ported funcs from alsglobal_guifuncs.zs - compile byte-codes

*/

import java.util.*;
import java.io.*;
import java.sql.Connection;
import java.sql.DriverManager;
import javax.sql.DataSource;
import groovy.sql.*;
import org.zkoss.zk.ui.*;
import org.zkoss.zul.*;
import org.zkoss.image.*;
import org.victor.*;

public class GuiFuncs
{
	SecurityFuncs sechand;

	public GuiFuncs()
	{
		sechand = new SecurityFuncs();
	}
	
// Function to show pop-up message box, wrap for the system Messagebox.show class
public final void showMessageBox(String wmessage)
{
	try
	{
		Messagebox.show(wmessage,"Bong",Messagebox.OK,Messagebox.EXCLAMATION);
	}
	catch (Exception e) {}
}

// 29/9/2010: remove whatever in a DIV by component-ID
public final void removeComponentInDiv(Div idiv, String compid)
{
	if(idiv.getFellowIfAny(compid) != null)
	{
		Component kkb = (Component)idiv.getFellow(compid);
		kkb.setParent(null);
	}
}

// 26/03/2012: added iplayground for root-page name
// link new window or panel to parentdiv_name Div
// iplayground: //als_portal_main/ - page root
// winfn = window
// windId = window id , hardcoded usually in the other modules on how the newid would be
// uParams = parameters to be passed to the new window - coded in html-POST format - raw, no preprocessing in here
public final void globalActivateWindow(String iplayground, String parentdiv_name, String winfn, String windId, String uParams, Object uAO)
{
	Include newinclude = new Include();
	newinclude.setId(windId);
	String includepath = winfn + "?myid=" + windId + "&" + uParams;
	newinclude.setSrc(includepath);
	sechand.setUserAccessObj(newinclude, uAO); // securityfuncs.zs
	Div contdiv = (Div)Path.getComponent(iplayground + parentdiv_name);
	newinclude.setParent(contdiv);

} // end of globalActivateWindow()

// 26/03/2012: added iplayground for root-page name, idiv=DIV name
// For those subwindows opened in Div .. getcomponent is hardcoded
public final void globalCloseWindow(String iplayground, String theincludeid)
{
	//als_portal_main/miscwindows
	Div contdiv = (Div)Path.getComponent(iplayground + "miscwindows");
	Include thiswin = (Include)contdiv.getFellow(theincludeid);
	thiswin.setSrc("");
    contdiv.removeChild(thiswin);
}

// 26/03/2012: added iplayground for root-page name, idiv=DIV name
// For those panels opened in Div.. hardcoded id
public final void globalClosePanel(String iplayground, String idiv, String theincludeid)
{
	//als_portal_main/worksandbox
	Div contdiv = (Div)Path.getComponent(iplayground + idiv);
	Include thiswin = (Include)contdiv.getFellow(theincludeid);
	thiswin.setSrc("");
    contdiv.removeChild(thiswin);
}

public final void localActivateWindow(Div parentdiv_name, String winfn, String windId, String uParams, Object uAO)
{
	Include newinclude = new Include();
	newinclude.setId(windId);
	String includepath = winfn + "?myid=" + windId + "&" + uParams;
	newinclude.setSrc(includepath);
	sechand.setUserAccessObj(newinclude, uAO); // securityfuncs.zs
	newinclude.setParent(parentdiv_name);
} // end of globalActivateWindow()

// 7/7/2010: Try and load an image - have to catch non-exist-file error
AImage loadShowImage(Session isession, String ifilename)
{
	AImage retimage = null;

	try
	{
	FileInputStream finstream = new FileInputStream(isession.getWebApp().getRealPath(ifilename));
	int filesiz = finstream.available();
	retimage = new AImage("wiki",finstream);
	//finstream.close();
	}
	catch (Exception e) {}
	
	return retimage;
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

// Insert a branch/leaf onto the tree
// ibranch : have to create manually this one in caller
// ilabel : label for the branch/leaf
// istyle : label style , css thang
public final Treeitem insertTreeLeaf(Treechildren ibranch, String ilabel, String istyle)
{
	Treeitem titem = new Treeitem();
	Treerow newrow = new Treerow();
	Treecell newcell1 = new Treecell();
	newcell1.setLabel(ilabel);
	if(!istyle.equals("")) newcell1.setStyle(istyle);
	newcell1.setParent(newrow);
	newrow.setParent(titem);
	titem.setParent(ibranch);
	return titem;
}

public final Treeitem insertTreeLeaf_Multi(Treechildren ibranch, String[] ilabel_array, String istyle)
{
	Treeitem titem = new Treeitem();
	Treerow newrow = new Treerow();
	String[] strarray = new String[1];

	for(int i=0; i < ilabel_array.length; i++)
	{
		Treecell newcell1 = new Treecell();
		newcell1.setLabel(ilabel_array[i]);
		if(!istyle.equals("")) newcell1.setStyle(istyle);
		newcell1.setParent(newrow);
	}
	newrow.setParent(titem);
	titem.setParent(ibranch);
	return titem;
}

// Return treecell label - wcol=which column(0 start)
// 6/9/2010: try use this one
public final String getTreeItemLabel_Column(Treeitem titem, int wcol)
{
	String retval = "";
	Component aki;
	Object[] thechildren = titem.getChildren().toArray();
	if(thechildren.length > 0)
	{
		Component mikg = (Component)thechildren[0];
		Object[] grandchildren = mikg.getChildren().toArray();
		if(grandchildren.length >= wcol+1)
		{
			aki = (Component)grandchildren[wcol];
			if(aki instanceof Treecell)
			{
				Treecell wolu = (Treecell)aki;
				retval = wolu.getLabel();
			}
		}
	}
	return retval;
}

// icolumn zero-start : 0 = column 1, 1 = column 2
// this one is used to get from Treeitem instead of Listitem .. hmmm, actually can combine them
// 8/7/2010: recode this bugga - scan treeitem.children
// 6/9/2010: dont use this one. need some debugging.
public final String getTreecellItemLabel(Treeitem ilbitem, int icolumn)
{
	boolean done = false;
	String retval = "";
	Component kkb = null;
	Component workme = ilbitem;
	int childsize;

	while(!done)
	{
		Object[] thechildren = workme.getChildren().toArray();
		childsize = thechildren.length;
		for(int i=0; i<childsize; i++)
		{
			kkb = (Component)thechildren[i];
			if(kkb instanceof Treerow) workme = (Treerow)kkb;

			if(kkb instanceof Treecell)
			{
				if(icolumn == i)
				{
					done = true;
					Treecell aki = (Treecell)kkb;
					retval = aki.getLabel();
				}
			}
		}
	}
	return retval;
}

// 25/08/2014: Get Treecell from Treeitem by column
public final Treecell getTreecellItem(Treeitem ilbitem, int icolumn)
{
	boolean done = false;
	Treecell retval = null;
	Component kkb = null;
	Component workme = ilbitem;
	int childsize;

	while(!done)
	{
		Object[] thechildren = workme.getChildren().toArray();
		childsize = thechildren.length;
		for(int i=0; i<childsize; i++)
		{
			kkb = (Component)thechildren[i];
			if(kkb instanceof Treerow) workme = (Treerow)kkb;

			if(kkb instanceof Treecell)
			{
				if(icolumn == i)
				{
					done = true;
					retval = (Treecell)kkb;
				}
			}
		}
	}
	return retval;	
}
	
}

