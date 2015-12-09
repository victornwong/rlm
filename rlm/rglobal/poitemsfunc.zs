// PO items management

Object[] poitemshds =
{
	new listboxHeaderWidthObj("No.",true,"55px"),
	new listboxHeaderWidthObj("stkid",false,""),
	new listboxHeaderWidthObj("Stock name",true,"150px"),
	new listboxHeaderWidthObj("Description",true,""),
	new listboxHeaderWidthObj("Qty",true,"50px"),
	new listboxHeaderWidthObj("U/Price",true,"70px"),
	new listboxHeaderWidthObj("SubTotal",true,"70px"),
	new listboxHeaderWidthObj("Struct",true,""),
};
POITEMS_STOCKCODE = 1; POITEMS_STOCKNAME = 2; POITEMS_EXTRANOTE = 3; POITEMS_QTY = 4;
POITEMS_UPRICE = 5; POITEMS_SUBTOTAL = 6; POITEMS_STRUCT = 7;

class poitemdclik implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(Event event) throws UiException
	{
		isel = event.getTarget();
		try
		{
			POitems_callback(isel);
		} catch (Exception e) {}
	}
}
poitems_dclick = new poitemdclik();

/**
 * More flexible to show PO items
 * @param ipo     the selected PO
 * @param iholder DIV holder
 * @param ilbid   listbox ID
 */
Listbox showPOitems(String ipo, Div iholder, String ilbid)
{
	Listbox newlb = lbhand.makeVWListbox_Width(iholder, poitemshds, ilbid, 10);
	newlb.setMultiple(true); newlb.setCheckmark(true);
	pograndtotal_lbl.setValue(""); // always clear previous grand-total if any

	sqlstm = "select m.description,m.unitprice,m.quantity,m.stock_code," +
	"(select stock_code from StockMasterDetails where ID=m.stock_code) as stockname from PurchaseReq_Items m where m.pr_parent_id=" + ipo;
	r = sqlhand.rws_gpSqlGetRows(sqlstm);
	if(r.size() > 0)
	{
		String[] fl = { "stock_code","stockname","description","quantity","unitprice" };
		ArrayList kabom = new ArrayList();
		for(d : r)
		{
			kabom.add("0");
			ngfun.popuListitems_Data(kabom,fl,d);
			kabom.add("0"); // subtotal

			stkstruct = (d.get("stock_code") != null) ? getStockMasterStruct(d.get("stock_code").toString()) : "";
			kabom.add(stkstruct);

			lbhand.insertListItems(newlb,kiboo.convertArrayListToStringArray(kabom),"false","");
			kabom.clear();
		}

		recalcSubtotal(newlb,POITEMS_QTY,POITEMS_UPRICE,POITEMS_SUBTOTAL);
		renumberListbox(newlb, 0, 1, true);
		lbhand.setDoubleClick_ListItems(newlb, poitems_dclick);
	}
	return newlb;
}

/**
 * Save PO items to PurchaseReq_Items - uses mysql batch statements
 * @param ipo   [description]
 * @param ipilb [description]
 */
void savePOitems(String ipo, Listbox ipilb)
{
	if(ipilb.getItemCount() == 0) return;
	ts = ipilb.getItems().toArray();

	sqlstm = "delete from PurchaseReq_Items where pr_parent_id=" + ipo;
	sqlhand.rws_gpSqlExecuter(sqlstm); // delete existing PO items

	Sql sql = wms_Sql();
	Connection thecon = sql.getConnection();
	PreparedStatement pstmt = thecon.prepareStatement(
	"insert into PurchaseReq_Items (pr_parent_id,description,unitprice,quantity,stock_code) " +
	"values (?,?,?,?,?);");

	for(i=0;i<ts.length;i++)
	{
		pstmt.setInt(1,Integer.parseInt(ipo));
		pstmt.setString(2, lbhand.getListcellItemLabel(ts[i],POITEMS_EXTRANOTE) );
		pstmt.setFloat(3, Float.parseFloat( lbhand.getListcellItemLabel(ts[i],POITEMS_UPRICE) ) );
		pstmt.setInt(4,Integer.parseInt( lbhand.getListcellItemLabel(ts[i],POITEMS_QTY) ));
		pstmt.setInt(5,Integer.parseInt( lbhand.getListcellItemLabel(ts[i],POITEMS_STOCKCODE) ));
		pstmt.addBatch();
	}
	pstmt.executeBatch(); pstmt.close(); sql.close();
}

/**
 * Get selected order-queue items from orderqueuefunc -> orderque_hds and put into poitemshds
 * @param idiv  : listbox holder
 * @param ilbid : listbox ID - def in orderqueuefunc.zs ORDERQUEUE_LB_ID
 * @param itype : 1=add queue item only, 2=add and remove from queue
 */
void addQueueItem_toPO(Div idiv, String ilbid, int itype)
{
	orderq_listo.close();
	if(!lbhand.check_ListboxExist_SelectItem(idiv,ilbid)) return;

	poitemslb = poitems_holder.getFellowIfAny("poitems_lb");
	if(poitemslb == null) return;

	tlb = idiv.getFellowIfAny(ilbid);
	ts = tlb.getSelectedItems().toArray();

	ArrayList kabom = new ArrayList();

	for(i=0;i<ts.length;i++)
	{
		stkid = lbhand.getListcellItemLabel(ts[i],ORDQ_STKID);
		kabom.add("0");
		kabom.add(stkid); // stkid
		kabom.add(lbhand.getListcellItemLabel(ts[i],ORDQ_STOCKCODE)); // stock-name
		kabom.add(getStockMaster_descriptionById(stkid)); // description
		kabom.add(lbhand.getListcellItemLabel(ts[i],ORDQ_QTY)); // qty
		kabom.add("0"); // unit-price
		kabom.add("0"); // subtotal
		kabom.add(""); // stock-master struct
		lbhand.insertListItems(poitemslb,kiboo.convertArrayListToStringArray(kabom),"false","");
		kabom.clear();
	}
	recalcSubtotal(poitemslb,POITEMS_QTY,POITEMS_UPRICE,POITEMS_SUBTOTAL);
	renumberListbox(poitemslb, 0, 1, true);
	lbhand.setDoubleClick_ListItems(poitemslb, poitems_dclick);

	if(itype == 2) orderqueue_doFunc("ordq_remove_b","",""); // remove queue items using func in orderqueuefunc.zs
}
