// Order-queue management - temp_orderitems, to speed-up PR/PO creation
// Remember 'em popups . Find them in outboundKanban_v1.zul

ORDERQUEUE_LB_ID = "orderqueue_lb";

/**
 * Order-queue functions : can be used in other modu - modularize it
 * Global vars req: glob_sel_stkid , glob_sel_stockcode
 * UI objs : ordq_reason_tb
 * @param iwhat button ID
 */
void orderqueue_doFunc(String iwhat, String istkid, String istockcode)
{
	orderq_addqty.close();
	todaydate =  kiboo.todayISODateTimeString();
	msgtext = sqlstm = sts = "";
	unm = "tester"; try { unm = useraccessobj.username; } catch (Exception e) {}

	if(iwhat.equals("ordq_additem_b")) // order-queue add item
	{
		if(istkid.equals("")) { guihand.showMessageBox("Double-click to select the stock-code.."); return; }
		qty = ordqty_tb.getValue().trim(); if(qty.equals("")) return;
		iqty = 0; try { iqty = Integer.parseInt(qty); } catch (Exception e) {}
		resn = ordq_reason_tb.getValue().trim();
		sqlstm = "insert into temp_orderitems (stk_id,stockcode,datecreated,username,qty,reason) values " +
		"(" + istkid + ",'" + istockcode + "','" + todaydate + "','" + unm + "'," + iqty.toString() + ",'" + resn + "');";

		msgtext = istockcode + " added to order-queue..";
	}

	if(iwhat.equals("ordq_remove_b")) // remove selected order-queue items from db
	{
		if(!lbhand.check_ListboxExist_SelectItem(orderqlist_holder,"orderqueue_lb")) return;
		if(Messagebox.show("This will delete the selected items from the order-queue..", "Are you sure?",
			Messagebox.YES | Messagebox.NO, Messagebox.QUESTION) != Messagebox.YES) return;

		koi = "";
		ts = orderqueue_lb.getSelectedItems().toArray();
		for(i=0; i<ts.length; i++)
		{
			koi += lbhand.getListcellItemLabel(ts[i],ORDQ_ORIGID) + ",";
			ts[i].setParent(null); // remove from list-box
		}
		renumberListbox(orderqueue_lb,0,1,true);

		try { koi = koi.substring(0,koi.length()-1); } catch (Exception e) {}
		if(!koi.equals(""))
		{
			sqlstm = "delete from temp_orderitems where origid in (" + koi + ");";
		}
	}

	if(iwhat.equals("notifprocure_b")) // send notification email to procurement : TODO
	{

	}

	if(!sqlstm.equals(""))
	{
		sqlhand.rws_gpSqlExecuter(sqlstm);
	}
	if(!msgtext.equals(""))
	{
		putNagText(msgtext);
	}
}

Object[] orderque_hds =
{
	new listboxHeaderWidthObj("No.",true,"60px"),
	new listboxHeaderWidthObj("Dated",true,"70px"),
	new listboxHeaderWidthObj("stkid",false,""), // 2
	new listboxHeaderWidthObj("StockCode",true,""),
	new listboxHeaderWidthObj("Qty",true,"50px"),
	new listboxHeaderWidthObj("Reason",true,""),
	new listboxHeaderWidthObj("origid.",false,""), // 6
	new listboxHeaderWidthObj("Struct",true,""),
};
ORDQ_STKID = 2; ORDQ_STOCKCODE = 3; ORDQ_QTY = 4;
ORDQ_ORIGID = 6; ORDQ_STRUCT = 7;

void showOrderQueue(Div iholder, String ist)
{
	Listbox newlb = lbhand.makeVWListbox_Width(iholder, orderque_hds, ORDERQUEUE_LB_ID, 3);
	esql = (!ist.equals("")) ? "and stockcode like '%" + ist + "%'" : "";

	sqlstm = "select origid,stk_id,stockcode,qty,reason,datecreated from temp_orderitems where po_ref is null " + esql + " order by stockcode;";
	r = sqlhand.rws_gpSqlGetRows(sqlstm);
	if(r.size() == 0) return;
	newlb.setRows(8); newlb.setMultiple(true); newlb.setCheckmark(true); // newlb.setMold("paging");
	//newlb.addEventListener("onSelect", outbd_cliker);

	String[] fl = { "datecreated","stk_id","stockcode","qty","reason","origid" };
	ArrayList kabom = new ArrayList();

	for(d : r)
	{
		kabom.add("0");
		ngfun.popuListitems_Data(kabom,fl,d);

		stkstruct = (d.get("stk_id") != null) ? getStockMasterStruct(d.get("stk_id").toString()) : "";
		kabom.add( stkstruct );
		lbhand.insertListItems(newlb,kiboo.convertArrayListToStringArray(kabom),"false","");
		kabom.clear();
	}
	renumberListbox(newlb,0,1,true);
	//lbhand.setDoubleClick_ListItems(newlb, outbd_dcliker);
}

