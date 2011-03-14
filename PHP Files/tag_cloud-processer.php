<?php
	
include_once("globalvars.php");

// Define an array of XSL files and one for the resulting output
// Each section will be assigned to an element in the xslOutputArray, at the same index as its corresponging xsl file
//////////////////////////////////////////////////////////////////////
	$xslArray = Array();
	$xslOutputArray = Array();
	$xslArray[0] = "tag_cloud_head.xsl";
	$xslArray[1] = "tag_cloud_body.xsl";
//////////////////////////////////////////////////////////////////////
// End section
	
// Create (empty) XML doc - set it to null first to avoid nasty issues with the page being loaded twice in quick succession
	$xml = null;
	$xml = new DOMDocument;

// Check that the supposed record has a document element (ie the record exists)
    $xml->loadXML($_SESSION['topCatsList']);
	$rootelement = $xml->documentElement;
	$counts = $xml->getElementsByTagName("occurence");
    foreach ($counts as $count) {
        $totalArray[] = $count->nodeValue;
    }
    $total = array_sum($totalArray);
    foreach ($counts as $count) {
        $logCount = $xml->createAttribute("logCount");
        $logCount->value = (0 < $count->nodeValue) ?  2 * log10($count->nodeValue) / log10($total) : $count->nodeValue;
        $count->appendChild($logCount);
    }
	
	
// Option to save results (for bug tracking)
//	$xml->save("C:\\Temp\\newphp.xml");
//	$xml->load("C:\\Temp\\newphp.xml");
	
	
// For each item in the xslArray, perform a transform on the XML doc using that item
	for ($i=0; $i<count($xslArray); $i++) {
		
		// Create xsl transform from xsl file
		$xsl = new DOMDocument;
		$xsl->load(xslRootPath.$xslArray[$i]);
		
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