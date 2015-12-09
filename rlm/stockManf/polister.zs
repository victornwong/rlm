/**
* PO list out functions
*/

LISTPOBACKGROUND = "background:#96BB1F";
POSTAT_SUSPEND = "font-size:9px;background:#F82613";
POSTAT_APPROVE = "font-size:9px;background:#47F07A";

last_show_po = 1;
glob_sel_po = glob_sel_poapcode = glob_sel_pocustomer = glob_sel_po_status = "";

void renumberPOlb(Listbox ilb)
{
	jk = ilb.getItems().toArray();
	for(i=0; i<jk.length; i++)
	{
		lbhand.setListcellItemLabel(jk[i],0, (i+1).toString() + "." );
	}
}

Object[] pohds =
{
	new listboxHeaderWidthObj(PO_PREFIX,true,"60px"),
	new listboxHeaderWidthObj("Dated",true,"80px"),
	new listboxHeaderWidthObj("apcode",false,""),
	new listboxHeaderWidthObj("Supplier",true,""),
	new listboxHeaderWidthObj("Status",true,"70px"),
	new listboxHeaderWidthObj("CurCode",true,"70px"),
	new listboxHeaderWidthObj("User",true,"80px"),
};
PO_LB_ORIGID = 0;
PO_LB_APCODE = 2;
PO_LB_CUSTOMER = 3;
PO_LB_STATUS = 4;

class poclik implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(Event event) throws UiException
	{
		isel = event.getReference();
		glob_sel_po = lbhand.getListcellItemLabel(isel,PO_LB_ORIGID);
		glob_sel_pocustomer = lbhand.getListcellItemLabel(isel,PO_LB_CUSTOMER);
		glob_sel_poapcode = lbhand.getListcellItemLabel(isel,PO_LB_APCODE);
		glob_sel_po_status = lbhand.getListcellItemLabel(isel,PO_LB_STATUS);

		PO_clickCallbak();
	}
}
pocliker = new poclik();

/**
 * [listPO description] - uses components defn in popup from calling module
 * @param itype list-out types -- check switches
 */
void listPO(int itype)
{
	last_show_po = itype;
	st = kiboo.replaceSingleQuotes(searhtxt_tb.getValue().trim());
	sdate = kiboo.getDateFromDatebox(startdate);
	edate = kiboo.getDateFromDatebox(enddate);
	bypon = kiboo.replaceSingleQuotes(byponum_tb.getValue().trim());
	Listbox newlb = lbhand.makeVWListbox_Width(poholder, pohds, "po_lb", 3);

	sqlstm = "select origid,APCode,supplier_name,datecreated,pr_status,curcode,username from PurchaseRequisition where ";

	switch(itype)
	{
		case 1: // by date range and search-text if any
			sqlstm += "datecreated between '" + sdate + " 00:00:00' and '" + edate + " 23:59:00' ";
			if(!st.equals(""))
				sqlstm += " and (APCode like '%" + st + "%' or supplier_name like '%" + st + "%');";
			break;

		case 2: // by PO number
			try { kk = Integer.parseInt(bypon); sqlstm += "origid=" + bypon; } catch (Exception e) { return; }
			break;
	}

	r = sqlhand.rws_gpSqlGetRows(sqlstm);
	if(r.size() == 0) return;
	newlb.setRows(11); newlb.setMold("paging"); // newlb.setMultiple(true); newlb.setCheckmark(true); 
	newlb.addEventListener("onSelect", pocliker);

	String[] fl = { "origid", "datecreated", "APCode", "supplier_name", "pr_status", "curcode", "username" };
	ArrayList kabom = new ArrayList();

	for(d : r)
	{
		ngfun.popuListitems_Data(kabom,fl,d);
		li = lbhand.insertListItems(newlb,kiboo.convertArrayListToStringArray(kabom),"false","");
		if(d.get("pr_status").equals("SUSPEND")) li.setStyle(POSTAT_SUSPEND);
		if(d.get("pr_status").equals("APPROVE")) li.setStyle(POSTAT_APPROVE);
		kabom.clear();
	}
	//lbhand.setDoubleClick_ListItems(newlb, stkindoublecliker);
}

Object[] digpohds =
{
	new listboxHeaderWidthObj(PO_PREFIX,true,"60px"),
	new listboxHeaderWidthObj("Dated",true,"80px"),
	new listboxHeaderWidthObj("Supplier",true,""),
};

class diggpodclick implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(Event event) throws UiException
	{
		isel = event.getTarget();
		try
		{
			diggPO_callback( PO_PREFIX + lbhand.getListcellItemLabel(isel,0), lbhand.getListcellItemLabel(isel,2) );
		} catch (Exception e) {}
	}
}
diggpo_dclick = new diggpodclick();

/**
 * Same as listPO() but for other modu to link reference
 */
