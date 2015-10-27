/**
 * Stock items handling functions - tblStockInDetail and tblStockInMaster
 */

void refreshThings()
{
	listStockIn(last_show_stockin);
}

/**
 * Toggle working buttons by stock-in entry status
 * @param istatus the status string
 */
void togMainButtons(String istatus)
{
	Component[] tbutts = { updstkin_b, w_reference_tb, w_description_tb, w_stock_code_tb, scanitemcode_tb,
	 capitemcode_b, mpfthing_b, chkdupitem_b, saveitem_b, remvitem_b, mpfupdqty_b, mpfupdcst_b, upditem_b,
	 digpo_b, digsupplier_b, digstockcode_b };

	tg = (istatus.equals("DRAFT")) ? false : true;

	for(i=0; i<tbutts.length; i++)
	{
		tbutts[i].setDisabled(tg);
	}
}

Object[] stkinhds =
{
	new listboxHeaderWidthObj("STKIN",true,"80px"),
	new listboxHeaderWidthObj("Dated",true,"80px"),
	new listboxHeaderWidthObj("Ref",true,""),
	new listboxHeaderWidthObj("Supplier / Desc",true,""),
	new listboxHeaderWidthObj("StkItem",true,"200px"),
	new listboxHeaderWidthObj("Qty",true,"70px"),
	new listboxHeaderWidthObj("User",true,"80px"), // 6
	new listboxHeaderWidthObj("Status",true,"70px"),
	new listboxHeaderWidthObj("Post",false,""),
	new listboxHeaderWidthObj("stk_id",false,""),
};
STKIN_ID_POS = 0;
STKIN_REF_POS = 2;
STKIN_DESC_POS = 3;
STKIN_STOCKNAME_POS = 4;
STKIN_USER_POS = 6;
STKIN_STATUS_POS = 7;
STKID_POS = 9;

class stkinclik implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(Event event) throws UiException
	{
		isel = event.getReference();
		glob_stkin_id = lbhand.getListcellItemLabel(isel,STKIN_ID_POS);
		glob_stkin_ref = lbhand.getListcellItemLabel(isel,STKIN_REF_POS);
		glob_stkin_description = lbhand.getListcellItemLabel(isel,STKIN_DESC_POS);
		glob_stkin_user = lbhand.getListcellItemLabel(isel,STKIN_USER_POS);
		glob_stkin_stkid = lbhand.getListcellItemLabel(isel,STKID_POS);
		glob_stkin_stockcode = lbhand.getListcellItemLabel(isel,STKIN_STOCKNAME_POS);
		glob_stkin_status = lbhand.getListcellItemLabel(isel,STKIN_STATUS_POS);

		w_id_lbl.setValue(glob_stkin_id);
		w_reference_tb.setValue(glob_stkin_ref);
		w_description_tb.setValue(glob_stkin_description);
		w_stock_code_tb.setValue( glob_stkin_stockcode ); // stock-code display name only - real linking in stk_id

		showItemcodes(glob_stkin_id, captureitemcodes_holder, "itemcodes_lb");
		togMainButtons( lbhand.getListcellItemLabel(isel,STKIN_STATUS_POS) );
		workarea.setVisible(true);
	}
}
stockinclicker = new stkinclik();

class stkindobuleclik implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(Event event) throws UiException
	{
		isel = event.getTarget();
		try
		{
		} catch (Exception e) {}
	}
}
stkindoublecliker = new stkindobuleclik();

/**
 * List stock-in entries - the items quantity uses a sub-select-count into tblStockInDetail by parent_id
 * @param itype listing type - check switch statement
 */
