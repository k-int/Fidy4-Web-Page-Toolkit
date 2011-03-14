<?php
	
    // R07 detail view tool start

    // Define variables
    include_once("globalvars.php");

	// Define and assign values from query string to relevant variables
    ///////////////////////////////////////////////////////////////////////////
	$absFullQuery = htmlspecialchars($_SERVER['QUERY_STRING']);
	$absRecordType = isset($_GET['recordType']) ? $_GET['recordType'] : "" ;
	$absRecordID = isset($_GET['recordID']) ? $_GET['recordID'] : "" ;

    // R08 tab view tool start
	$absView = isset($_GET['view']) ? $_GET['view'] : "" ;
    // R08 tab view tool end

    // F10 See Also tool start
	$absChosenCategory = isset($_GET['category']) ? $_GET['category'] : "" ;
    // F10 See Also tool end

	$absDisplayType = isset($_GET['displayType']) ? $_GET['displayType'] : "" ;
    ///////////////////////////////////////////////////////////////////////////
    // End section


    // Define two arrays of XSL files (one for ECD records, one for FSD records) and one for the resulting output
    // Each section will be assigned to an element in the xslOutputArray, at the same index as its corresponging xsl file
    //////////////////////////////////////////////////////////////////////
	$xslECDArray = Array();
	$xslFSDArray = Array();
	$xslOutputArray = Array();
	$xslECDArray[] = "details-ecd_head.xsl";
	$xslECDArray[] = "details-ecd_body.xsl";
	$xslFSDArray[] = "details-fsd_head.xsl";
    $xslFSDArray[] = "details-fsd_body.xsl";
    //////////////////////////////////////////////////////////////////////
    // End section
	
    // Set the appropriate url to the PKHD aggregator based on recordType
	if ("ECD" == $absRecordType) {
		$query = "/dpp/resource/" . $absRecordID . "/stream/ECD?apikey=" . apikey;
	} else if ("FSD" == $absRecordType) {
		$query = "/dpp/resource/" . $absRecordID . "/stream/FSD?apikey=" . apikey;
	} else {
        // If recordType is neither ECD nor FSD, there has been a problem - direct user to custom error page
        redirect_error();
	}
	
    // Load data into XML document
	$fetchRecord = root . $query;
    // Create (empty) XML doc - set it to null first to avoid nasty issues with the page being loaded twice in quick succession
	$xml = null;
	$xml = new DOMDocument;
	$xml->load($fetchRecord);
	
	$rootelement = $xml->documentElement;
	// Check that the supposed record has a document element (ie the record exists)
	if (0 < strlen($rootelement->nodeValue)) {
		
	    // Create the nodes to be added to the XML
		$echo = $xml->createElement("echoedData");
		
		$queryString = $xml->createElement("queryString");
		$recordID = $xml->createAttribute("recordID");
		$recordType = $xml->createAttribute("recordType");

    // R08 tab view tool start
		$view = $xml->createAttribute("view");
    // R08 tab view tool end
		
		$displayType = $xml->createElement("displayType");
		
		
	    // Populate nodes
		$queryString->nodeValue = $absFullQuery;
		
		$recordID->value = "5";
		if ("" != $absRecordID) {
			$recordID->value = $absRecordID;
		}
		$recordType->value = "ECD";
		if ("" != $absRecordType) {
			$recordType->value = $absRecordType;
		}
    // R08 tab view tool start
		$view->value = "1";
		if ("" != $absView) {
			$view->value = $absView;
		}
    // R08 tab view tool end
		
		$displayType->nodeValue = $absDisplayType;
		
		// and add them to the xml
		$queryString->appendChild($recordID);
		$queryString->appendChild($recordType);

    // R08 tab view tool start
		$queryString->appendChild($view);
    // R08 tab view tool end

		$echo->appendChild($queryString);
		$echo->appendChild($displayType);
		$rootelement->appendChild($echo);
		
		
		// Build the SRU required to fetch the attribution data
		$solrAttributionQuery = root . "/sru/xml/default?version=1.2&operation=searchRetrieve&apikey=" . apikey . "&maximumRecords=1&startRecord=1&query=InternalId=" .  $absRecordID;
		
		// Load the category list (to calculate parent categories) into a new XML document
      $attribution = new DOMDocument();
	   // Create a node in the original doc to hold list data
	   $attributionData = $xml->createElement("attributionData");
      $attribution->load($solrAttributionQuery);
        
      // Create a node in the original doc to hold data
      $attributionDataList = $xml->createElement("attributionDataList");
        		
      // add data
      $attributionTree = $attribution->documentElement;
      $attributionDataList->appendChild($xml->importNode($attributionTree, true));
      $attributionData->appendChild($attributionDataList);
		$rootelement->appendChild($attributionData);
		
		
		// Load the category list (to calculate parent categories) into a new XML document
        $vocab = new DOMDocument();
	    // Create a node in the original doc to hold list data
	    $vocabData = $xml->createElement("controlledListData");
        $vocab->loadXML($_SESSION['fullCatsList']);
        
        // Create a node in the original doc to hold data
        $listData = $xml->createElement("catsList");
        		
        // add data
        $vocabTree = $vocab->documentElement;
        $listData->appendChild($xml->importNode($vocabTree, true));
        $vocabData->appendChild($listData);
		$rootelement->appendChild($vocabData);
		

		// Obtain the geocoded location data from the SOLR record
		// Load the solr result (which contains lat/lng data) into a new XML document
		$solrQuery = "/dpp/resource/" . $absRecordID . "/stream/solr?apikey=" . apikey;
        $locDoc = new DOMDocument();
        $locDoc->load(root . $solrQuery);
		$list = $locDoc->getElementsByTagName("field");

		// Create the nodes
		$authority = $xml->createElement("authority");
		$homebase = $xml->createElement("centrePoint");
		$homebaseCoordsLat = $xml->createAttribute("lat");
		$homebaseCoordsLng = $xml->createAttribute("lng");

		// Add data from solr result (by checking each element in solr result to see if it is lat or lng)
        $i=0;
		foreach ($list as $element) {
			// If the element has the 'lat' attribute then it contains the latitude
			if ("lat" == $element->getAttribute("name")) {
				$homebaseCoordsLat->value = $element->nodeValue;
			}
			// If the element has the 'lng' attribute then it contains the longitude
			if ("lng" == $element->getAttribute("name")) {
				$homebaseCoordsLng->value = $element->nodeValue;
			}
			// If the element has the 'authority' attribute then it contains the authorioty name (used for checking if this is a Nationwide service)
			if ("authority" == $element->getAttribute("name")) {
				$authority->nodeValue = $element->nodeValue;
			}
			// If the element has the 'dc.subject.orig_s' attribute then it contains the ORIGINAL subjects the record was tagged with
			if ("dc.subject.orig_s" == $element->getAttribute("name")) {
                $categories = (8 > $i && $absChosenCategory != $element->nodeValue) ? "%20or%20" . $element->nodeValue : $categories;
                $i++;
			}
        }
		
		// and add them to the xml
		$homebase->appendChild($homebaseCoordsLat);
		$homebase->appendChild($homebaseCoordsLng);
		$echo->appendChild($authority);
		$echo->appendChild($homebase);
		// End geocoding
		
    // F10 See Also tool start
        // Create a second SRU query, searching for records which share a category (barring the one used to find this record)
        // Note - this only operates on the ORIGINAL subjects the record was tagged with, not any higher-level ones or associated ones
        if ("" != $absChosenCategory) {
            $categories = substr($categories, 8);
            if ("" != $categories) {
                $xmlSeeAlso = null;
                $xmlSeeAlso = new DOMDocument;
                $sruSeeAlso = root . "/sru/xml/default?version=1.2&apikey=" . apikey . "&operation=searchRetrieve&query=Subject%3D(%22" . $categories . "%22)%20not%20InternalId%3D" . $absRecordID . "%20and%20Authority%3D%22NFSDPortal%22&sortKeys=score&maximumRecords=5&startRecord=1";
                $xmlSeeAlso->load($sruSeeAlso);
                // echo $sruSeeAlso;
                if (0 < $xmlSeeAlso->getElementsByTagName("numberOfRecords")->item(0)->nodeValue) {
                    $resultsTree = $xmlSeeAlso->getElementsByTagName("records")->item(0);
                    $echo->appendChild($xml->importNode($resultsTree, true));
    		        $category = $xml->createAttribute("category");
                    $category->value = $absChosenCategory;
		            $queryString->appendChild($category);
                }
            }
        }
    // F10 See Also tool end



	} else {
        // If the main XML document does not have a root element, there has been a problem - direct user to custom error page
		redirect_error();
	}
	
	// Option to save/load results (for bug tracking)
	// $xml->save("C:\\Temp\\newphp.xml");
	// $xml->load("C:\\Temp\\newphp.xml");
	
	for ($i=0; $i<count($xslECDArray); $i++) {

        // Load appropriate XSL file for ECD or FSD
		$xsl = new DOMDocument;
		if ("ECD" == $absRecordType) {
			$xsl->load(xslRootPath . $xslECDArray[$i]);
		}
		if ("FSD" == $absRecordType) {
			$xsl->load(xslRootPath . $xslFSDArray[$i]);
	    }
		
		// Configure the transformer
		$proc = new XSLTProcessor;
		$proc->importStyleSheet($xsl); // attach the xsl rules
		
		// Set the output
		$doc = new DOMDocument;
		
		// Combine the docs to create output
		$doc = $proc->transformToDoc($xml);
		
		// Save result to relevant position in xslOutputArray
		$xslOutputArray[$i] = $doc->saveHTML();
	}

	// R07 detail view tool end

?>
