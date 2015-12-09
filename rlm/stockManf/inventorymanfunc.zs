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
		try
		{
			inventory_peritem_Callback(event.getReference());
		} catch (Exception e) {}
	}
}
invperitem_clicker = new invt_peritem_click();

Listbox showInventory_ItemsList(String pStkid, Div pHolder, String pLBid)
{
	Listbox newlb = lbhand.makeVWListbox_Width(pHolder, invtitemhds, pLBid, 18);
	sqlstm = "select origid,Itemcode,RefNo,RefDate,Balance,Bin,stage,LastPurchase,OutRefNo,OutRefDate,stk_id from StockList where stk_id=" + pStkid + " order by stage;";
	r = sqlhand.rws_gpSqlGetRows(sqlstm);
	if(r.size() == 0) return;
	newlb.setMultiple(true); newlb.setCheckmark(true); // newlb.setRows(20); newlb.setMold("paging");
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
	return newlb;
}

/**
 * Show inventory things by stock-master ID passed
 * @param istkid : the stock-master ID
 */
void showInventoryMeta(String istkid)
{
	newlb = showInventory_ItemsList(istkid,invtitems_holder,"inventoryitems_lb");
	items_need_update = false;
}

class invtclick implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(Event event) throws UiException
	{
		try
		{
			inventoryLBonselect_callback(event.getReference());
		} catch (Exception e) {}
	}
}
invtlist_clicker = new invtclick();

class invtdclick implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(Event event) throws UiException
	{
		try
		{
			setGlobalInventoryLBvars(event.getTarget());
		} catch (Exception e) {}
	}
}
invtlist_dclicker = new invtdclick();

Object[] invthds =
{
	new listboxHeaderWidthObj("STKID",true,"60px"),
	new listboxHeaderWidthObj("Struct",true,""),
	new listboxHeaderWidthObj("Stock code",true,""),
	new listboxHeaderWidthObj("Description",true,""),
	new listboxHeaderWidthObj("Qty",true,"80px"),
	new listboxHeaderWidthObj("NEW",true,"80px"),
	new listboxHeaderWidthObj("WIP",true,"80px"),
	new listboxHeaderWidthObj("TRAN",true,"80px"),
	
};
INVT_STKID_POS = 0; INVT_STRUCT_POS = 1; INVT_STOCKCODE_POS = 2;
INVT_DESC_POS = 3; INVT_QTY_POS = 4;

/**
 * Load inventory from StockList
*/
void loadInventory(int itype)
{
	st = kiboo.replaceSingleQuotes(ivt_searchtext_tb.getValue().trim());
	Listbox newlb = lbhand.makeVWListbox_Width(inventoryholder, invthds, "inventory_lb", 18);

	sqlstm = "select distinct i.stk_id, s.Stock_Code, s.Description, " +
	"(select sum(Balance) from StockList where stk_id=i.stk_id) as totalqty," +
	"(select sum(Balance) from StockList where stk_id=i.stk_id and stage='NEW' or stage='' or stage is null) as newqty," +
	"(select sum(Balance) from StockList where stk_id=i.stk_id and stage='WIP') as wipqty," +
	"(select sum(Balance) from StockList where stk_id=i.stk_id and stage='TRAN') as tranqty " +
	"from StockList i left join StockMasterDetails s on i.stk_id=s.ID ";

	if(!st.equals(""))
		sqlstm += "where s.stock_code like '%" + st + "%' or i.Itemcode like '%" + st + "%' or i.RefNo like '%" + st + "%' or " +
		"i.OutRefNo like '%" + st + "%' or Bin like '%" + st + "%' ";

	sqlstm += " order by s.Stock_Code";

	r = sqlhand.rws_gpSqlGetRows(sqlstm);
	if(r.size() == 0) return;
	newlb.setMold("paging"); // newlb.setRows(20); newlb.setMultiple(true); newlb.setCheckmark(true); 
	newlb.addEventListener("onSelect", invtlist_clicker);

	String[] fl = { "Stock_Code","Description","totalqty","newqty","wipqty","tranqty" };
	ArrayList kabom = new ArrayList();

	for(d : r)
	{
		istkid = d.get("stk_id").toString();
		kabom.add(istkid);
		kabom.add(getStockMasterStruct(istkid));
		ngfun.popuListitems_Data(kabom,fl,d);
		lbhand.insertListItems(newlb,kiboo.convertArrayListToStringArray(kabom),"false","");
		kabom.clear();
	}
	//lbhand.setDoubleClick_ListItems(newlb, invtlist_dclicker);
}