void listStockIn(int itype)
{
	if(itype == 0) return;
	last_show_stockin = itype;

	st = kiboo.replaceSingleQuotes(searhtxt_tb.getValue().trim());
	sdate = kiboo.getDateFromDatebox(startdate);
	edate = kiboo.getDateFromDatebox(enddate);

	Listbox newlb = lbhand.makeVWListbox_Width(stockins_holder, stkinhds, "stockin_lb", 3);

	sqlstm = "select tm.Id,tm.Reference,tm.Description, (select Stock_Code from StockMasterDetails where ID=stk_id) as stock_code," +
	"FLOOR((select count(*) from tblStockInDetail where parent_id = tm.Id)) as childqty," +
	"tm.Posted,tm.username,tm.stk_id,tm.EntryDate,tm.status from tblStockInMaster tm ";

	switch(itype)
	{
		case 1: // by date range and search text
			sqlstm += "where EntryDate between '" + sdate + " 00:00:00' and '" + edate + " 23:59:00' ";
			if(!st.equals(""))
				sqlstm += " and (Reference like '%" + st + "%' or Description like '%" + st + "%' or " +
				"stk_id in (select ID from StockMasterDetails where Stock_Code='" + st + "') );";
			break;

		case 2: // by stkin voucher no. only
			try { sti = Integer.parseInt(stkinnum_tb.getValue().trim()).toString(); sqlstm += "where tm.Id=" + sti; }
			catch (Exception e) { stkinnum_tb.setValue(""); return; }
			break;
	}

	r = sqlhand.rws_gpSqlGetRows(sqlstm);
	if(r.size() == 0) return;
	newlb.setRows(20); newlb.setMold("paging"); // newlb.setMultiple(true); newlb.setCheckmark(true); 
	newlb.addEventListener("onSelect", stockinclicker);

	String[] fl = { "Id", "EntryDate", "Reference", "Description", "stock_code", "childqty", "username", "status", "Posted","stk_id" };
	ArrayList kabom = new ArrayList();

	for(d : r)
	{
		ngfun.popuListitems_Data(kabom,fl,d);
		lbhand.insertListItems(newlb,kiboo.convertArrayListToStringArray(kabom),"false","");
		kabom.clear();
	}
	lbhand.setDoubleClick_ListItems(newlb, stkindoublecliker);
}

/**
 * Show 'em item-codes from tblStockInDetail by parent_id
 * @param istkin   stock-in voucher - parent_id
 * @param lbholder DIV holder for listbox
 * @param lbid     the listbox ID to use
 */
void showItemcodes(String istkin, Div lbholder, String lbid)
{
	prvlb = lbholder.getFellowIfAny(lbid);
	if(prvlb != null) prvlb.setParent(null); // remove previous listbox

	newlb = lbhand.makeVWListbox_Width(lbholder, itmcodehds, lbid, 10);
	newlb.setMultiple(true); newlb.setCheckmark(true);

	sqlstm = "select ItemCode,Quantity,Cost,Bin from tblStockInDetail where parent_id=" + istkin;
	r = sqlhand.rws_gpSqlGetRows(sqlstm);
	if(r.size() == 0) return;
	ArrayList kabom = new ArrayList();

	for(d : r)
	{
		kabom.add("0"); kabom.add(d.get("ItemCode").trim());

		kabom.add( ((d.get("Quantity") == null) ? "1" : d.get("Quantity").toString()) );
		kabom.add( ((d.get("Cost") == null) ? "0" : d.get("Quantity").toString()) );
		kabom.add( kiboo.checkNullString(d.get("Bin")));

		lbhand.insertListItems(newlb,kiboo.convertArrayListToStringArray(kabom),"false","");
		kabom.clear();
	}
	renumberListbox(newlb,0,1,true);
	lbhand.setDoubleClick_ListItems(newlb, itemdoubleclicker);
}

/**
 * [saveItemcodes description]
 * @param istkin   stock-in voucher id
 * @param istkid   stock-code id - as in stockmasterdetails
 * @param istkcode stock-code display name
 * @param lbholder DIV holder for listbox
 * @param lbid     the listbox ID to use
 */
