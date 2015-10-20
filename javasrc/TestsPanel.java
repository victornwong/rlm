package org.victor;

import java.util.*;
import java.text.*;
import java.math.BigDecimal;
import org.zkoss.zk.ui.*;
import org.zkoss.zk.ui.event.Event;
import org.zkoss.zul.*;
import org.victor.*;
import java.sql.*;
import groovy.sql.*;

public class TestsPanel
{
	public Div division_holder, section_holder, tests_holder;
	public Label debugLabel;
	public org.zkoss.zk.ui.event.EventListener testOnClicker;
	public org.zkoss.zk.ui.event.EventListener testOnDoubleClicker;
	public int showType = 1; // default 1=normal without pricing, 2=with pricing, tobeused in stockserviceitems
	public String selected_category, selected_groupcode;

	private Generals kiboo;
	private ListboxHandler lbhand;
	private SqlFuncs sqlhand;
	private LookupFuncs luhand;
	private String division_lbid, section_lbid, tests_lbid;

	Object[] blankish_lb_headers = {
		new listboxHeaderObj("",true)
	};

public TestsPanel(Div idivhold, String divname, Div isechold, String secname, Div itestshold, String testsname)
{
	division_holder = idivhold;
	section_holder = isechold;
	tests_holder = itestshold;

	//debugLabel = ideblbl;

	kiboo = new Generals();
	lbhand = new ListboxHandler();
	sqlhand = new SqlFuncs();
	luhand = new LookupFuncs();

	selected_category = selected_groupcode = "";
	
	division_lbid = (divname.equals("")) ? "division_stockcat_lb" : divname;
	section_lbid = (secname.equals("")) ? "section_groupcode_lb" : secname;
	tests_lbid = (testsname.equals("")) ? "tests_description_lb" : testsname;
}

// Populate division column - refer to mysoft.stockmasterdetails.stock_cat
// nominal_code=glcode=5xxxxx = services we sell
// istock_cat = as in stockmasterdetails.stock_cat
// 27/03/2012: uses showType to determine which one to show, 1=default,2=stock-pricing,3=testpackage
// 07/03/2013: pricing_lb_headers add "Subcon" column = stockmasterdetails.newfield4
public final void populateTestParametersColumn(String istock_cat, String igroupcode) throws SQLException
{
	Object[] testparameters_lb_headers = {
	new listboxHeaderObj("mysoftcode",false),
	new listboxHeaderObj("Test",true),
	new listboxHeaderObj("Method",true),
	};

	Object[] pricing_lb_headers = {
	new listboxHeaderObj("mysoftcode",false),
	new listboxHeaderObj("Stock.Code",true),
	new listboxHeaderObj("Test",true),
	new listboxHeaderObj("Method",true),
	new listboxHeaderObj("Cost",true),
	new listboxHeaderObj("Selling",true),
	new listboxHeaderObj("Subcon",true),
	};
	
	Object[] testpackages_lb_headers = {
	new listboxHeaderObj("mysoftcode",false),
	new listboxHeaderObj("Stock.Code",true),
	new listboxHeaderObj("Test",true),
	new listboxHeaderObj("Method",true),
	new listboxHeaderObj("S.Price",true),
	new listboxHeaderObj("LOR",true),
	new listboxHeaderObj("Bill",true),
	new listboxHeaderObj("Units",true),
	};

	Object[] whichheader = null;
	String sqlstm = "";
	//NumberFormat nf = NumberFormat.getCurrencyInstance();
	DecimalFormat nf = new DecimalFormat("####.00");
	String costprice,sellingprice;

	switch(showType)
	{
		case 1:
			whichheader = testparameters_lb_headers;
			// 30/9/2010: put a filter to knockout p-p2-%METALS items
			sqlstm = "select id,description,description2 from stockmasterdetails where item_type='Service Item' and nominal_code like '5%' " + 
				"and stock_cat='" + istock_cat + "' " +
				"and groupcode='" + igroupcode + "' " +
				"and stock_code not like 'p-p2-%METALS' " +
				"order by description" ;
			break;
		case 2:
			whichheader = pricing_lb_headers;
			sqlstm = "select id,stock_code,description,description2,cost_price,selling_price,newfield4 " + 
				"from stockmasterdetails where item_type='Service Item' and nominal_code like '5%' " + 
				"and stock_cat='" + istock_cat + "' " +
				"and groupcode='" + igroupcode + "' " +
				"order by description" ;
			break;
		case 3:
			whichheader = testpackages_lb_headers;
			sqlstm = "select id,stock_code,description,description2,newfield8,newfield9,newfield10,selling_price " + 
				"from stockmasterdetails where item_type='Service Item' and nominal_code like '5%' " + 
				"and stock_cat='" + istock_cat + "' " +
				"and groupcode='" + igroupcode + "' " +
				"order by description" ;
			break;
	}

	Listbox newlb = lbhand.makeVWListbox(tests_holder,whichheader,tests_lbid,15);

	Sql sql = sqlhand.als_mysoftsql();
	if(sql == null ) return;
	List<GroovyRowResult> tlist = sql.rows(sqlstm);
	sql.close();

	String lor,bill,units;

	if(tlist.size() == 0) return;
	if(testOnClicker != null) newlb.addEventListener("onSelect",testOnClicker);

	for(GroovyRowResult ilist : tlist)
	{
		ArrayList kabom = new ArrayList();

		switch(showType)
		{
			case 1:
				kabom.add(String.valueOf(ilist.get("id")));
				kabom.add(kiboo.checkNullString((String)ilist.get("description")));
				kabom.add(kiboo.checkNullString((String)ilist.get("description2")));
				break;

			case 2:
				kabom.add(ilist.get("id").toString());
				kabom.add(kiboo.checkNullString((String)ilist.get("stock_code")));

				kabom.add(lbhand.trimListitemLabel(kiboo.checkNullString((String)ilist.get("description")),35));
				kabom.add(lbhand.trimListitemLabel(kiboo.checkNullString((String)ilist.get("description2")),35));

				costprice = nf.format((Double)ilist.get("cost_price"));
				kabom.add(costprice);

				sellingprice = nf.format((Double)ilist.get("selling_price"));
				kabom.add(sellingprice);
				kabom.add(kiboo.checkNullString((String)ilist.get("newfield4")));
				break;

			case 3:
				kabom.add(ilist.get("id").toString());
				kabom.add(kiboo.checkNullString((String)ilist.get("stock_code")));
				kabom.add(kiboo.checkNullString_RetWat((String)ilist.get("description"),"---"));
				//methodme = trimListitemLabel(ilist.get("description2"), 30);
				kabom.add(kiboo.checkNullString_RetWat((String)ilist.get("description2"),"---"));

				kabom.add(nf.format(ilist.get("selling_price")));

				lor = kiboo.checkNullString((String)ilist.get("newfield8"));
				bill = kiboo.checkNullString((String)ilist.get("newfield9"));
				units = kiboo.checkNullString((String)ilist.get("newfield10"));

				lor = (lor.equals("")) ? "----" : lor;
				bill = (bill.equals("")) ? "---" : bill;
				units = (units.equals("")) ? "----" : units;

				kabom.add(lor);
				kabom.add(bill);
				kabom.add(units);
				break;
		}

		String[] strarray = kiboo.convertArrayListToStringArray(kabom);	
		lbhand.insertListItems(newlb,strarray,"true","");
	}
	
	if(testOnDoubleClicker != null)
		lbhand.setDoubleClick_ListItems(newlb, testOnDoubleClicker);

} // end of populateTestParametersColumn()

class sectionOnClick implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(Event event) throws UiException,SQLException
	{
		Listbox thelb = (Listbox)section_holder.getFellowIfAny(section_lbid);
		String iwhat = thelb.getSelectedItem().getLabel();
		selected_groupcode = iwhat; // save for later usage
		populateTestParametersColumn(selected_category,iwhat);
	}
}

