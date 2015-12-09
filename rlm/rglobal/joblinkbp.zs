/**
 * Job-linking business-process class
 * This class will hold the job-linking notes and perform business-process/rules
 * In modules that require multiple of this object, set the appropriate linking-code
 * Uses: db.joblink_bp (refer to the struct, changes will occur regularly)
 */
class JobLinkBP
{
	private SqlFuncs p_sqlhand;
	private ListboxHandler p_lbhand;
	public String linkcode;
	public Div lb_holder;
	public String lb_id;

	JobLinkBP(String pLinkcode, Div pHolder, String pLBid)
	{
		linkcode = pLinkcode;
		lb_holder = pHolder; lb_id = pLBid;

		p_sqlhand = new SqlFuncs(); p_lbhand = new ListboxHandler();
	}

	public void showJobLink_List(int pLBrows)
	{
		String sqlstm = "select origid,username,datecreated,notes from joblink_bp where linkingcode='" + linkcode + "' order by datecreated desc;";
	}

}