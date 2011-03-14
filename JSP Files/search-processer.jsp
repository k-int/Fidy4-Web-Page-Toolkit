<%@ page import="java.util.*, java.text.*, java.net.*, java.io.*, java.lang.*, javax.xml.transform.*, org.w3c.dom.*, org.xml.sax.*, javax.xml.parsers.*, javax.xml.transform.stream.*, javax.xml.transform.dom.*" %>

<%@ include file="globalvars.jsp" %>

<%

	System.gc();
	
	// Define an array of XSL files and one for the resulting output
	// Each section will be assigned to an element in the xslOutputArray, at the same index as its corresponging xsl file
	//////////////////////////////////////////////////////////////////////
	int numberOfParts = 2;
	String[] xslArray = new String[numberOfParts];
	String[] xslOutputArray = new String[numberOfParts];
	xslArray[0] = "search_head.xsl";
	xslArray[1] = "search_body.xsl";
	//////////////////////////////////////////////////////////////////////
	// End section
	
	Source xmlFile = new StreamSource() ;

	for (int i=0; i<numberOfParts; i++) {
		
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
