package org.victor;

/*
File: General purpose menubar GUI funcs put them here
Written by: Victor Wong
Original dated: 08/10/2011
Port dated: 26/03/2012

Notes: Ported funcs from menubarfuncs.zs - compile byte-codes

*/

import java.util.*;
import java.io.*;
import java.sql.*;
import javax.sql.*;
import groovy.sql.*;
import org.zkoss.zk.ui.*;
import org.zkoss.zul.*;
import org.victor.*;

public class MenuFuncs extends SqlFuncs
{
public MenuFuncs() {}
	
// GUI Func: Menubar maker
public final Menubar menuBarMaker(String compoid, String istyle, String iwidth, Div iparent)
{
	Menubar tmenubar = new Menubar();
	if(!istyle.equals("")) tmenubar.setStyle(istyle);
	if(!iwidth.equals("")) tmenubar.setWidth(iwidth); else tmenubar.setWidth("100%");
	tmenubar.setId(compoid);
	tmenubar.setParent(iparent);
	return tmenubar;
}

// GUI Func: make Menu component - as drop-down menu-tab
public final Menu menuTabMaker(String compoid, String ilabel, String istyle, Component iparent)
{
	Menu menutab = new Menu();
	if(!compoid.equals("")) menutab.setId(compoid);
	if(!istyle.equals("")) menutab.setStyle(istyle);
	menutab.setLabel(ilabel);
	menutab.setParent(iparent);
	return menutab;
}

// GUI Func: Menupopup() maker
public final Menupopup menuListMaker(String compoid, Menu iparent)
{
	Menupopup mpopup = new Menupopup();
	mpopup.setId(compoid);
	mpopup.setParent(iparent);
	return mpopup;
}

// GUI Func: menuitem maker - make program shorter in some way.. haha
// itype: 1=internal, 2=call def mods in database
// 26/03/2012: for internal and external menuitem clicker, def in main .zul EventListener
public final Menuitem menuItemMaker(String compoid, String ilabel, String istyle, Menupopup iparent, int itype)
{
	Menuitem mitem = new Menuitem();
	if(!compoid.equals("")) mitem.setId(compoid);
	if(!istyle.equals("")) mitem.setStyle(istyle);

/*
	if(itype == 1)
		mitem.addEventListener("onClick", new internalMenuItem_Clicker());
	else
		mitem.addEventListener("onClick", new externalMenuItem_Clicker());
*/

	mitem.setLabel(ilabel);
	mitem.setParent(iparent);
	return mitem;
}

// DBFunc: insert new menu into menu-tree
public final boolean insertNewMenu(String iname, String imyparent) throws SQLException
{
	Sql sql = als_mysoftsql();
	if(sql == null) return false;
	String sqlstm = "insert into elb_menutree (menuname,menulabel,accesslevel,menuparent,disabled,guitype,module_fn) " + 
	"values ('" + iname + "','NEW',1," + imyparent + ",0,'PANEL','')";
	sql.execute(sqlstm);
	sql.close();
	return true;
}

// DBFunc: get menu-item rec from elb_menutree
public final GroovyRowResult getMenuRec(String iorigid) throws SQLException
{
	Sql sql = als_mysoftsql();
	GroovyRowResult retval = null;
	if(sql == null) return retval;
	String sqlstm = "select * from elb_menutree where origid=" + iorigid;
	retval = (GroovyRowResult)sql.firstRow(sqlstm);
	sql.close();
	return retval;
}

// DBFunc: check if there's a branch attached to folder-rec
public final boolean existBranch(String iorigid) throws SQLException
{
	boolean retval = false;
	Sql sql = DMS_Sql();
	if(sql == null) return retval;
	String sqlstm = "select top 1 origid from folderstructure where folderparent=" + iorigid;
	GroovyRowResult trec = (GroovyRowResult)sql.firstRow(sqlstm);
	sql.close();
	if(trec != null) retval = true;
	return retval;
}
	
}

