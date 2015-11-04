// Purchase req/order functions
// Some of the funcs use hardcoded UI objs

// call-back from polister.diggpodclick() double-clicker event
// ipo = PO_PREFIX + PO no.
// isupplier = the PO supplier
void diggPO_callback(String ipo, String isupplier)
{
	digpo_pop.close();
	w_reference_tb.setValue(ipo);
	w_description_tb.setValue(isupplier);
}

/**
 * call-back from polister.diggpoitemsdclick()
 * @param isel selected list-item, refer to SML_POITEM_* in polister.zs
 */
void diggPOitems_callback(Object isel)
{
	glob_stkin_stkid = lbhand.getListcellItemLabel(isel,SML_POITEM_STKID);
	glob_sel_stock_code = lbhand.getListcellItemLabel(isel,SML_POITEM_STOCKCODE);
	glob_item_uprice = lbhand.getListcellItemLabel(isel,SML_POITEM_UPRICE);
	glob_po_exchange_rate = lbhand.getListcellItemLabel(isel,SML_POITEM_EXCHANGERATE);
	glob_po_curcode = lbhand.getListcellItemLabel(isel,SML_POITEM_CURCODE);
	w_stock_code_tb.setValue(glob_sel_stock_code);
	digpoitems_pop.close();
}

/**
 * Call-back from stock-master listbox clicker - call from stocklister.stkitemdoubelclik() and stocklister.stkitemclik()
 * @param itarget the selected listitem object
 */
void stockItemListbox_callback(Object itarget)
{
	glob_stkin_stkid = glob_sel_id; // glob_sel_id set by event-handler
	w_stock_code_tb.setValue(glob_sel_stock_code);
	editstockitem_pop.close();
	liststkmaster_pop.close();
}

/**
 * Double-click callback from itemsfunc.itemsdclick
 * @param isel list-item cliked
 */
void inboundItems_callBack(Object isel)
{
	i_itemcode_tb.setValue( lbhand.getListcellItemLabel(isel,ITEM_CODE_POS) );
	i_quantity_tb.setValue( lbhand.getListcellItemLabel(isel,ITEM_QTY_POS) );
	i_cost_tb.setValue( lbhand.getListcellItemLabel(isel,ITEM_COST_POS) );
	i_bin_tb.setValue( lbhand.getListcellItemLabel(isel,ITEM_LOCA_POS) );
	itemcode_sel_obj = isel;

	showStock_location(glob_stkin_stkid, edititemstkloca_holder, "");

	edititem_pop.open(isel);
}

/**
 * Put-away stock into StockLister - get scanned items from listbox and insert, presumming loca/bin already verified
 * istkinid : stock-in voucher no
 * istkid : stock-master ID
 * iref : stock-in reference as in PO or internal-transact no.
 * icurcode : PO curcode
 * iexhrate : PO exchange rate
 * iuprice : unit-price from PO
 * lbholder : Div holder
 * lbid : listbox string ID
*/
void putAwayStock(String istkinid, String istkid, String iref, String icurcode, String iexhrate, String iuprice, Div lbholder, String lbid)
{
	//SimpleDateFormat formatter = new SimpleDateFormat("yyyy-MM-dd");
	//todaydate = new java.sql.Date(formatter.parse(kiboo.todayISODateTimeString()));
	todaydate = kiboo.todayISODateTimeString();
	newlb = lbholder.getFellowIfAny(lbid);
	if(newlb == null) return false;
	ts = newlb.getItems().toArray();

	Sql sql = wms_Sql();
	Connection thecon = sql.getConnection();

	PreparedStatement pstmt = thecon.prepareStatement(
		"insert into StockList (Itemcode,Balance,AverageCost,Bin,stk_id,RefNo,RefDate,LastPurchase,VoucherNo,stage,CurCode,ExchangeRate,Purchase) " +
		"values (?,?,?,?,?, ?,?,?,?,?, ?,?,?);");

	for(i=0;i<ts.length;i++)
	{
		itmc = lbhand.getListcellItemLabel(ts[i],ITEM_CODE_POS); qty = lbhand.getListcellItemLabel(ts[i],ITEM_QTY_POS);
		cost = lbhand.getListcellItemLabel(ts[i],ITEM_COST_POS); loca = lbhand.getListcellItemLabel(ts[i],ITEM_LOCA_POS);

		pstmt.setString(1,itmc);
		pstmt.setInt(2, (int)Float.parseFloat(qty));
		pstmt.setFloat(3, Float.parseFloat(cost));
		pstmt.setString(4, loca);
		pstmt.setInt(5, Integer.parseInt(istkid));

		pstmt.setString(6,iref); // RefNo
		pstmt.setDate(7, new java.sql.Date(System.currentTimeMillis()) ); // RefDate
		pstmt.setDate(8, new java.sql.Date(System.currentTimeMillis()) ); // LastPurchase
		pstmt.setString(9, STKIN_PREFIX + istkinid); // VoucherNo = stkin_prefix defn in rglobal.zs
		pstmt.setString(10,"NEW");
		pstmt.setString(11,icurcode); // currency code
		pstmt.setFloat(12,Float.parseFloat(iexhrate)); // exchange rate
		pstmt.setFloat(13,Float.parseFloat(iuprice)); // PO item unit-price
		pstmt.addBatch();
	}
	pstmt.executeBatch(); pstmt.close(); sql.close();
}

