/**
* Global definitions and things for the system
*/
STKIN_PREFIX = "STKIN";
STKOUT_PREFIX = "STKOUT";
WORKORDER_PREFIX = "MYWO";
PO_PREFIX = "MYPO"; // Malaysia PO prefix - change to others when reqd

Float GST_RATE = 0.06;

PANEL_WIDTH = "1200px";
KANBAN_WIDTH = "1300px";

PRIORITY_MEDIUM_STYLE = "background:#D5E72E;font-size:9px;font-weight:bold";
PRIORITY_HIGH_STYLE = "background:#E25423;font-size:9px;font-weight:bold";
PRIORITY_ZTC_STYLE = "background:#F60D0D;font-size:9px;font-weight:bold";

UNKNOWN_STRING = "UNKWN";

SUPP_FORM_STYLE = "background:#1D7FDA";
MPFPOP_BACKGROUND = "background:#D66A0E";
WODETAIL_STYLE = "background:#339ABC";
ENTRYFORM_STYLE = "background:#2299B0";
LISTPOBACKGROUND = "background:#1F50C8";
NEWSTOCKITEM_BACKGROUND = "background:#16BB6A";
WORKAREA_BACKGROUND = "background:#208EC7";

// used in supplierManPanel_v1.zul
SUPP_FORM_STYLE = "background:#D77272";
SUPP_FORM_STYLE2 = "background:#DE3E0E";

// Work-order stage names
WOSTAGE_NEW = "NEW";
WOSTAGE_WIP = "WIP";
WOSTAGE_TRANS = "TRANSIT";
WOSTAGE_DONE = "DONE";
WOSTAGE_KIV = "KIV";

STKIN_LOCATION_LABEL = "rlm/stockidlabel_v1.rptdesign";


BIRT_WEBVIEWER_SHORT = "/birt/frameset?__report=";
EXTERNAL_BIRTVIEWER = "http://192.168.130.198:8080/BIRT/frameset?__report=";

// Make the BIRT URL outta ZK Executions.getCurrent() stuff
String birtURL()
{
	callscheme = Executions.getCurrent().getScheme();
	theurl = Executions.getCurrent().getServerName();
	theport = Executions.getCurrent().getServerPort().toString();
	return callscheme + "://" + theurl + ":" + theport + BIRT_WEBVIEWER_SHORT;
}
