/**
 * Return items to WH functions
 */

Object[] retitemshds =
{
	new listboxHeaderWidthObj("No.",true,"40px"),

	new listboxHeaderWidthObj("stk_id",false,""),
	new listboxHeaderWidthObj("Serial No.",true,""),
	new listboxHeaderWidthObj("Qty",true,"50px"), // 3
	new listboxHeaderWidthObj("Stat",true,""), // 4
	new listboxHeaderWidthObj("origid",true,""), // 5

	new listboxHeaderWidthObj("Loca",true,"70px"),
	new listboxHeaderWidthObj("Struct",true,""), // 7
	new listboxHeaderWidthObj("parent_origid",false,""),
};
RETITEM_STKID_POS = 1; RETITEM_SERIAL_POS = 2; RETITEM_QTY_POS = 3;
RETITEM_STATUS_POS = 4; RETITEM_ORIGID_POS = 5;
RETITEM_LOCA_POS = 6; RETITEM_STRUCT_POST = 7;
RETITEM_PARENTORIGID_POS = 8; 

Listbox showReturnItems_listbox(String pParent, Div pHolder, String pLbid)
{
	returnslb = lbhand.makeVWListbox_Width(pHolder, retitemshds, pLbid, 8);
	retsql = "select origid,stk_id,Itemcode,Qty,status from tblStockReturn where stkout_parent=" + pParent;
	r = sqlhand.rws_gpSqlGetRows(retsql);
	if(r.size() > 0)
	{
		ArrayList kabom = new ArrayList();
		String[] fl = { "stk_id","Itemcode","Qty","status","origid" };
		for(d : r)
		{
			kabom.add("0");
			ngfun.popuListitems_Data(kabom,fl,d);

			kabom.add( getInventoryLastLoca(d.get("Itemcode")) ); // get item last location
			stkstruct = (d.get("stk_id") != null) ? getStockMasterStruct(d.get("stk_id").toString()) : ""; // rlmsql.zs
			kabom.add(stkstruct); // stock-master struct
			kabom.add("0"); // stk-out origid, nothing to remove anymore, already handled by saveReturnList()

			lbhand.insertListItems(returnslb,kiboo.convertArrayListToStringArray(kabom),"false","");
			kabom.clear();
		}
		renumberListbox(returnslb,0,1,true);
	}
	return returnslb;
}

/**
 * Copy ticked scan-items to return list. Things to populate, refer to retitemshds
 * @param pOrig scan-items listbox
 * @param pTo   to which listbox
 */
void addToReturnList(Listbox pOrig, Listbox pTo)
{
	oglbs = pOrig.getSelectedItems().toArray();
	ArrayList kabom = new ArrayList();
	for(i=0; i<oglbs.length; i++)
	{
		isel = oglbs[i];
		istkid = lbhand.getListcellItemLabel(isel,ITEM_STKID_POS);
		snum = lbhand.getListcellItemLabel(isel,ITEM_CODE_POS);

		kabom.add("0");
		kabom.add( istkid ); // itemsfunc.itmcodehds column position
		kabom.add( snum );
		kabom.add( lbhand.getListcellItemLabel(isel,ITEM_QTY_POS) );
		kabom.add( "DRAFT" ); // ret-item status
		kabom.add( "0" ); // new ret-item, no db origid

		kabom.add( getInventoryLastLoca(snum) ); // get item last location
		stkstruct = (d.get("stk_id") != null) ? getStockMasterStruct(d.get("stk_id").toString()) : ""; // rlmsql.zs
		kabom.add( stkstruct ); // stock-master struct
		kabom.add( lbhand.getListcellItemLabel(isel,ITEM_ORIGID_POS) ); // parent scan-item tblStockOutDetail origid

		lbhand.insertListItems(pTo,kiboo.convertArrayListToStringArray(kabom),"false","");
		kabom.clear();
		isel.setParent(null); // remove from original listbox
	}
	renumberListbox(pTo,0,1,true);
	renumberListbox(pOrig,0,1,true);
	pOrig.clearSelection();
}

/**
 * Save return items to tblStockReturn
 * @param pOb    parent stock outbound voucher no.
 * @param pRetlb the listbox containing all the items to be saved
 */
