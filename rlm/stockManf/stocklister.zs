/**
 * Stock master lister things - can be used by other modu with some modif
 */

stockmaster_lister_bread = ""; // used by other modu that wants to show the stock-master structure (cat->grp->cls)

void fillStockMasterSelectorDropdowns()
{
	fillListbox_uniqField("StockMasterDetails","Stock_Cat", m_stock_cat_lb );
	fillListbox_uniqField("StockMasterDetails","GroupCode", m_groupcode_lb );
	fillListbox_uniqField("StockMasterDetails","ClassCode", m_classcode_lb );
}

Object[] stkitemshds =
{
	new listboxHeaderWidthObj("StockCode",true,""),
	new listboxHeaderWidthObj("Description",true,""),
	new listboxHeaderWidthObj("Eqt/Model",true,""),
	new listboxHeaderWidthObj("Category",true,""),
	new listboxHeaderWidthObj("Group",true,""),
	new listboxHeaderWidthObj("Class",true,""), // 5
	new listboxHeaderWidthObj("Entry",true,""),
	new listboxHeaderWidthObj("Act",false,""),
	new listboxHeaderWidthObj("STKID",false,""), // 8
	new listboxHeaderWidthObj("Avail",true,"50px"), // 9
};
ITM_STOCKCODE = 0; ITM_DESCRIPTION = 1; ITM_EQTMODEL = 2;
ITM_CATEGORY = 3; ITM_GROUP = 4; ITM_CLASS = 5;
ITM_ENTRYDATE = 6; ITM_ACTIVEFLAG = 7;
ITM_ID = 8;
ITM_AVAILABLE = 9;

/**
 * onSelect for stock_items_lb
 * TODO need to add call-back for other modu
 */
class stkitemclik implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(Event event) throws UiException
	{
		try
		{
		stockmasterOnselect_callback(event.getReference());
		} catch (Exception e) {}
	}
}
stockitemclicker = new stkitemclik();

class stkitemdoubelclik implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(Event event) throws UiException
	{
		try
		{
			stockmasterDoubleclick_callback(event.getTarget());
		} catch (Exception e) {}
	}
}
stkitem_doubclik = new stkitemdoubelclik();

/**
 * [listStockItems description]
 * @param itype list type to perform - check switch-case
 */
void listStockItems(int itype)
{
	if(itype == 0) return;
	last_show_stockitems = itype;
	Listbox newlb = lbhand.makeVWListbox_Width(stockitems_holder, stkitemshds, "stock_items_lb", 3);

	sqlstm = "select sm.Stock_Code,sm.Description,sm.Stock_Cat,sm.GroupCode,sm.ClassCode,sm.EntryDate,sm.ID,sm.IsActive, sm.Product_Detail," +
	"(select sum(Balance) from StockList where stk_id=sm.ID and stage='NEW') as available from StockMasterDetails sm ";
	wherestr = "where ";
	stkcat = "";
	try { stkcat = kiboo.replaceSingleQuotes(m_stock_cat_lb.getSelectedItem().getLabel()); } catch (Exception e) {}
	grpcode = "";
	try { grpcode = kiboo.replaceSingleQuotes(m_groupcode_lb.getSelectedItem().getLabel()); } catch (Exception e) {}
	clscode = "";
	try { clscode = kiboo.replaceSingleQuotes(m_classcode_lb.getSelectedItem().getLabel()); } catch (Exception e) {}
	
	Object[] lsto = { m_stock_cat_lb, m_groupcode_lb, m_classcode_lb };
	String[] lstn = { "Stock_Cat", "GroupCode", "ClassCode" };
	//fln = lstn[itype-1];
	k = "";

	switch(itype)
	{
		case 1: // by stock-cat
			wherestr += lstn[0] + "='" + stkcat + "' ";
			stockmaster_lister_bread = stkcat;

			break;

		case 2: // by group-code
			wherestr += lstn[0] + "='" + stkcat + "' and " + lstn[1] + "='" + grpcode + "' ";
			stockmaster_lister_bread = stkcat + " > " + grpcode;
			break;

		case 3: // by class-code
			wherestr += lstn[0] + "='" + stkcat + "' and " + lstn[1] + "='" + grpcode + "' and " + lstn[2] + "='" + clscode + "'";
			stockmaster_lister_bread = stkcat + " > " + grpcode + " > " + clscode;
			break;			

		case 4: // by search-text or just dump everything -- need to limit
			k = kiboo.replaceSingleQuotes( m_searchtext_tb.getValue().trim() );
			if(!k.equals(""))
			{
				wherestr = "where Stock_Code like '%" + k + "%' or Description like '%" + k + "%' ";
			}
			else
			{
				wherestr = "limit 100";
			}
			break;
	}

	sqlstm += wherestr;

	r = sqlhand.rws_gpSqlGetRows(sqlstm);
	if(r.size() == 0) return;
	newlb.setRows(20); newlb.setMultiple(true); newlb.setCheckmark(true); newlb.setMold("paging");
	newlb.addEventListener("onSelect", stockitemclicker);

	String[] fl = { "Stock_Code", "Description", "Product_Detail", "Stock_Cat", "GroupCode", "ClassCode", "EntryDate", "IsActive", "ID", "available" };
	ArrayList kabom = new ArrayList();

	for(d : r)
	{
		ngfun.popuListitems_Data(kabom,fl,d);
		lbhand.insertListItems(newlb,kiboo.convertArrayListToStringArray(kabom),"false","");
		kabom.clear();
	}
	lbhand.setDoubleClick_ListItems(newlb, stkitem_doubclik);
}
