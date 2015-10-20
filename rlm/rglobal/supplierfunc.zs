/**
 * Suppliers handling funcs
 */

Object[] ldsuphds =
{
	new listboxHeaderWidthObj("id",false,""),
	new listboxHeaderWidthObj("APCode",true,""),
	new listboxHeaderWidthObj("Supplier",true,""),
	new listboxHeaderWidthObj("Act",true,"40px"),
};

class ldsupplierclik implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(Event event) throws UiException
	{
		isel = event.getReference();
		//glob_sel_stock_code = lbhand.getListcellItemLabel(isel,0);
		loadSupplier_callback(isel);
	}
}
loadsupplclick = new ldsupplierclik();

class loadsupplirdclick implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(Event event) throws UiException
	{
		isel = event.getTarget();
		try
		{
			loadSupplier_callback(isel);
		} catch (Exception e) {}
	}
}
loadsuppr_doubclik = new loadsupplirdclick();

/**
 * Load suppliers list from SupplierDetail. Listbox id = "loadsuppliers_lb"
 * @param iwhat search string
 */
void loadSupplier(String iwhat, Div idiv)
{
	Listbox newlb = lbhand.makeVWListbox_Width(idiv, ldsuphds, "loadsuppliers_lb", 10);

	sqlstm = "select ID,APCode,SupplierName,IsActive from SupplierDetail " +
	"where APCode like '%" + iwhat + "%' or SupplierName like '%" + iwhat + "%'" + ISACTIVE_SUPPLIER_LOADING + LIMIT_SUPPLIERS_LOADING + ";";
	r = sqlhand.rws_gpSqlGetRows(sqlstm);
	
	if(r.size() == 0) return;
	newlb.addEventListener("onSelect", loadsupplclick);

	String[] fl = { "ID","APCode","SupplierName","IsActive" };
	ArrayList kabom = new ArrayList();

	for(d : r)
	{
		ngfun.popuListitems_Data(kabom,fl,d);
		lbhand.insertListItems(newlb,kiboo.convertArrayListToStringArray(kabom),"false","");
		kabom.clear();
	}
	lbhand.setDoubleClick_ListItems(newlb, loadsuppr_doubclik);
}