void saveReturnList(String pOb, Listbox pRetlb)
{
	todaydate =  kiboo.todayISODateTimeString();
	unm = "tester";
	try { unm = useraccessobj.username; } catch (Exception e) {}

	sqlstm = "delete from tblStockReturn where stkout_parent=" + pOb + ";"; // delete prev any saved return-list
	sqlhand.rws_gpSqlExecuter(sqlstm);

	Sql sql = wms_Sql();
	Connection thecon = sql.getConnection();
	PreparedStatement pstmt = thecon.prepareStatement("insert into tblStockReturn (stk_id,Itemcode,Qty,stkout_parent,username,status) values " +
	"(?,?,?,?,?,?);");

	toremove = ""; // origid from RETITEM_PARENTORIGID_POS to be removed
	ts = pRetlb.getItems().toArray(); // start batch insert return items
	for(i=0;i<ts.length;i++)
	{
		oborigid = lbhand.getListcellItemLabel(ts[i],RETITEM_PARENTORIGID_POS);
		if(!oborigid.equals("") && !oborigid.equals("0")) // a valid tblstockoutdetail origid
		{
			toremove += oborigid + ",";
		}

		pstmt.setInt(1, Integer.parseInt(lbhand.getListcellItemLabel(ts[i],RETITEM_STKID_POS)) );
		pstmt.setString(2, lbhand.getListcellItemLabel(ts[i],RETITEM_SERIAL_POS) );
		pstmt.setInt(3, Integer.parseInt(lbhand.getListcellItemLabel(ts[i],RETITEM_QTY_POS)) );
		pstmt.setInt(4, Integer.parseInt(pOb) );
		pstmt.setString(5, unm);
		pstmt.setString(6, lbhand.getListcellItemLabel(ts[i],RETITEM_STATUS_POS) );

		pstmt.addBatch();
	}
	pstmt.executeBatch(); pstmt.close(); sql.close();
	try
	{
		toremove = toremove.substring(0,toremove.length()-1);
		sqlstm = "delete from tblStockOutDetail where Id in (" + toremove + ");";
		sqlhand.rws_gpSqlExecuter(sqlstm);
	} catch (Exception e) {}
}

/**
 * Revert,pushback part-return items into STKOUT
 * @param pOb    : the outbound voucher no.
 * @param pRetlb : return parts listbox
 */
void revertParts_toStkout(String pOb, Listbox pRetlb)
{

}

/**
 * Return the return-parts back to StockList
 * @param pOb    : the outbound voucher no.
 * @param pRetlb : return parts listbox
 */
void returnParts_toInventory(String pOb, Listbox pRetlb)
{
	if(pRetlb.getItemCount() == 0) return;
	ts = pRetlb.getItems().toArray();
	today = kiboo.todayISODateTimeString();

	Sql sql = wms_Sql(); Connection thecon = sql.getConnection();
	PreparedStatement pst = thecon.prepareStatement("update StockList set Balance=Balance+?, stage='NEW', OutRefNo=null, OutRefDate=null where Itemcode=? and stk_id=? limit 1;");
	PreparedStatement updst = thecon.prepareStatement("update tblStockReturn set commitdate=?, status='RET' where origid=? limit 1;");

	for(i=0; i<ts.length; i++)
	{
		istat = lbhand.getListcellItemLabel(ts[i],RETITEM_STATUS_POS);
		if(istat.equals("DRAFT")) // only return if DRAFT, else already returned to inventory
		{
			pst.setInt(1, Integer.parseInt(lbhand.getListcellItemLabel(ts[i],RETITEM_QTY_POS)) );
			pst.setString(2, lbhand.getListcellItemLabel(ts[i],RETITEM_SERIAL_POS) );
			pst.setInt(3, Integer.parseInt(lbhand.getListcellItemLabel(ts[i],RETITEM_STKID_POS)) );
			pst.addBatch();

			updst.setTimestamp(1, java.sql.Timestamp.valueOf(today));
			updst.setInt(2, Integer.parseInt(lbhand.getListcellItemLabel(ts[i],RETITEM_ORIGID_POS)) );
			updst.addBatch();

			lbhand.setListcellItemLabel(ts[i], RETITEM_STATUS_POS, "RET"); // set return-item status to RET, incase use press again, don't double-post
		}
	}
	pst.executeBatch(); pst.close();
	updst.executeBatch(); updst.close();
	sql.close();
}
