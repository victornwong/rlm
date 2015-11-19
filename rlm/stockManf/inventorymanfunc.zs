// Inventory management funcs

/**
 * Update inventory movement, StockList.stage and StockList.balance - used in outboundKanban_v1.zul during movement of block lanes
 * Notes: can get negative inventory balance
 * @param ioid   : tblStockOutMaster.Id
 * @param istage : set to which stage
 * @param iqty : inventory qty difference, (0=just move stage, -1=minus balance, 1=plus balance)
 */
void updateInventory_movement(String ioid, String istage, int iqty)
{
	updmove = true;
	today = kiboo.todayISODateTimeString();
	unm = "tester"; try { unm = useraccessobj.username; } catch (Exception e) {}
	stkoutref = STKOUT_PREFIX+ioid; // STKOUT-id for StockList.OutRefNo

	sqlstm = "update tblStockOutMaster set stage='" + istage + "', stage_user='" + unm + "', stage_date='" + today + "' where Id=" + ioid;
	sqlhand.rws_gpSqlExecuter(sqlstm);

	Sql sql = wms_Sql(); Connection thecon = sql.getConnection();
	PreparedStatement pstupd = thecon.prepareStatement("update StockList set stage=?, OutRefNo=?, OutRefDate=?, Balance=Balance+? where Itemcode=? and stk_id=?;");

	sqlstm = "select StockCode,stk_id,Quantity from tblStockOutDetail where parent_id=" + ioid;
	trs = sqlhand.rws_gpSqlGetRows(sqlstm);
	for(d : trs)
	{
		pstupd.setString(1,istage);
		pstupd.setString(2,stkoutref);
		pstupd.setTimestamp(3, java.sql.Timestamp.valueOf(today));
		pstupd.setInt(4,d.get("Quantity")*iqty);
		pstupd.setString(5,d.get("StockCode")); // Itemcode=?
		pstupd.setInt(6,d.get("stk_id")); // stk_id=?
		pstupd.addBatch();
	}
	pstupd.executeBatch(); pstupd.close(); sql.close();
}

/**
 * Save inventory items - uses listbox invtitemhds.origid column for updating
 * Others(refno,outrefno,etc) will be updated dynamically by other modu
 * 13/09/2015: save quantity(StockList.Balance), location(StockList.Bin)
 * @param ilb : listbox to iterate
 */
void saveInventoryItems(Listbox ilb)
{
	if(ilb.getItemCount() == 0) return;
	ts = ilb.getSelectedItems().toArray();
	Sql sql = wms_Sql();
	Connection thecon = sql.getConnection();
	PreparedStatement pstmt = thecon.prepareStatement("update StockList set Balance=?, Bin=? where origid=?");
	for(i=0; i<ts.length; i++)
	{
		oid = lbhand.getListcellItemLabel(ts[i],INVTITEM_ORIGID_POS);
		if(!oid.equals("")) // need - stocklist.origid
		{
			loca = lbhand.getListcellItemLabel(ts[i],INVTITEM_LOCA_POS);
			qty = lbhand.getListcellItemLabel(ts[i],INVTITEM_QTY_POS);

			pstmt.setInt(1,Integer.parseInt(qty));
			pstmt.setString(2,loca);
			pstmt.setInt(3,Integer.parseInt(oid));
			pstmt.addBatch();
		}
	}
	pstmt.executeBatch(); pstmt.close(); sql.close();
}

Object[] invtitemhds =
{
	new listboxHeaderWidthObj("Serial No.",true,""),
	new listboxHeaderWidthObj("Qty",true,"80px"),
	new listboxHeaderWidthObj("Loca/Bin",true,"100px"),
	new listboxHeaderWidthObj("Stage",true,"100px"),
	new listboxHeaderWidthObj("OutRefNo",true,"100px"),
	new listboxHeaderWidthObj("OutRefDate",true,"100px"), // 5
	new listboxHeaderWidthObj("LastPr",true,"80px"),
	new listboxHeaderWidthObj("RefNo",true,"100px"),
	new listboxHeaderWidthObj("RefDate",true,"80px"),
	new listboxHeaderWidthObj("origid",false,""), // 9
};
INVTITEM_STOCKCODE_POS = 0;
INVTITEM_QTY_POS = 1;
INVTITEM_LOCA_POS = 2;
INVTITEM_STAGE_POS = 3;
INVTITEM_REFNO_POS = 7; // usually is the PO no.
INVTITEM_ORIGID_POS = 9;

class invt_peritem_click implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(Event event) throws UiException
	{
		inventory_peritem_Callback(event.getReference());
	}
}
invperitem_clicker = new invt_peritem_click();