void diggyPO(int itype, Div iholder, Datebox istart, Datebox iend, Textbox isearch, Textbox ipono)
{
	st = kiboo.replaceSingleQuotes(isearch.getValue().trim());
	sdate = kiboo.getDateFromDatebox(istart);
	edate = kiboo.getDateFromDatebox(iend);
	bypon = kiboo.replaceSingleQuotes(ipono.getValue().trim());
	Listbox newlb = lbhand.makeVWListbox_Width(iholder, digpohds, "digpo_lb", 3);

	sqlstm = "select origid,supplier_name,datecreated from PurchaseRequisition where ";

	switch(itype)
	{
		case 1: // by date range and search-text if any
			sqlstm += "datecreated between '" + sdate + " 00:00:00' and '" + edate + " 23:59:00' ";
			if(!st.equals(""))
				sqlstm += " and (APCode like '%" + st + "%' or supplier_name like '%" + st + "%');";
			break;

		case 2: // by PO number
			try { kk = Integer.parseInt(bypon); sqlstm += "origid=" + bypon; } catch (Exception e) { return; }
			break;
	}

	sqlstm += PRSTATUS_CONTROL;

	r = sqlhand.rws_gpSqlGetRows(sqlstm);
	if(r.size() == 0) return;
	newlb.setRows(11); //newlb.setMold("paging"); // newlb.setMultiple(true); newlb.setCheckmark(true); 
	//newlb.addEventListener("onSelect", pocliker);

	String[] fl = { "origid", "datecreated", "supplier_name" };
	ArrayList kabom = new ArrayList();

	for(d : r)
	{
		ngfun.popuListitems_Data(kabom,fl,d);
		li = lbhand.insertListItems(newlb,kiboo.convertArrayListToStringArray(kabom),"false","");
		kabom.clear();
	}
	lbhand.setDoubleClick_ListItems(newlb, diggpo_dclick);
}

Object[] digpoitemshds =
{
	new listboxHeaderWidthObj("stkid",false,""),
	new listboxHeaderWidthObj("Stock code",true,""),
	new listboxHeaderWidthObj("Description",true,""),
	new listboxHeaderWidthObj("Qty",true,"60px"),
	new listboxHeaderWidthObj("UPrice",false,"60px"),
	new listboxHeaderWidthObj("exhrate",false,"60px"),
	new listboxHeaderWidthObj("curcode",false,"60px"),
	new listboxHeaderWidthObj("Struct",true,""),
};
SML_POITEM_STKID = 0; SML_POITEM_STOCKCODE = 1; SML_POITEM_DESC = 2;
SML_POITEM_QTY = 3; SML_POITEM_UPRICE = 4; SML_POITEM_EXCHANGERATE = 5;
SML_POITEM_CURCODE = 6; SML_POITEM_STRUCT = 7;

class diggpoitemsdclick implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(Event event) throws UiException
	{
		isel = event.getTarget();
		try
		{
			//diggPOitems_callback( 
			diggPOitems_callback(isel);
		} catch (Exception e) {}
	}
}
digpoitems_dclick = new diggpoitemsdclick();

/**
 * Dig PO items and show for selection
 */
void digloadPOitems(Div iholder, int ipo)
{
	Listbox newlb = lbhand.makeVWListbox_Width(iholder, digpoitemshds, "digpoitems_lb", 10);

	sqlstm = "select m.description,m.quantity,m.stock_code,unitprice," +
	"(select exchange_rate from PurchaseRequisition where origid=" + ipo + ") as exhrate, " +
	"(select curcode from PurchaseRequisition where origid=" + ipo + ") as cur_code," +
	"(select stock_code from StockMasterDetails where ID=m.stock_code) as stockname from PurchaseReq_Items m where m.pr_parent_id=" + ipo.toString();
	r = sqlhand.rws_gpSqlGetRows(sqlstm);
	if(r.size() > 0)
	{
		String[] fl = { "stock_code","stockname","description","quantity","unitprice","exhrate","cur_code" };
		ArrayList kabom = new ArrayList();
		for(d : r)
		{
			ngfun.popuListitems_Data(kabom,fl,d);
			stkstruct = (d.get("stock_code") != null) ? getStockMasterStruct(d.get("stock_code").toString()) : ""; // rlmsql.zs
			kabom.add( stkstruct );
			lbhand.insertListItems(newlb,kiboo.convertArrayListToStringArray(kabom),"false","");
			kabom.clear();
		}
		//renumberListbox(newlb, 0, 1, true);
		lbhand.setDoubleClick_ListItems(newlb, digpoitems_dclick);
	}
}

/**
 * Show small-window - PO details w/o unit-price
 * @param ipo : the selected PO no.
 */
void viewPO_small(String ipo)
{
	kpo = ""; try { kpo = ipo.substring( PO_PREFIX.length(), ipo.length() ); } catch (Exception e) { return; } // extract PO voucher no.
	r = null;
	try { r = getPurchaseReqRec(kpo); } catch (Exception e) { return; }
	if(r == null) return;

	kwin = ngfun.vMakeWindow(windowsholder,ipo, "1", "center", "600px", "");

	smy = "[APCODE: " + kiboo.checkNullString(r.get("APCode")) + "] Vendor: " + r.get("supplier_name") +
	"\nDated: " + kiboo.dtf2.format(r.get("datecreated")) + " -- Approved: " + ((r.get("approvedate") != null) ? kiboo.dtf2.format(r.get("approvedate")) : "-") +
	"\nNotes: " + kiboo.checkNullString(r.get("notes"));

	itmh = new Div(); itmh.setParent(kwin); itmh.setSclass("shadowbox"); itmh.setStyle("background:#ED400E");
	kk = ngfun.gpMakeLabel(itmh,"",smy,""); kk.setMultiline(true); kk.setStyle("color:#ffffff");
	digloadPOitems(itmh, Integer.parseInt(kpo)); // polister.zs
}