/**
 * Hard-delete STKIN records - use with care
 * @param istkin STKIN voucher no.
 */
void deleteStockin(String istkin)
{
	sqlstm = "delete from tblStockInDetail where parent_id=" + istkin;
	sqlhand.rws_gpSqlExecuter(sqlstm);
	sqlstm = "delete from tblStockInMaster where Id=" + istkin;
	sqlhand.rws_gpSqlExecuter(sqlstm);
	refreshThings();
}

/**
 * Multi-purpose function dispenser - uses captureitemcodes_holder and "itemcodes_lb". ITEM_QTY_POS, ITEM_COST_POS defi in itemsfunc.zs
 * @param iwhat button ID
 */
void mpfFunc(String iwhat)
{
	newlb = captureitemcodes_holder.getFellowIfAny("itemcodes_lb");
	if(newlb == null) return;
	ts = newlb.getSelectedItems().toArray();
	if(ts.length == 0) return;

	sqty = ""; try { sqty = Integer.parseInt(mpf_quantity_tb.getValue()).toString(); } catch (Exception e) {}
	scost = ""; try { scost = Float.parseFloat(mpf_cost_tb.getValue()).toString(); } catch (Exception e) {}
	sloca = kiboo.replaceSingleQuotes( mpf_bin_tb.getValue().trim() ); 
	errflag = false; errmsg = ""; updcolumn = -1; updstr = "";

	if(iwhat.equals("mpfupdqty_b") && sqty.equals("")) // empty qty
	{
		errflag = true; errmsg = "ERR: must enter a number for quantity";
	}

	if(iwhat.equals("mpfupdcst_b") && scost.equals("")) // empty cost
	{
		errflag = true; errmsg = "ERR: must enter a proper cost";
	}

	if(errflag)
	{
		guihand.showMessageBox(errmsg); return;
	}

	if(iwhat.equals("mpfupdqty_b"))
	{
		updcolumn = ITEM_QTY_POS;
		updstr = sqty;
	}

	if(iwhat.equals("mpfupdcst_b"))
	{
		updcolumn = ITEM_COST_POS;
		updstr = scost;
	}

	if(iwhat.equals("mpfupdbin_b"))
	{
		updcolumn = ITEM_LOCA_POS;
		updstr = sloca;
	}

	for(i=0; i<ts.length; i++)
	{
		lbhand.setListcellItemLabel(ts[i],updcolumn,updstr);
	}
}