/**
 * Show inventory things by stock-master ID passed
 * @param istkid : the stock-master ID
 */
void showInventoryMeta(String istkid)
{
	Listbox newlb = lbhand.makeVWListbox_Width(invtitems_holder, invtitemhds, "inventoryitems_lb", 3);
	sqlstm = "select origid,Itemcode,RefNo,RefDate,Balance,Bin,stage,LastPurchase,OutRefNo,OutRefDate,stk_id from StockList where stk_id=" + istkid + " order by stage;";
	r = sqlhand.rws_gpSqlGetRows(sqlstm);
	if(r.size() == 0) return;
	newlb.setRows(20); newlb.setMultiple(true); newlb.setCheckmark(true); //newlb.setMold("paging");
	newlb.addEventListener("onSelect", invperitem_clicker);

	String[] fl = { "Itemcode","Balance","Bin","stage","OutRefNo","OutRefDate","LastPurchase","RefNo","RefDate", "origid" };
	ArrayList kabom = new ArrayList();

	for(d : r)
	{
		ngfun.popuListitems_Data(kabom,fl,d);
		lbhand.insertListItems(newlb,kiboo.convertArrayListToStringArray(kabom),"false","");
		kabom.clear();
	}
	//lbhand.setDoubleClick_ListItems(newlb, invtlist_dclicker);

	items_need_update = false;
}

class invtclick implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(Event event) throws UiException
	{
		isel = event.getReference();
		setGlobalInventoryLBvars(isel);
		showInventoryMeta(glob_invt_stkid);
		workarea.setVisible(true);
	}
}
invtlist_clicker = new invtclick();

class invtdclick implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(Event event) throws UiException
	{
		isel = event.getTarget();
		try
		{
			setGlobalInventoryLBvars(isel);
		} catch (Exception e) {}
	}
}
invtlist_dclicker = new invtdclick();

Object[] invthds =
{
	new listboxHeaderWidthObj("STKID",true,"60px"),
	new listboxHeaderWidthObj("Stock code",true,""),
	new listboxHeaderWidthObj("Description",true,""),
	new listboxHeaderWidthObj("Qty",true,"80px"), // 3
	new listboxHeaderWidthObj("NEW",true,"80px"),
	new listboxHeaderWidthObj("WIP",true,"80px"), // 5
	new listboxHeaderWidthObj("TRAN",true,"80px"),
	new listboxHeaderWidthObj("Struct",true,""), // 7
};
INVT_STKID_POS = 0;
INVT_STOCKCODE_POS = 1;
INVT_DESC_POS = 2;
INVT_QTY_POS = 3;
INVT_STRUCT_POS = 7;

/**
 * Load inventory from StockList
*/
void loadInventory(int itype)
{
	st = kiboo.replaceSingleQuotes(ivt_searchtext_tb.getValue().trim());
	Listbox newlb = lbhand.makeVWListbox_Width(inventoryholder, invthds, "inventory_lb", 3);

	sqlstm = "select distinct i.stk_id, s.Stock_Code, s.Description, " +
	"(select sum(Balance) from StockList where stk_id=i.stk_id) as totalqty," +
	"(select sum(Balance) from StockList where stk_id=i.stk_id and stage='NEW' or stage='' or stage is null) as newqty," +
	"(select sum(Balance) from StockList where stk_id=i.stk_id and stage='WIP') as wipqty," +
	"(select sum(Balance) from StockList where stk_id=i.stk_id and stage='TRAN') as tranqty " +
	"from StockList i left join StockMasterDetails s on i.stk_id=s.ID ";

	if(!st.equals(""))
		sqlstm += "where s.stock_code like '%" + st + "%' or i.Itemcode like '%" + st + "%' or i.RefNo like '%" + st + "%' or " +
		"i.OutRefNo like '%" + st + "%' or Bin like '%" + st + "%' ";

	sqlstm += " order by i.stk_id";

	r = sqlhand.rws_gpSqlGetRows(sqlstm);
	if(r.size() == 0) return;
	newlb.setRows(20); newlb.setMold("paging"); // newlb.setMultiple(true); newlb.setCheckmark(true); 
	newlb.addEventListener("onSelect", invtlist_clicker);

	String[] fl = { "stk_id","Stock_Code","Description","totalqty","newqty","wipqty","tranqty" };
	ArrayList kabom = new ArrayList();

	for(d : r)
	{
		ngfun.popuListitems_Data(kabom,fl,d);
		kabom.add(getStockMasterStruct(d.get("stk_id").toString()));
		lbhand.insertListItems(newlb,kiboo.convertArrayListToStringArray(kabom),"false","");
		kabom.clear();
	}
	//lbhand.setDoubleClick_ListItems(newlb, invtlist_dclicker);
}

