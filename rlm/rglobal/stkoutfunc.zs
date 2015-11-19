/**
 * STKOUT handling funcs - outboundReq_v1.zul, outboundKanban_v1.zul use these funcs
 */

/**
 * Check scan item is already inside some other STKOUT. Uses StockList.OutRefNo
 * @param  pItemcode scan-item code
 * @return           empty string=not inside any STKOUT, string=with scan-item + STKOUT
 */
String checkItemcode_isFree(String pItemcode)
{
	sqlstm = "select OutRefNo from StockList where Itemcode='" + pItemcode + "';";
	r = sqlhand.rws_gpSqlFirstRow(sqlstm);
	if(r == null) return "";
	if(kiboo.checkNullString(r.get("OutRefNo")).equals("")) return "";
	return pItemcode + " found in " + r.get("OutRefNo") + "\n";
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
 * Insert item-codes in iks to listbox : this works with STKOUT
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
	iteminsomeother = "";

	for(i=0; i<itms.length; i++)
	{
		itmc = itms[i].trim();

		chkfree = checkItemcode_isFree(itmc); // check to make sure scan item not in other STKOUT
		//chkfree = "";
		if(chkfree.equals("")) // empty string, add to scan-item listbox
		{
			kabom.add("0"); kabom.add(itmc);
			kabom.add("1"); kabom.add("0"); kabom.add("UNK");
			kabom.add("UNK"); kabom.add("0"); kabom.add("0"); // stockcode,stk_id,origid
			lbhand.insertListItems(newlb,kiboo.convertArrayListToStringArray(kabom),"false","");
			kabom.clear();
		}
		else // scan item inside some other STKOUT, add to user notification and don't add to scan-item listbox
		{
			iteminsomeother += chkfree;
		}
	}
	lbhand.setDoubleClick_ListItems(newlb, itemdoubleclicker);
	renumberListbox(newlb,0,1,true);
	newlb.setRows(10);

	if(!iteminsomeother.equals(""))
	{
		alert(iteminsomeother); // show user scan-items already inside some other STKOUT
	}
	return newlb;
}

/**
 * Save or update scan-items into tblStockOutDetail - by parent_id = iob
 * Update StockList.OutRefNo and stage too
 * @param iob outbound voucher no.
 * @param iparentstkid selected parent stock-ID
 * @param ilb listbox to process
 * @param istage stkout stage
 */
void saveOutboundScanItems(String iob, String iparentstkid, Listbox ilb, String istage)
{
	checkScanItemStockCode(); // before saving, do stock-code digging for all scan-items
	dbg = "";
	today = kiboo.todayISODateTimeString();
	stkoutref = STKOUT_PREFIX+iob; // STKOUT-id for StockList.OutRefNo

	Sql sql = wms_Sql();
	Connection thecon = sql.getConnection();
	PreparedStatement pstmtinsert = thecon.prepareStatement("insert into tblStockOutDetail (StockCode,parent_id,stk_id,par_order_stk_id,Quantity) values (?,?,?,?,?);");
	PreparedStatement pstmtupdate = thecon.prepareStatement("update tblStockOutDetail set StockCode=?, stk_id=?, Quantity=? where Id=?");
	PreparedStatement slpstmt = thecon.prepareStatement("update StockList set OutRefNo=?, OutRefDate=?, stage=? where stk_id=? and Itemcode=?;");

	ts = ilb.getItems().toArray();
	for(i=0;i<ts.length;i++)
	{
		itm = lbhand.getListcellItemLabel(ts[i],ITEM_CODE_POS);
		stkid = Integer.parseInt( lbhand.getListcellItemLabel(ts[i],ITEM_STKID_POS) );
		origid = Integer.parseInt( lbhand.getListcellItemLabel(ts[i],ITEM_ORIGID_POS) );
		qty = Integer.parseInt( lbhand.getListcellItemLabel(ts[i],ITEM_QTY_POS) );

		if(origid == 0) // if no origid, insert into db
		{
			pstmtinsert.setString(1,itm);
			pstmtinsert.setInt(2,Integer.parseInt(iob));
			pstmtinsert.setInt(3,stkid);
			pstmtinsert.setInt(4,Integer.parseInt(iparentstkid));
			pstmtinsert.setInt(5,qty);
			pstmtinsert.addBatch();
		}
		else
		{
			pstmtupdate.setString(1,itm);
			pstmtupdate.setInt(2,stkid);
			pstmtupdate.setInt(3,qty);
			pstmtupdate.setInt(4,origid);
			pstmtupdate.addBatch();
		}
		//if(DEBUGON) dbg += "[UPD] itm: " + itm + " :: stkid: " + stkid + " :: origid: " + origid + "\n";
		
		// Update StockList with outrefno and stage
		slpstmt.setString(1,stkoutref);
		slpstmt.setTimestamp(2, java.sql.Timestamp.valueOf(today));
		slpstmt.setString(3, istage);
		slpstmt.setInt(4,stkid); // stk_id=?
		slpstmt.setString(5,itm); // Itemcode=?
		slpstmt.addBatch();
	}

	pstmtupdate.executeBatch(); pstmtupdate.close();
	pstmtinsert.executeBatch(); pstmtinsert.close();
	slpstmt.executeBatch(); slpstmt.close();
	sql.close();
	//putNagText("iob=" + iob + " istage=" + istage);
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
			kabom.add(getStockMasterStruct( d.get("stk_id").toString() )); // inventorymanfunc.zs
			lbhand.insertListItems(newlb,kiboo.convertArrayListToStringArray(kabom),"false","");
			kabom.clear();
		}
		lbhand.setDoubleClick_ListItems(newlb, itemdoubleclicker); // uses double-clicker handler in itemsfunc.zs
		renumberListbox(newlb,0,1,true);
		checkScanItemStockCode();
	}
	return newlb;
}

