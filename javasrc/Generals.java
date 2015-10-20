package org.victor;

import java.util.*;
import java.text.*;
import java.io.*;
//import org.zkoss.zk.ui.*;
import org.zkoss.zk.ui.*;
import org.zkoss.zul.Datebox;

/*
Purpose: Global general purpose functions we put them here
Written by : Victor Wong
Date : 11/08/2009
Notes:
*/

public class Generals extends GlobalDefs
{
	// empty constructor
	void Generals()	{ }
	
	// Check if file exist - ZK specific, uses session.getWebApp().getRealPath(thefilename) to get real-path in tombat
public final boolean realPath_FileExist(String thefn)
{
	Session session = Sessions.getCurrent();
	File f = new File(session.getWebApp().getRealPath(thefn));
	return f.exists();
}

public final static String listmybut()
{
	Session session = Sessions.getCurrent();
	return session.getWebApp().getRealPath("img");
}

// Will format date string properly for MySQL
// Parameter: idatebox = zkoss datebox of which will construct the date YYYY-MM-DD
public final String getDateFromDatebox(Datebox idatebox)
{
	String datestr = "";
	
	try
	{
	java.util.Date thed = idatebox.getValue();
	java.util.Calendar tcalendar = java.util.Calendar.getInstance();
	tcalendar.setTime(thed);
	java.util.Calendar thedd = tcalendar;

	datestr = "" + thedd.get(java.util.Calendar.YEAR) + "-" +
		(thedd.get(java.util.Calendar.MONTH)+1) + "-" +
		thedd.get(java.util.Calendar.DAY_OF_MONTH);
	}
	catch (Exception e) {}

	return datestr;
}
	
public final void setTodayDatebox(Datebox datebox1)
{
	java.util.Calendar kkk = java.util.Calendar.getInstance();
	datebox1.setValue(kkk.getTime());
}

// Set Datebox value from date string passed "2010-01-01"
public final void setDateBox_FromString(Datebox iwhich, String idate)
{
	if(idate.equals("")) return;

	int yyear = Integer.parseInt(idate.substring(0,4));
	int ymonth = Integer.parseInt(idate.substring(5,7)) - 1;
	int ydate = Integer.parseInt(idate.substring(8,10));

	java.util.Calendar tcalendar = java.util.Calendar.getInstance();
	tcalendar.set(yyear,ymonth,ydate);
	iwhich.setValue(tcalendar.getTime());
}

// Set Calendar from string : "2010-01-01" or "2010-1-1" .. setDateBox_FromString() will fail if string is different - fixed substring
public final java.util.Calendar stringToDate(String iwhat)
{
	java.util.Calendar retcal = java.util.Calendar.getInstance();
	String[] kkk = iwhat.split("-");
	int tyear = Integer.parseInt(kkk[0]);
	int tmonth = Integer.parseInt(kkk[1]) - 1;
	int tdate = Integer.parseInt(kkk[2]);

	retcal.set(tyear,tmonth,tdate);
	return retcal;
}

public final String mapWeekDayString(int iwhich)
{
	String[] myday = {"Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"};
	return myday[iwhich-1];
}

// Add number of days to idateb and store new date in itoupdate
public final void addDaysToDate(Datebox idateb, Datebox itoupdate, int howmanydays)
{
	// get date value
	java.util.Date dcreat = idateb.getValue();

	java.util.Calendar iduedate = java.util.Calendar.getInstance();
	iduedate.setTime(dcreat);
	iduedate.add(iduedate.DAY_OF_MONTH, howmanydays);

	itoupdate.setValue(iduedate.getTime());

	/*
	datestr = "" + iduedate.get(Calendar.YEAR) + "-" +
		(iduedate.get(Calendar.MONTH)+1) + "-" +
		iduedate.get(Calendar.DAY_OF_MONTH);

	return datestr;
	*/

}

// Weekend checks.. to make sure due-date ain't weekends. nobody want to work!!!
// Will update ithedate
public final void weekEndCheck(Datebox ithedate)
{
	java.util.Calendar iduedatecheck = java.util.Calendar.getInstance();
	iduedatecheck.setTime(ithedate.getValue());
		
	int iwday = iduedatecheck.get(iduedatecheck.DAY_OF_WEEK);
	int addupweekends = 0;
	if(iwday == iduedatecheck.SUNDAY) addupweekends = 1;
	if(iwday == iduedatecheck.SATURDAY) addupweekends = 2;
		
	addDaysToDate(ithedate,ithedate,addupweekends);
}

// calc business-days .. knockoff from some web codes.
public final int calcBusinessDays(Datebox idateb, int howmany)
{
	java.util.Date dcreat = idateb.getValue();
	java.util.Calendar cadate = java.util.Calendar.getInstance();
	cadate.setTime(dcreat);

	int numdays = 0;
	for(int i=0; i<howmany; i++)
	{
		cadate.add(java.util.Calendar.DATE,1);
		numdays++;
		if(cadate.get(java.util.Calendar.DAY_OF_WEEK) == 1 || cadate.get(java.util.Calendar.DAY_OF_WEEK) == 7)
			numdays++;
	}

	return numdays;
}

// Returns the date string "yyyy-mm-dd" to be used in SQL or display
// itodaydate = today's date - set always at top - eg
//
// TimeZone zone=TimeZone.getTimeZone("GMT+08");
// Date currentDate=new Date();
// DateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
// String DATE_FORMAT = "yyyy-MM-dd";
// SimpleDateFormat sdf = new SimpleDateFormat(DATE_FORMAT);
// Calendar todayDate = Calendar.getInstance();
// todayDate.setTime(currentDate);
//
// dateformat = SimpleDateFormat as defined above too
// numdays = number of days to add(4 = add) or minus (-4 = minus) from today's date.
public final String getDateString(java.util.Calendar itodaydate, SimpleDateFormat isdf, int numdays)
{
	java.util.Calendar temptodate = (java.util.Calendar)itodaydate.clone();
	if(numdays != 0) temptodate.add(java.util.Calendar.DATE,numdays);
	String retval = isdf.format(temptodate.getTime());
	return retval;
}

// other stuff
	
