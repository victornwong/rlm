package org.victor;

/*
File: Listbox header object - knock from alsglobal_guifuncs.zs
Written by: Victor Wong
Dated: 13/03/2012

To define those simple listbox header in all modules - this one to dig DB-tables field

*/

public class listboxHeaderWidthObj extends listboxHeaderObj
{
	//public String header_str;
	//public boolean header_visible;
	public String width;

	public listboxHeaderWidthObj(String iheaderstr, boolean iheadvisible, String iwidth)
	{
		super(iheaderstr, iheadvisible);
		//header_str = iheaderstr;
		//header_visible = iheadvisible;
		width = iwidth;
	}
}

