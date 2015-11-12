/**
 * Outbound STKOUT module funcs
 */

Object[] outbitemshds =
{
	new listboxHeaderWidthObj("No.",true,"60px"),
	new listboxHeaderWidthObj("StockCode",true,""),
	new listboxHeaderWidthObj("Description",true,""),
	new listboxHeaderWidthObj("stkid",false,""),
	new listboxHeaderWidthObj("Qty",true,"50px"),
	new listboxHeaderWidthObj("U/Price",true,"70px"),
	new listboxHeaderWidthObj("SubTotal",true,"70px"),
	new listboxHeaderWidthObj("Struct",true,"70px"),

};

Object[] outbitems_noprice_hds =
{
	new listboxHeaderWidthObj("No.",true,"60px"),
	new listboxHeaderWidthObj("StockCode",true,""),
	new listboxHeaderWidthObj("Description",false,""),
	new listboxHeaderWidthObj("stkid",false,""),
	new listboxHeaderWidthObj("Qty",true,"50px"),
	new listboxHeaderWidthObj("U/Price",false,""),
	new listboxHeaderWidthObj("SubTotal",false,""),
	new listboxHeaderWidthObj("Struct",true,"70px"),
};

OBITM_STKCODE_POS = 1;
OBITM_DESC_POS = 2;
OBITM_STKID_POS = 3;
OBITM_QTY_POS = 4;
OBITM_UPRICE_POS = 5;
OBITM_SUBTOT_POS = 6;
OBITM_STRUCT_POS = 7;

class outitmdlcick implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(Event event) throws UiException
	{
		isel = event.getTarget();
		try
		{
			obitem_callBack(isel);
		} catch (Exception e) {}
	}
}
outbitem_dclick = new outitmdlcick();

/**
 * Show outbound request items - more flexible, can be used in other modu
 * @param iob      outbound rec from tblStockOutMaster - caller must retrieve first
 * @param iholder  DIV listbox holder
 * @param ilbid    listbox ID
 * @param showtype 1=show cost/subtotal, 2=show qty only
 * @param imaxrows max listbox rows
 * @return the created listbox
 */
OBITEMS_QTY_ONLY = 2;
OBITEMS_PRICE = 1;
Listbox showOutboundItems(Object iob, Div iholder, String ilbid, int showtype, int imaxrows)
{
	newlb = iholder.getFellowIfAny(ilbid);
	if(newlb != null) newlb.setParent(null); // always remove old listbox

	hdrs = (showtype == 1) ? outbitemshds : outbitems_noprice_hds; // select show-type listbox headers
	newlb = lbhand.makeVWListbox_Width(iholder, hdrs, ilbid, 3);
	newlb.setMultiple(true); newlb.setCheckmark(true);

	itmcount = 0;
	ArrayList kabom = new ArrayList();

	try
	{
		desc = iob.get("order_desc").split("::");
		stkid = iob.get("order_stockid").split("::");
		qty = iob.get("order_qty").split("::");
		uprice = iob.get("order_uprice").split("::");

		for(i=0; i<desc.length; i++)
		{
			kabom.add("0");

			// INEFFICIENT codes to get stock_code from stockmasterdetails - RECODE LATER
			sr = gpWMS_FirstRow("select Stock_Code from StockMasterDetails where ID=" + stkid[i]);
			sc = (sr == null) ? UNKNOWN_STRING : sr.get("Stock_Code");
			kabom.add(sc);
			
			kabom.add(desc[i]);
			kabom.add(stkid[i]); kabom.add(qty[i]); kabom.add(uprice[i]);
			kabom.add("0");
			kabom.add(getStockMasterStruct(stkid[i])); // inventorymanfunc.zs
			lbhand.insertListItems(newlb,kiboo.convertArrayListToStringArray(kabom),"false","");
			kabom.clear();
			itmcount++;
		}
	
	} catch (Exception e) {}

	if(itmcount > 0)
	{
		if(showtype == 1) // calc subtotal
		{
			recalcSubtotal(newlb,OBITM_QTY_POS,OBITM_UPRICE_POS,OBITM_SUBTOT_POS);
		}

		renumberListbox(newlb,0,1,true);
		newlb.setRows(imaxrows);
		lbhand.setDoubleClick_ListItems(newlb, outbitem_dclick);
	}

	return newlb;
}

