package org.victor;

import java.util.*;
import java.text.*;
import java.io.*;
import java.sql.*;
import groovy.sql.*;
import org.zkoss.zk.ui.*;
import org.zkoss.zul.*;
import org.zkoss.util.*;
import org.victor.*;

/*
22/08/2014: show folderstructu.actiondate in the tree
*/

public class DirectoryTree extends GlobalDefs
{
	public static String itmstyle = "font-size:9px";
	private GuiFuncs guihand;
	private SqlFuncs sqlhand;
	private Generals kiboo;
	//private SimpleDateFormat mdtf;

	Treechildren tobeshown;
	Sql mainSql;
	
	public DirectoryTree(Treechildren thechild, String iparentid) throws SQLException
	{
		guihand = new GuiFuncs();
		sqlhand = new SqlFuncs();
		kiboo = new Generals();
		//mdtf = new SimpleDateFormat("yyyy-MM-dd");

		mainSql = sqlhand.DMS_Sql();
		if(mainSql == null) return;

		String sqlstatement = "select origid,folderid,folder_desc,actiondate,actiontodo from folderstructure where deleted=0 and folderparent=" + iparentid;
		ArrayList catlist = (ArrayList)mainSql.rows(sqlstatement);
		tobeshown = thechild;
		fillMyTree(thechild, catlist);
		mainSql.close();
	}

	void fillMyTree(Treechildren tchild, ArrayList prolist) throws SQLException
	{
		for(GroovyRowResult opis : (List<GroovyRowResult>)prolist)
		{
			Treeitem titem = new Treeitem();
			Treerow newrow = new Treerow();

			Treecell newcell1 = new Treecell();
			Treecell newcell2 = new Treecell();
			Treecell newcell3 = new Treecell();
			Treecell newcell4 = new Treecell();
			Treecell newcell5 = new Treecell();

			String thisbranchid = (String)opis.get("origid").toString();
			String folderid = (String)opis.get("folderid");
			String actiond = (opis.get("actiondate") == null) ? "" : (String)dtf2.format(opis.get("actiondate"));
			String todo = kiboo.checkNullString( (String)opis.get("actiontodo") );

			if(folderid.length() > 40) folderid = folderid.substring(0,38) + "..";

			String folderdesc = (String)opis.get("folder_desc");
			if(folderdesc.length() > 30) folderdesc = folderdesc.substring(0,28) + "..";

			String sqlqueryline = "select origid,folderid,folder_desc,actiondate,actiontodo from folderstructure where folderparent=" + thisbranchid;
			ArrayList subchild = (ArrayList)mainSql.rows(sqlqueryline);

			boolean highlite = false;

			if(subchild.size() > 0)
			{
				Treechildren newone = new Treechildren();
				newone.setParent(titem);
				fillMyTree(newone,subchild);
				highlite = true;
				//newcell1.setLabel("${subchild.size()} ${opis[2]}");
			}

			newcell3.setVisible(false);
			newcell3.setLabel(thisbranchid);

			//if(highlite) itmstyle += ";background:#99AA88";

			newcell1.setLabel(folderid);
			newcell1.setStyle(itmstyle);
			newcell1.setDraggable("treedrop");

			newcell2.setLabel(folderdesc);
			newcell2.setStyle(itmstyle);

			newcell4.setLabel(todo);
			newcell4.setStyle(itmstyle);

			newcell5.setLabel(actiond);
			newcell5.setStyle(itmstyle);

			newcell1.setParent(newrow);
			newcell2.setParent(newrow);
			newcell3.setParent(newrow);
			newcell4.setParent(newrow);
			newcell5.setParent(newrow);
			newrow.setParent(titem);
			titem.setParent(tchild);
		}
	}

// end of class directoryTree

}

