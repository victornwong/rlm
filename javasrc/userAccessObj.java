package org.victor;

/*
User access object class for storing stuff to be plonged around
*/

public class userAccessObj
{
	public int origid;
    public String username;
    public int accesslevel;
	public String fullname;
	public String email;
	public String handphone;
	public String branch;
	public String stockcat;
	public String groupcode;

	public userAccessObj() {}

	public final void clearAll()
	{
		origid = 0;
		username = "";
		accesslevel = 0;
		fullname = "";
		email = "";
		handphone = "";
		branch = "";
		stockcat = "";
		groupcode = "";
	}
}

