<?php
	
include_once("globalvars.php");

	// Define and assign values to relevant variables
	// Comment out (or delete) these lines if you are using included method, and define these variables in your containing ASP page
	//////////////////////////////////////////////////////////////////////////
	$absFullQuery = $_SERVER['QUERY_STRING'];
	$absLetter = isset($_GET['ltr']) ? $_GET['ltr'] : "";
	//////////////////////////////////////////////////////////////////////////
	// End section
	
	// Define an array of XSL files and one for the resulting output
	// Each section will be assigned to an element in the xslOutputArray, at the same index as its corresponging xsl file
	// You may find it easier to completely remove these and define them in the containing server-side script (as with the section above)
	// (For if you are integrating templates in various places in a page - ignore these lines if you are using the templates as-is
	//////////////////////////////////////////////////////////////////////
	$xslArray = Array();
	$xslOutputArray = Array();
	$xslArray[0] = "subject_index_head.xsl";
	$xslArray[1] = "subject_index_body.xsl";
	//////////////////////////////////////////////////////////////////////
	// End section
	
// Create (empty) XML doc - set it to null first to avoid nasty issues with the page being loaded twice in quick succession
	$xml = null;
	$xml = new DOMDocument;
    $xml->loadXML($_SESSION['fullCatsList']);

    // Check that the supposed record has a document element (ie the record exists)
    if ($rootelement = $xml->documentElement) {

	    // Create the nodes
	    $echo = $xml->createElement("echoedData");
	    $queryString = $xml->createElement("queryString");
	    $letter = $xml->createAttribute("letter");
    			
	    // add data
	    $queryString->nodeValue = $absFullQuery;
	    $letter->value = "a";
	    if ("" != $absLetter) {
		    $letter->value = $absLetter;
	    }
    	
	    // and add them to the xml
	    $queryString->appendChild($letter);
	    $echo->appendChild($queryString);
	    $rootelement->appendChild($echo);
    } else {
        redirect_error();
    }
	
	// Option to save results (for bug tracking)
	// $xml->save("C:\\Temp\\newphp.xml");
	
	for ($i=0; $i<count($xslArray); $i++) {
		
		$xsl = new DOMDocument;
		$xsl->load(xslRootPath . $xslArray[$i]);
		
		// Configure the transformer
		$proc = new XSLTProcessor;
		$proc->importStyleSheet($xsl); // attach the xsl rules
		
		$doc = new DOMDocument;
		$doc = $proc->transformToDoc($xml);
		
		$xslOutputArray[$i] = $doc->saveHTML();
	}
	
?>