// Inventory transfer functions - uses hardcoded UI components etc

/**
 * Fill-up changecategory_pop.sametype_stockcode_lb with similar stock-master stock-code but different cat>grp>class
 * Uses glob_invt_stockcode and glob_invt_stkid
 */
void updateSameType_stockcodelist()
{
	sametype_stockcode_lb.getItems().clear(); // remove any previous list-items

	sqlstm = "select distinct ID,Stock_Cat,GroupCode,ClassCode,Stock_Code from StockMasterDetails " +
	"where Stock_Code='" + glob_invt_stockcode + "' and ID<>" + glob_invt_stkid;

	r = sqlhand.rws_gpSqlGetRows(sqlstm);
	if(r.size() == 0) return;

	ArrayList kabom = new ArrayList();
	for(d : r)
	{
		kstruct = kiboo.checkNullString(d.get("Stock_Cat")) + ">" + kiboo.checkNullString(d.get("GroupCode")) + ">" + 
		kiboo.checkNullString(d.get("ClassCode")) + "> " + d.get("Stock_Code");

		kabom.add(kstruct);
		kabom.add( d.get("ID").toString() ); // stock-master ID
		lbhand.insertListItems(sametype_stockcode_lb,kiboo.convertArrayListToStringArray(kabom),"false","");
		kabom.clear();
	}
	try { sametype_stockcode_lb.setSelectedIndex(0); } catch (Exception e) {}
}

Object[] stktfxhds =
{
	new listboxHeaderWidthObj("origid",false,""),
	new listboxHeaderWidthObj("No.",true,"50px"),
	new listboxHeaderWidthObj("Serial No.",true,""),
};

/**
 * Populate the selected inventory item into the "to-move" listbox
 * The things in the listbox will be inserted into db.InventoryTransferRecs
 * Uses changecategory_pop.itemstransfer_holder
 * Refer to inventorymanfunc.invtitemhds for listbox column pos
 */
void populateSelectedInventoryToMove()
{
	if(itemstransfer_holder.getFellowIfAny("itemstransfer_lb") != null)
		itemstransfer_lb.getItems().clear(); // always clear them prev transfer items if any

	newlb = invtitems_holder.getFellowIfAny("inventoryitems_lb");
	if(newlb == null) return;
	ts = newlb.getSelectedItems().toArray();
	if(ts.length == 0) return;

	Listbox newlb = lbhand.makeVWListbox_Width(itemstransfer_holder, stktfxhds, "itemstransfer_lb", 8);
	ArrayList kabom = new ArrayList(); linecount = 1;
	for(i=0; i<ts.length; i++)
	{
		kabom.add(lbhand.getListcellItemLabel(ts[i],INVTITEM_ORIGID_POS));
		kabom.add( linecount.toString() + "." );
		kabom.add(lbhand.getListcellItemLabel(ts[i],INVTITEM_STOCKCODE_POS));
		lbhand.insertListItems(newlb,kiboo.convertArrayListToStringArray(kabom),"false","");
		kabom.clear();
		linecount++;
	}
}

/**
 * Actually putting them selected items into InventoryTransferRecs to keep track of the movements.
 * Update StockList also with new stk_id
 */
