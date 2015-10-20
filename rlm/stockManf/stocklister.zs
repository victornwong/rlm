/**
 * Stock master lister things - can be used by other modu with some modif
 */

void fillStockMasterSelectorDropdowns()
{
	fillListbox_uniqField("StockMasterDetails","Stock_Cat", m_stock_cat_lb );
	fillListbox_uniqField("StockMasterDetails","GroupCode", m_groupcode_lb );
	fillListbox_uniqField("StockMasterDetails","ClassCode", m_classcode_lb );
}

Object[] stkitemshds =
{
	new listboxHeaderWidthObj("Stock-code",true,""),
	new listboxHeaderWidthObj("Description",true,""),
	new listboxHeaderWidthObj("Category",true,""),
	new listboxHeaderWidthObj("Group",true,""),
	new listboxHeaderWidthObj("Class",true,""),
	new listboxHeaderWidthObj("Entry",true,""), // 5
	new listboxHeaderWidthObj("Act",false,""),
	new listboxHeaderWidthObj("id",false,""), // 7
	new listboxHeaderWidthObj("Avail",true,"50px"),

};
ITM_ID = 7;

/**
 * onSelect for stock_items_lb
 * TODO need to add call-back for other modu
 */
class stkitemclik implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(Event event) throws UiException
	{
		isel = event.getReference();
		glob_sel_stock_code = lbhand.getListcellItemLabel(isel,0);
		glob_sel_description = lbhand.getListcellItemLabel(isel,1);
		glob_sel_stock_cat = lbhand.getListcellItemLabel(isel,2);
		glob_sel_groupcode = lbhand.getListcellItemLabel(isel,3);
		glob_sel_classcode = lbhand.getListcellItemLabel(isel,4);
		glob_sel_id = lbhand.getListcellItemLabel(isel,ITM_ID);

		stockItemListbox_callback(isel);
	}
}
stockitemclicker = new stkitemclik();

class stkitemdoubelclik implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(Event event) throws UiException
	{
		isel = event.getTarget();
		try
		{
			glob_sel_stock_code = lbhand.getListcellItemLabel(isel,0);
			glob_sel_description = lbhand.getListcellItemLabel(isel,1);
			glob_sel_stock_cat = lbhand.getListcellItemLabel(isel,2);
			glob_sel_groupcode = lbhand.getListcellItemLabel(isel,3);
			glob_sel_classcode = lbhand.getListcellItemLabel(isel,4);
			glob_sel_id = lbhand.getListcellItemLabel(isel,ITM_ID);

			e_stock_code_tb.setValue(glob_sel_stock_code);
			e_description_tb.setValue(glob_sel_description);
			e_stock_cat_cb.setValue(glob_sel_stock_cat);
			e_groupcode_cb.setValue(glob_sel_groupcode);
			e_classcode_cb.setValue(glob_sel_classcode);

			editstockitem_pop.open(isel);

			stockItemListbox_callback(isel);

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

	sqlstm = "select sm.Stock_Code,sm.Description,sm.Stock_Cat,sm.GroupCode,sm.ClassCode,sm.EntryDate,sm.ID,sm.IsActive," +
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
			break;

		case 2: // by group-code
			wherestr += lstn[0] + "='" + stkcat + "' and " + lstn[1] + "='" + grpcode + "' ";
			break;

		case 3: // by class-code
			wherestr += lstn[0] + "='" + stkcat + "' and " + lstn[1] + "='" + grpcode + "' and " + lstn[2] + "='" + clscode + "'";
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

	String[] fl = { "Stock_Code", "Description", "Stock_Cat", "GroupCode", "ClassCode", "EntryDate", "IsActive", "ID", "available" };
	ArrayList kabom = new ArrayList();

	for(d : r)
	{
		ngfun.popuListitems_Data(kabom,fl,d);
		lbhand.insertListItems(newlb,kiboo.convertArrayListToStringArray(kabom),"false","");
		kabom.clear();
	}
	lbhand.setDoubleClick_ListItems(newlb, stkitem_doubclik);
}