void saveItemcodes(String istkin, String istkid, String istkcode, Div lbholder, String lbid)
{
	newlb = lbholder.getFellowIfAny(lbid);
	if(newlb == null) return;
	ts = newlb.getItems().toArray();
	if(ts.length == 0) return;

	df = checkDuplicateItems(lbholder,lbid,1);
	if(df > 0)
	{
		guihand.showMessageBox("ERR: duplicate item-codes detected, please check and remove duplicates before saving.");
		return;
	}

	sqlstm = "delete from tblStockInDetail where parent_id=" + istkin;
	sqlhand.rws_gpSqlExecuter(sqlstm); // delete previous item-codes by parent_id=istkin if any

	todaydate =  kiboo.todayISODateTimeString();

	Sql sql = wms_Sql();
	Connection thecon = sql.getConnection();
	PreparedStatement pstmt = thecon.prepareStatement("insert into tblStockInDetail (parent_id,StockCode,stk_id,ItemCode,Quantity,Cost,Amount,Bin) " +
		"values (?,?,?,?,?,?,?,?);");

	for(i=0;i<ts.length;i++)
	{
		pstmt.setInt(1,Integer.parseInt(istkin));
		pstmt.setString(2,istkcode);
		pstmt.setInt(3,Integer.parseInt(istkid));

		itmc = lbhand.getListcellItemLabel(ts[i],ITEM_CODE_POS);
		pstmt.setString(4,itmc);

		pstmt.setFloat(5,1); // quantity
		pstmt.setFloat(6,0); // cost
		pstmt.setFloat(7,0); // amount
		pstmt.setString(8, lbhand.getListcellItemLabel(ts[i],ITEM_LOCA_POS) );
		pstmt.addBatch();
	}
	pstmt.executeBatch(); pstmt.close();
	sql.close();
	guihand.showMessageBox("Items saved into stock-in database");
}

Object[] itmcodehds =
{
	new listboxHeaderWidthObj("No.",true,"70px"),
	new listboxHeaderWidthObj("Serial No.",true,""),
	new listboxHeaderWidthObj("Qty",true,"80px"),
	new listboxHeaderWidthObj("Cost",false,""),
	new listboxHeaderWidthObj("Loca",true,"80px"),
	new listboxHeaderWidthObj("StockCode",false,""),
	new listboxHeaderWidthObj("stk_id",false,""),
	new listboxHeaderWidthObj("origid",false,""),
};

Object[] itmcode_stockcode_hds =
{
	new listboxHeaderWidthObj("No.",true,"70px"),
	new listboxHeaderWidthObj("Serial No.",true,""),
	new listboxHeaderWidthObj("Qty",true,"80px"),
	new listboxHeaderWidthObj("Cost",false,""),
	new listboxHeaderWidthObj("Loca",false,"80px"),
	new listboxHeaderWidthObj("StockCode",true,""),
	new listboxHeaderWidthObj("stk_id",false,""),
	new listboxHeaderWidthObj("origid",false,""),
};

ITEM_CODE_POS = 1;
ITEM_QTY_POS = 2;
ITEM_COST_POS = 3;
ITEM_LOCA_POS = 4;
ITEM_STOCKCODE_POS = 5;
ITEM_STKID_POS = 6;
ITEM_ORIGID_POS = 7; // for other module to populate origid if any 

class itemsdclick implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(Event event) throws UiException
	{
		isel = event.getTarget();
		try
		{
			inboundItems_callBack(isel);
		} catch (Exception e) {}
	}
}
itemdoubleclicker = new itemsdclick();

/**
 * Insert item-codes in iks to listbox
 * @param iks      item-codes string delimited by \n
 * @param lbholder DIV holder for listbox
 * @param lbid     the listbox ID to use
 * @param showtype 1=without stock-code, 2=with stock-code
 */
