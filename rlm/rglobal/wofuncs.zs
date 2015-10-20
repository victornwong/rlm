/**
 * Work-orders related funcs - lister and etc
 * Written by Victor Wong
 */

String getSTKOUT_byWorkOrder(String iwo)
{
	String retval = "";
	String wko = WORKORDER_PREFIX + " " + iwo;
	String sqlstm = "select Id from tblStockOutMaster where WorksOrder='" + wko + "';";
	r = sqlhand.rws_gpSqlGetRows(sqlstm);

	if(r.size() > 0)
	{
		for(d : r)
		{
			retval += STKOUT_PREFIX + d.get("Id").toString() + " ";
		}
	}
	return retval;
}

void viewSTKOUT_small(String iwos)
{
	if(iwos.equals("")) return;
	wos = iwos.split(" ");
	for(i=0; i<wos.length; i++)
	{
		wo = wos[i].replaceAll(STKOUT_PREFIX,"");
		r = getOutboundRec(wo);
		if(r != null)
		{
			//"Address1","Address2","Address3","Address4","customer_name",
			//"telephone","fax","email","contact","salesrep","order_type","WorksOrder"

			kwin = ngfun.vMakeWindow(windowsholder,"Outbound " + wos[i], "1", "center", "400px", "");

			smy = "Customer: " + kiboo.checkNullString(r.get("customer_name")) +
			"\nContact: " + kiboo.checkNullString(r.get("contact")) + "\nTel: " + kiboo.checkNullString(r.get("telephone")) + 
			"\nEmail: " + kiboo.checkNullString(r.get("email")) + "\nWH stage: " + r.get("stage");

			itmh = new Div(); itmh.setParent(kwin); itmh.setSclass("shadowbox"); itmh.setStyle("background:#ED400E");
			kk = ngfun.gpMakeLabel(itmh,"",smy,"");
			kk.setMultiline(true); kk.setStyle("color:#ffffff");

			newlb = showOutboundItems(r,itmh,"outitems_lb" + i.toString(),OBITEMS_QTY_ONLY,5);
		}
	}
}

/**
 * [showWorkOrder_meta description]
 * @param iwo selected work-order origid
 * @return work-order record
 */
Object showWorkOrder_meta(String iwo)
{
	wr = getWorkOrderRec(iwo);

	w_origid.setValue( WORKORDER_PREFIX + " " + iwo);
	ngfun.populateUI_Data(wocustomermetaboxes,wocustomermfields,wr);
	ngfun.populateUI_Data(woextrameta,woextramfields,wr);

	wograndtotal_lbl.setValue(""); // clear them totals and gst
	gst_lbl.setValue("");

	newlb = showWorkOrder_items(wr,things_holder,"things_lb",1,MAX_WORKORDER_ITEMS_ROWS);
	if(newlb != null)
	{
		gp_calcPOTotal(newlb,WOI_SUBTOTAL_POS,wograndtotal_lbl,"");
		gp_calcGST(wograndtotal_lbl,GST_RATE,gst_lbl,"");
	}

	// show them IRIS codes
	lbhand.matchListboxItemsColumn(iris_position, kiboo.checkNullString(wr.get("iris_position")), 1);
	lbhand.matchListboxItemsColumn(iris_defect, kiboo.checkNullString(wr.get("iris_defect")), 1);
	lbhand.matchListboxItemsColumn(iris_section, kiboo.checkNullString(wr.get("iris_section")), 1);
	lbhand.matchListboxItemsColumn(iris_repair, kiboo.checkNullString(wr.get("iris_repair")), 1);

	if(wr.get("iris_code") != null)
	{
		kk = wr.get("iris_code").split("-");
		try { iris_condition_code.setValue(kk[0]); } catch (Exception e) {}
		try { iris_problem_code.setValue(kk[1]); } catch (Exception e) {}
		try { iris_extended_code.setValue(kk[2]); } catch (Exception e) {}
	}
	
	wko = getSTKOUT_byWorkOrder(iwo); // show STKOUT if any
	WorksOrder_ref.setValue(wko);

	workarea.setVisible(true);
	return wr;
}

