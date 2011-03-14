<%@ page import="java.util.*, java.text.*, java.net.*, java.io.*, java.lang.*, javax.xml.transform.*, org.w3c.dom.*, org.xml.sax.*, javax.xml.parsers.*, javax.xml.transform.stream.*, javax.xml.transform.dom.*, javax.xml.xpath.*" %>

<%@ include file="globalvars.jsp" %>

<%

	System.gc();

	// Define and assign values to relevant variables
	//////////////////////////////////////////////////////////////////////////
	String absFullQuery = request.getQueryString();
	String absLetter = (null != request.getParameter("ltr")) ? request.getParameter("ltr") : "a";

	// Define an array of XSL files and one for the resulting output
	// Each section will be assigned to an element in the xslOutputArray, at the same index as its corresponging xsl file
	//////////////////////////////////////////////////////////////////////
	int numberOfParts = 2;
	String[] xslArray = new String[numberOfParts];
	String[] xslOutputArray = new String[numberOfParts];
	xslArray[0] = "subject_index_head.xsl";
	xslArray[1] = "subject_index_body.xsl";
	//////////////////////////////////////////////////////////////////////
	// End section
	
	// Create a factory and builder
	DocumentBuilder builder = DocumentBuilderFactory.newInstance().newDocumentBuilder();
	// Parse the XML data with the builder
	Document xmlDoc = null;

    try {
	    ByteArrayInputStream bais = new ByteArrayInputStream(application.getAttribute("fullCatsList").toString().getBytes());
	    xmlDoc = builder.parse(bais);
	    // LC: Added setXmlStandalone below to suppress the adding of "standalone="no"" to the XML declaration.
	    // This makes the XML fetched from the aggregator match the other toolkits, didn't help
	    xmlDoc.setXmlStandalone(true);
	    Element rootElement = xmlDoc.getDocumentElement();
    	
	    Element echo = xmlDoc.createElement("echoedData");
	    echo.setAttributeNS("http://www.w3.org/2000/xmlns/", "xmlns", "");
	    rootElement.appendChild(echo);
    	
	    // Create the nodes
	    Element queryString = xmlDoc.createElement("queryString");
	    String letter = "a";
	    if (null != absLetter && true != absLetter.equals("")) {
		    letter = absLetter;			   
	    }
	    
	    if(absFullQuery != null)
	    {
	    	    // LC: Add some inner text to the queryString node, this matches how the other toolkits added this node, but the XLS doesn't use the value anyway
	    	   // and so as expected didn't fix the problem
	    	    Text queryStringText = xmlDoc.createTextNode(absFullQuery);
	    	    queryString.appendChild(queryStringText);	    	    
	    }
	    	    	    
	    queryString.setAttribute("letter", letter);	 
	    echo.appendChild(queryString);	    

    }
    catch (FileNotFoundException f) {
		out.println(Helpers.redirectError(response, "FileNotFoundException " + f + "<br />"));
		return;
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
	//Result dest2 = new StreamResult(new File("C:\\Temp\\newjava.xml"));  
	// aTransformer.transform(src, dest2);
	

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