SHOWWITH_STOCKCODE = 2;
SHOWNO_STOCKCODE = 1;
Listbox insertItemcodes(String iks, Div lbholder, String lbid, int showtype)
{
	newlb = lbholder.getFellowIfAny(lbid);
	if(newlb == null) // listbox not exist, create one
	{
		hds = (showtype == SHOWWITH_STOCKCODE) ? itmcode_stockcode_hds : itmcodehds;
		newlb = lbhand.makeVWListbox_Width(lbholder, hds, lbid, 10);
		newlb.setMultiple(true); newlb.setCheckmark(true);
	}

	ArrayList kabom = new ArrayList();
	itms = iks.split("\n");

	for(i=0; i<itms.length; i++)
	{
		kabom.add("0"); kabom.add(itms[i].trim());
		kabom.add("1"); kabom.add("0"); kabom.add("UNK");
		kabom.add("UNK"); kabom.add("0"); kabom.add("0"); // stockcode,stk_id,origid
		lbhand.insertListItems(newlb,kiboo.convertArrayListToStringArray(kabom),"false","");
		kabom.clear();
	}
	lbhand.setDoubleClick_ListItems(newlb, itemdoubleclicker);
	renumberListbox(newlb,0,1,true);
	newlb.setRows(10);

	return newlb;
}

/**
 * Check scan-items or loaded-items from tblStockOutDetail 's stock-code
 * hi-lite unmatching ones
 */
void checkScanItemStockCode()
{
	scanitmlb = scanitems_holder.getFellowIfAny("itemcodes_lb");
	checkUpdateStockCode(scanitems_holder,"itemcodes_lb",ITEM_CODE_POS,ITEM_STOCKCODE_POS,ITEM_STKID_POS);
	if(scanitmlb != null) // hi-lite un-matching selected outbound stock-code against scan-items
	{
		ts = scanitmlb.getItems().toArray();
		for(i=0;i<ts.length;i++)
		{
			skc = lbhand.getListcellItemLabel(ts[i],ITEM_STOCKCODE_POS);
			if(!glob_sel_stockcode.equals(skc))
			{
				setListcellItemStyle(ts[i],ITEM_STOCKCODE_POS,"background:#CC3838;font-size:9px");
			}
		}
	}
}

/**
 * Check in listbox column iscancol item against StockList for stock-code
 * @param iholder  DIV holder
 * @param ilbid    listbox ID
 * @param iscancol items column to scan
 * @param istkcol  stock-code to update
 * @param istkidcol  StockMasterDetail ID
 */
void checkUpdateStockCode(Div iholder, String ilbid, int iscancol, int istkcol, int istkidcol)
{
	prvlb = iholder.getFellowIfAny(ilbid);
	if(prvlb == null) return;
	ts = prvlb.getItems().toArray();
	if(ts.length == 0) return;

	Sql sql = wms_Sql();
	for(i=0;i<ts.length;i++)
	{
		sci = lbhand.getListcellItemLabel(ts[i],iscancol);
		if(!sci.equals(""))
		{
			sqlstm = "select ID,Stock_Code from StockMasterDetails where ID=" +
			"(select stk_id from StockList where Itemcode='" + sci + "' limit 1);";

			r = (GroovyRowResult)sql.firstRow(sqlstm);

			if(r != null)
			{
				lbhand.setListcellItemLabel(ts[i],istkidcol, kiboo.checkNullString(r.get("ID").toString()));
				lbhand.setListcellItemLabel(ts[i],istkcol, kiboo.checkNullString(r.get("Stock_Code")));
			}
		}
	}
	sql.close();
}

/**
 * Save or update scan-items into tblStockOutDetail - by parent_id = iob
 * @param iob outbound voucher no.
 * @param iparentstkid selected parent stock-ID
 * @param ilb listbox to process
 */