Object[] wohds2 = // for other modu - show min WO details just for picking
{
	new listboxHeaderWidthObj(WORKORDER_PREFIX,true,"60px"),
	new listboxHeaderWidthObj("Dated",true,"70px"),
	new listboxHeaderWidthObj("Customer",true,""),
	new listboxHeaderWidthObj("Contact",true,""),
	new listboxHeaderWidthObj("W.Type",true,"80px"),
	new listboxHeaderWidthObj("Serial",false,"80px"), // 5
	new listboxHeaderWidthObj("Model",false,"80px"),
	new listboxHeaderWidthObj("Warranty",false,"80px"),
	new listboxHeaderWidthObj("Status",false,"70px"),
	new listboxHeaderWidthObj("Stage",false,"70px"),
	new listboxHeaderWidthObj("arcode",false,""), // 10
	new listboxHeaderWidthObj("Priority",false,"70px"),
	new listboxHeaderWidthObj("User",false,"70px"),
};

Object[] wohds1 =
{
	new listboxHeaderWidthObj(WORKORDER_PREFIX,true,"60px"),
	new listboxHeaderWidthObj("Dated",true,"70px"),
	new listboxHeaderWidthObj("Customer",true,""),
	new listboxHeaderWidthObj("Contact",true,""),
	new listboxHeaderWidthObj("W.Type",true,"80px"),
	new listboxHeaderWidthObj("Serial",true,"80px"), // 5
	new listboxHeaderWidthObj("Model",true,"80px"),
	new listboxHeaderWidthObj("Warranty",false,"80px"),
	new listboxHeaderWidthObj("Status",true,"70px"),
	new listboxHeaderWidthObj("Stage",true,"70px"),
	new listboxHeaderWidthObj("arcode",false,""), // 10
	new listboxHeaderWidthObj("Priority",true,"70px"),
	new listboxHeaderWidthObj("User",true,"70px"),
	new listboxHeaderWidthObj("Tech",true,"70px"),
	new listboxHeaderWidthObj("Pickup",true,"70px"),
};
WO_ORIGID_POS = 0;
WO_CUSTOMER_POS = 2;
WO_WORKTYPE_POS = 4;
WO_SERIALNO_POS = 5;
WO_MODEL_POS = 6;
WO_STATUS_POS = 8;
WO_STAGE_POS = 9;
WO_ARCODE_POS = 10;
WO_PRIORITY_POS = 11;
WO_USERNAME_POS = 12;
WO_TECHNICIAN_POS = 13;
WO_TECHPICKUP_POS = 14;

last_list_wo = 0;

class wolbclicker implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(Event event) throws UiException
	{
		workOrder_callBack(event.getReference());
	}
}
workorderlb_cliker = new wolbclicker();

class wolbdclikcer implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(Event event) throws UiException
	{
		isel = event.getTarget();
		try
		{
			workOrder_dc_callBack(isel);
		} catch (Exception e) {}
	}
}
workorderlb_dcliker = new wolbdclikcer();

/**
 * When listing by technician/user, only non DRAFT will show.
 * @param iholder [description]
 * @param ilbid   [description]
 * @param istart  [description]
 * @param iend    [description]
 * @param isearch [description]
 * @param ibywo   [description]
 * @param itype   [description]
 * @param ifull   show full headers WO or min. for picking by other modu
 */
