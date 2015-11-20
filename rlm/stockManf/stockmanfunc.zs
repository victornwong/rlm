/**
 * Stock masters management functions
 */

/**
 * Import stock-master definitions from XLS
 * Format column: Stock_Code	Description	Stock_Cat	GroupCode	ClassCode	Product_Detail	Supplier_Code
 */
void importStockDetails()
{
	stkdets = new uploadedWorksheet();
	stkdets.getUploadFileData();
	if(stkdets.thefiledata == null)
	{
		guihand.showMessageBox("ERR: Invalid worksheet, try again");
		return;
	}

	org.apache.poi.hssf.usermodel.HSSFRow checkrow;
	Cell kcell;
	todaydate =  kiboo.todayISODateTimeString();
	//unm = useraccessobj.username;
	String[] dt = new String[7];
	sqlstm = "";

	inps = "";
	if(stkdets.thefiledata instanceof java.io.ByteArrayInputStream) inps = stkdets.thefiledata;
	else inps = new ByteArrayInputStream(stkdets.thefiledata);
	//HSSFWorkbook excelWB = new HSSFWorkbook(pricewk.thefiledata);
	HSSFWorkbook excelWB = new HSSFWorkbook(inps);
	FormulaEvaluator evaluator = excelWB.getCreationHelper().createFormulaEvaluator();
	wksht0 = excelWB.getSheetAt(0);
	wknumrows = wksht0.getPhysicalNumberOfRows();

	lineimp = 0; // to count actual rows imported..

	Sql sql = wms_Sql();
	Connection thecon = sql.getConnection();
	todaydate =  kiboo.todayISODateTimeString();
	PreparedStatement pstmt = thecon.prepareStatement("insert into StockMasterDetails (Stock_Code, Description, Stock_Cat, GroupCode, ClassCode, " +
		"Product_Detail, Supplier_Code, EntryDate, IsActive) values " +
		"(?,?,?,?,?,?,?,?,?)");

	for(i=1; i<wknumrows; i++) // Skip row 1 = headers
	{
		try
		{
			checkrow = wksht0.getRow(i);

			for(k=0; k<7; k++)
			{
				dt[k] = "";
				try { kcell = checkrow.getCell(k); dt[k] = POI_GetCellContentString(kcell,evaluator,"").trim(); }
				catch (Exception e) {}
			}

			if(!dt[0].equals("")) // make sure got stock_code before inserting into database
			{
				for(m=0;m<7;m++)
				{
					pstmt.setString(m+1,dt[m]);
				}

				pstmt.setString(8,todaydate);
				pstmt.setInt(9,1);
				pstmt.addBatch();
				lineimp++; // count line inserted
			}
		} catch (Exception e) {}
	}
	pstmt.executeBatch(); pstmt.close(); sql.close();

	guihand.showMessageBox("Imported: " + lineimp.toString() + " rows from EXCEL worksheet..");
	populateDropdowns(); // refresh dropdowns etc
	listStockItems(last_show_stockitems);
}

/**
 * Populate 'em drop-downs used throughout the UI
 */
void populateDropdowns()
{
	fillListbox_uniqField("StockMasterDetails","Stock_Cat", m_stock_cat_lb );
	fillListbox_uniqField("StockMasterDetails","GroupCode", m_groupcode_lb );
	fillListbox_uniqField("StockMasterDetails","ClassCode", m_classcode_lb );

	fillComboboxUniq("StockMasterDetails","Stock_Cat",e_stock_cat_cb);
	fillComboboxUniq("StockMasterDetails","GroupCode",e_groupcode_cb);
	fillComboboxUniq("StockMasterDetails","ClassCode",e_classcode_cb);

	fillComboboxUniq("StockMasterDetails","Stock_Cat",n_stock_cat_cb);
	fillComboboxUniq("StockMasterDetails","GroupCode",n_groupcode_cb);
	fillComboboxUniq("StockMasterDetails","ClassCode",n_classcode_cb);
}

/**
 * Helper function to call both populateDropdowns() and listStockItems()
 */
void refreshThings()
{
	listStockItems(last_show_stockitems);
	populateDropdowns();
}

/**
 * Get selected stock-items in the main stock-items listbox
 * @return comma-sepa string of stock ID - to be used in sql-statements
 */
String getSelected_StockItemIDfromListbox()
{
	if( stockitems_holder.getFellowIfAny("stock_items_lb") == null) return "";
	if(stock_items_lb.getSelectedCount() == 0) return "";
	lbs = stock_items_lb.getSelectedItems().toArray();
	retval = "";
	for(i=0; i<lbs.length; i++)
	{
		retval += lbhand.getListcellItemLabel(lbs[i],ITM_ID) + ",";
	}
	try { retval = retval.substring(0,retval.length()-1); } catch (Exception e) {}
	return retval;
}

/**
 * Delete multi-selected stock items - uses stock-items listbox
 */
void multiDeleteStockItems()
{
	idl = getSelected_StockItemIDfromListbox();
	if(idl.equals("")) return;
	try
	{
		sqlstm = "select count(origid) as itemcount from StockList where stk_id in (" + idl + ");"; // make sure got no serialized item in this stock-code
		kr = sqlhand.rws_gpSqlFirstRow(sqlstm);
		if(kr != null)
		{
			if(kr.get("itemcount") > 0)
			{
				guihand.showMessageBox("ERR: there are serialized items tied to the selected stock-code");
				return;
			}
		}
		sqlstm = "delete from StockMasterDetails where ID in (" + idl + ");";
		sqlhand.rws_gpSqlExecuter(sqlstm);
		listStockItems(last_show_stockitems);
		guihand.showMessageBox("OK: selected stock-items deleted from database");
	}
	catch (Exception e) { guihand.showMessageBox("ERR: cannot delete the selected stock-items"); }
}

/**
 * Set suspend/active IsActive on selected stock-items. Uses stock-items listbox
 * @param iact 0=suspend, 1=active
 */
void multiSuspendActiveStockItems(int iact)
{
	idl = getSelected_StockItemIDfromListbox();
	if(idl.equals("")) return;
	try
	{
		sqlstm = "update StockMasterDetails set IsActive=" + iact.toString() + " where ID in (" + idl + ");";
		sqlhand.rws_gpSqlExecuter(sqlstm);
		listStockItems(last_show_stockitems);
		guihand.showMessageBox("OK: selected items set to " + ((iact == 1) ? "ACTIVE" : "SUSPEND") );
	}
	catch (Exception e) { guihand.showMessageBox("ERR: cannot set active/suspend on selected items"); }
}

/**
 * Check for duplicates in stock-master - show in popup - later can program some double-clicker
 */
void checkDuplicateStockCode()
{
	sqlstm = "SELECT Stock_Code, COUNT( * ) c FROM StockMasterDetails GROUP BY Stock_Code HAVING c >1";
	r = sqlhand.rws_gpSqlGetRows(sqlstm);
	if(r.size() == 0) return;
	ks = "";
	for(d : r)
	{
		ks += d.get("Stock_Code") + " : " + d.get("c").toString() + " duplicates\n";
	}
	dups_output_label.setValue(ks);
	showduplicates_pop.open(chkdupstk_b);
}
