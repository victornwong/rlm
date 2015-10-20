package org.victor;

/*
File: Listbox header object
Written by: Victor Wong
Dated: 22/07/2014

New class to include style

*/

public class listboxHeaderWS extends listboxHeaderWidthObj
{
	//public String header_str;
	//public boolean header_visible;
	//public String width;
	public String thestyle;

	public listboxHeaderWS(String iheaderstr, boolean iheadvisible, String iwidth, String istyle)
	{
		super(iheaderstr, iheadvisible, iwidth);
		thestyle = istyle;
	}
}