/**
 * Remove stkout scan-items from listbox, if got origid, remove from database
 * knockoff from rlmsql.removeItemcodes()
 * @param iob [description]
 * @param ilb [description]
 */
void removeScanItems(String iob, Listbox ilb)
{
	if(ilb.getItemCount() == 0) return;
	ts = ilb.getSelectedItems().toArray();

	if(Messagebox.show("Remove the selected items..", "Are you sure?",
		Messagebox.YES | Messagebox.NO, Messagebox.QUESTION) != Messagebox.YES) return;

	Sql sql = wms_Sql();
	Connection thecon = sql.getConnection();
	PreparedStatement pstmt = thecon.prepareStatement("delete from tblStockOutDetail where Id=?;");
	PreparedStatement slpst = thecon.prepareStatement("update StockList set OutRefNo=null, OutRefDate=null, stage='NEW' where stk_id=? and Itemcode=?;");

	// TODO not sure if want to remove OutRefNo from StockList : how to handle things which are DONE then un-DONE !!

	for(i=0;i<ts.length;i++)
	{
		origid = Integer.parseInt( lbhand.getListcellItemLabel(ts[i],ITEM_ORIGID_POS) );
		stkid = Integer.parseInt( lbhand.getListcellItemLabel(ts[i],ITEM_STKID_POS) );
		itm = lbhand.getListcellItemLabel(ts[i],ITEM_CODE_POS);
		if(origid != 0) // scan-item is from database, remove it too
		{
			pstmt.setInt(1,origid);
			pstmt.addBatch();
		}

		slpst.setInt(1,stkid); // stk_id=?
		slpst.setString(2,itm); // Itemcode=?
		slpst.addBatch();

		ts[i].setParent(null);
	}
	pstmt.executeBatch(); pstmt.close();
	slpst.executeBatch(); slpst.close(); sql.close();
	renumberListbox(ilb,0,1,true);
}

/**
 * Save outbound items listbox to db, store them into TEXT fields delimited
 * @param iob the outbound rec ID
 * @param ilb listbox holding 'em items
 * @return true=save, false=not
 */
boolean saveOutboundItems(String iob, Listbox ilb)
{
	if(ilb.getItemCount() == 0) return false;
	ts = ilb.getItems().toArray();
	desc = stkcode = stkid = qty = uprice = "";
	for(i=0;i<ts.length;i++)
	{
		desc += kiboo.replaceSingleQuotes(lbhand.getListcellItemLabel(ts[i],OBITM_DESC_POS)) + "::";
		//stkcode += lbhand.getListcellItemLabel(ts[i],OBITM_STKCODE_POS) + "::";
		stkid += lbhand.getListcellItemLabel(ts[i],OBITM_STKID_POS) + "::";
		qty += lbhand.getListcellItemLabel(ts[i],OBITM_QTY_POS) + "::";
		uprice += lbhand.getListcellItemLabel(ts[i],OBITM_UPRICE_POS) + "::";
	}
	sqlstm = "update tblStockOutMaster set order_stockid='" + stkid + "', order_desc='" + desc + "'," +
	"order_qty='" + qty + "', order_uprice='" + uprice + "' where Id=" + iob;

	sqlhand.rws_gpSqlExecuter(sqlstm);
	return true;
}

/**
 * [showOutboundMeta description]
 * @param iob outbound ID
 */
