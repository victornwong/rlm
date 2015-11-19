// Support funcs for anyReservator.zul
// Written by Victor Wong 18/08/2014
import org.victor.*;

Object getReservation_rec(String iwhat)
{
	sqlstm = "select * from elb_reservator where origid=" + iwhat;
	return sqlhand.gpSqlFirstRow(sqlstm);
}

WEEKLY_LOOKBACK = -2;
WEEKLY_DAYS_TOSHOW = 14;
WEEKLY_DIV_STYLE = "background:#5C7D91";
SUNDAY_DIV_STYLE = "background:#E35610";
SUNDAY_DIV_WIDTH = "100px";
WEEKLY_DIV_WIDTH = "360px";
WEEKLY_DIV_HEIGHT = "350px";

void drawWeekdaysCalendar(Datebox idate, Datebox iedate, Label imonlbl, Div iholder)
{
	String[] weekname = { "SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT" };
	Calendar stdate = Calendar.getInstance();
	Calendar eddate = Calendar.getInstance();

	// set to date selected by user . minus 7 days
	stdate.setTime(idate.getValue()); stdate.add(Calendar.DATE,WEEKLY_LOOKBACK);
	eddate.setTime(stdate.getTime()); eddate.add(Calendar.DATE,WEEKLY_DAYS_TOSHOW-1);

	//ks = kiboo.dtf2.format(stdate.getTime()) + " :: " + kiboo.dtf2.format(eddate.getTime()); debugbox.setValue(ks);
	// clear whatever in DIV before putting new
	ks = iholder.getChildren().toArray();
	for(i=0;i<ks.length;i++)
	{
		ks[i].setParent(null);
	}

	mhbox = new Hbox(); mhbox.setParent(iholder);

	for(i=0; i<WEEKLY_DAYS_TOSHOW; i++)
	{
		wkn = stdate.get(Calendar.DAY_OF_WEEK);

		dstyle = WEEKLY_DIV_STYLE; dwidth = WEEKLY_DIV_WIDTH;
		if(wkn == 7 || wkn == 1) { dstyle = SUNDAY_DIV_STYLE; } // set SAT and SUN style

		wdv = new Div(); wdv.setWidth(dwidth); wdv.setHeight(WEEKLY_DIV_HEIGHT); wdv.setStyle(dstyle);
		wdv.setParent(mhbox);
		wboxm = new Div(); wboxm.setStyle("background:#F0D20E;padding:3px"); wboxm.setParent(wdv);

		kh = new Hbox(); kh.setParent(wboxm);
		
		daylabel = ngfun.gpMakeLabel(kh,"",weekname[wkn-1],"font-weight:bold;font-size:14px");
		ngfun.gpMakeSeparator(1,"200px",kh);
		datelabel = ngfun.gpMakeLabel(kh,"", GlobalDefs.dtf2.format(stdate.getTime()),"font-weight:bold;font-size:14px");

		renderWeekly_details_callback(kiboo.dtf2.format(stdate.getTime()),wdv);
		stdate.add(Calendar.DATE,1);
	}
	// show month and year label
	/*
	SimpleDateFormat monyr = new SimpleDateFormat("MMM yyyy");
	imonlbl.setValue(monyr.format(idate.getValue()));
	*/
}

void drawBigCalendar(Datebox idate, Label imonlbl, Component idiv, String igid, Object idivcliker)
{
	glob_prev_date = idate.getValue(); // save for later
	cellheight = "60px";

	if(!igid.equals("")) // remove any previous calendar by id
	{
		kk = idiv.getFellowIfAny(igid);
		if(kk != null) kk.setParent(null);
	}

	Grid mgrid = new Grid(); mgrid.setParent(idiv);
	mgrid.setSclass("GridLayoutNoBorder");
	if(!igid.equals("")) mgrid.setId(igid);

	mrows = new Rows(); mrows.setParent(mgrid);
	krow = new Row(); krow.setParent(mrows);
	krow.setStyle("background:#2E2E2D");

	String[] weekname = { "SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT" };
	for(i=0; i<7; i++) // Draw week-day name
	{
		dtv = new Div(); dtv.setParent(krow);
		dtv.setStyle("background:#EF1111"); //dtv.setHeight("40px");

		dstr = new Label();
		dstr.setParent(dtv); dstr.setSclass("subhead2"); dstr.setStyle("padding:10px");
		dstr.setValue(weekname[i]);
	}

	Calendar cal = Calendar.getInstance();
	cal.setTime(idate.getValue());
	cal.set(Calendar.DAY_OF_MONTH, 1);
	tstart = dtf2.format(cal.getTime());

	sday = cal.get(Calendar.DAY_OF_WEEK); // get 1st of the month falls on which day
	cal.set(Calendar.DAY_OF_MONTH, cal.getActualMaximum(Calendar.DAY_OF_MONTH) ); // get max days per month
	tend = dtf2.format(cal.getTime());
	eday = cal.get(Calendar.DAY_OF_MONTH) + 1;

	// customize this for other modules
	// Retrieve the reservations for the whole month to be used for highliting
	jsqlstm = "select distinct convert(datetime,convert(varchar,res_start,112),112) as rdate, count(origid) as rcount " +
	"from elb_reservator where res_start between '" + tstart + "' and '" + tend + "' " +
	"group by convert(datetime,convert(varchar,res_start,112),112)";

	HashMap hlit = new HashMap();	
	rx = sqlhand.gpSqlGetRows(jsqlstm);
	if(rx.size() != 0)
	{
		for(d : rx)
		{
			hlit.put(GlobalDefs.dtf2.format(d.get("rdate")), d.get("rcount") );
		}
	}

	//debugbox.setValue(jsqlstm);

	krow = new Row(); krow.setParent(mrows);
	krow.setStyle("background:#2E2E2D");

	for(k=1;k<sday;k++) // empty days padding
	{
		dtv = new Div(); dtv.setParent(krow);
		//dtv.setStyle("background:#3E6179");
		dtv.setHeight(cellheight);
	}

	for(i=1; i<eday; i++) // show all dates
	{
		dtv = new Div(); dtv.setParent(krow);
		dtv.setStyle("background:#3E6179"); dtv.setHeight(cellheight);
		if(idivcliker != null) dtv.addEventListener("onDoubleClick", idivcliker );

		dtlb = new Label();
		dtlb.setParent(dtv); dtlb.setSclass("subhead1"); dtlb.setStyle("padding:5px");
		dtlb.setValue(i.toString()); // + " : " + (sday%7).toString());

		cal.set(Calendar.DAY_OF_MONTH, i);
		cklit = GlobalDefs.dtf2.format( cal.getTime() );
		try
		{
			rcnt = hlit.get(cklit).toString();
			rslb = new Label();
			rslb.setParent(dtv); rslb.setStyle("font-size:9px;color:#ffffff;text-shadow: 1px 1px #000000;");
			rslb.setValue(rcnt + " reservation(s)");
		} catch (Exception e) {}

		if(sday%7 == 0) // set to new row when hit "SAT"
		{
			krow = new Row(); krow.setParent(mrows);
			krow.setStyle("background:#2E2E2D");
		}
		sday++;
	}

	// show month and year label
	SimpleDateFormat monyr = new SimpleDateFormat("MMM yyyy");
	imonlbl.setValue(monyr.format(idate.getValue()));
}

