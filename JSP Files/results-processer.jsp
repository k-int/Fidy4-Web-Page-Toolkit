<%@ page import="java.util.*, java.util.regex.*, java.text.*, java.net.*, java.io.*, java.lang.*, javax.xml.transform.*, org.w3c.dom.*, org.xml.sax.*, javax.xml.parsers.*, javax.xml.transform.stream.*, javax.xml.transform.dom.*, javax.xml.xpath.*" %>

<%!
	public class DynArray {
		
		Vector intArray = new Vector();
		
		public void pushItem(String contents) {
			intArray.addElement(contents);
		}
		
		public void clear() {
			intArray.clear();
		}
		
		public int size() {
			return intArray.size();
		}
		
		public String getVal(int i) {
			return intArray.get(i).toString();
		}
		
		public void setVal(int i, String valueToSet)
		{
			intArray.setElementAt(valueToSet, i);
		}
		
	}
	
    public class XMLIterator {
        public Document XMLDoc;
        public Element RootElement;
        public Boolean QueryError;
        public Boolean UseLocation;
        public int ErrorCounter;
    }

    public class AbsVarsObject {
        public String AbsFreetext;
        public String AbsCat;
        public String AbsSubCat;
        public String AbsSubSubCat;
        public String AbsEligibility;
        public String AbsTitle;
        public String AbsLocation;
        public String AbsDistance;
        public String AbsFilters;
        public String AbsReferralCriteria;
        public String AbsAccessChannel;
        public String AbsLanguage;
        public String AbsWheelchairAccess;
        public String AbsSpecialNeeds;
        public String AbsNational;
        public String AbsXNational;
        public String AbsView;
        public String AbsSortBy;
        public int AbsStartPoint;
        public int AbsMaximumRecords;
        public int AbsPerPage;
        public String AbsFullQuery;
    }

    public String age_range(int min, int max) {
        String searching =  "("+
                                "(AgeRangeMin%3E"+(min - 1)+"%20and%20AgeRangeMax%3C"+(max + 1)+")"+
                            "%20or%20"+
                                "(AgeRangeMin%3C"+(min + 1)+"%20and%20AgeRangeMax%3E"+(max - 1)+")"+
                            "%20or%20"+
                                "("+
                                    "(AgeRangeMin%3E"+(min - 1)+"%20or%20AgeRangeMax%3C"+(max + 1)+")"+
                                  "%20and%20"+
                                    "(AgeRangeMin%3C"+(min + 1)+"%20or%20AgeRangeMax%3E"+(max - 1)+")"+
                                  "%20and%20"+
                                    "(AgeRangeMin%3C"+(max + 1)+"%20and%20AgeRangeMax%3E"+(min - 1)+")"+
                                ")"+
                           ")";
        return searching;
    }