void listWorkOrders(Div iholder, String ilbid, Datebox istart, Datebox iend,
	Textbox isearch, Textbox ibywo, int itype, boolean ifull)
{
	last_list_wo = itype;
	hds = (ifull) ? wohds1 : wohds2;
	Listbox newlb = lbhand.makeVWListbox_Width(iholder, hds, ilbid, 3);

	sqlstm = "select origid,datecreated,customer_name,ar_code,contact," +
	"work_type,serial_no,model,warrantycard,status,stage,priority,username,technician,stage_date from workorders ";

	unm = "AH_PAI";
	try { unm = useraccessobj.username; } catch (Exception e) {}

	sdate = kiboo.getDateFromDatebox(istart);
	edate = kiboo.getDateFromDatebox(iend);

	sti = "";
	try { sti = Integer.parseInt(ibywo.getValue().trim()).toString(); } catch (Exception e) {}

	st = kiboo.replaceSingleQuotes(isearch.getValue().trim());

	switch(itype)
	{
		case 1: // by start-end date and search-text if any
			sqlstm += "where datecreated between '" + sdate + " 00:00:00' and '" + edate + " 23:59:00' ";
			if(!st.equals(""))
				sqlstm += " and (customer_name like '%" + st + "%' or work_type like '%" + st + "%' or stage like '%" + st + "%');";

			break;

		case 2:
			if(sti.equals("")) return;
			sqlstm += "where origid=" + sti;
			break;

		case 3: // by technician and date-range, the login user - used for work-order fulfillment
			sqlstm += "where datecreated between '" + sdate + " 00:00:00' and '" + edate + " 23:59:00' and " +
				"technician='" + unm + "' and status<>'DRAFT' order by datecreated desc";
			break;

		case 4: // by technician and work-order if it belongs to him
			if(sti.equals("")) return;
			sqlstm += "where technician='" + unm + "' and status<>'DRAFT' and  and origid=" + sti;
			break;

		case 5: // list all work-order by technician/username
			sqlstm += "where technician='" + unm + "' and status<>'DRAFT' order by datecreated desc;";
			break;
	}

	if(DEBUG_MODE) debugbox.setValue(sqlstm);
	r = sqlhand.rws_gpSqlGetRows(sqlstm);
	if(r.size() == 0) return;
	newlb.setRows(15); newlb.setMold("paging"); // newlb.setMultiple(true); newlb.setCheckmark(true); 
	newlb.addEventListener("onSelect", workorderlb_cliker);

	String[] fl = { "origid","datecreated","customer_name","contact","work_type",
	"serial_no","model","warrantycard","status","stage","ar_code","priority","username","technician","stage_date" };
	ArrayList kabom = new ArrayList();

	for(d : r)
	{
		ngfun.popuListitems_Data(kabom,fl,d);
		sty = "";
		// check on priority and set style
		if(d.get("priority").equals("MEDIUM")) sty = PRIORITY_MEDIUM_STYLE;
		if(d.get("priority").equals("HIGH")) sty = PRIORITY_HIGH_STYLE;
		if(d.get("priority").equals("ZERO_TOLERANCE")) sty = PRIORITY_ZTC_STYLE;

		li = lbhand.insertListItems(newlb,kiboo.convertArrayListToStringArray(kabom),"false",sty);
		if(d.get("priority").equals("ZERO_TOLERANCE")) li.setSclass("blink");

		kabom.clear();
	}
	lbhand.setDoubleClick_ListItems(newlb, workorderlb_dcliker);

	//return newlb;
}

Object[] woitemshds =
{
	new listboxHeaderWidthObj("No.",true,"60px"),
	new listboxHeaderWidthObj("Problem",true,""),
	new listboxHeaderWidthObj("Solution",true,""),
	new listboxHeaderWidthObj("StockCode",true,"130px"),
	new listboxHeaderWidthObj("stkid",true,""),
	new listboxHeaderWidthObj("Qty",true,"50px"),
	new listboxHeaderWidthObj("U/Price",true,"70px"),
	new listboxHeaderWidthObj("SubTotal",true,"70px"),
};
WOI_PROBLEM_POS = 1;
WOI_SOLUTION_POS = 2;
WOI_STOCKCODE_POS = 3;
WOI_STKID_POS = 4;
WOI_QTY_POS = 5;
WOI_UPRICE_POS = 6;
WOI_SUBTOTAL_POS = 7;

class woitemdclicker implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(Event event) throws UiException
	{
		isel = event.getTarget();
		try
		{
			woItems_callBack(isel);
		} catch (Exception e) {}
	}
}
woitem_dclicker = new woitemdclicker();

MAX_WORKORDER_ITEMS_ROWS = 8;

/**
 * [insertWOitem description]
 * @param iholder DIV holder
 * @param ilbid   listbox string ID
 * @param howmany how many to insert
 */
void insertWOitem(Div iholder, String ilbid, int howmany)
{
	newlb = iholder.getFellowIfAny(ilbid);
	if(newlb == null)
	{
		newlb = lbhand.makeVWListbox_Width(iholder, woitemshds, ilbid, MAX_WORKORDER_ITEMS_ROWS);
		newlb.setMultiple(true); newlb.setCheckmark(true);
	}

	ArrayList kabom = new ArrayList();
	for(i=0;i<howmany;i++)
	{
		kabom.add("0"); kabom.add("NEW PROBLEM"); kabom.add("NO SOLUTION"); // no. , problem, solution
		kabom.add(UNKNOWN_STRING); kabom.add("0"); // stock-code, stk-id
		kabom.add("0"); kabom.add("0"); kabom.add("0"); // qty,uprice,subtotal
		lbhand.insertListItems(newlb,kiboo.convertArrayListToStringArray(kabom),"false","");
		lbhand.setDoubleClick_ListItems(newlb, woitem_dclicker); // refresh the double-clicker for added item
	}
	renumberListbox(newlb,0,1,true);	
}