void transferInventory()
{
	smi = null;
	try { smi = sametype_stockcode_lb.getSelectedItem(); } catch (Exception e) {}
	if(smi == null) { guihand.showMessageBox("ERR: invalid stock-master to transfer items to"); return; } // Make sure got valid transfer-to stock-master code

	smstkid = lbhand.getListcellItemLabel(smi,1); // get stk-id from drop-down, refer to sametype_stockcode_lb

	if(itemstransfer_holder.getFellowIfAny("itemstransfer_lb") == null) return;
	if(itemstransfer_lb.getItemCount() == 0) return; // nothing in transfer items listbox

	if(Messagebox.show("This will move the selected inventory items to the new stock-master", "Are you sure?",
		Messagebox.YES | Messagebox.NO, Messagebox.QUESTION) != Messagebox.YES) return;

	ts = itemstransfer_lb.getItems().toArray();
	todaydate =  kiboo.todayISODateTimeString();
	unm = "tester"; try { unm = useraccessobj.username; } catch (Exception e) {}

	Sql sql = wms_Sql();
	Connection thecon = sql.getConnection();
	PreparedStatement pstmt = thecon.prepareStatement("insert into InventoryTransferRecs (tfxdate,username,Itemcode,last_stkid,new_stkid) values " +
	"(?,?,?,?,?);");
	PreparedStatement updstk = thecon.prepareStatement("update StockList set stk_id=? where origid=? limit 1;");
	for(i=0; i<ts.length; i++)
	{
		iorig = Integer.parseInt( lbhand.getListcellItemLabel(ts[i],0) ); // refer to stktfxhds for column pos
		isn = lbhand.getListcellItemLabel(ts[i],2);
		newstkid = Integer.parseInt(smstkid);

		pstmt.setDate(1, new java.sql.Date(System.currentTimeMillis()) );
		pstmt.setString(2,unm);
		pstmt.setString(3,isn);
		pstmt.setInt(4, Integer.parseInt(glob_invt_stkid) ); // last_stkid
		pstmt.setInt(5, newstkid ); // new_stkid
		pstmt.addBatch();

		updstk.setInt(1,newstkid);
		updstk.setInt(2,iorig);
		updstk.addBatch();
	}
	updstk.executeBatch(); updstk.close();
	pstmt.executeBatch(); pstmt.close(); sql.close();

	// Refresh the inventory list and inventory items list
	showInventoryMeta(glob_invt_stkid);
	loadInventory(1);
	putNagText("Items transfered..");
}

Object[] fullstktrfxhds =
{
	new listboxHeaderWidthObj("REC",true,"60px"),
	new listboxHeaderWidthObj("Dated",true,"70px"),
	new listboxHeaderWidthObj("User",true,"70px"),
	new listboxHeaderWidthObj("Serial No.",true,""),
	new listboxHeaderWidthObj("Prev.SM",true,""),
	new listboxHeaderWidthObj("New.SM",true,""),
};

/**
 * Show inventory transfer/movement - data from InventoryTransferRecs
 * @param  pStart  start datebox
 * @param  pEnd    end datebox
 * @param  pSearch search textbox - search for item serial-no
 * @param  pHolder DIV holder
 * @return         the created listbox
 */
Listbox showInventoryTransfer(Datebox pStart, Datebox pEnd, Textbox pSearch, Div pHolder)
{
	st = kiboo.replaceSingleQuotes(pSearch.getValue().trim());
	sdate = kiboo.getDateFromDatebox(pStart); edate = kiboo.getDateFromDatebox(pEnd);

	Listbox newlb = lbhand.makeVWListbox_Width(pHolder, fullstktrfxhds, "inventorytransfer_lb", 10);

	sqlstm = "select * from InventoryTransferRecs where date(tfxdate) between '" + sdate + "' and '" + edate + "' ";
	if(!st.equals("")) sqlstm += "and Itemcode like '%" + st + "%' ";

	r = sqlhand.rws_gpSqlGetRows(sqlstm);
	if(r.size() == 0) return;

	String[] fl = { "origid","tfxdate","username","Itemcode" };
	ArrayList kabom = new ArrayList();

	for(d : r)
	{
		ngfun.popuListitems_Data(kabom,fl,d);

		stkstruct = (d.get("last_stkid") != null) ? getStockMasterStruct_withstockcode(d.get("last_stkid").toString()) : ""; // rlmsql.zs
		kabom.add( stkstruct );

		stkstruct = (d.get("new_stkid") != null) ? getStockMasterStruct_withstockcode(d.get("new_stkid").toString()) : ""; // rlmsql.zs
		kabom.add( stkstruct );

		lbhand.insertListItems(newlb,kiboo.convertArrayListToStringArray(kabom),"false","");
		kabom.clear();
	}
	return newlb;
}

/**
 * Export inventory transfer items from listbox to ms-excel
 * Uses hardcoded stuff
 */
void exportInventoryTransfer()
{
	if(tfxlist_holder.getFellowIfAny("inventorytransfer_lb") == null) return;
	exportExcelFromListbox(inventorytransfer_lb, kasiexport, fullstktrfxhds, "inventorytransfer.xls","transfers");
}