// This method applies a default "OR" operation to words in the freetext and title queries, unless the words are OR, NOT or AND
// If there is a quoted string, this is added as an exact match for the access point specified when the method is called
public String addBools(String unbooledString, String accessPoint) {

    // Create a new Regex Pattern and define the regular expression
    Pattern p = Pattern.compile("[^\\s\"']+|\"([^\"]*)\"|'([^']*)'");
    Pattern pProblemChars = Pattern.compile("[^A-Za-z0-9]{1}");  // Matches a string if the string contains unusual characters
        
    // Create a Matcher for the input string
    Matcher m = p.matcher(unbooledString.toLowerCase());
    // Split the input string by the regex pattern
    DynArray textArray = new DynArray();
    while (m.find()) {
        if (m.group().equals("and") || m.group().equals("or") || m.group().equals("not")) {
            textArray.pushItem(m.group());
        } else if ((1 < m.group().length() && m.group().startsWith("*")) || m.group().startsWith("?")) {
            String temp = m.group().replace("*", "\\*");
            temp = temp.replace("?", "\\?");
            textArray.pushItem(temp);
        } else {
        	// Get the initial keyword being searched for, this needs to be single quoted or double quoted where it contains
                // special characters.
        	textArray.pushItem("\"" + m.group() + "\"");
        	
        	// If this string isn't already double quoted then double quote it if it contains problem characters
                if (!textArray.getVal(textArray.size() - 1).startsWith("\"\"") || !textArray.getVal(textArray.size() - 1).endsWith("\"\""))
                {
                    // Not already double quoted, see if should be
                    if (pProblemChars.matcher(m.group()).find())
                    {
                        // Double quote as contains special chars
                        textArray.setVal(textArray.size() - 1, "\"" + textArray.getVal(textArray.size() - 1).replace("%C3%A8","e") + "\"");
                    }                   
                }
            
        }
    }

	String[] newTextArray = new String[textArray.size()];
	String result = new String();
    Integer limit = textArray.size() - 1;

    if (textArray.getVal(0).equals("and") || textArray.getVal(0).equals("or") || textArray.getVal(0).equals("not")) {
        newTextArray[0] = "";
    } else if (0 <= textArray.getVal(0).indexOf("\"\"")) {
        newTextArray[0] = accessPoint + " adj (" + textArray.getVal(0) + ")";
    } else {
        newTextArray[0] = textArray.getVal(0);
    }

    if (0 < limit) {
        for (int i=1; i<limit; i++) {

		    if (textArray.getVal(i).equals("and") || textArray.getVal(i).equals("or") || textArray.getVal(i).equals("not")) {
                if (textArray.getVal(i-1).equals("and") || textArray.getVal(i-1).equals("or") || textArray.getVal(i-1).equals("not")) {
			        newTextArray[i] = "";
                } else {
			        newTextArray[i] = " "+textArray.getVal(i);
                }
		    } else if (textArray.getVal(i-1).equals("and") || textArray.getVal(i-1).equals("or") || textArray.getVal(i-1).equals("not")) {
                if (0 <= textArray.getVal(i).indexOf("\"\"")) {
                    newTextArray[i] = " " + accessPoint + " adj (" + textArray.getVal(i) + ")";
                } else {
                    newTextArray[i] = " "+textArray.getVal(i);
                }
            } else {
                if (0 <= textArray.getVal(i).indexOf("\"\"")) {
                    newTextArray[i] = " or " + accessPoint + " adj (" + textArray.getVal(i) + ")";
                } else {
                    newTextArray[i] = " or "+textArray.getVal(i);
                }
		    }

	    } // end for loop

        if (textArray.getVal(limit).equals("and") || textArray.getVal(limit).equals("or") || textArray.getVal(limit).equals("not")) {
            if (textArray.getVal(limit-1).equals("and") || textArray.getVal(limit-1).equals("or") || textArray.getVal(limit-1).equals("not")) {
	            newTextArray[limit] = "\"" + textArray.getVal(limit) + "\"";
            } else {
	            newTextArray[limit] = "";
            }
        } else if (textArray.getVal(limit-1).equals("and") || textArray.getVal(limit-1).equals("or") || textArray.getVal(limit-1).equals("not")) {
            if (0 <= textArray.getVal(limit).indexOf("\"\"")) {
                newTextArray[limit] = " " + accessPoint + " adj (" + textArray.getVal(limit) + ")";
            } else {
                newTextArray[limit] = " "+textArray.getVal(limit);
            }
        } else {
            if (0 <= textArray.getVal(limit).indexOf("\"\"")) {
                newTextArray[limit] = " or " + accessPoint + " adj (" + textArray.getVal(limit) + ")";
            } else {
                newTextArray[limit] = " or "+textArray.getVal(limit);
            }
        }

    }

	for (String item : newTextArray) {
	    result = result + item;
	}
	result = result.toLowerCase().replace("\"\"", "\"");
	result = result.replace(accessPoint.toLowerCase(), accessPoint);

    String encodedURL = new String();
    try {
        encodedURL = URLEncoder.encode(result, "ISO-8859-1");
        return encodedURL;
    } catch(UnsupportedEncodingException uee){
        System.err.println(uee);
    }

    return encodedURL;
}