void saveOutboundScanItems(String iob, String iparentstkid, Listbox ilb)
{
	checkScanItemStockCode(); // before saving, do stock-code digging for all scan-items
	dbg = "";

	Sql sql = wms_Sql();
	Connection thecon = sql.getConnection();
	PreparedStatement pstmtinsert = thecon.prepareStatement("insert into tblStockOutDetail (StockCode,parent_id,stk_id,par_order_stk_id,Quantity) values (?,?,?,?,?);");
	PreparedStatement pstmtupdate = thecon.prepareStatement("update tblStockOutDetail set StockCode=?, stk_id=?, Quantity=? where Id=?");

	ts = ilb.getItems().toArray();
	for(i=0;i<ts.length;i++)
	{
		itm = lbhand.getListcellItemLabel(ts[i],ITEM_CODE_POS);
		stkid = lbhand.getListcellItemLabel(ts[i],ITEM_STKID_POS);
		origid = lbhand.getListcellItemLabel(ts[i],ITEM_ORIGID_POS);
		qty = lbhand.getListcellItemLabel(ts[i],ITEM_QTY_POS);

		if(origid.equals("0")) // if no origid, insert into db
		{
			pstmtinsert.setString(1,itm);
			pstmtinsert.setInt(2,Integer.parseInt(iob));
			pstmtinsert.setInt(3,Integer.parseInt(stkid));
			pstmtinsert.setInt(4,Integer.parseInt(iparentstkid));
			pstmtinsert.setInt(5,Integer.parseInt(qty));
			pstmtinsert.addBatch();
		}
		else
		{
			pstmtupdate.setString(1,itm);
			pstmtupdate.setInt(2,Integer.parseInt(stkid));
			pstmtupdate.setInt(3,Integer.parseInt(qty));
			pstmtupdate.setInt(4,Integer.parseInt(origid));
			pstmtupdate.addBatch();
		}
			//if(DEBUGON) dbg += "[UPD] itm: " + itm + " :: stkid: " + stkid + " :: origid: " + origid + "\n";
	}

	pstmtupdate.executeBatch(); pstmtupdate.close();
	pstmtinsert.executeBatch(); pstmtinsert.close();
	sql.close();

	//if(DEBUGON) debugbox.setValue(dbg);
}

/**
 * Load/show recs from tblStockOutDetail , uses listbox header defs in itemsfunc.itmcode_stockcode_hds
 * @param  pParent parent stock outbound voucher no.
 * @param  pStkid  the stk-id, normally just use glob_sel_stkid
 * @param  pHolder DIV holder
 * @param  pLbid   listbox ID
 * @return         the created-filled listbox
 */
Listbox showScanItems_byParent(String pParent, String pStkid, Div pHolder, String pLbid)
{
	newlb = lbhand.makeVWListbox_Width(pHolder, itmcode_stockcode_hds, pLbid, 3);
	newlb.setMultiple(true); newlb.setCheckmark(true);

	sqlstm = "select Id,StockCode,stk_id,Quantity from tblStockOutDetail where par_order_stk_id=" + pStkid + " and parent_id=" + pParent;
	r = sqlhand.rws_gpSqlGetRows(sqlstm);
	if(r.size() > 0)
	{
		newlb.setRows(10);
		ArrayList kabom = new ArrayList();
		for(d : r)
		{
			kabom.add("0"); kabom.add(d.get("StockCode").trim());
			kabom.add(d.get("Quantity").toString()); kabom.add("0"); kabom.add("UNK");
			kabom.add("UNK"); kabom.add(d.get("stk_id").toString()); kabom.add( d.get("Id").toString() ); // stockcode,stk_id,origid
			lbhand.insertListItems(newlb,kiboo.convertArrayListToStringArray(kabom),"false","");
			kabom.clear();
		}
		lbhand.setDoubleClick_ListItems(newlb, itemdoubleclicker); // uses double-clicker handler in itemsfunc.zs
		renumberListbox(newlb,0,1,true);
		checkScanItemStockCode();
	}
	return newlb;
}

