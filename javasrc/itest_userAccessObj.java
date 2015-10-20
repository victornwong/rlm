package org.victor;

/*
User access object class for storing stuff to be plonged around
*/

public class itest_userAccessObj
{
	public int origid;
	public String ar_code;
	public String username;
	public int accesslevel;
	public String fullname;
	public String email;
	public String handphone;
	public String branch;
	public String stockcat;
	public String groupcode;
	public String field1, field2, field3, field4, field5, field6;

	public itest_userAccessObj() {}
	public final void clearAll()
	{
		origid = 0;
		accesslevel = 0;
		ar_code = username = fullname = email = handphone = branch = stockcat = groupcode = "";
		field1 = field2 = field3 = field4 = field5 = field6 = "";
	}
}

