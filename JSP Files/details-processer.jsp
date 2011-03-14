<%@ page import="java.util.*, java.text.*, java.net.*, java.io.*, java.lang.*, javax.xml.transform.*, org.w3c.dom.*, org.xml.sax.*, javax.xml.parsers.*, javax.xml.transform.stream.*, javax.xml.transform.dom.*" %>

<%@ include file="globalvars.jsp" %>

<%
	
	// Define variables
	String query = new String();

	// Define and assign values to relevant variables
	//////////////////////////////////////////////////////////////////////////
    String absRecordType = (null != request.getParameter("recordType") && false == request.getParameter("recordType").equals("")) ? request.getParameter("recordType") : "";
    Integer absRecordID = (null != request.getParameter("recordID") && false == request.getParameter("recordID").equals("")) ? Integer.parseInt(request.getParameter("recordID")) : 0;
	String absFullQuery = request.getQueryString();

    // R08 tab view tool start
	String absView = request.getParameter("view");
    // R08 tab view tool end

    // F10 See Also tool start
    String absChosenCategory = (null != request.getParameter("category") && false == request.getParameter("category").equals("")) ? request.getParameter("category") : "";
    // F10 See Also tool end

    String absDisplayType = request.getParameter("displayType");
	//////////////////////////////////////////////////////////////////////////
	// End section
	
	
	// Define two arrays of XSL files (one for ECD records, one for FSD records) and one for the resulting output
	// Each section will be assigned to an element in the xslOutputArray, at the same index as its corresponging xsl file
	//////////////////////////////////////////////////////////////////////
	int numberOfParts = 2;
	String[] xslECDArray = new String[numberOfParts];
	String[] xslFSDArray = new String[numberOfParts];
	String[] xslOutputArray = new String[numberOfParts];
	xslECDArray[0] = "details-ecd_head.xsl";
	xslECDArray[1] = "details-ecd_body.xsl";
	xslFSDArray[0] = "details-fsd_head.xsl";
	xslFSDArray[1] = "details-fsd_body.xsl";
	//////////////////////////////////////////////////////////////////////
	// End section
	
	if (0 < absRecordID.compareTo(0)) {
	    if (absRecordType.equals("ECD")) {
		    query = "/dpp/resource/" + absRecordID + "/stream/ECD?apikey=" + Helpers.apikey;
	    } else if (absRecordType.equals("FSD")) {
		    query = "/dpp/resource/" + absRecordID + "/stream/FSD?apikey=" + Helpers.apikey;
	    } else {
			out.println(Helpers.redirectError(response, "Record type not recognised<br />"));
			return;
	    }
    } else {
		out.println(Helpers.redirectError(response, "Record ID missing<br />"));
		return;
    }

	String fetchRecord = Helpers.root + query;
	
	// Create a factory and builder
	DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
    factory.setNamespaceAware(true);
	DocumentBuilder builder = factory.newDocumentBuilder();
	// Parse the XML data with the builder
    Document xmlDoc = null;
	Element rootElement = null;

    try {
	    xmlDoc = builder.parse(fetchRecord);
	    rootElement = xmlDoc.getDocumentElement();
    }
	catch (Exception e) {
		out.println(Helpers.redirectError(response, "Generic Exception " + e + "<br />"));
		return;
    }

    Element echo = xmlDoc.createElement("echoedData");
    echo.setAttributeNS("http://www.w3.org/2000/xmlns/", "xmlns", "");
    rootElement.appendChild(echo);
	
    // Create the nodes
    Element queryString = xmlDoc.createElement("queryString");
    queryString.setAttribute("recordID", absRecordID.toString());
    queryString.setAttribute("recordType", absRecordType);

    // R08 tab view tool start
    String viewAtt = "1";
    if (null != absView) {
	    viewAtt = absView;
    }
    queryString.setAttribute("view", viewAtt);
    // R08 tab view tool end

    Text queryStringText = xmlDoc.createTextNode(absFullQuery);
    queryString.setNodeValue(absFullQuery);
    queryString.appendChild(queryStringText);
    echo.appendChild(queryString);
	
    Element displayType = xmlDoc.createElement("displayType");
    Text displayTypeText = xmlDoc.createTextNode("");
    if (null != absDisplayType) {
	    displayTypeText.setNodeValue(absDisplayType);
    } else {
	    displayTypeText.setNodeValue("");
    }
    displayType.appendChild(displayTypeText);
    echo.appendChild(displayType);
	
    // Attribution data
    String solrAttributionQuery = "/sru/xml/default?version=1.2&operation=searchRetrieve&apikey=" + Helpers.apikey + "&maximumRecords=1&startRecord=1&query=InternalId=" + absRecordID;
    // Create a node in the original doc to hold attribution data
  
    //Obtain the full categories list
    Document attribution = null;
    // Load the attribution data into a new document
    try {
        attribution = builder.parse(Helpers.root + solrAttributionQuery);     
        // Create a node in the original doc to hold data
        Element attributionData = xmlDoc.createElement("attributionData");
        attributionData.setAttributeNS("http://www.w3.org/2000/xmlns/", "xmlns", "");
        Element attributionDataList = xmlDoc.createElement("attributionDataList");
        attributionDataList.setAttributeNS("http://www.w3.org/2000/xmlns/", "xmlns", "");
        // add data
        Element attributionTree = attribution.getDocumentElement(); 
        attributionDataList.appendChild(xmlDoc.importNode(attributionTree, true));
        attributionData.appendChild(attributionDataList);
        rootElement.appendChild(attributionData);
    } catch (Exception e) {
        // Do nothing - just don't load the vocab list..
    }
    
      
    // End categories listing
    
    
    // Categories listing
    // Create a node in the original doc to hold list data
    Element vocabData = xmlDoc.createElement("controlledListData");
    //Obtain the full categories list
    Document vocab = null;
    // Load the vocabulary into a new document
    try {
        ByteArrayInputStream bais = new ByteArrayInputStream(application.getAttribute("fullCatsList").toString().getBytes());
        vocab = builder.parse(bais);
        // Create a node in the original doc to hold data
        Element listData = xmlDoc.createElement("catsList");
        // add data
        Element vocabTree = vocab.getDocumentElement();
        listData.appendChild(xmlDoc.importNode(vocabTree, true));
        vocabData.appendChild(listData);
    } catch (Exception e) {
        // Do nothing - just don't load the vocab list..
    }
    rootElement.appendChild(vocabData);
    // End categories listing

	
    // Obtain the geocoded location data from the SOLR record
    String solrQuery = "/dpp/resource/" + absRecordID + "/stream/solr?apikey=" + Helpers.apikey;
    Document locDoc = builder.parse(Helpers.root + solrQuery);
    NodeList list = locDoc.getElementsByTagName("field");
	
    String lat = new String();
    String lng = new String();
	
    for (int i=0; i<list.getLength(); i++) {
	    if (list.item(i).getAttributes().item(0).getNodeValue().equals("lat")) {
		    lat = list.item(i).getFirstChild().getNodeValue();
	    }
	    if (list.item(i).getAttributes().item(0).getNodeValue().equals("lng")) {
		    lng = list.item(i).getFirstChild().getNodeValue();
	    }
    }
	
    Element homebase = xmlDoc.createElement("centrePoint");
    homebase.setAttribute("lat", lat);
    homebase.setAttribute("lng", lng);
	
    echo.appendChild(homebase);
	
    // End geocoding
	
    // F10 See Also tool start
        // Create a second SRU query, searching for records which share a category (barring the one used to find this record)
        // Note - this only operates on the ORIGINAL subjects the record is tagged with, not any higher-level ones or associated ones
        if (false == absChosenCategory.equals("")) {
            String cats = new String();
            int j=0;
            for (int i=0; i<list.getLength(); i++) {
                if (null != list.item(i).getAttributes().item(0).getNodeValue() && list.item(i).getAttributes().item(0).getNodeValue().equals("dc.subject.orig_s") && 8 > j) {
                    cats = (0 < cats.length()) ? cats + "%20or%20" + list.item(i).getFirstChild().getNodeValue() : list.item(i).getFirstChild().getNodeValue();
                    j++;
                }
            }
            if (0 < cats.length()) {
                String sruSeeAlso = "/sru/xml/default?version=1.2&apikey=" + Helpers.apikey + "&operation=searchRetrieve&query=Subject%3D(%22" + cats + "%22)%20not%20InternalId%3D" + absRecordID + "%20and%20Authority%3D%22NFSDPortal%22&sortKeys=score&maximumRecords=5&startRecord=1";
                Document xmlSeeAlso = builder.parse(Helpers.root + sruSeeAlso);
                // out.println(Helpers.root + sruSeeAlso + "<br />");
                if (0 < Integer.parseInt(xmlSeeAlso.getElementsByTagName("srw:numberOfRecords").item(0).getFirstChild().getNodeValue())) {
                    Node resultsTree = xmlSeeAlso.getElementsByTagName("srw:records").item(0);
                    echo.setAttribute("xmlns:srw", "http://www.loc.gov/zing/srw/");
                    echo.appendChild(xmlDoc.importNode(resultsTree, true));
                    queryString.setAttribute("category", absChosenCategory);
                }
            }
        }
    // F10 See Also tool end
	
	
	// Output the full xmlDoc to a string, which can then be read as an input
	// Create transformer
	TransformerFactory tranFactory = TransformerFactory.newInstance();
	Transformer aTransformer = tranFactory.newTransformer();
	// Set teh xmlDoc as the source
	Source src = new DOMSource(xmlDoc);
	// Create a ByteArrayOutputStream to hold the result of the transform
	ByteArrayOutputStream tempDoc = new ByteArrayOutputStream();
	Result dest = new StreamResult(tempDoc);
	aTransformer.transform(src, dest);

	// Optional alternative to save results for bug tracking
	// Result dest2 = new StreamResult(new File("C:\\Temp\\newjava.xml"));  
	// aTransformer.transform(src, dest2);

	xmlDoc = null;
	
	
	for (int i=0; i<numberOfParts; i++) {
		
	    // Take the tempDoc created earlier, convert it to string and set it as the source
	    StringReader xmlReader = new StringReader( tempDoc.toString("utf-8") );
	    Source xmlFile = new StreamSource( xmlReader ) ;
    	
		String xslPath = new String();
		if (absRecordType.equals("ECD")) {
			xslPath = getServletContext().getRealPath(Helpers.xslRootPath + xslECDArray[i]);
		} else if (absRecordType.equals("FSD")) {
			xslPath = getServletContext().getRealPath(Helpers.xslRootPath + xslFSDArray[i]);
		} else {
			out.println(Helpers.redirectError(response, "Record type not recognised<br />"));
			return;
		}
		
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