	// Convert a string array into comma-separated string
public final String convertStringArrayToString(String[] iwhat)
{
	String retval = "";
	for(int i=0; i<iwhat.length; i++)
	{
		retval += iwhat[i] + ",";
	}
	
	return retval.substring(0,retval.length()-1);
}

// To be used to replace ' to ` during SQL operation
public final String replaceSingleQuotes(String thestring)
{
	return thestring.replace("'","`");
}

// To strip first 6 chars off any rec number .. eg DSPSCHxxx . we just need the rec number only.
public final String strip_PrefixID(String iwhat)
{
	String retval = "";
	
	if(!iwhat.equals(""))
		retval = iwhat.substring(6);
	
	return retval;
}

// Convert integer to string and 0-pad. String.format() just won't work here, not sure why, otherwise the codes won't be this kludgy.
// up to 6 digits 000001 (updated 12/4/2010)
public final String padZeros5(int iwhich)
{
	String retval = String.valueOf(iwhich);
	String padstr = "";

	if(iwhich < 10) padstr = "0000";
	if(iwhich > 9) padstr = "000";
	if(iwhich > 99) padstr = "00";
	if(iwhich > 999) padstr = "0";
	if(iwhich > 9999) padstr = "";
		
	return padstr + retval;
}

public final String padZeros3(int iwhich)
{
	String retval = String.valueOf(iwhich);
	String padstr = "";

	if(iwhich < 10) padstr = "00";
	if(iwhich > 9) padstr = "0";
		
	return padstr + retval;
}

// Check if ioo = "" , return "--UnD--" , else return ioo . Simple func to streamline codes.
// useful when populating listbox from database and column is ""
// eg. strarray[1] = checkEmptyString(eqsatu.get("EQ_name"));
public String checkEmptyString(String ioo)
{
	return (ioo.equals("")) ? BLANK_REPLACER : ioo;
}

public final String checkNullString(String ioo)
{
	if(ioo == null) return "";
	else return ioo;
}

public final String checkNullString_RetWat(String ioo, String retval)
{
	if(ioo == null) return retval;
	else return ioo;
}

// Return the folder prefix - all def in alsglobaldefs.zs - JOBFOLDERS_PREFIX, JB_JOBFOLDERS_PREFIX, KK_JOBFOLDERS_PREFIX
public final String folderPrefixByBranch(String ibranch)
{
	String folderprefix = JOBFOLDERS_PREFIX;
	if(ibranch.equals("JB")) folderprefix = JB_JOBFOLDERS_PREFIX;
	if(ibranch.equals("KK")) folderprefix = KK_JOBFOLDERS_PREFIX;
	return folderprefix;
}

// Convert ArrayList to String[]
public final String[] convertArrayListToStringArray(ArrayList iwhat)
{
	int arsz = iwhat.size();
	String[] retarray = new String[arsz];
	Object[] wopa = iwhat.toArray();
	for(int i=0; i<arsz; i++)
	{
		retarray[i] = (String)wopa[i];
	}
	return retarray;
}

// 22/03/2011: check null date(from sql) return some string or the chopped date string
public final String checkNullDate(Object thedate, String nullstring)
{
	String retval = nullstring;
	if(thedate != null) retval = thedate.toString().substring(0,10);
	return retval;
}

// Make a random id for component - iprestr = prefix string
public final String makeRandomId(String iprestr)
{
	long rannum = Math.round(Math.random() * 1000);
	String retval = iprestr + String.valueOf(rannum);
	return retval;
}

public final boolean existInStringArray(String[] thearray, String thecheck)
{
	boolean retval = false;
	for(int i=0; i<thearray.length; i++)
	{
		if(thearray[i].equals(thecheck))
		{
			retval = true;
			break;
		}	
	}
	return retval;
}

// Return true if iwhat is in ichklist - isepchar = separation character
public final boolean checkExistinString(String ichklist, String isepchar, String iwhat)
{
	boolean retval = false;
	String[] splito = ichklist.split(isepchar);
	String spitem;

	for(int i=0; i < splito.length; i++)
	{
		spitem = splito[i];
		if(spitem.equals(iwhat)) { retval = true; break; }
	}

	return retval;
}

public final String escapedHTMLString(String iwhat)
{
	String retval = iwhat.replaceAll("<","&lt;");
	retval = retval.replaceAll(">","&gt;");
	retval = retval.replaceAll("\"","&quot;");
	retval = retval.replaceAll("&","&amp;");
	return retval;
}

// 17/08/2012: try to convert float number to string
// With exception handling and DecimalFormat() thing
public final String floatToString(String iwhat, String iformat)
{
	String retval = "";
	try
	{
		DecimalFormat nf = new DecimalFormat(iformat);
		retval = nf.format(Float.parseFloat(iwhat));
	}
	catch (java.lang.NumberFormatException e)
	{
		retval = iwhat;
	}
	return retval;
}

// 13/09/2012: iso date format - need not use getDateFromDatebox() old func
public final String todayISODateString()
{
	Date now = new Date();
	SimpleDateFormat dtf = new SimpleDateFormat("yyyy-MM-dd");
	return dtf.format(now);
}

// 09/04/2013: returns iso-date and time format
public final String todayISODateTimeString()
{
	Date now = new Date();
	SimpleDateFormat dtf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
	return dtf.format(now);
}

public final String makeQuotedFromComma(String iwhat)
{
	if(iwhat.equals("")) return "";
	String[] pp = iwhat.split("\n");
	String lcs = "";
	for(int i=0; i<pp.length; i++)
	{
		lcs += "'" + pp[i].trim() + "',";
	}
	try { lcs = lcs.substring(0,lcs.length()-1); } catch (Exception e) {}
	return lcs;
}

// Merge 2 object-arrays into 1 - codes copied from some website
public final Object[] mergeArray(Object[] lst1, Object[] lst2)
{
	List list = new ArrayList(Arrays.asList(lst1));
	list.addAll(Arrays.asList(lst2));
	Object[] c = list.toArray();
	return c;
}

public final int countMonthYearDiff(int itype, Component ist, Component ied)
{
	Calendar std = new GregorianCalendar();
	Calendar edd = new GregorianCalendar();
	Datebox kist = (Datebox)ist; Datebox kied = (Datebox)ied;
	std.setTime(kist.getValue());
	edd.setTime(kied.getValue());
	int diffYear = edd.get(Calendar.YEAR) - std.get(Calendar.YEAR);
	int diffMonth = diffYear * 12 + edd.get(Calendar.MONTH) - std.get(Calendar.MONTH);
	return (itype == 1) ? diffMonth : diffYear;
}

}
// ENDOF public class Generals

