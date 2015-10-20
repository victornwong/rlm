/**
 * Inventory - stock-master related funcs
 */

/**
 * Fill up listbox dropdowns for location/bin selector
*/
void fillupLocationBin(Object[] tdropdowns)
{
	String[] mainbin = { "A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z" };
	String[] lip = new String[1];

	for(i=0;i<mainbin.length;i++)
	{
		lip[0] = mainbin[i];
		lbhand.insertListItems(tdropdowns[0],lip,"false","");
	}

	for(i=1;i<10;i++)
	{
		lip[0] = i.toString();
		lbhand.insertListItems(tdropdowns[1],lip,"false","");
		lbhand.insertListItems(tdropdowns[2],lip,"false","");
		lbhand.insertListItems(tdropdowns[3],lip,"false","");
	}
	// set default selected in each dropdown
	for(i=0;i<tdropdowns.length;i++)
	{
		tdropdowns[i].setSelectedIndex(0);
	}
}

/**
 * Concat them location/bin listboxes selector into string and put into ibox
*/
void insertBinSelector(Listbox imainbin, Listbox imainbino, Listbox ishelfno, Listbox ipartino, Component ibox)
{
	locas = imainbin.getSelectedItem().getLabel() + imainbino.getSelectedItem().getLabel() + "-" +
		ishelfno.getSelectedItem().getLabel() + "-" + ipartino.getSelectedItem().getLabel();

	ibox.setValue(locas);
}

/**
 * Check for dups StockList.Itemcode
 * @return dups found - formatted string
 */
String checkDuplicateStockItems()
{
	sqlstm = "SELECT Itemcode, COUNT( * ) c FROM StockList GROUP BY Itemcode HAVING c >1";
	r = gpWMS_GetRows(sqlstm);
	if(r.size() == 0) return "";
	ks = "";
	for(d : r)
	{
		ksql = "select Id from tblStockInMaster where Reference in (select RefNo from StockList where Itemcode='" + d.get("Itemcode") + "');";

		refs = sqlhand.rws_gpSqlGetRows(ksql);
		trf = "";
		for(c : refs)
		{
			trf += STKIN_PREFIX + c.get("Id").toString() + " ";
		}
		trf = trf.trim();

		ks += d.get("Itemcode") + " : " + d.get("c").toString() + " duplicates (Ref: " + trf + ")\n";
	}
	return ks;
}