void changeDate()
{
	if(glob_prev_date == null) { drawBigCalendar(resv_date, month_lbl, calendar_holder,"maincalendar",datelabelcliker); return; }

	redraw = false;
	Calendar cal = Calendar.getInstance();
	cal.setTime(resv_date.getValue());
	nyr = cal.get(Calendar.YEAR);
	nmt = cal.get(Calendar.MONTH);

	Calendar pcal = Calendar.getInstance();
	pcal.setTime(glob_prev_date);
	pyr = pcal.get(Calendar.YEAR);
	pmt = pcal.get(Calendar.MONTH);

	if(nmt != pmt) redraw = true;
	if(nyr != pyr) redraw = true;

	if(redraw)
	{
		drawBigCalendar(resv_date, month_lbl, calendar_holder,"maincalendar",datelabelcliker);
		doFunc("clearres_b");
		if(day_holder.getFellowIfAny("dayresv_lb") != null) dayresv_lb.setParent(null);
	}
}

class reslbcliker implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(Event event) throws UiException
	{
		isel = event.getReference();
		glob_sel_reservation = lbhand.getListcellItemLabel(isel,RESERV_ORIGID_POS);
		glob_sel_username = lbhand.getListcellItemLabel(isel,RESERV_USER_POS);
		k = getReservation_rec(glob_sel_reservation);
		n_res_start.setValue(k.get("res_start"));
		n_res_end.setValue(k.get("res_end"));
		n_description.setValue(k.get("description"));
		n_origid.setValue(k.get("origid").toString());
	}
}
reservationcliker = new reslbcliker();

Object[] dayreslbhd =
{
	new listboxHeaderWidthObj("ID",true,"40px"),
	new listboxHeaderWidthObj("Start",true,"40px"),
	new listboxHeaderWidthObj("End",true,"70px"),
	new listboxHeaderWidthObj("User",true,""),
	new listboxHeaderWidthObj("Description",true,""),
};
RESERV_ORIGID_POS = 0;
RESERV_USER_POS = 3;

void showDayReservation(String iday)
{
	SimpleDateFormat sdf = new SimpleDateFormat("d MMM yyyy");
	glob_sel_date = sdf.parse( iday + " " + month_lbl.getValue() );
	resv_date.setValue(glob_sel_date);

	Listbox newlb = lbhand.makeVWListbox_Width(day_holder, dayreslbhd, "dayresv_lb", 5);

	sqlstm = "select origid,res_start,res_end,username,description from elb_reservator " + 
	"where convert(datetime,convert(varchar,res_start,112),112)='" + dtf2.format(resv_date.getValue()) + "'";
	rs = sqlhand.gpSqlGetRows(sqlstm);
	if(rs.size() == 0) return;

	newlb.setRows(22); newlb.setMold("paging");
	newlb.addEventListener("onSelect", reservationcliker );
	ArrayList kabom = new ArrayList();
	SimpleDateFormat tfm = new SimpleDateFormat("hh:mm");
	for( d : rs )
	{
		kabom.add( d.get("origid").toString() );
		kabom.add( tfm.format(d.get("res_start")) );
		kabom.add( tfm.format(d.get("res_end")) );
		kabom.add( d.get("username") );
		kabom.add( d.get("description") );
		ki = lbhand.insertListItems(newlb,kiboo.convertArrayListToStringArray(kabom),"false","");
		kabom.clear();
	}

//day_holder
//alert( dtf2.format(glob_sel_date) );
}

	/*
		overflow-y:auto
		Calendar cal = Calendar.getInstance();
		cal.setTime(idate.getValue());

		cal.add(Calendar.DATE,-7); // last week
		tstart = dtf2.format(cal.getTime());

		sday = cal.get(Calendar.DAY_OF_WEEK); // get 1st of the month falls on which day
		cal.set(Calendar.DAY_OF_MONTH, cal.getActualMaximum(Calendar.DAY_OF_MONTH) ); // get max days per month
		tend = dtf2.format(cal.getTime());
		eday = cal.get(Calendar.DAY_OF_MONTH) + 1;
	*/