/**
 * Show work-order items - can be used in other modu
 * @param  iob      work-order db record
 * @param  iholder  DIV holder
 * @param  ilbid    listbox ID
 * @param  showtype 0=without subtotal, 1=with subtotal
 * @param  imaxrows max rows for listbox
 * @return          created listbox
 */
Listbox showWorkOrder_items(Object iob, Div iholder, String ilbid, int showtype, int imaxrows)
{
	//newlb = iholder.getFellowIfAny(ilbid);
	//if(newlb != null) newlb.setParent(null); // always remove old listbox

	//hdrs = (showtype == 1) ? outbitemshds : outbitems_noprice_hds; // select show-type listbox headers
	hdrs = woitemshds;
	newlb = lbhand.makeVWListbox_Width(iholder, hdrs, ilbid, 3);
	newlb.setMultiple(true); newlb.setCheckmark(true);

	itmcount = 0;
	ArrayList kabom = new ArrayList();

	try {
	prob = iob.get("problem_desc").split("::");
	solut = iob.get("solution_desc").split("::");
	stkcode = iob.get("parts_used").split("::");
	stkid = iob.get("parts_stkid").split("::");
	qty = iob.get("parts_qty").split("::");
	uprice = iob.get("parts_uprice").split("::");
	} catch (Exception e) { return null; }

	for(i=0; i<prob.length; i++)
	{
		kabom.add("0");
		// INEFFICIENT codes to get stock_code from stockmasterdetails - RECODE
		//sr = gpWMS_FirstRow("select Stock_Code from StockMasterDetails where ID=" + stkid[i]);
		//sc = (sr == null) ? UNKNOWN_STRING : sr.get("Stock_Code");
		//kabom.add(sc);

		kk = ""; try { kk = prob[i]; } catch (Exception e) {}
		kabom.add(kk);

		kk = ""; try { kk = solut[i]; } catch (Exception e) {}
		kabom.add(kk);
		
		kk = UNKNOWN_STRING; try { kk = stkcode[i]; } catch (Exception e) {}
		kabom.add(kk);

		kk = "0"; try { kk = stkid[i]; } catch (Exception e) {}
		kabom.add(kk);

		kk = ""; try { kk = qty[i]; } catch (Exception e) {}
		kabom.add(kk);

		kk = ""; try { kk = uprice[i]; } catch (Exception e) {}
		kabom.add(kk);

		kabom.add("0");

		lbhand.insertListItems(newlb,kiboo.convertArrayListToStringArray(kabom),"false","");
		kabom.clear();
		itmcount++;
	}

	if(itmcount > 0)
	{
		if(showtype == 1) // calc subtotal
		{
			recalcSubtotal(newlb,WOI_QTY_POS,WOI_UPRICE_POS,WOI_SUBTOTAL_POS);
		}

		renumberListbox(newlb,0,1,true);
		newlb.setRows(imaxrows);
		lbhand.setDoubleClick_ListItems(newlb, woitem_dclicker);
	}

	return newlb;
}

/**
 * [saveWO_items description]
 * @param iwo     [description]
 * @param iholder DIV holder
 * @param ilbid   listbox string ID
 */
boolean saveWO_items(String iwo, Div iholder, String ilbid)
{
	ilb = iholder.getFellowIfAny(ilbid);
	if(ilb == null) return false;
	if(ilb.getItemCount() == 0) return false;

	ts = ilb.getItems().toArray();
	prob = solut = stkcode = stkid = qty = uprice = "";

	for(i=0;i<ts.length;i++)
	{
		prob += kiboo.replaceSingleQuotes(lbhand.getListcellItemLabel(ts[i],WOI_PROBLEM_POS)) + "::";
		solut += kiboo.replaceSingleQuotes(lbhand.getListcellItemLabel(ts[i],WOI_SOLUTION_POS)) + "::";
		stkcode += lbhand.getListcellItemLabel(ts[i],WOI_STOCKCODE_POS) + "::";
		stkid += lbhand.getListcellItemLabel(ts[i],WOI_STKID_POS) + "::";
		qty += lbhand.getListcellItemLabel(ts[i],WOI_QTY_POS) + "::";
		uprice += lbhand.getListcellItemLabel(ts[i],WOI_UPRICE_POS) + "::";
	}
	sqlstm = "update workorders set problem_desc='" + prob + "', solution_desc='" + solut + "'," +
	"parts_used='" + stkcode + "', parts_uprice='" + uprice + "', parts_qty='" + qty + "', parts_stkid='" + stkid + "' where origid=" + iwo;

	sqlhand.rws_gpSqlExecuter(sqlstm);
	return true;
}

