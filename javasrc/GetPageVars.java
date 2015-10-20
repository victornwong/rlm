package org.victor;

import java.util.List;
//import org.zkoss.zk.ui.Div;
//import org.zkoss.zul.Button;
//import org.zkoss.zk.ui.util.GenericForwardComposer;
import org.zkoss.zul.*;
import org.zkoss.zk.ui.ext.*;
//import org.zkoss.zk.ui.impl.PageImpl;

/*
File: Stuff to get things from a page. Vars and components
Written by: Victor Wong
Dated: 12/03/2012

String manis = (String)this.getDesktop().getPage("rndstuff_mod").getZScriptVariable("manis");
*/

public class GetPageVars extends Div
{

	// Get vars defined in <zscript>, return as Object, so have to cast accordingly
	public final Object getPageVar(String ipageid, String ivarname)
	{
		Object retval = this.getDesktop().getPage(ipageid).getZScriptVariable(ivarname);
		return retval;
	}

	// Get all children in a page - useful to find get values	
	public final List getPageChildren(String iparent)
	{
		List allch;
		if(!iparent.equals("")) allch = this.getFellowIfAny(iparent).getChildren();
		else allch = this.getChildren();
		return allch;
	}

	/*	
    public final void clicko()
    {

	try {
			Button btnOutside = (Button)this.getFellowIfAny("btnOutside");
			//Messagebox.show("hand java-beans 332222");
			btnOutside.setLabel("clicked...");
            List allch = this.getChildren();

			Desktop dskt = this.getDesktop();


            Messagebox.show(allch.toString() + manis);
            

        } catch (Exception e) {
            e.printStackTrace();
        }   
    }
    */

}