void showOutboundMeta(String iob)
{
	r = getOutboundRec(iob);
	c_voucherno.setValue("STKOUT " + iob);
	ngfun.populateUI_Data(outboundmetaboxes,outbound_fields,r);

	glob_sel_arcode = kiboo.checkNullString(r.get("ar_code"));
	c_customer_name.setDisabled( (!glob_sel_arcode.equals("")) ? true : false); // disable customer-name entry if selected-customer from db

	togButts( (r.get("status").equals("DRAFT")) ? false : true ); // only DRAFT outbound can be juggled

	obgrandtotal_lbl.setValue(""); // clear them totals and gst
	gst_lbl.setValue("");

	newlb = showOutboundItems(r,outitems_holder,"outitems_lb",OBITEMS_PRICE,15);
	gp_calcPOTotal(newlb,OBITM_SUBTOT_POS,obgrandtotal_lbl,"");
	gp_calcGST(obgrandtotal_lbl,GST_RATE,gst_lbl,"");

	workarea.setVisible(true);
}

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
 * Extract stkout items from text field, insert into stkoutprint to be used by BIRT
 * @param pStkout : stock-out voucher no.
 */
void expPrintParts_salesorder(String pStkout)
{
	r = getOutboundRec(pStkout); // parse and insert items into stkoutprint
	if(r == null)
	{
		guihand.showMessageBox("ERR: cannot get stock-out record from database.. contact technical");
		return;
	}
	
	sqlstm = "delete from stkoutprint where stkout_parent=" + pStkout;
	sqlhand.rws_gpSqlExecuter(sqlstm); // delete prev entries in stkoutprint

	Sql sql = wms_Sql();
	Connection thecon = sql.getConnection();
	PreparedStatement pstmt = thecon.prepareStatement("insert into stkoutprint (item_desc,unit_price,qty,stock_code,stk_id,stkout_parent) values " +
		"(?,?,?,?,?,?);");

	desc = stkid = qty = uprice = null;

	try {
	desc = r.get("order_desc").split("::");
	stkid = r.get("order_stockid").split("::");
	qty = r.get("order_qty").split("::");
	uprice = r.get("order_uprice").split("::");
	} catch (Exception e) {}

	if(desc == null) return;

	for(i=0; i<desc.length; i++)
	{
		pstmt.setString(1,desc[i]);
		iuprice = 0.0; try { uprc = Float.parseFloat(uprice[i]); } catch (Exception e) {}
		pstmt.setFloat(2,uprc);
		iqty = 0; try { iqty = Integer.parseInt(qty[i]); } catch (Exception e) {}
		pstmt.setInt(3,iqty);

		// INEFFICIENT codes to get stock_code from stockmasterdetails - RECODE
		sr = null; try { sr = sqlhand.rws_gpSqlFirstRow("select Stock_Code from StockMasterDetails where ID=" + stkid[i]); }  catch (Exception e) {}
		sc = (sr == null) ? UNKNOWN_STRING : sr.get("Stock_Code");
		pstmt.setString(4,sc);

		istkid = 0; try { istkid = Integer.parseInt(stkid[i]); } catch (Exception e) {}
		pstmt.setInt(5,istkid);

		pstmt.setInt(6,Integer.parseInt(pStkout));
		pstmt.addBatch();
	}
	pstmt.executeBatch(); pstmt.close(); sql.close();
}

/**
 * Print parts-request/STKOUT in BIRT
 * Show BIRT in pop-up : partreqprintoutput
 * TODO to add 2 other templates, WORK-ORDER and CONSIGNMENT request
 * @param pStkout [description]
 * @param pType : type, CASH_SALES, CONSIGNMENT, WORK_ORDER
 */
void printPartsReq_birt(String pStkout, String pType)
{
	bfn = "";
	if(pType.equals("CASH_SALES")) bfn = "rlm/fd_partsales_v1.rptdesign";
	if(pType.equals("CONSIGNMENT")) bfn = "rlm/fd_consignment_v1.rptdesign";
	if(bfn.equals("")) return; // in-case not-yet program template

	thesrc = birtURL() + bfn + "&whstkout=" + pStkout + "&whstkoutpref=" + STKOUT_PREFIX;

	if(partreqprintholder.getFellowIfAny("partsprintframe") != null) partsprintframe.setParent(null);
	Iframe newiframe = new Iframe();
	newiframe.setId("partsprintframe"); newiframe.setWidth("100%");	newiframe.setHeight("600px");
	newiframe.setSrc(thesrc); newiframe.setParent(partreqprintholder);
	partreqprintoutput.open(printpartsreq_b);
}

