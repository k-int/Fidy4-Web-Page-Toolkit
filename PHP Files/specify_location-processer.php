<?php
	
    include_once("globalvars.php");

	// Define and assign values to relevant variables
	// Comment out (or delete) these lines if you are using included method, and define these variables in your containing ASP page
	//////////////////////////////////////////////////////////////////////////
	$absFullQuery = $_SERVER['QUERY_STRING'];
	$absCat = isset($_GET['category']) ? $_GET['category'] : "";
	//////////////////////////////////////////////////////////////////////////
	// End section
	

    // Define an array of XSL files and one for the resulting output
    // Each section will be assigned to an element in the xslOutputArray, at the same index as its corresponging xsl file
    ///////////////////////////////////////////////////////////////////////////
	$xslArray = Array();
	$xslOutputArray = Array();
	$xslArray[0] = "specify_location_head.xsl";
	$xslArray[1] = "specify_location_body.xsl";
    ///////////////////////////////////////////////////////////////////////////
    // End section
    	
    	
// Create (empty) XML doc - set it to null first to avoid nasty issues with the page being loaded twice in quick succession
	$xml = null;
	$xml = new DOMDocument;
    $xml->loadXML($_SESSION['topCatsList']);

    // Check that the supposed record has a document element (ie the record exists)
    $rootelement = $xml->firstChild;
    if (0 < strlen($rootelement->nodeValue)) {
		// Create the nodes
		$echo = $xml->createElement("echoedData");
		$queryString = $xml->createElement("queryString");
		$category = $xml->createAttribute("category");
				
		// Add data
		$queryString->nodeValue = $absFullQuery;
		$category->value = "";
		if ("" != $absCat) {
			$category->value = $absCat;
		}
		
		// add to xml
		$queryString->appendChild($category);
		$echo->appendChild($queryString);
		$rootelement->appendChild($echo);
    } else {
	    redirect_error();
    }
    	

    // Option to save/load results (for bug tracking)
    //	$xml->save("C:\\Temp\\newphp.xml");
    //	$xml->load("C:\\Temp\\newphp.xml");
    	
    	
    // For each item in the xslArray, perform a transform on the XML doc using that item
	for ($i=0; $i<count($xslArray); $i++) {
		
		// Create xsl transform from xsl file
		$xsl = new DOMDocument;
		$xsl->load(xslRootPath . $xslArray[$i]);
		
		// Configure the transformer
		$proc = new XSLTProcessor;
		$proc->importStyleSheet($xsl); // attach the xsl rules
		
		// Set the output
		$doc = new DOMDocument;
		
		// Combine the docs to create output
		$doc = $proc->transformToDoc($xml);
		
		// Write the output to relevant array element
		$xslOutputArray[$i] = $doc->saveHTML();
	}
	
?>
