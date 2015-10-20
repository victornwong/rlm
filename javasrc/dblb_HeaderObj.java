package org.victor;

/*
File: Listbox header object - knock from alsglobal_guifuncs.zs
Written by: Victor Wong
Dated: 13/03/2012

To define those simple listbox header in all modules - this one to dig DB-tables field

*/

public class dblb_HeaderObj extends listboxHeaderObj
{
	//public String header_str;
	//public boolean header_visible;
	public String db_fieldname;
	public int db_fieldtype;

	// constructor: ifieldname = table fieldname, ifieldtype = field-type (1=varchar,2=int,3=date)
	public dblb_HeaderObj(String iheaderstr, boolean iheadvisible, String ifieldname, int ifieldtype)
	{
		super(iheaderstr,iheadvisible);
		//header_str = iheaderstr;
		//header_visible = iheadvisible;
		db_fieldname = ifieldname;
		db_fieldtype = ifieldtype;
	}
}

