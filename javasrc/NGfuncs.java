package org.victor;
import java.util.*;
import java.text.*;
import java.lang.*;
import groovy.sql.*;
import org.zkoss.zul.*;
import org.zkoss.zk.ui.*;
import org.zkoss.zk.ui.event.*;
import java.math.BigDecimal;
//import org.zkoss.zk.ui.*;
//import org.zkoss.zk.zutl.*;
//import org.zkoss.util.media.AMedia;

public class NGfuncs extends GlobalDefs
{
// UI-related funcs

	public final void removeSubDiv(Div idivholder)
	{
		Object[] prvds = idivholder.getChildren().toArray();
		Div myw;
		for(int i=0;i<prvds.length;i++) // remove prev sub-divs if any
		{
			myw = (Div)prvds[i];
			myw.setParent(null);
		}
	}

// Make grid, with headers, move to byte-comp later
public final void checkMakeGrid(String[] colws, String[] colls, Div idiv, String igridid, String irowsid, String ihdstyle, String iwidth, boolean icenter)
{
	if(idiv.getFellowIfAny(igridid) == null) // make new grid if none
	{
		Grid igrd = new Grid(); igrd.setId(igridid);
		if(!iwidth.equals("")) igrd.setWidth(iwidth);
		org.zkoss.zul.Columns icols = new org.zkoss.zul.Columns();
		for(int i=0;i<colws.length;i++)
		{
			org.zkoss.zul.Column ico0 = new org.zkoss.zul.Column();
			ico0.setWidth(colws[i]); ico0.setLabel(colls[i]);
			if(icenter) ico0.setAlign("center");
			ico0.setStyle(ihdstyle); ico0.setParent(icols);
		}
		icols.setParent(igrd);
		org.zkoss.zul.Rows irows = new org.zkoss.zul.Rows();
		irows.setId(irowsid); irows.setParent(igrd);
		igrd.setParent(idiv);
	}
}

public final void fillListbox_uniqField(String itbn, String ifl, Listbox ilb) throws java.sql.SQLException
{
	SqlFuncs sqlhand = new SqlFuncs();
	ListboxHandler lbhand = new ListboxHandler();
	String sqlstm = "select distinct " + ifl + " from " + itbn;
	ArrayList r = sqlhand.gpSqlGetRows(sqlstm);
	if(r.size() == 0) return;
	String[] kabom = new String[1];
	String dk;
	GroovyRowResult kk;
	for(Object d : r)
	{
		kk = (GroovyRowResult)d;
		dk = (String)kk.get(ifl);
		if(dk != null)
		{
			kabom[0] = dk;
			lbhand.insertListItems(ilb,kabom,"false","");
		}
	}
	ilb.setSelectedIndex(0);
}


public final void clearUI_Field(Object[] iob)
{
	Generals kiboo = new Generals();
	for(int i=0; i<iob.length; i++)
	{
		if(iob[i] instanceof Textbox) { Textbox kk = (Textbox)iob[i]; kk.setValue(""); }
		if(iob[i] instanceof Label) { Label kk = (Label)iob[i]; kk.setValue(""); }
		if(iob[i] instanceof Datebox) { Datebox kk = (Datebox)iob[i]; kiboo.setTodayDatebox(kk); }
		if(iob[i] instanceof Listbox) { Listbox kk = (Listbox)iob[i]; kk.setSelectedIndex(0); }
	}
}

public final void disableUI_obj(Component[] iob, boolean iwhat)
{
	for(int i=0; i<iob.length; i++)
	{
		if(iob[i] instanceof Checkbox) { Checkbox kk = (Checkbox)iob[i]; kk.setDisabled(iwhat); }
		if(iob[i] instanceof Combobox) { Combobox kk = (Combobox)iob[i]; kk.setDisabled(iwhat); }
		if(iob[i] instanceof Textbox) { Textbox kk = (Textbox)iob[i]; kk.setDisabled(iwhat); }
		if(iob[i] instanceof Datebox) { Datebox kk = (Datebox)iob[i]; kk.setDisabled(iwhat); }
		if(iob[i] instanceof Listbox) { Listbox kk = (Listbox)iob[i]; kk.setDisabled(iwhat); }
	}
}

public final Object vMakeWindow(Object ipar, String ititle, String iborder, String ipos, String iw, String ih) throws InterruptedException
{
	Component kk = (Component)ipar;
	Window rwin = new Window(ititle,iborder,true);
	rwin.setWidth(iw); rwin.setHeight(ih);
	rwin.setPosition(ipos); rwin.setParent(kk);
	rwin.setMode("overlapped");
	return rwin;
}

public final void popuListitems_Data2(ArrayList ikb, String[] ifl, GroovyRowResult ir)
{
	String kstr = "";

	for(int i=0; i<ifl.length; i++)
	{
		//try {
		Object kk = ir.get(ifl[i]);

		if(kk == null) kstr = "";
		else
			if(kk instanceof Date) kstr = dtf.format(kk);
		else
			if(kk instanceof Integer) kstr = nf0.format(kk);
		else
			if(kk instanceof BigDecimal)
			{
				BigDecimal xt = (BigDecimal)kk;
				BigDecimal rt = xt.remainder(BigDecimal.ONE);
				if(rt.floatValue() != 0.0)
					kstr = nf2.format(kk);
				else
					kstr = nf0.format(kk);
			}
		else
			if(kk instanceof Double) kstr = nf2.format(kk);
		else
			if(kk instanceof Float) kstr = kk.toString();
		else
			if(kk instanceof Boolean)
			{
				Boolean mm = (Boolean)kk;
				String wi = (mm) ? "Y" : "N";
				kstr = wi;
			}
		else
			kstr = (String)kk;

		ikb.add( kstr );
		//} catch (Exception e) {}
	}
}

public final void popuListitems_Data(ArrayList ikb, String[] ifl, GroovyRowResult ir)
{
	String kstr = "";

	for(int i=0; i<ifl.length; i++)
	{
		//try {
		Object kk = ir.get(ifl[i]);
		if(kk == null) kstr = "";
		else

			if(kk instanceof Date) kstr = dtf2.format(kk);
		else
			if(kk instanceof Integer) kstr = nf0.format(kk);
		else
			if(kk instanceof BigDecimal)
			{
				BigDecimal xt = (BigDecimal)kk;
				BigDecimal rt = xt.remainder(BigDecimal.ONE);
				if(rt.floatValue() != 0.0)
					kstr = nf2.format(kk);
				else
					kstr = nf0.format(kk);
			}
		else
			if(kk instanceof Double) kstr = nf2.format(kk);
		else
			if(kk instanceof Float) kstr = kk.toString();
		else
			if(kk instanceof Boolean)
			{
				Boolean mm = (Boolean)kk;
				String wi = (mm) ? "Y" : "N";
				kstr = wi;
			}
		else
			kstr = (String)kk;

		ikb.add( kstr );
		//} catch (Exception e) {}
	}
}

String[] getString_fromUI(Object[] iob)
{
	Generals kiboo = new Generals();
	String[] rdt = new String[iob.length];
	for(int i=0; i<iob.length; i++)
	{
		rdt[i] = "";
		try
		{
			if(iob[i] instanceof Textbox)
			{
				Textbox kk = (Textbox)iob[i];
				rdt[i] = kiboo.replaceSingleQuotes(kk.getValue().trim());
			}

			if(iob[i] instanceof Label)
			{
				Label kk = (Label)iob[i];
				rdt[i] = kiboo.replaceSingleQuotes(kk.getValue().trim());
			}

			if(iob[i] instanceof Listbox)
			{
				Listbox kk = (Listbox)iob[i];
				rdt[i] = kk.getSelectedItem().getLabel();
			}

			if(iob[i] instanceof Datebox)
			{
				Datebox kk = (Datebox)iob[i];
				rdt[i] = dtf2.format( kk.getValue() );
			}

			if(iob[i] instanceof Checkbox)
			{
				Checkbox kk = (Checkbox)iob[i];
				rdt[i] = (kk.isChecked()) ? "1" : "0";
			}
		}
		catch (Exception e) {}
	}
	return rdt;
}

public final void populateUI_Data(Object[] iob, String[] ifl, GroovyRowResult ir)
{
	Generals kiboo = new Generals();
	ListboxHandler lbhand = new ListboxHandler();
	for(int i=0;i<iob.length;i++)
	{
//		try
//		{
			Object woi = ir.get(ifl[i]);

			if(iob[i] instanceof Textbox || iob[i] instanceof Label)
			{
				String kk = "";
				if(woi == null) kk = "";
				else
				if(woi instanceof Date) kk = dtf2.format(woi);
				else
				if(woi instanceof Integer || woi instanceof Double || woi instanceof BigDecimal) kk = woi.toString();
				else
				if(woi instanceof Float) kk = nf2.format(woi);
				else
					kk = (String)woi;

				if(iob[i] instanceof Textbox) { Textbox mm = (Textbox)iob[i]; mm.setValue(kk); }
				if(iob[i] instanceof Label) { Label mm = (Label)iob[i]; mm.setValue(kk); }
			}

			if(iob[i] instanceof Checkbox)
			{
				Checkbox kk = (Checkbox)iob[i];
				kk.setChecked( (woi == null ) ? false : (Boolean)woi);
			}

			if(iob[i] instanceof Listbox)
			{
				lbhand.matchListboxItems( (Listbox) iob[i], kiboo.checkNullString((String)woi).toUpperCase() );
			}
			if(iob[i] instanceof Datebox)
			{
				Datebox kk = (Datebox)iob[i];
				kk.setValue( (Date)woi );
			}

//		} catch (Exception e) {}
	}
}

// itype: 1=width, 2=height
public final void gpMakeSeparator(int itype, String ival, Component iparent)
{
	Separator sep = new Separator();
	if(itype == 1) sep.setWidth(ival);
	if(itype == 2) sep.setHeight(ival);
	sep.setParent(iparent);
}

public final Button gpMakeButton(Object iparent, String iid, String ilabel, String istyle, Object iclick)
{
	Button retv = new Button();
	if(!istyle.equals("")) retv.setStyle(istyle);
	if(!ilabel.equals("")) retv.setLabel(ilabel);
	if(!iid.equals("")) retv.setId(iid);
	if(iclick != null) retv.addEventListener("onClick", (org.zkoss.zk.ui.event.EventListener)iclick);
	retv.setParent((Component)iparent);
	return retv;
}

public final Label gpMakeLabel(Object iparent, String iid, String ivalue, String istyle)
{
	Label retv = new Label();
	if(!iid.equals("")) retv.setId(iid);
	if(!istyle.equals("")) retv.setStyle(istyle);
	retv.setValue(ivalue);
	retv.setParent((Component)iparent);
	return retv;
}

public final Checkbox gpMakeCheckbox(Object iparent, String iid, String ilabel, String istyle)
{
	Checkbox retv = new Checkbox();
	if(!iid.equals("")) retv.setId(iid);
	if(!istyle.equals("")) retv.setStyle(istyle);
	if(!ilabel.equals("")) retv.setLabel(ilabel);
	retv.setParent((Component)iparent);
	return retv;
}

// idropevt: define in caller module -- it's a class extending org.zkoss.zk.ui.event.EventListener
public final Textbox gpMakeTextbox(Component iparent, String iid, String ivalue, String istyle, String iwidth, org.zkoss.zk.ui.event.EventListener idropevt)
{
	Textbox retv = new Textbox();
	if(!iid.equals("")) retv.setId(iid);
	if(!istyle.equals("")) retv.setStyle(istyle);
	if(!ivalue.equals("")) retv.setValue(ivalue);
	if(!iwidth.equals("")) retv.setWidth(iwidth);
	retv.setDroppable("true");
	retv.addEventListener("onDrop", idropevt);
	retv.setParent(iparent);
	return retv;
}

public final void gpmakeGridHeaderColumns_Width(String[] icols, String[] iwidths, Object iparent)
{
	Columns colms = new Columns();
	for(int i=0; i<icols.length; i++)
	{
		Column hcolm = new Column();
		hcolm.setLabel(icols[i]);
		/*
		Comp asc = new Comp(true,i);
		Comp dsc = new Comp(false,i);
		hcolm.setSortAscending(asc);
		hcolm.setSortDescending(dsc);
		*/
		hcolm.setStyle("font-size:9px");
		hcolm.setWidth(iwidths[i]);
		hcolm.setParent((Component)colms);	
	}
	colms.setParent((Component)iparent);
}

public final void blindTings(Component iwhat, Component icomp)
{
	Button kk = (Button)iwhat;
	String itype = kk.getId();
	String klk = kk.getLabel();
	boolean bld = (klk.equals("+")) ? true : false;
	kk.setLabel( (klk.equals("-")) ? "+" : "-" );
	icomp.setVisible(bld);
}

public final void blindTings_withTitle(Component iwhat, Component icomp, Component itlabel)
{
	Button kk = (Button)iwhat;
	String itype = kk.getId();
	String klk = kk.getLabel();
	boolean bld = (klk.equals("+")) ? true : false;
	kk.setLabel( (klk.equals("-")) ? "+" : "-" );
	icomp.setVisible(bld);

	itlabel.setVisible((bld == false) ? true : false );
}

public final void activateModule(String iplayg, String parentdiv_name, String winfn, String windId, String uParams, userAccessObj uAO)
{
	SecurityFuncs sechand = new SecurityFuncs();
	Include newinclude = new Include();
	newinclude.setId(windId);

	String includepath = winfn + "?myid=" + windId + "&" + uParams;
	newinclude.setSrc(includepath);

	sechand.setUserAccessObj(newinclude, uAO); // securityfuncs.zs

	Div contdiv = (Div)Path.getComponent(iplayg + parentdiv_name);
	newinclude.setParent(contdiv);

} // activateModule()

// Use to refresh 'em checkboxes labels -- can be used for other mods
// iprefix: checkbox id prefix, inextcount: next id count, pcomp: parent component
public final void refreshCheckbox_CountLabel(String iprefix, int inextcount, Component pcomp)
{
	int count = 1;
	String bci;
	Checkbox icb;
	for(int i=1;i<inextcount; i++)
	{
		bci = iprefix + Integer.toString(i);
		icb = (Checkbox)pcomp.getFellowIfAny(bci);
		if(icb != null)
		{
			icb.setLabel(count + ".");
			count++;
		}
	}
}

public final void fillComboboxUniq(String isqlstm, String ifield, Combobox icombo) throws java.sql.SQLException
{
	Generals kiboo = new Generals();
	GridHandler gridhand = new GridHandler();
	SqlFuncs sqlhand = new SqlFuncs();

	ArrayList recs = sqlhand.gpSqlGetRows(isqlstm);
	if(recs.size() == 0) return;

	// clear any previous comboitem if any
	Object[] remi = icombo.getItems().toArray();
	Comboitem myk;
	for(int i=0; i<remi.length; i++)
	{
		myk = (Comboitem)remi[i]; 
		myk.setParent(null);
	}

	ArrayList kabom = new ArrayList();
	for( Object d : recs)
	{
		GroovyRowResult kk = (GroovyRowResult)d;
		kabom.add( kiboo.checkNullString( (String)kk.get(ifield)) );
	}

	gridhand.makeComboitem(icombo, kiboo.convertArrayListToStringArray(kabom) );
	//String sqlstm = "select username from portaluser where username<>'" + discardname + "' and deleted=0 and locked=0 order by username";
}

}
