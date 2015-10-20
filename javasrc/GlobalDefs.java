package org.victor;

import java.util.*;
import java.text.*;

public class GlobalDefs
{
public static String BLANK_REPLACER = "------";

// 15/4/2010: branches job-folders prefix
public static String JOBFOLDERS_PREFIX = "ALSM";
public static String JB_JOBFOLDERS_PREFIX = "ALJB";
public static String KK_JOBFOLDERS_PREFIX = "ALKK";

// DB stuff
public static String MYSOFTDATABASESERVER = "alsslws007:1433";
public static String MYSOFTDATABASENAME = "AccDatabase1";
public static String DOCUMENTSTORAGE_DATABASE = "DocumentStorage";

public static String CHEMISTRY_RESULTS_TABLE = "elb_Chemistry_Results";
public static String JOBFOLDERS_TABLE = "JobFolders";
public static String JOBSAMPLES_TABLE =  "JobSamples";
public static String JOBTESTPARAMETERS_TABLE = "JobTestParameters";
public static String RUNLIST_TABLE = "RunList";
public static String RUNLISTITEMS_TABLE = "RunList_Items";
public static String CASHSALES_CUSTOMERINFO_TABLE = "CashSales_CustomerInfo";

// 24/08/2011: document management using a different database - AdminDocument. Tables struct same and with additional stuff
public static String DMS_DATABASE = "AdminDocuments";

public static String ARCHIVE_DOC_DATABASE = "DocuArchives";

// END of DB Stuff

public static String FOLDERLOGGED = "LOGGED";
public static String FOLDERDRAFT = "DRAFT";
public static String FOLDERCOMMITED = "COMMITED";
public static String FOLDERRELEASED = "RELEASED";
public static String FOLDERWIP = "WIP";
public static String FOLDERRETEST = "RETEST";

public static SimpleDateFormat dtf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
public static SimpleDateFormat dtf2 = new SimpleDateFormat("yyyy-MM-dd");
public static SimpleDateFormat yearonly = new SimpleDateFormat("yyyy");
public static DecimalFormat nf2 = new DecimalFormat("#0.00");
public static DecimalFormat nf3 = new DecimalFormat("###,##0.00");
public static DecimalFormat nf = new DecimalFormat("###,##0.00");
public static DecimalFormat nf0 = new DecimalFormat("#");

// used in RWMS_sql.java

public final int BOM_JOBID = 1; // BOM link to job-id
public final int PICKLIST_JOBID = 2; // pick-list link to job-id
public final int BOM_DOID = 3; // BOM link to DO
public final int PICKLIST_DOID = 4; // pick-list link to DO
public final int DO_MANIFESTID = 5; // DO link to manifest
public final int PR_JOB = 6; // PR link to job

}

