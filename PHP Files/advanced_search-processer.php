<?php
	
include_once("globalvars.php");


    // If "subcatSelect" is not present in the query string, it means the main Search button was pressed, and results should be passed to the Results page
    if (isset($_GET['target']) && "Search" == $_GET['target']) {
        header("Location: http://".host.rtrim(dirname($_SERVER['PHP_SELF']), '/\\')."/results.php?".$_SERVER['QUERY_STRING']);
    }

// Define variables
    $vocabFilePath = root . "/sru/xml/default?apikey=" . apikey . "&version=1.1&operation=searchRetrieve&query=*&maximumRecords=1" 
                         . "&x-kint-facet=true" 
                         . "&x-kint-facet.field=dc.subject" 
                         . "&x-kint-facet.field=referral_criteria_s" 
                         . "&x-kint-facet.field=mode_of_access_s" 
                         . "&x-kint-facet.field=language_spoken_s" 
                         . "&x-kint-facet.mincount=1";

// Define an array of XSL files and one for the resulting output
// Each section will be assigned to an element in the xslOutputArray, at the same index as its corresponging xsl file
///////////////////////////////////////////////////////////////////////////
    $xslArray = Array();
    $xslOutputArray = Array();
    $xslArray[0] = "advanced_search_head.xsl";
    $xslArray[1] = "advanced_search_body.xsl";
///////////////////////////////////////////////////////////////////////////
// End section
	
	
// Create (empty) XML doc - set it to null first to avoid nasty issues with the page being loaded twice in quick succession
	$xml = null;
	$xml = new DOMDocument;
	$xml->load($vocabFilePath);
	
	
// Check that the supposed record has a document element (ie the record exists)
	$rootelement = $xml->documentElement;
	if (0 < strlen($rootelement->nodeValue)) {

	    $echo = $xml->createElement("echoedData");
	    $queryString = $xml->createElement("queryString");
        foreach ($_GET as $thing => $value) {
	        $thingAtt = $xml->createAttribute($thing);
            $thingAtt->value = $value;
            $queryString->appendChild($thingAtt);
        }
	    $echo->appendChild($queryString);
        $rootelement->appendChild($echo);


        // Create array of codes for controlled list data
        $lists = Array("fullCatsList", "referralList", "accessChannelsList", "langList");
        // Load controlled list data to construct lists of filters
		    // Create a node in the original doc to hold list data
		    $vocabData = $xml->createElement("controlledListData");
            // Load the vocabulary into a new document
            foreach ($lists as $title) {
	            $vocab = new DOMDocument;
                $vocab->loadXML($_SESSION[$title]);
                
	            // Create a child node for this particular list
	            $listData = $xml->createElement($title);
    		    		
	            // add data
                $vocabTree = $vocab->documentElement;
                $listData->appendChild($xml->importNode($vocabTree, true));
	            $vocabData->appendChild($listData);
            }
		$rootelement->appendChild($vocabData);
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
