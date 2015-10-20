package org.victor;

import java.util.*;
import java.text.*;
import java.io.*;
//import org.zkoss.zk.ui.*;
import org.zkoss.zk.ui.*;
import org.zkoss.zul.*;

/*
Purpose: Global general purpose <grid> handling functions we put them here
Written by : Victor Wong
Date : 13/03/2012
Notes:

*/

public class GridHandler extends GlobalDefs
{
	// empty constructor
	void GridHandler()	{ }
	
// Make a new label component and attach to parent
public final void makeLabelToParent(String ivalue, String istyle, Object iparent)
{
	Label thelabel = new Label();
	thelabel.setValue(ivalue);
	if(istyle.equals("")) istyle="font-size:9px";
	thelabel.setStyle(istyle);
	thelabel.setParent((Component)iparent);
}

// Make a new label component and attach to parent
public final void makeLabelMultilineToParent(String ivalue, String istyle, Object iparent)
{
	Label thelabel = new Label();
	thelabel.setValue(ivalue);
	if(istyle.equals("")) istyle="font-size:9px";
	thelabel.setStyle(istyle);
	thelabel.setMultiline(true);
	thelabel.setParent((Component)iparent);
}

// <GRID> related : make <ROWS> object
public final Rows gridMakeRows(String theid, String istyle, Object iparent)
{
	Rows therows = new Rows();
	if(!istyle.equals("")) therows.setStyle(istyle);
	if(!theid.equals("")) therows.setId(theid);
	therows.setParent((Component)iparent);
	return therows;
}

// <GRID> related : make <ROW> object
public final Row gridMakeRow(String theid, String istyle, String ispans, Object iparent)
{
	Row therow = new Row();
	if(!istyle.equals("")) therow.setStyle(istyle);
	if(!theid.equals("")) therow.setId(theid);
	if(!ispans.equals("")) therow.setSpans(ispans);
	therow.setParent((Component)iparent);
	return therow;
}

public final Textbox makeTextboxToParent(String ivalue, String istyle, String iwidth, String iheight, boolean imultiline, Object iparent)
{
	Textbox thetextbox = new Textbox();
	thetextbox.setValue(ivalue);
	if(istyle.equals("")) istyle="font-size:9px";
	if(imultiline)
	{
		thetextbox.setMultiline(imultiline);
		thetextbox.setHeight(iheight);
	}
			
	if(!iwidth.equals("")) thetextbox.setWidth(iwidth);
	thetextbox.setStyle(istyle);
	thetextbox.setParent((Component)iparent);
	return thetextbox;
}

public final void makeGridHeaderColumns(String[] icols, Object iparent)
{
	Columns colms = new Columns();
	for(int i=0; i<icols.length; i++)
	{
		Column hcolm = new Column();
		hcolm.setLabel(icols[i]);

		Comp asc = new Comp(true,i);
		Comp dsc = new Comp(false,i);

		hcolm.setSortAscending(asc);
		hcolm.setSortDescending(dsc);

		hcolm.setStyle("font-size:9px");
		hcolm.setParent(colms);	
	}
	colms.setParent((Component)iparent);
}

public final void makeGridHeaderColumns_Width(String[] icols, String[] iwidths, Object iparent)
{
	Columns colms = new Columns();
	for(int i=0; i<icols.length; i++)
	{
		Column hcolm = new Column();
		hcolm.setLabel(icols[i]);
		Comp asc = new Comp(true,i);
		Comp dsc = new Comp(false,i);
		hcolm.setSortAscending(asc);
		hcolm.setSortDescending(dsc);
		hcolm.setStyle("font-size:9px");
		hcolm.setWidth(iwidths[i]);
		hcolm.setParent(colms);	
	}
	colms.setParent((Component)iparent);
}

// Create and attach Comboitem to Combobox .. uses string-array iwhat
public final void makeComboitem(Combobox icombobox, String[] iwhat)
{
	for(int i=0;i<iwhat.length;i++)
	{
		Comboitem citem = new Comboitem();
		citem.setLabel(iwhat[i]);
		citem.setParent((Component)icombobox);
	}	
}

// knock-off from above, but with ID string and parent obj
public final void makeComboitem2(Combobox icombobox, String[] iwhat, String itheid, Object itheparent)
{
	for(int i=0;i<iwhat.length;i++)
	{
		Comboitem citem = new Comboitem();
		citem.setLabel(iwhat[i]);
		citem.setParent(icombobox);
	}

	icombobox.setStyle("font-size:9px");
	icombobox.setId(itheid);
	icombobox.setParent((Component)itheparent);
}

// Make blank-label to fill-up column in <grid><rows><row>
public final void grid_makeBlankColumn(Row theparent, int howmany)
{
	for(int i=0;i<howmany;i++)
	{
		makeLabelToParent("","",(Component)theparent);
	}
}

}
// ENDOF public class GridHandler

