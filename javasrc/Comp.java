package org.victor;

import java.util.*;
import java.text.*;
import java.io.*;
//import org.zkoss.zk.ui.*;
import org.zkoss.zk.ui.*;
import org.zkoss.zul.*;

/*
Written by : Victor Wong
Date : 13/03/2012
Notes:
*/

// class copied from ZK website for comparing stuff - works for <grid><column>
public class Comp implements Comparator
{
	private boolean _asc;
	private int _columnindex;

	public Comp(boolean asc, int icolm)
	{
		_asc = asc;
		_columnindex = icolm;
	}

	public int compare(Object o1, Object o2)
	{
		Column c_o1 = (Column)o1;
		Column c_o2 = (Column)o2;
		
		Label c_l1 = (Label)c_o1.getChildren().get(_columnindex);
		Label c_l2 = (Label)c_o2.getChildren().get(_columnindex);

		//String s1 = c_o1.getChildren().get(_columnindex).getValue(),
		//	s2 = c_o2.getChildren().get(_columnindex).getValue();
		
		String s1 = c_l1.getValue(), s2 = c_l2.getValue();

		int v = s1.compareTo(s2);
		return _asc ? v: -v;
	}
}