// Populate division column - refer to mysoft.stockmasterdetails.stock_cat
// nominal_code=glcode=5xxxxx = services we sell
// istock_cat = as in stockmasterdetails.stock_cat
public final void populateSectionColumn(String istock_cat)
{
	Sql sql = sqlhand.als_mysoftsql();
	if(sql == null ) return;

	String sqlstm = "select distinct groupcode from stockmasterdetails where item_type='Service Item' and nominal_code like '5%' " + 
	"and stock_cat='" + istock_cat + "' order by groupcode" ;

	List<GroovyRowResult> tlist = null;

	try
	{
		tlist = sql.rows(sqlstm);
		sql.close();
	}
	catch (SQLException e) {}

	if(tlist == null) return;

	selected_category = istock_cat; // save for later usage

	if(tlist.size() == 0) return;

	Listbox newlb = lbhand.makeVWListbox(section_holder, blankish_lb_headers, section_lbid, 20);
	newlb.addEventListener("onSelect", new sectionOnClick());

	String[] strarray = new String[1];

	for(GroovyRowResult ilist : tlist)
	{
		strarray[0] = (String)ilist.get("groupcode");
		lbhand.insertListItems(newlb,strarray,"true","");
	}

} // end of populateSectionColumn()

class divisionOnClick implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(Event event) throws UiException, SQLException
	{
		Listbox thelb = (Listbox)division_holder.getFellowIfAny(division_lbid);
		String iwhat = thelb.getSelectedItem().getLabel();
		String iname = luhand.matchLookup_ReturnStr("TP_DIVISIONS",iwhat,2); // get name by disptext
		populateSectionColumn(iname);
		
		// remove prev tests lb if any
		if(tests_holder.getFellowIfAny(tests_lbid) != null)
		{
			Listbox prevlb = (Listbox)tests_holder.getFellowIfAny(tests_lbid);
			prevlb.setParent(null);
		}
	}
}

public final void populateDivisionColumn() throws SQLException
{
	Sql sql = sqlhand.als_mysoftsql();
	if(sql == null ) return;

	List<GroovyRowResult> tlist = null;
	String sqlstm = "select distinct stock_cat from stockmasterdetails where item_type='Service Item' and nominal_code like '5%' order by stock_cat" ;

	try
	{
		tlist = sql.rows(sqlstm);
		sql.close();
	}
	catch (SQLException e) {}

	if(tlist.size() == 0) return;

	Listbox newlb = lbhand.makeVWListbox(division_holder, blankish_lb_headers, division_lbid, 20);
	newlb.addEventListener("onSelect", new divisionOnClick());

	String[] strarray = new String[1];
	String tp_division = luhand.getRec_Origid("TP_DIVISIONS"); // hardcoded
	
	//debugLabel.setValue("getrec_origid: " + tp_division);

	for(GroovyRowResult ilist : tlist)
	{
		strarray[0] = luhand.matchLookup_ReturnStr("TP_DIVISIONS",(String)ilist.get("stock_cat"),1);
		//strarray[0] = (String)ilist.get("stock_cat");
		lbhand.insertListItems(newlb,strarray,"true","");
	}

} // end of populateDivisionColumn()

   
}

