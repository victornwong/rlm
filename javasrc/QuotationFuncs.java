package org.victor;

import java.util.*;
import java.sql.*;
import groovy.sql.*;
import org.zkoss.zk.ui.*;
import javax.sql.DataSource;
import org.victor.*;

public class QuotationFuncs extends SqlFuncs
{

String QUOTE_PREFIX = "QT";
String QTSTAT_NEW = "NEW";
String QTSTAT_COMMIT = "COMMITTED";
String QTSTAT_RETIRED = "RETIRED";
String QTSTAT_WIN = "WIN";
String QTSTAT_LOSE = "LOSE";
String QTSTAT_WAIT = "WAIT";

	public QuotationFuncs() {}

// Database func: insert a new quotation into elb_Quotations
public final void insertQuotation_Rec(String iusername, String idatecreated) throws SQLException
{
	Sql sql = als_mysoftsql();
	if(sql == null ) return;
	Connection thecon = sql.getConnection();
	PreparedStatement pstmt = thecon.prepareStatement("insert into elb_Quotations (ar_code,customer_name,datecreated,username,deleted,qstatus,version) values (?,?,?,?,?,?,?)");
	pstmt.setString(1,"");
	pstmt.setString(2,"");
	pstmt.setString(3,idatecreated);
	pstmt.setString(4,iusername);
	pstmt.setInt(5,0);
	pstmt.setString(6,QTSTAT_NEW);
	pstmt.setInt(7,0);
	pstmt.executeUpdate();
	sql.close();
}

public final GroovyRowResult getQuotation_Rec(String iorigid) throws SQLException
{
	GroovyRowResult retval = null;
	Sql sql = als_mysoftsql();
	if(sql == null ) return retval;
	String sqlstm = "select * from elb_Quotations where origid=" + iorigid;
	retval = (GroovyRowResult)sql.firstRow(sqlstm);
	sql.close();
	return retval;
}

// Set only elb_Quotations.qstatus field
public final void setQuotation_Status(String iorigid, String iwhat) throws SQLException
{
	Sql sql = als_mysoftsql();
	if(sql == null ) return;
	String sqlstm = "update elb_Quotations set qstatus='" + iwhat + "' where origid=" + iorigid;
	sql.execute(sqlstm);
	sql.close();
}

// Database func: insert a new rec into elb_quotation_items - params self-explanatory
public final void insertQuoteItem_Rec(String iq_parent, String imysoftcode, String idesc, String idesc2, String icurcode, Double iunitprice) throws SQLException
{
	Sql sql = als_mysoftsql();
	if(sql == null ) return;
	Connection thecon = sql.getConnection();

	PreparedStatement pstmt = thecon.prepareStatement("insert into elb_Quotation_Items (mysoftcode,description,description2,LOR,quote_parent, quantity,curcode,unitprice,discount," +
	"total_net,total_gross) values (?,?,?,?,?, ?,?,?,?,?, ?)");

	pstmt.setInt(1,Integer.parseInt(imysoftcode));
	pstmt.setString(2,idesc);
	pstmt.setString(3,idesc2);
	pstmt.setString(4,"");
	pstmt.setInt(5, Integer.parseInt(iq_parent));

	pstmt.setInt(6,1);
	pstmt.setString(7,icurcode);
	pstmt.setDouble(8,iunitprice);

	pstmt.setDouble(9,0);
	pstmt.setDouble(10, iunitprice);
	pstmt.setDouble(11, iunitprice);

	pstmt.executeUpdate();
	sql.close();
}

public final void insertQuoteItem_Rec2(String iq_parent, String imysoftcode, String idesc, String idesc2, String icurcode, Double iunitprice, String iversion) throws SQLException
{
	Sql sql = als_mysoftsql();
	if(sql == null ) return;
	Connection thecon = sql.getConnection();

	PreparedStatement pstmt = thecon.prepareStatement("insert into elb_Quotation_Items (mysoftcode,description,description2,LOR,quote_parent, quantity,curcode,unitprice,discount," +
	"total_net,total_gross,version) values (?,?,?,?,?, ?,?,?,?,?, ?,?)");

	pstmt.setInt(1,Integer.parseInt(imysoftcode));
	pstmt.setString(2,idesc);
	pstmt.setString(3,idesc2);
	pstmt.setString(4,"");
	pstmt.setInt(5, Integer.parseInt(iq_parent));

	pstmt.setInt(6,1);
	pstmt.setString(7,icurcode);
	pstmt.setDouble(8,iunitprice);
	pstmt.setDouble(9,0);
	pstmt.setDouble(10, iunitprice);
	pstmt.setDouble(11, iunitprice);
	pstmt.setInt(12, Integer.parseInt(iversion));

	pstmt.executeUpdate();
	sql.close();
}

// Database func: delete a quote-item
public final void deleteQuoteItem_Rec(String iorigid) throws SQLException
{
	Sql sql = als_mysoftsql();
	if(sql == null ) return;
	String sqlstm = "delete from elb_Quotation_Items where origid=" + iorigid;
	sql.execute(sqlstm);
	sql.close();
}

// Database func: just quote-item rec
public final GroovyRowResult getQuoteItem_Rec(String iorigid) throws SQLException
{
	GroovyRowResult retval = null;
	Sql sql = als_mysoftsql();
	if(sql == null ) return retval;
	String sqlstatem = "select * from elb_Quotation_Items where origid=" + iorigid;
	retval = (GroovyRowResult)sql.firstRow(sqlstatem);
	sql.close();
	return retval;
}

// Database func: just use to update prices x quantity thing and LOR
public final void updateQuoteItem_Value(String iorigid, String iunitprice, String idiscount, String iquantity, String ilor, String idesc, String idesc2) throws SQLException
{
	Float kunitp = Float.parseFloat(iunitprice);
	Integer kquant = Integer.parseInt(iquantity);
	Float kdisct = Float.parseFloat(idiscount);
	Float total_gross = kunitp * kquant;
	Float total_net = total_gross - kdisct;
	Sql sql = als_mysoftsql();
	if(sql == null ) return;
	String sqlstm = "update elb_Quotation_Items set unitprice=" + String.valueOf(kunitp) + ", discount=" + String.valueOf(kdisct) + ", quantity=" + String.valueOf(kquant) +
	", total_net=" + String.valueOf(total_net) + ", total_gross=" + String.valueOf(total_gross) + ", LOR='" + ilor + "', description='" + idesc + "', description2='" + idesc2 + "' " + 
	"where origid=" + iorigid;
	sql.execute(sqlstm);
	sql.close();
}

// Database func: toggle elb_Quotations.deleted flag
public final void toggleQuotation_DeletedFlag(String iorigid) throws SQLException
{
	Sql sql = als_mysoftsql();
	if(sql == null ) return;
	String sqlstm = "select deleted from elb_Quotations where origid=" + iorigid;
	GroovyRowResult retval = (GroovyRowResult)sql.firstRow(sqlstm);
	if(retval != null)
	{
		String toggler = ((Integer)retval.get("deleted") == 1) ? "0" : "1";
		String sqlstm2 = "update elb_Quotations set deleted=" + toggler + " where origid=" + iorigid;
		sql.execute(sqlstm2);
	}
	sql.close();
}

// Database func: Get quotation-package record
public final GroovyRowResult getQuotePackageRec(String iorigid) throws SQLException
{
	GroovyRowResult retval = null;
	Sql sql = als_mysoftsql();
	if(sql == null) return retval;
	String sqlstm = "select * from elb_quotation_package where origid=" + iorigid;
	retval = (GroovyRowResult)sql.firstRow(sqlstm);
	sql.close();
	return retval;
}

// Return 1 if any quote-items linked to quote else 0
public final int quotePackageItems_Avail(String iparent_qp) throws SQLException
{
	int retval = 0;
	Sql sql = als_mysoftsql();
	if(sql == null) return retval;
	String sqlstm = "select top 1 origid from elb_quotepackage_items where qpack_parent=" + iparent_qp;
	GroovyRowResult ll = (GroovyRowResult)sql.firstRow(sqlstm);
	sql.close();
	if(ll != null) retval = 1;
	return retval;
}

}