/**
 * Save IRIS things to work-order, uses hardcoded listbox and etc. Can be used in other modu
 * @param iwo selected work-order
 */
void saveIRIS_codes(String iwo)
{
	if(iwo.equals("")) return;
	irisfulcode = iris_condition_code.getValue() + "-" + iris_problem_code.getValue() + "-" + iris_extended_code.getValue();
	irpos = lbhand.getListcellItemLabel(iris_position.getSelectedItem(),1);
	irdef = lbhand.getListcellItemLabel(iris_defect.getSelectedItem(),1);
	irsect = lbhand.getListcellItemLabel(iris_section.getSelectedItem(),1);
	irrep = lbhand.getListcellItemLabel(iris_repair.getSelectedItem(),1);

	sqlstm = "update workorders set iris_code='" + irisfulcode + "',iris_position='" + irpos + "',iris_defect='" + irdef + "'," +
	"iris_section='" + irsect + "', iris_repair='" + irrep + "' where origid=" + iwo;

	sqlhand.rws_gpSqlExecuter(sqlstm);
}

/**
 * Re-populate full IRIS problem-code listbox
 * @param pcode1  code 1
 * @param pcode2  code 2
 * @param pcodedd the problem-code listbox dropdown
 */
void populateIRIS_dropdown(String pcode1, String pcode2, Listbox pcodedd)
{
	ts = pcodedd.getItems().toArray();
	for(i=0;i<ts.length;i++) // clear any previous listitems
	{
		ts[i].setParent(null);
	}

	prfcode = pcode1 + pcode2;

	sqlstm = "select disptext,value1 from lookups " +
	"where myparent=convert((select idlookups from lookups where name='IRIS_ALL_CODES'),char(255)) and " +
	"disptext like '" + prfcode + "%' " +
	"order by idlookups";

	r = sqlhand.gpSqlGetRows(sqlstm);
	String[] st = new String[2];
	for(d: r)
	{
		st[0] = kiboo.checkNullString(d.get("disptext"));
		st[1] = kiboo.checkNullString(d.get("value1"));
		lbhand.insertListItems(pcodedd,st,"false","");
	}
	try { pcodedd.setSelectedIndex(0); } catch (Exception e) {}
}

/**
 * onSelect for full IRIS code selection
 * @param piris_dd      the problem-code listbox dropdown
 * @param pirisfullcode LABEL to show the code
 */
void irisFullCodeOnSelect(Listbox piris_dd, Label pirisfullcode)
{
	fullcode = lbhand.getListcellItemLabel(piris_dd.getSelectedItem(),1);
	pirisfullcode.setValue(fullcode);
}

void irisCodeOnSelect(Listbox pcode1, Listbox pcode2, Listbox pddrop)
{
	c1 = lbhand.getListcellItemLabel(pcode1.getSelectedItem(),1);
	c2 = lbhand.getListcellItemLabel(pcode2.getSelectedItem(),1);
	populateIRIS_dropdown(c1,c2,pddrop);
}

/**
 * Hardcoded to fill-up the drop-downs, UI things must be defined in the calling modu.
 * refer to workOrderMan_v1.zul for the IRIS grid
 */
void initIRIS_selector()
{
	luhand.populateListBox_ValueSelection(iris_condition,"IRIS_CONDITION_CODES",2,1);
	luhand.populateListBox_ValueSelection(iris_code1,"IRIS_AREA_CODES",2,1);
	luhand.populateListBox_ValueSelection(iris_code2,"IRIS_TYPE_CODES",2,1);
	irisCodeOnSelect(iris_code1,iris_code2,iriscode_dd);

	luhand.populateListBox_ValueSelection(iris_position,"IRIS_POSITION_CODES",2,1);
	luhand.populateListBox_ValueSelection(iris_defect,"IRIS_DEFECTS_CODES",2,1);
	luhand.populateListBox_ValueSelection(iris_repair,"IRIS_REPAIR_CODES",2,1);
	luhand.populateListBox_ValueSelection(iris_section,"IRIS_SECTION_CODES",2,1);
}