void grabStockCode(Component icom)
{
	refno = w_reference_tb.getValue().trim();
	gotpo = "";
	try { gotpo = refno.substring(0,4); } catch (Exception e) {}
	if(!gotpo.equals("MYPO")) liststkmaster_pop.open(icom);
	else
	{
		pono = 0;
		try {	pono = Integer.parseInt(refno.substring(4,refno.length())); } catch (Exception e) {}
		if(pono != 0) // see valid PO no.
		{
			digloadPOitems(digpoitems_holder,pono); // polister.zs
			digpoitems_pop.open(icom);
		}
		else
			liststkmaster_pop.open(icom); // show the stock-master selector
	}
}

/**
 * showStock_location double-click call-back - to modify location drop-downs - can be customized for other modu
 * @param isel [description]
 */
void showStockLoca_dcallback(Object isel)
{
	//T1-2-3
	loca = lbhand.getListcellItemLabel(isel,0);
	try
	{
		rack = loca.substring(0,1);
		rackn = loca.substring(1,2);
		shf = loca.substring(3,4);
		bin = loca.substring(5,6);

		lbhand.matchListboxItems(mpf_mainbin,rack); // update MPF popup location drop-downs
		lbhand.matchListboxItems(mpf_mainbinno,rackn);
		lbhand.matchListboxItems(mpf_shelfno,shf);
		lbhand.matchListboxItems(mpf_partino,bin);

		lbhand.matchListboxItems(i_mainbin,rack); // update per item location drop-downs
		lbhand.matchListboxItems(i_mainbinno,rackn);
		lbhand.matchListboxItems(i_shelfno,shf);
		lbhand.matchListboxItems(i_partino,bin);
	} catch (Exception e) {}
	//debugbox.setValue(rack + " :: " + rackn + " :: " + shf + " :: " + bin);
}

Object[] stklocahds =
{
	new listboxHeaderWidthObj("Bin / Location",true,""),
	new listboxHeaderWidthObj("Qty",true,"70px"),
};

class shwstklocadclick implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(Event event) throws UiException
	{
		isel = event.getTarget();
		try
		{
			showStockLoca_dcallback(isel);
		} catch (Exception e) {}
	}
}
shwstkloca_doubclik = new shwstklocadclick();

void showStock_location(String istkid, Div iholder, String ilbid)
{
	kc = iholder.getChildren().toArray();
	for(i=0;i<kc.length;i++) // clear previous listbox if any
	{
		kc[i].setParent(null);
	}

	sqlstm = "SELECT distinct sl.Bin, (select sum(Balance) from StockList where Bin=sl.Bin) as qty from StockList sl " +
	"where sl.stage='NEW' and sl.stk_id=" + istkid + " order by sl.Bin;";

	r = sqlhand.rws_gpSqlGetRows(sqlstm);
	if(r.size() == 0) return;

	if(ilbid.equals("")) ilbid = kiboo.makeRandomId("locab");

	Listbox newlb = lbhand.makeVWListbox_Width(iholder, stklocahds, ilbid, 5);
	ArrayList kabom = new ArrayList();
	String[] fl = { "Bin", "qty" };
	for(d : r)
	{
		ngfun.popuListitems_Data(kabom,fl,d);
		lbhand.insertListItems(newlb,kiboo.convertArrayListToStringArray(kabom),"false","");
		kabom.clear();
	}
	lbhand.setDoubleClick_ListItems(newlb, shwstkloca_doubclik);
}

/**
 * Generate PO template using BIRT - can be used for other modu, remember the popup
 * @param ipo : the PO
 */
void printPO_birt(String ipo)
{
	bfn = "rlm/purchaseOrder_v1.rptdesign";
	thesrc = birtURL() + bfn + "&ponum=" + ipo + "&popref=" + PO_PREFIX;

	if(poprintholder.getFellowIfAny("poprintframe") != null) poprintframe.setParent(null);
	Iframe newiframe = new Iframe();
	newiframe.setId("poprintframe"); newiframe.setWidth("100%");	newiframe.setHeight("600px");
	newiframe.setSrc(thesrc); newiframe.setParent(poprintholder);
	poprintoutput.open(printpo_b);
}
