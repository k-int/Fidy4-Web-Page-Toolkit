<%@ page import="java.util.*, java.text.*, java.net.*, java.io.*, java.lang.*, javax.xml.transform.*, org.w3c.dom.*, org.xml.sax.*, javax.xml.parsers.*, javax.xml.transform.stream.*, javax.xml.transform.dom.*" %>

<%@ include file="globalvars.jsp" %>

<%

	System.gc();

    // If "subcatSelect" is not present in the query string, it means the main Search button was pressed, and results should be passed to the Results page
    if (null != request.getParameter("target") && request.getParameter("target").equals("Search")) {
        response.sendRedirect("results.jsp?" + request.getQueryString());
    }

	// Define variables
    String vocabPath = Helpers.root + "/sru/xml/default?apikey=" + Helpers.apikey + "&version=1.1&operation=searchRetrieve&query=*&maximumRecords=1"
                     + "&x-kint-facet=true"
                     + "&x-kint-facet.field=dc.subject"
                     + "&x-kint-facet.field=flags"
                     + "&x-kint-facet.field=immediate_vacancies_s"
                     + "&x-kint-facet.field=referral_criteria_s"
                     + "&x-kint-facet.field=mode_of_access_s"
                     + "&x-kint-facet.field=language_spoken_s"
                     + "&x-kint-facet.mincount=1";

	// Define an array of XSL files and one for the resulting output
	// Each section will be assigned to an element in the xslOutputArray, at the same index as its corresponging xsl file
	//////////////////////////////////////////////////////////////////////
	int numberOfParts = 2;
	String[] xslArray = new String[numberOfParts];
	String[] xslOutputArray = new String[numberOfParts];
	xslArray[0] = "advanced_search_head.xsl";
	xslArray[1] = "advanced_search_body.xsl";
	//////////////////////////////////////////////////////////////////////
	// End section
	

	// Create a factory and builder
	DocumentBuilder builder = DocumentBuilderFactory.newInstance().newDocumentBuilder();
	// Parse the XML data with the builder
    Document xmlDoc = null;

    try {
        ByteArrayInputStream bais = new ByteArrayInputStream(Helpers.ReadFile(vocabPath).getBytes());
	    xmlDoc = builder.parse(bais);
	    Element rootElement = xmlDoc.getDocumentElement();

        // Retrieve all query string elements to populate the form
	    Element echo = xmlDoc.createElement("echoedData");
        Element queryString = xmlDoc.createElement("queryString");
        Enumeration enumeration = request.getParameterNames();
        while (enumeration.hasMoreElements()) {
            String thing = enumeration.nextElement().toString();
            queryString.setAttribute(thing, request.getParameter(thing));
        }
	    rootElement.appendChild(echo);
	    echo.appendChild(queryString);

    	
        // Create a node in the original doc to hold list data
        Element vocabData = xmlDoc.createElement("controlledListData");
        // Create array of codes for controlled list data
        String[] lists = {"fullCatsList", "referralList", "accessChannelsList", "langList"};
        // Load controlled list data to construct lists of filters
        for (int i=0; i<lists.length; i++) {
            Document vocab = null;
            // Load the vocabulary into a new document
            try {
                ByteArrayInputStream vocabBais = new ByteArrayInputStream(application.getAttribute(lists[i]).toString().getBytes());
	            vocab = builder.parse(vocabBais);
                // Create a child node for this particular list
                Element listData = xmlDoc.createElement(lists[i]);
                // add data
                Element vocabTree = vocab.getDocumentElement();
                listData.appendChild(xmlDoc.importNode(vocabTree, true));
                vocabData.appendChild(listData);
            } catch (Exception e) {
                 out.println("Cannot load " + lists[i] + " - " + e + "<br />");
            }
        }
	    rootElement.appendChild(vocabData);
    }
    catch (Exception e) {
		out.println(Helpers.redirectError(response, "Generic Exception " + e + "<br />"));
		return;
    }

	
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
            optimus.setOutputProperty(OutputKeys.METHOD, "html");
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