public String make_query(AbsVarsObject absVars, DynArray queryArray, Boolean useLocation, Map filterFlagSearches, Map filterAgeSearches, String apikey) throws SearchFailException {
    // Create an SRU query from the url
    
    queryArray.clear();

	//S01: simple search tool start
	if (false == (absVars.AbsFreetext.equals(""))) {
		queryArray.pushItem("("+addBools(absVars.AbsFreetext, "cql.serverChoice")+")");
	}
	//S01: simple search tool end
	
	//S02: category tool start
	if (false == (absVars.AbsSubSubCat.equals(""))) {
		queryArray.pushItem("Subject%3D(%22"+absVars.AbsSubSubCat+"%22)");
	} else if (false == (absVars.AbsSubCat.equals(""))) {
		queryArray.pushItem("Subject%3D(%22"+absVars.AbsSubCat+"%22)");
	} else if (false == (absVars.AbsCat.equals(""))) {
		queryArray.pushItem("Subject%3D(%22"+absVars.AbsCat+"%22)");
	}
	//S02: category tool start
	
	//S04: eligibility criteria tool start
	if (false == (absVars.AbsEligibility.equals(""))) {
		queryArray.pushItem("EligibilityCriteria%3D("+addBools(absVars.AbsEligibility, "EligibilityCriteria")+")");
	}
	//S04: eligibility criteria tool end
	   	
	//S05: Referral criteria specification start
	// check if referral criterion was set via the Advanced Search page
	if (false == absVars.AbsReferralCriteria.equals("")) {
	    absVars.AbsFilters = absVars.AbsFilters + "," + absVars.AbsReferralCriteria;
   	}
	//S05: Referral criteria specification end

	//S06: Access channel specification start
	// check if referral criterion was set via the Advanced Search page
	if (false == absVars.AbsAccessChannel.equals("")) {
	    absVars.AbsFilters = absVars.AbsFilters + "," + absVars.AbsAccessChannel;
   	}
	//S06: Access channel specification end

	//S07: Language criteria specification start
	// check if referral criterion was set via the Advanced Search page
	if (false == absVars.AbsLanguage.equals("")) {
	    absVars.AbsFilters = absVars.AbsFilters + "," + absVars.AbsLanguage;
   	}
	//S07: Language specification end

	//S08: Wheelchair access/special needs specification start
	// check if WheelChairAccess was set via the Advanced Search page
	if (absVars.AbsWheelchairAccess.equals("on")) {
	    absVars.AbsFilters = absVars.AbsFilters + ",wAcc";
   	}
	// check if SpecialNeeds was set via the Advanced Search page
	if (absVars.AbsSpecialNeeds.equals("on")) {
	    absVars.AbsFilters = absVars.AbsFilters + ",sNeeds";
   	}
	//S08: Wheelchair access/special needs specification end

	//S09: Service title search tool (advanced search) start
	if (false == (absVars.AbsTitle.equals(""))) {
		queryArray.pushItem("dc.title%3D("+addBools(absVars.AbsTitle, "dc.title")+")");
	}
	//S09: Service title search tool (advanced search) end
	
	//L01: Location / proximity filter tool start
	if ("" != absVars.AbsLocation && true == useLocation) {
		Pattern pLatLong = Pattern.compile("^-{0,1}\\d+\\.\\d+,-{0,1}\\d+\\.\\d+$");
		Matcher mLatLong = pLatLong.matcher(absVars.AbsLocation);		
		if(mLatLong.matches()){
			queryArray.pushItem("geostr%3D%22" + absVars.AbsLocation);			
		}
		else{		
			String qLocation = Helpers.HTMLEncode(absVars.AbsLocation.replace("\"", ""));
			
			queryArray.pushItem("Location%3D%22" + qLocation);
			
				
		}
	}
	
	double qFilterDist = 5;
	if (false == absVars.AbsDistance.equals("")) {
        NumberFormat number = new DecimalFormat("#0.00");
        qFilterDist = (1 > Double.parseDouble(absVars.AbsDistance)) ? 1 : Double.parseDouble(number.format(Double.parseDouble(absVars.AbsDistance)));
	}
    String qNational	= "true";
	if (absVars.AbsNational.equals("off") || (absVars.AbsXNational.equals("off") && (false == absVars.AbsNational.equals("on")))) {
		qNational	= "false";
	}
	//L01: Location / proximity filter tool end
	
	//S03, F02, F03, F04, F05, F06, F07, F08, F09: filter tools start
	if (false == absVars.AbsFilters.equals("")) {
		String refs = new String();
		String accs = new String();
		String lans = new String();
	    String flags = new String();
		String ages = new String();
		String vacs = new String();
        absVars.AbsFilters = (',' == absVars.AbsFilters.charAt(0)) ? absVars.AbsFilters.substring(1) : absVars.AbsFilters;
		String[] filtersArray = absVars.AbsFilters.split(",");
		for (String filterCodename : filtersArray) {

            // F02 age range filter start
			if (null != (filterAgeSearches.get(filterCodename))) {
                ages = (ages.equals("")) ? filterAgeSearches.get(filterCodename).toString() : ages + "%20AND%20" + filterAgeSearches.get(filterCodename).toString();
			}
            // F02 age range filter end

	        // F03: referral criteria filter start
            if (filterCodename.substring(0,3).equals("ref")) {
                refs = (refs.equals("")) ? filterCodename.substring(3) : refs + "%20AND%20" + filterCodename.substring(3);
            }
	        // F03: referral criteria filter end


	        // F04: access channel filter start
            if (filterCodename.substring(0,3).equals("acc")) {
                accs = (accs.equals("")) ? filterCodename.substring(3) : accs + "%20AND%20" + filterCodename.substring(3);
            }
	        // F04: access channel filter end

	        // F05: language filter start
            if (filterCodename.substring(0,3).equals("lan")) {
                lans = (lans.equals("")) ? filterCodename.substring(3) : lans + "%20AND%20" + filterCodename.substring(3);
            }
	        // F05: language filter end

            // F06, F07, F09 filters start
			if (null != (filterFlagSearches.get(filterCodename))) {
                flags = (flags.equals("")) ? filterFlagSearches.get(filterCodename).toString() : flags + "%20AND%20" + filterFlagSearches.get(filterCodename).toString();
			}
            // F06, F07, F09 filters end

            // F08 current vacancies filter start
			if (filterCodename.equals("vacs")) {
			    vacs = "Vacancies%3dtrue";
			}
            // F08 current vacancies filter end

		}
		if (false == (ages.equals(""))) {
	     	queryArray.pushItem(ages);
	    }
		if (false == (refs.equals(""))) {
	     	queryArray.pushItem("ReferralCriteria%3D(" + refs + ")");
	    }
		if (false == (accs.equals(""))) {
	     	queryArray.pushItem("AccessChannel%3D(" + accs + ")");
	    }
		if (false == (lans.equals(""))) {
	     	queryArray.pushItem("Language%3D(" + lans + ")");
	    }
		if (false == (flags.equals(""))) {
	   	    queryArray.pushItem("Flags%3D(" + flags + ")");
	   	}
		if (false == (vacs.equals(""))) {
	      	queryArray.pushItem(vacs);
	    }
	}
	//S03, F02, F03, F04, F05, F06, F07, F08, F09: filter tools end

	// Check if ANY search criteria are set
	String query = new String();
    if (0 == queryArray.size()) {
        query = "*";
    } else if (1 == queryArray.size() && 13 < queryArray.getVal(0).length() && queryArray.getVal(0).substring(0, 14).equals("Location%3D%22")) {
        query = "*" + "%20and%20" + queryArray.getVal(0);
    } else {
	    for (int q=0; q<queryArray.size(); q++) {
		    query += queryArray.getVal(q) + "%20and%20";
	    }
        query = (9 < query.length()) ? query.substring(0, (query.length() - 9)) : "";
    }

	// Create a RESTful request
    int sruStartRecord = (50 <= absVars.AbsStartPoint) ? absVars.AbsStartPoint - 50 : 1;

	if (qNational.equals("false")) {
	    query = query + "%20NOT%20Authority%3D%22NFSDPortal%22";
    }

    //R01: results set sorting tool start
    String sruSortKeys = new String();
    if (absVars.AbsSortBy.equals("name")) {
        sruSortKeys = "title";
    } else if (absVars.AbsSortBy.equals("last updated")) {
        sruSortKeys = "modified,,0%20title";
    } else if (absVars.AbsSortBy.equals("distance")) {
        sruSortKeys = "geo_distance%20title";
    } else {
        sruSortKeys = "score,,0%20title";
    }
    //R01: results set sorting tool end

	String sruString = "/sru/xml/default?version=1.2&apikey=" + Helpers.apikey + "&operation=searchRetrieve&query=" + query + "&radius=" + qFilterDist + "&sortKeys=" + sruSortKeys + "&maximumRecords=100&startRecord=" + sruStartRecord
                     + "&x-kint-facet=true"
                     + "&x-kint-facet.field=dc.subject"
                     + "&x-kint-facet.field=flags"
                     + "&x-kint-facet.field=immediate_vacancies_s"
                     + "&x-kint-facet.field=referral_criteria_s"
                     + "&x-kint-facet.field=mode_of_access_s"
                     + "&x-kint-facet.field=language_spoken_s"
                     + "&x-kint-facet.mincount=1";
	
    return sruString;
}

