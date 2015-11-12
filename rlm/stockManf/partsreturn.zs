/**
 * Return items to WH functions
 */

Object[] retitemshds =
{
	new listboxHeaderWidthObj("No.",true,"50px"),
	new listboxHeaderWidthObj("stk_id",false,""),
	new listboxHeaderWidthObj("Serial No.",true,""),
	new listboxHeaderWidthObj("Qty",true,"50px"),
	new listboxHeaderWidthObj("Loca",true,"70px"),
	new listboxHeaderWidthObj("parent_origid",false,""),
};
RETITEM_STKID_POS = 1;
RETITEM_SERIAL_POS = 2;
RETITEM_QTY_POS = 3;
RETITEM_LOCA_POS = 4;
RETITEM_PARENTORIGID_POS = 5;

Listbox showReturnItems_listbox(String pParent, Div pHolder, String pLbid)
{
	returnslb = lbhand.makeVWListbox_Width(pHolder, retitemshds, pLbid, 8);
	retsql = "select stk_id,Itemcode,Qty from tblStockReturn where stkout_parent=" + pParent;
	r = sqlhand.rws_gpSqlGetRows(retsql);
	if(r.size() > 0)
	{
		ArrayList kabom = new ArrayList();
		String[] fl = { "stk_id","Itemcode","Qty" };
		for(d : r)
		{
			kabom.add("0");
			ngfun.popuListitems_Data(kabom,fl,d);
			kabom.add( getInventoryLastLoca(d.get("Itemcode")) ); // get item last location
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

		kabom.add("0");
		snum = lbhand.getListcellItemLabel(isel,ITEM_CODE_POS);
		kabom.add( lbhand.getListcellItemLabel(isel,ITEM_STKID_POS) ); // itemsfunc.itmcodehds column position
		kabom.add( snum );
		kabom.add( lbhand.getListcellItemLabel(isel,ITEM_QTY_POS) );
		kabom.add( getInventoryLastLoca(snum) ); // get item last location
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
		pstmt.setString(6, "DRAFT");

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

}