Object[] outbdhds =
{
	new listboxHeaderWidthObj("STKOUT",true,"55px"),
	new listboxHeaderWidthObj("Dated",true,"80px"),
	new listboxHeaderWidthObj("Customer",true,""),
	new listboxHeaderWidthObj("Type",true,"80px"),
	new listboxHeaderWidthObj("Status",true,"80px"),
	new listboxHeaderWidthObj("WH Stage",true,"80px"), // 5
	new listboxHeaderWidthObj(WORKORDER_PREFIX,true,"80px"),
	new listboxHeaderWidthObj("User",true,"80px"),
};
OUTB_ORIGID_POS = 0;
OUTB_STATUS_POS = 4;
OUTB_STAGE_POS = 5;
OUTB_WORKORDER_POS = 6;

class outbclicker implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(Event event) throws UiException
	{
		outbound_CallBack(event.getReference());
	}
}
outbd_cliker = new outbclicker();

class outbdcoubliekr implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(Event event) throws UiException
	{
		isel = event.getTarget();
		try
		{
		} catch (Exception e) {}
	}
}
outbd_dcliker = new outbdcoubliekr();

/**
 * [listOutbounds description]
 * @param itype type of list-out
 */
void listOutbounds(int itype)
{
	last_list_type = itype;
	Listbox newlb = lbhand.makeVWListbox_Width(outbounds_holder, outbdhds, "outbounds_lb", 3);
	st = kiboo.replaceSingleQuotes(searhtxt_tb.getValue().trim());
	sdate = kiboo.getDateFromDatebox(startdate);
	edate = kiboo.getDateFromDatebox(enddate);

	sqlstm = "select Id,strDate,customer_name,status,order_type,stage,username,WorksOrder from tblStockOutMaster tm ";

	switch(itype)
	{
		case 1:
			sqlstm += "where strDate between '" + sdate + " 00:00:00' and '" + edate + " 23:59:00' ";
			if(!st.equals(""))
				sqlstm += " and (customer_name like '%" + st + "%' or order_type like '%" + st + "%' or stage like '%" + st + "%');";
			break;

		case 2:
			try { sti = Integer.parseInt(byoutnum_tb.getValue().trim()).toString(); sqlstm += "where tm.Id=" + sti; }
			catch (Exception e) { byoutnum_tb.setValue(""); return; }
			break;

		case 3: // for part-returns, hmm.. list only DONE-stage outbound .. else non-DONE, can remove them items manually
			sqlstm += "where strDate between '" + sdate + " 00:00:00' and '" + edate + " 23:59:00' and stage='DONE' ";
			if(!st.equals(""))
					sqlstm += "and customer_name like '%" + st + "%';";
			break;

		case 4: // for part-returns, only DONE-stage
			try { sti = Integer.parseInt(byoutnum_tb.getValue().trim()).toString(); sqlstm += "where stage='DONE' and tm.Id=" + sti; }
			catch (Exception e) { byoutnum_tb.setValue(""); return; }
			break;
	}

	r = sqlhand.rws_gpSqlGetRows(sqlstm);
	if(r.size() == 0) return;
	newlb.setRows(15); newlb.setMold("paging"); // newlb.setMultiple(true); newlb.setCheckmark(true); 
	newlb.addEventListener("onSelect", outbd_cliker);

	String[] fl = { "Id","strDate","customer_name","order_type","status","stage","WorksOrder","username" };
	ArrayList kabom = new ArrayList();

	for(d : r)
	{
		ngfun.popuListitems_Data(kabom,fl,d);
		lbhand.insertListItems(newlb,kiboo.convertArrayListToStringArray(kabom),"false","");
		kabom.clear();
	}
	lbhand.setDoubleClick_ListItems(newlb, outbd_dcliker);
}