private static Pattern isNumber = Pattern.compile("^\\d*\\.?\\d*");

public boolean IsNumeric(String theValue)
{
    Matcher m = isNumber.matcher(theValue);
    return m.matches();
} //IsNumeric

public class SearchDiagnosticsException extends Exception{};
public class SearchLocationException extends Exception{};
public class SearchFailException extends Exception{};


%>

<%@ include file="globalvars.jsp" %>

<%

	// Define variables
	String query = new String();

	// Define and assign values to relevant variables
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	AbsVarsObject absVars = new AbsVarsObject();

	//S01: simple search tool start
	// Freetext - a simple string query, like you would put in Google (e.g. "Schools Basingstoke")
	// We use a regular expression and full querystring to extract this value to allow coping correctly with accented characters, which are not passed correctly
	// when using request.getParameter
	Pattern pFreeText = Pattern.compile("(?<=freetext=)[^&]*");
	Matcher mFreeText = pFreeText.matcher(request.getQueryString());
	if(mFreeText.find())
	{
		absVars.AbsFreetext = mFreeText.group(0).replace("%C3%A8","e");		
	}
	else
	{
		absVars.AbsFreetext = "";	
	}
	
	//absVars.AbsFreetext = (null != request.getParameter("freetext")) ? URLDecoder.decode(request.getParameter("freetext"), "UTF-8").replace("%C3%A8","e") : "";
	
	//S01: simple search tool end

	//S02: category browse tool start
	// Subject - the specific title of a service (e.g. "Little Tots Nursery")
	absVars.AbsCat = (null != request.getParameter("category")) ? request.getParameter("category") : "";
	absVars.AbsSubCat = (null != request.getParameter("subcategory")) ? request.getParameter("subcategory") : "";
	absVars.AbsSubSubCat = (null != request.getParameter("subsubcategory")) ? request.getParameter("subsubcategory") : "";
	//S02: category browse tool end

	//S04: eligibility criteria tool start
	// Freetext - a simple string query, like you would put in Google (e.g. "Schools Basingstoke")
	absVars.AbsEligibility = (null != request.getParameter("eligibilityCriteria")) ? request.getParameter("eligibilityCriteria") : "";
	//S04: eligibility criteria tool end

	//S09: service title search tool start
	// Title - the specific title of a service (e.g. "Little Tots Nursery")
	absVars.AbsTitle = (null != request.getParameter("title")) ? request.getParameter("title") : "";
	//S09: service title search tool start

	//L01: Location tool start
	// Location - a town, city, area or postcode (either full or just the first part)
	// Valid examples include "London", "Norwich", "Shoreditch", "N11" and "B23 5RS"
	absVars.AbsLocation = (null != request.getParameter("location")) ? request.getParameter("location") : "";

	// National - boolean option to exclude Nationwide services from the results.
	// If this is set to anything other than 'off', Nationwide services will be included in the results
	absVars.AbsNational = (null != request.getParameter("national")) ? request.getParameter("national") : "";

	// XNational - Modifies above. If set 'off' it excludes Nationwide services unless National is also set to 'on'
	absVars.AbsXNational = (null != request.getParameter("xnational")) ? request.getParameter("xnational") : "";

	// Distance - radial limit (in miles) from the centre of the above location.
	// This option must be used in conjunction with Location, as without that it has no point of reference.
	absVars.AbsDistance = (null != request.getParameter("filterDist") && IsNumeric(request.getParameter("filterDist").toString())) ? request.getParameter("filterDist") : "";
	//L01: Location tool end

	//F02, F03, F04, F05, F06, F07, F08, F10: filter tools start
	// Filters - comma-separated list of codes (see the fullFilterNames list below) of filters to apply.
	// The list must only use codes defined below, and have no spaces. For example, "wAcc,vacs,yrs1-4"
	absVars.AbsFilters = (null != request.getParameter("filters")) ? request.getParameter("filters") : "";

	absVars.AbsReferralCriteria = (null != request.getParameter("referralCriteria")) ? request.getParameter("referralCriteria") : "";
	absVars.AbsAccessChannel = (null != request.getParameter("accessChannel")) ? request.getParameter("accessChannel") : "";
	absVars.AbsLanguage = (null != request.getParameter("language")) ? request.getParameter("language") : "";
	absVars.AbsWheelchairAccess = (null != request.getParameter("wheelchairAccess")) ? request.getParameter("wheelchairAccess") : "";
	absVars.AbsSpecialNeeds = (null != request.getParameter("specialNeeds")) ? request.getParameter("specialNeeds") : "";
	//F02, F03, F04, F05, F06, F07, F08, F10: filter tools end

	
	//R04, R05, R06:  List view, Table view, and Map view tools start
	// View - Valid values "list", "table" or "map", defaults to "list".  Sets which tab is active on results page
	absVars.AbsView = (null != request.getParameter("view")) ? request.getParameter("view") : "list";
	//R04, R05, R06:  List view, Table view, and Map view tools start

	//R01: Results sorting tool start
	// sortBy - Valid values "name", "updated" or (if map enabled) "distance", defaults to "relevance".
	absVars.AbsSortBy = (null != request.getParameter("sortBy")) ? request.getParameter("sortBy") : "relevance";
	//R01: Results sorting tool end

	//R02: results pagination tool start
	// StartRecord - First record on page, defaults to "1".  Used to page through results
	absVars.AbsStartPoint = (null != request.getParameter("startPoint")) ? Integer.parseInt(request.getParameter("startPoint")) : 1;
	//R02: resutls pagination tool end

	//R03: Results set sizing tool start
	// PerPage - Results per page, default "10".
	absVars.AbsPerPage = (null != request.getParameter("perPage")) ? Integer.parseInt(request.getParameter("perPage")) : 10;
	//R03: Results set sizing tool end

	absVars.AbsFullQuery = request.getQueryString().replace("%C3%A8","e");
		
	
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// End section
	
	
	// Define an array of XSL files and one for the resulting output
	// Each section will be assigned to an element in the xslOutputArray, at the same index as its corresponging xsl file
	//////////////////////////////////////////////////////////////////////
	int numberOfParts = 2;
	String[] xslArray = new String[numberOfParts];
	String[] xslOutputArray = new String[numberOfParts];
	xslArray[0] = "results_head.xsl";
	xslArray[1] = "results_body.xsl";
	//////////////////////////////////////////////////////////////////////
	// End section
	
	DynArray queryArray = new DynArray();
	
	Map fullFilterNames = new HashMap();
	fullFilterNames.put("wAcc", "Wheelchair Access");
	fullFilterNames.put("sNeeds", "Caters for Special Needs");
	fullFilterNames.put("vacs", "Current Vacancies");
	fullFilterNames.put("crb", "CRB Checked");
	fullFilterNames.put("pickup", "School Pickups");
	fullFilterNames.put("yrs0-1", "0-1 year");
	fullFilterNames.put("yrs1-4", "1-4 years");
	fullFilterNames.put("yrs5-10", "5-10 years");
	fullFilterNames.put("yrs10-18", "10-18 years");
	fullFilterNames.put("yrs18-25", "18-25 years");
	fullFilterNames.put("yrs25", "25+ years");

	Map filterFlagSearches = new HashMap();
	filterFlagSearches.put("wAcc", "WheelChairAccess");
	filterFlagSearches.put("sNeeds", "SpecialNeeds");
    filterFlagSearches.put("crb", "CRB");
    filterFlagSearches.put("pickup", "SchoolPickup");
	Map filterAgeSearches = new HashMap();
	filterAgeSearches.put("yrs0-1", age_range(0,1));
	filterAgeSearches.put("yrs1-4", age_range(1,4));
	filterAgeSearches.put("yrs5-10", age_range(5,10));
	filterAgeSearches.put("yrs10-18", age_range(10,18));
	filterAgeSearches.put("yrs18-25", age_range(18,25));
	filterAgeSearches.put("yrs25", "(AgeRangeMin%3E24%20or%20AgeRangeMax%3E24)");

    // Create a factory and builder
    DocumentBuilder builder = DocumentBuilderFactory.newInstance().newDocumentBuilder();
    XMLIterator xmlIterator = new XMLIterator();
    xmlIterator.QueryError = false;
    xmlIterator.UseLocation = true;
    xmlIterator.ErrorCounter = 0;
	
    // Get the URL for the search
    String fetchRecord = "";
    do {
        xmlIterator.QueryError = false;
        fetchRecord = Helpers.root + make_query(absVars, queryArray, xmlIterator.UseLocation, filterFlagSearches, filterAgeSearches, Helpers.apikey);
        // out.println(fetchRecord + "<br />");
        try {
	                	
        	// Parse the XML data with the builder
	        xmlIterator.XMLDoc = builder.parse(fetchRecord);

            xmlIterator.RootElement = xmlIterator.XMLDoc.getDocumentElement();
            if (xmlIterator.RootElement.getTagName().equals("diagnostics")) {
                throw new SearchLocationException();
            } else if (false == xmlIterator.RootElement.getTagName().equals("srw:searchRetrieveResponse")) {
                throw new SearchFailException();
            }
        }
        catch (SearchLocationException ex) {
  	        xmlIterator.QueryError = true;
	        xmlIterator.UseLocation = false;
	        xmlIterator.ErrorCounter = xmlIterator.ErrorCounter + 1;
        }
        catch (SearchFailException ex) {
  	        xmlIterator.QueryError = true;
	        xmlIterator.ErrorCounter = xmlIterator.ErrorCounter + 1;
        }
        catch (Exception ex) {
  	        xmlIterator.QueryError = true;
	        xmlIterator.ErrorCounter = xmlIterator.ErrorCounter + 1;
        }
              	
       
    } while (true == xmlIterator.QueryError && 5 > xmlIterator.ErrorCounter);

    if (5 <= xmlIterator.ErrorCounter) {
		out.println(Helpers.redirectError(response, "404 - <br />"));
		return;
    }

	Element echo = xmlIterator.XMLDoc.createElement("echoedData");
	echo.setAttributeNS("http://www.w3.org/2000/xmlns/", "xmlns", "");
	xmlIterator.RootElement.appendChild(echo);
	
	// Create the nodes
	Element queryString = xmlIterator.XMLDoc.createElement("queryString");
	
    //S01: simple search tool start
	String freetextAtt = URLEncoder.encode(absVars.AbsFreetext);
	freetextAtt = freetextAtt.replace("+", " ");
	freetextAtt = freetextAtt.replace(" and ", " AND ");
    freetextAtt = freetextAtt.replace(" or ", " OR ");
    freetextAtt = freetextAtt.replace(" not ", " NOT ");
	queryString.setAttribute("freetext", freetextAtt);
    //S01: simple search tool end

	//S02: category tool start
	queryString.setAttribute("category", absVars.AbsCat);
	queryString.setAttribute("subcategory", absVars.AbsSubCat);
	queryString.setAttribute("subsubcategory", absVars.AbsSubSubCat);
	//S02: category tool end
	
    //S04: eligibility criteria tool start
	String elgibilityAtt = URLEncoder.encode(absVars.AbsEligibility);
	elgibilityAtt = elgibilityAtt.replace("+", " ");
	elgibilityAtt = elgibilityAtt.replace(" and ", " AND ");
    elgibilityAtt = elgibilityAtt.replace(" or ", " OR ");
    elgibilityAtt = elgibilityAtt.replace(" not ", " NOT ");
	queryString.setAttribute("eligibilityCriteria", elgibilityAtt);
    //S04: eligibility criteria tool end

	//S09: service title search tool (advanced search) start
	String titleAtt = URLEncoder.encode(absVars.AbsTitle);
	titleAtt = titleAtt.replace("+", " ");
	titleAtt = titleAtt.replace(" and ", " AND ");
    titleAtt = titleAtt.replace(" or ", " OR ");
	titleAtt = titleAtt.replace(" not ", " NOT ");
	queryString.setAttribute("title", titleAtt);
	//S09: service title search tool (advanced search) end
	
	//L01: location / proximity filter tool start
	queryString.setAttribute("location", absVars.AbsLocation.replace("+", " "));
    String locationError = (true == xmlIterator.UseLocation) ? "" : "yes";
	queryString.setAttribute("locationError", locationError);
    Double qFilterDist = Double.parseDouble("5");
    if (false == absVars.AbsDistance.equals("")) {
        NumberFormat number = new DecimalFormat("#0.00");
        qFilterDist = (1 > Double.parseDouble(absVars.AbsDistance)) ? 1 : Double.parseDouble(number.format(Double.parseDouble(absVars.AbsDistance)));
    }
    queryString.setAttribute("filterDist", qFilterDist.toString());
	if (absVars.AbsNational.equals("off") || (absVars.AbsXNational.equals("off") && (false == absVars.AbsNational.equals("on")))) {
		queryString.setAttribute("national", "off");
	} else {
		queryString.setAttribute("national", "on");
	}
	//L01: location / proximity filter tool end

	// S03, S04, S05, S06, S07, S08, F02, F03, F04, F05, F06, F07, F08, F09: filter tools start
    // Create a node in the original doc to hold list data
    Element vocabData = xmlIterator.XMLDoc.createElement("controlledListData");
    // Create array of codes for controlled list data
    String[] lists = {"fullCatsList", "referralList", "accessChannelsList", "langList"};
    String catInternalId = "";
    String subcatInternalId = "";
    // Load controlled list data to construct lists of filters
    for (int i=0; i<lists.length; i++) {
        Document vocab = null;
        // Load the vocabulary into a new document
        try {
            ByteArrayInputStream vocabBais = new ByteArrayInputStream(application.getAttribute(lists[i]).toString().getBytes());
            vocab = builder.parse(vocabBais);
            // Create a child node for this particular list
            Element listData = xmlIterator.XMLDoc.createElement(lists[i]);
            // add data
            Element vocabTree = vocab.getDocumentElement();
            listData.appendChild(xmlIterator.XMLDoc.importNode(vocabTree, true));
            vocabData.appendChild(listData);
        }
        catch (Exception e) {
            // Do nothing - just don't load the vocab list..
            // out.println("Cannot load " + lists[i] + " - " + e + "<br />");
        }
    }
	xmlIterator.RootElement.appendChild(vocabData);
        
	// Logic for processing filters (only kicks in if filters have been selected)
    if (0 < absVars.AbsFilters.length()) {
		Element filterList = xmlIterator.XMLDoc.createElement("filterList");
		String[] filtersArray = absVars.AbsFilters.split(",");
        for (String filterCodename : filtersArray) {
			Element filterName = xmlIterator.XMLDoc.createElement("filterName");
            if (fullFilterNames.containsKey(filterCodename)) {
        		Text filterNameText = xmlIterator.XMLDoc.createTextNode(fullFilterNames.get(filterCodename).toString());
				filterName.appendChild(filterNameText);
            }
			filterName.setAttribute("filterCode", filterCodename);
			filterList.appendChild(filterName);
        }
		echo.appendChild(filterList);
    }
    queryString.setAttribute("filters", absVars.AbsFilters);
	// S03, S04, S05, S06, S07, S08, F02, F03, F04, F05, F06, F07, F08, F09: filter tools end

	
	// R04, R05, R06: List view, table view, and Map view tools start
	String viewAtt = "list";
	if (null != absVars.AbsView) {
		viewAtt = absVars.AbsView;
	}
	queryString.setAttribute("view", viewAtt);
	//R04, R05, R06: List view, table view, and Map view tools end

	//R01: Results set sorting tool start
	String sortAtt = "relevance";
	if (null != absVars.AbsSortBy) {
		sortAtt = absVars.AbsSortBy;
	}
	queryString.setAttribute("sortBy", sortAtt);
	//R01: Results set sorting tool end

	//R02: Results pagination tool start
	queryString.setAttribute("startPoint", Integer.toString(absVars.AbsStartPoint));
    int sruStartRecord = (50 <= absVars.AbsStartPoint) ? absVars.AbsStartPoint - 50 : 1;
	queryString.setAttribute("sruStartRecord", Integer.toString(sruStartRecord));
	//R02: Results pagination tool end
	
	//R03: Results set sizing tool start
	queryString.setAttribute("perPage", Integer.toString(absVars.AbsPerPage));
	//R03: Results set sizing tool end

	Text queryStringText = xmlIterator.XMLDoc.createTextNode(absVars.AbsFullQuery);
	queryString.appendChild(queryStringText);
	
	echo.appendChild(queryString);
	
	
	//R06: Map view tool start
	// Obtain the geocoded location data from the SOLR record
	NodeList list = xmlIterator.XMLDoc.getElementsByTagName("srw:extraProp");
	
	String lat = new String();
	String lng = new String();
	String homebasePostcode = new String();
	
    for (int i=0; i<list.getLength(); i++) {
        if (list.item(i).getAttributes().item(0).getNodeValue().equals("geo_lat")) {
            lat = list.item(i).getAttributes().item(1).getNodeValue();
        }
        if (list.item(i).getAttributes().item(0).getNodeValue().equals("geo_lon")) {
	        lng = list.item(i).getAttributes().item(1).getNodeValue();
        }
    }
    
	homebasePostcode = (true == absVars.AbsLocation.equals("")) ? "" : Helpers.HTMLEncode(absVars.AbsLocation.replace(" ", " "));
	
	Element homebase = xmlIterator.XMLDoc.createElement("centrePoint");
	homebase.setAttribute("lat", lat);
	homebase.setAttribute("lng", lng);
	homebase.setAttribute("PostCode", homebasePostcode);
	
	echo.appendChild(homebase);
	
	// End geocoding
	//R06: Map view tool end
	
	
	
	// Output the full xmlIterator.XMLDoc to a string, which can then be read as an input
	// Create transformer
	TransformerFactory tranFactory = TransformerFactory.newInstance();
	Transformer aTransformer = tranFactory.newTransformer();
	// Set teh xmlIterator.XMLDoc as the source
	Source src = new DOMSource(xmlIterator.XMLDoc);
	// Create a ByteArrayOutputStream to hold the result of the transform
	ByteArrayOutputStream tempDoc = new ByteArrayOutputStream();
	Result dest = new StreamResult(tempDoc);
	aTransformer.transform(src, dest);
	
	// Optional alternative to save results for bug tracking
	// Result dest2 = new StreamResult(new File("C:\\Temp\\newjava.xml"));  
	// aTransformer.transform(src, dest2);

	xmlIterator.XMLDoc = null;
	

	for (int i=0; i<numberOfParts; i++) {

	    // Take the tempDoc created earlier, convert it to string and set it as the source
	    StringReader xmlReader = new StringReader( tempDoc.toString("utf8") );
	    Source xmlFile = new StreamSource( xmlReader ) ;

		String xslPath = new String(getServletContext().getRealPath(Helpers.xslRootPath + xslArray[i]));
		File xslFileObject = new File(xslPath);
		Source xsl = new StreamSource(xslFileObject);
		
		ByteArrayOutputStream baos = new ByteArrayOutputStream();
		Result result = new StreamResult(baos);
		
		try {
			TransformerFactory cybertron = TransformerFactory.newInstance();
			Transformer optimus = cybertron.newTransformer(xsl);
			optimus = Helpers.setToolkitParameters(optimus);
			optimus.transform(xmlFile, result);
		}
		catch(TransformerException transEx) {
			out.println(Helpers.redirectError(response, "Transformation error: " + transEx.getMessage()));
			return;
		}
		catch (Exception e) {
			out.println(Helpers.redirectError(response, "Generic Exception " + e + "<br />"));
			return;
		}
		
		xslOutputArray[i] = baos.toString();
		
	}
	
%>