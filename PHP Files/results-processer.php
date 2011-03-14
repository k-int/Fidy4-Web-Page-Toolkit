<?php
	
    // Define variables
    include_once("globalvars.php");

	// Define and assign values to relevant variables
	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	$absFullQuery = htmlspecialchars(replace_accents($_SERVER['QUERY_STRING']));
	
	//S01: simple search tool start
	// Freetext - a simple string query, like you would put in Google (e.g. "Schools Basingstoke")
	$absFreetext = isset($_GET['freetext']) ? $_GET['freetext'] : "";
	//S01: simple search tool end
	
	//S02:  category tool start
	// Category - the code for the category a service is in (e.g. "001-8")
	$absCat = isset($_GET['category']) ? $_GET['category'] : "";
	// Subcategory - the code for the sub-category a service is in (e.g. "001-8e")
	$absSubCat = isset($_GET['subcategory']) ? $_GET['subcategory'] : "";
	// Sub-subcategory - the code for the sub-subcategory a service is in (e.g. "001-8ef")
	$absSubSubCat = isset($_GET['subsubcategory']) ? $_GET['subsubcategory'] : "";
	//S02:  category tool end

	//S09:  service title search tool (advance search) start
	// Title - the specific title of a service (e.g. "Little Tots Nursery")
	$absTitle = isset($_GET['title']) ? $_GET['title'] : "";
	//S09:  service title search tool (advance search) end

	//S04:  Eligibility Criteria search tool start
	// Eligibility Criteria - freetext suggesting who is eligible for a service (e.g. "out-of-work")
	$absEligibility = isset($_GET['eligibilityCriteria']) ? $_GET['eligibilityCriteria'] : "";
	//S04:  Eligibility Criteria search tool end


	//L01: Location / proximity filter tool start
	// Location - a town, city, area or postcode (either full or just the first part)
	// Valid examples include "London", "Norwich", "Shoreditch", "N11" and "B23 5RS"
	$absLocation = isset($_GET['location']) ? $_GET['location'] : "";

	// Distance - radial limit (in miles) from the centre of the above location.
	// This option must be used in conjunction with Location, as without that it has no point of reference.
	$absDistance = (isset($_GET['filterDist']) && is_numeric($_GET['filterDist'])) ? $_GET['filterDist'] : "";

	// National - boolean option to exclude Nationwide services from the results.
	// If this is set to anything other than 'off', Nationwide services will be included in the results
	$absNational = isset($_GET['national']) ? $_GET['national'] : "";

	// XNational - Modifies above. If set 'off' it excludes Nationwide services unless National is also set to 'on'
	$absXNational = isset($_GET['xnational']) ? $_GET['xnational'] : "";
	//L01: Location / proximity filter tool end
	

	//F02, F06, F07, F08, F10: filter tools start
	// Filters - comma-separated list of codes (see the fullFilterNames list below) of filters to apply.
	// The list must only use codes defined below, and have no spaces. For example, "wAcc,vacs,yrs1-4"
	$absFilters = isset($_GET['filters']) ? $_GET['filters'] : "";
	//F02, F06, F07, F08, F10: filter tools end

	//R04, R05, R06:  List view, Table view, and Map view tools start
	// View - Valid values "list", "table" or "map", defaults to "list".  Sets which tab is active on results page
	$absView = isset($_GET['view']) ? $_GET['view'] : "list";
	//R04, R05, R06:  List view, Table view, and Map view tools start

	//R01: Results sorting tool start
	// sortBy - Valid values "name", "updated" or (if map enabled) "distance", defaults to "relevance".
	$absSortBy = isset($_GET['sortBy']) ? $_GET['sortBy'] : "relevance";
	//R01: Results sorting tool end

	//R02: results pagination tool start
	// StartPoint - First record on page, defaults to "1".  Used to page through results
	$absStartPoint = (isset($_GET['startPoint']) && is_numeric($_GET['startPoint'])) ? $_GET['startPoint'] : 1;
	//R02: resutls pagination tool end
	
	//R03: Results set sizing tool start
	// PerPage - Results per page, default "10"
	$absPerPage = (isset($_GET['perPage']) && is_numeric($_GET['perPage'])) ? $_GET['perPage'] : 10;
	//R03: Results set sizing tool end
	
	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// End section
	
	
	// Define an array of XSL files and one for the resulting output
	// Each section will be assigned to an element in the xslOutputArray, at the same index as its corresponging xsl file
	//////////////////////////////////////////////////////////////////////
	$xslArray = Array();
	$xslOutputArray = Array();
	$xslArray[] = "results_head.xsl";
	$xslArray[] = "results_body.xsl";
	//////////////////////////////////////////////////////////////////////
	// End section
	
	$queryArray = Array();
    $filtersArray = Array();

	$fullFilterNames = Array();
	
	//F06: Wheelchair access filter tool start
	$fullFilterNames['wAcc'] = "Wheelchair Access";
	//F06: Wheelchair access filter tool end
	
	//F07: Special needs filter tool start
	$fullFilterNames['sNeeds'] = "Caters for Special Needs";
	//F07: Special needs filter tool end 
	
	//F08: Current vacancies filter tool start
	$fullFilterNames['vacs'] = "Current Vacancies";
	//F08: Current vacancies filter tool end
	
	//F10: has school pickup filter tool start
	$fullFilterNames['pickup'] = "School Pickups";
	//F10: has school pickup filter tool end
	
	//F02: Age range filter tool start
	$fullFilterNames['yrs0-1'] = "0-1 year";
	$fullFilterNames['yrs1-4'] = "1-4 years";
	$fullFilterNames['yrs5-10'] = "5-10 years";
	$fullFilterNames['yrs10-18'] = "10-18 years";
	$fullFilterNames['yrs18-25'] = "18-25 years";
	$fullFilterNames['yrs25'] = "25+ years";

	$filterAgeSearches = Array();
	$filterAgeSearches['yrs0-1'] = age_range(0,1);
	$filterAgeSearches['yrs1-4'] = age_range(1,4);
    $filterAgeSearches['yrs5-10'] = age_range(5,10);
	$filterAgeSearches['yrs10-18'] = age_range(10,18);
	$filterAgeSearches['yrs18-25'] = age_range(18,25);
	$filterAgeSearches['yrs25'] = "(AgeRangeMin%3E24%20or%20AgeRangeMax%3E24)";
	//F02: Age range filter tool end

	$filterFlagSearches = Array();
	//F06: Wheelchair access filter tool start
	$filterFlagSearches['wAcc'] = "WheelChairAccess";
	//F06: Wheelchair access filter tool end
	
	//F07: Special needs filter tool start
	$filterFlagSearches['sNeeds'] = "SpecialNeeds";
	//F07: Special needs filter tool end
	
	//F10: has school pickup filter tool start
	$filterFlagSearches['pickup'] = "SchoolPickup";
	//F10: has school pickup filter tool end
	
   // This function creates an SRU String fragment specifying the criteria needed for an age range search between two given ages ($min and $max)
	//F02: Age range filter tool start
    function age_range($min, $max){
        $string = "(".
                        "(AgeRangeMin%3E".($min - 1)."%20and%20AgeRangeMax%3C".($max + 1).")".
                    "%20or%20".
                        "(AgeRangeMin%3C".($min + 1)."%20and%20AgeRangeMax%3E".($max - 1).")".
                    "%20or%20".
                        "(".
                            "(AgeRangeMin%3E".($min - 1)."%20or%20AgeRangeMax%3C".($max + 1).")".
                          "%20and%20".
                            "(AgeRangeMin%3C".($min + 1)."%20or%20AgeRangeMax%3E".($max - 1).")".
                          "%20and%20".
                            "(AgeRangeMin%3C".($max + 1)."%20and%20AgeRangeMax%3E".($min - 1).")".
                        ")".
                   ")";
        return $string;
    }
	//F02: Age range filter tool end

	// This function applies a default "OR" operation to words in the freetext and title queries, unless the words are OR, NOT or AND
    // If there is a quoted string, this is added as an exact match for the access point specified when the function is called
	function add_bools($unbooledString, $accessPoint) {
		$textArray = array();
		$newTextArray = array();
				
		preg_match_all("/[^\s\"]+|\"([^\"]*)\"|'([^']*)'/", $unbooledString, $matches, PREG_PATTERN_ORDER);
		// Add each item matched into an array, surrounded with quotes (this will double-quote quoted strings
		foreach ($matches[0] as $match) {
            if ("and" == strtolower($match) || "or" == strtolower($match) || "not" == strtolower($match)) {
                $textArray[] = $match;
            } else if ((1 < strlen($match) && "*" == substr($match, 0, 1)) || "?" == substr($match, 0, 1)) {
                $tmpstr = str_replace($match, "*", "\*");
                $textArray[] = str_replace($tmpstr, "?", "\?");
            } else {
                // Get the initial keyword being searched for, this needs to be single quoted or double quoted where it contains
                // special characters.
                $textArray[] = "\"".$match."\"";
                end($textArray);
                
                // If this string isn't already double quoted then double quote it if it contains problem characters
              	 if(!beginsWith(current($textArray), "\"\"") || !endsWith (current($textArray), "\"\"")) 
              	 {	   
	                 	if (preg_match("/[^A-Za-z0-9]{1}/", $match) > 0)
	               	{            
              					$textArray[count($textArray) - 1] =  "\"". replace_accents(current($textArray)) ."\"";
                		}
                }           
             }             
		}
		
		$limit = count($textArray) - 1;
	
        if ("and" == strtolower($textArray[0]) || "or" == strtolower($textArray[0]) || "not" == strtolower($textArray[0])) {
		    $newTextArray[0] = "";
        } else if (false !== strpos($textArray[0], "\"\"")) {
            $newTextArray[0] = $accessPoint . " adj (" . strtolower($textArray[0]) . ")";
        } else {
            $newTextArray[0] = strtolower($textArray[0]);
        }

        if (0 < $limit) {
		    for ($i=1; $i<$limit; $i++) {

			    if ("and" == strtolower($textArray[$i]) || "or" == strtolower($textArray[$i]) || "not" == strtolower($textArray[$i])) {
                    if ("and" == strtolower($textArray[$i-1]) || "or" == strtolower($textArray[$i-1]) || "not" == strtolower($textArray[$i-1])) {
                        $newTextArray[$i] = "";
                    } else {
                        $newTextArray[$i] = " ".$textArray[$i];
                    }
                } else if ("and" == strtolower($textArray[$i-1]) || "or" == strtolower($textArray[$i-1]) || "not" == strtolower($textArray[$i-1])) {
				    if (false !== strpos($textArray[$i], "\"\"")) {
                        $newTextArray[$i] = " " . $accessPoint . " adj (" . strtolower($textArray[$i]) . ")";
                    } else {
                        $newTextArray[$i] = " " . $textArray[$i];
                    }
                } else {
				    if (false !== strpos($textArray[$i], "\"\"")) {
                        $newTextArray[$i] = " or " . $accessPoint . " adj (" . strtolower($textArray[$i]) . ")";
                    } else {
                        $newTextArray[$i] =  " or ".$textArray[$i];
                    }
                }

		    } // end for loop

		    if ("and" == strtolower($textArray[$limit]) || "or" == strtolower($textArray[$limit]) || "not" == strtolower($textArray[$limit])) {
                if ("and" == strtolower($textArray[$limit-1]) || "or" == strtolower($textArray[$limit-1]) || "not" == strtolower($textArray[$limit-1])) {
                    $newTextArray[$limit] = "\"" . $textArray[$limit] . "\"";
                } else {
                    $newTextArray[$limit] = "";
                }
            } else if ("and" == strtolower($textArray[$limit-1]) || "or" == strtolower($textArray[$limit-1]) || "not" == strtolower($textArray[$limit-1])) {
			    if (false !== strpos($textArray[$limit], "\"\"")) {
                    $newTextArray[$limit] = " " . $accessPoint . " adj (" . strtolower($textArray[$limit]) . ")";
                } else {
                    $newTextArray[$limit] = " " . $textArray[$limit];
                }
            } else {
			    if (false !== strpos($textArray[$limit], "\"\"")) {
                    $newTextArray[$limit] = " or " . $accessPoint . " adj (" . strtolower($textArray[$limit]) . ")";
                } else {
                    $newTextArray[$limit] =  " or ".$textArray[$limit];
                }
            }
        }

        $returnString = strtolower(implode("", $newTextArray));
        $returnString = str_replace(strtolower($accessPoint), $accessPoint, $returnString);
       
		return rawurlencode(str_replace("\"\"", "\"", $returnString));
	}

	/***********Function ************************
	Name: make_query
	Description: Creates an SRU query from the received url
	Parameters - IN: $useLocation - boolean, default = true. Sets whether to include location search information in query
	Parameters - OUT: none
	Customisable: MODIFY INDICATED SECTIONS ONLY
	Notes: 
	 ********************************************/
    function make_query($useLocation=true) {

        global $absFreetext, $absTitle, $absCat, $absSubCat, $absSubSubCat, $absEligibility, $absLocation, $absDistance, $absFilters, $absNational, $absXNational, $absStartPoint, $absPerPage;
        global $qLocation, $qNational, $filtersArray, $filterFlagSearches, $filterAgeSearches, $absSortBy, $apikey;
        global $host, $four0fourPage, $noResultsPage;

		//S01: simple search tool start
	    if ("" != $absFreetext) {
		    $queryArray[] = "(".add_bools($absFreetext, "cql.serverChoice").")";
	    }
    	//S01: simple search tool end
		
		//S02: category tool start
	    if ("" != $absSubSubCat) {
		    $queryArray[] = "Subject%3D(%22".$absSubSubCat."%22)";
	    } else if ("" != $absSubCat) {
		    $queryArray[] = "Subject%3D(%22".$absSubCat."%22)";
	    } else if ("" != $absCat) {
		    $queryArray[] = "Subject%3D(%22".$absCat."%22)";
	    }
    	//S02: category tool end
    	
		//S04: Eligibility criteria search tool start
	    if ("" != $absEligibility) {
		    $queryArray[] = "EligibilityCriteria%3D(".add_bools($absEligibility, "EligibilityCriteria").")";
	    }
		//S04: Eligibility criteria search tool end
    	
	    // check if WheelChairAccess, SpecialNeeds, language etc have been set via the Advanced Search page
		//S05: Referral criteria search tool start
	    if (isset($_GET['referralCriteria']) && 0 < strlen($_GET['referralCriteria'])) {
            $absFilters = (0 < strlen($absFilters)) ? $absFilters . "," . $_GET['referralCriteria'] : $_GET['referralCriteria'];
   	    }
		//S05: Referral criteria search tool end
       	
		//S06: Means of access search tool start
	    if (isset($_GET['accessChannel']) && 0 < strlen($_GET['accessChannel'])) {
            $absFilters = (0 < strlen($absFilters)) ? $absFilters . "," . $_GET['accessChannel'] : $_GET['accessChannel'];
   	    }
		//S06: Means of access search tool end
       	
		//S07: Language search tool start
	    if (isset($_GET['language']) && 0 < strlen($_GET['language'])) {
            $absFilters = (0 < strlen($absFilters)) ? $absFilters . "," . $_GET['language'] : $_GET['language'];
   	    }
		//S07: Language search tool end
       	
		//S08: Wheelchair access/Special needs search tool start
	    if (isset($_GET['wheelchairAccess']) && "on" == $_GET['wheelchairAccess']) {
            $absFilters = (0 < strlen($absFilters)) ? $absFilters . ",wAcc" : "wAcc";
   	    }
	    if (isset($_GET['specialNeeds']) && "on" == $_GET['specialNeeds']) {
            $absFilters = (0 < strlen($absFilters)) ? $absFilters . ",sNeeds" : "sNeeds";
   	    }
		//S08: Wheelchair access/Special needs search tool end
		
		//S09: Service title search tool (advanced search) start
	    if ("" != $absTitle) {
		    $queryArray[] = $qTitle = "dc.title%3D(".add_bools($absTitle, "dc.title").")";
	    }
    	//S09: Service title search tool (advanced search) end
		

		//L01: Location / proximity filter tool start
		// Check if location is a latitude and longitude or textual location
	    if ("" != $absLocation && true == $useLocation) {
		    if (preg_match("/^-{0,1}\d+\.\d+,-{0,1}\d+\.\d+$/", $absLocation) > 0){
		    		$queryArray[] = "geostr%3D%22" . $absLocation;
		    }
		    else{		    
			    $qLocation = rawurlencode(str_replace("\"", "", $absLocation));
		    	    
			    $queryArray[] = "Location%3D%22" . $qLocation . "%22";
			    
		    }
	    }
    	
	    $qFilterDist = 5;
	    if ("" != $absDistance) {
	        $qFilterDist = (1 > $absDistance) ? "1" : round($absDistance, 2);
    	}
		
		if ("off" == $absNational || ("off" == $absXNational && ("on" != $absNational))) {
		    $qNational = "false";
	    } else {
		    $qNational = "true";
	    }
		//L01: Location / proximity filter tool end
		

		// S02, F02, F03, F04, F05, F06, F07, F08, F09: filter tools start
	    if ("" != $absFilters) {
		    $refs = $accs = $lans = $flags = $ages = $vacs = "";
		    $filtersArray = explode(",", $absFilters);
		    foreach ($filtersArray as $filterCodename ) {
                if ("ref" == substr($filterCodename, 0, 3)) {
			        if ("" != $refs) {
			            $refs = $refs . "%20AND%20" . substr($filterCodename, 3);
			        } else {
			            $refs = substr($filterCodename, 3);
			        }
                }
                if ("acc" == substr($filterCodename, 0, 3)) {
			        if ("" != $accs) {
			            $accs = $accs . "%20AND%20" . substr($filterCodename, 3);
			        } else {
			            $accs = substr($filterCodename, 3);
			        }
                }
                if ("lan" == substr($filterCodename, 0, 3)) {
			        if ("" != $lans) {
			            $lans = $lans . "%20AND%20" . substr($filterCodename, 3);
			        } else {
			            $lans = substr($filterCodename, 3);
			        }
                }
			    if (array_key_exists($filterCodename, $filterFlagSearches)) {
			        if ("" != $flags) {
			            $flags = $flags . "%20AND%20" . $filterFlagSearches[$filterCodename];
			        } else {
			            $flags = $filterFlagSearches[$filterCodename];
			        }
			    }
			    if (array_key_exists($filterCodename, $filterAgeSearches)) {
			        if ("" != $ages) {
			            $ages = $ages . "%20AND%20" . $filterAgeSearches[$filterCodename];
			        } else {
			            $ages = $filterAgeSearches[$filterCodename];
			        }
			    }
			    if ("vacs" == $filterCodename) {
			        $vacs = "Vacancies%3Dtrue";
			    }
		    }
		    if ("" != $refs) {
		        $refs = "ReferralCriteria%3D(".$refs.")";
	   	        $queryArray[] = $refs;
	   	    }
		    if ("" != $accs) {
		        $accs = "AccessChannel%3D(".$accs.")";
	   	        $queryArray[] = $accs;
	   	    }
		    if ("" != $lans) {
		        $lans = "Language%3D(".$lans.")";
	   	        $queryArray[] = $lans;
	   	    }
		    if ("" != $flags) {
		        $flags = "Flags%3D(".$flags.")";
	   	        $queryArray[] = $flags;
	   	    }
		    if ("" != $ages) {
	     	    $queryArray[] = $ages;
	        }
		    if ("" != $vacs) {
	      	    $queryArray[] = $vacs;
	        }
	    }
	    // S02, F02, F03, F04, F05, F06, F07, F08, F09: filter tools end
   	    

        //Check if ANY search criteria have come in - if not, redirect to the 'no results' page
        if (empty($queryArray)) {
            $query = "*";
        } else if (1 == count($queryArray) && "Location%3D%22" == substr($queryArray[0], 0, 14)) {
            $query = "*%20and%20" . $queryArray[0];
        } else {
            $query = implode("%20and%20", $queryArray);
        }

        // Create a RESTful request
        $sruStartRecord = ("50" <= $absStartPoint) ? $absStartPoint - 50 : "1";
        if ("false" == $qNational) {
            $query = $query . "%20NOT%20Authority%3D%22NFSDPortal%22";
        }

        // R01 results sorting tool start
        switch ($absSortBy) {
            case "name":
                $sruSortKeys = "title";
                break;
            case "last updated":
                $sruSortKeys = "modified,,0%20title";
                break;
            case "distance":
                $sruSortKeys = "geo_distance%20title";
                break;
            default:
                $sruSortKeys = "score,,0%20title";
        }
        // R01 results sorting tool end

        $sruString = "/sru/xml/default?version=1.2&apikey=" . apikey . "&operation=searchRetrieve&query=" . $query . "&radius=" . $qFilterDist . "&sortKeys=" . $sruSortKeys . "&maximumRecords=100&startRecord=" . $sruStartRecord .
                     "&x-kint-facet=true" .
                     "&x-kint-facet.field=dc.subject" .
                     "&x-kint-facet.field=flags" .
                     "&x-kint-facet.field=immediate_vacancies_s" .
                     "&x-kint-facet.field=mode_of_access_s" .
                     "&x-kint-facet.field=language_spoken_s" .
                     "&x-kint-facet.field=referral_criteria_s" .
                     "&x-kint-facet.mincount=1";

        return $sruString;
    }

// Create (empty) XML doc - set it to null first to avoid nasty issues with the page being loaded twice in quick succession
	$xml = null;
	$xml = new DOMDocument;
	$rootelement = "";
	
 class SearchDiagnosticsException extends Exception{};
 class SearchLocationException extends Exception{};
 class SearchFailException extends Exception{};

/***********Function ************************
Name: loadXML
Description: Loads in the received stream of XML data that holds the results information from a query
Parameters - IN: $fetchRecord - XML data stream
Parameters - OUT: none
Customisable: DO NOT MODIFY
Notes: Can change the text of the error message
 ********************************************/
 function loadXML($fetchRecord) {

	global $xml, $rootelement;
	$xml->preseveWhiteSpace = false;
	$xml->load($fetchRecord);
	
	$rootelement = $xml->documentElement;
	// Check that the supposed record has a document element (ie the record exists)
	if ("diagnostics" == $rootelement->nodeName) {
        switch ($xml->getElementsByTagName("details")->item(0)->nodeValue) {
            case "Location":
                throw new SearchLocationException($xml->getElementsByTagName("message")->item(0)->nodeValue );
                break;
            default:
            throw new SearchDiagnosticsException($xml->getElementsByTagName("message")->item(0)->nodeValue );
        }
    } else if ("srw:searchRetrieveResponse" != $rootelement->nodeName) {
        throw new SearchFailException("Error loading XML" );
    }
 }


$exception = false;
$useLocation = true;
$errorCounter = 0;
do {
    $exception = false;
    $fetchRecord = root . make_query($useLocation);
    // echo $fetchRecord . "<br />";
    try {
        loadXML($fetchRecord);
    }
    catch (SearchLocationException $e) {
        $exception = true;
        $useLocation = false;
        $errorCounter++;
    }
    catch (SearchDiagnosticsException $e) {
        $exception = true;
        $errorCounter++;
    }
    catch (SearchFailException $e) {
        $exception = true;
        $errorCounter++;
    }
} while (true == $exception && 5 > $errorCounter);

if (5 <= $errorCounter) {
    redirect_error();
}

		// Create the nodes
		$echo = $xml->createElement("echoedData");
		
		$queryString = $xml->createElement("queryString");
		$queryString->nodeValue = $absFullQuery;
		
		//S01: simple search tool start
		$freetext = $xml->createAttribute("freetext");
		$freetextval = str_replace(" or ", " OR ", $absFreetext);
		$freetextval = str_replace(" not ", " NOT ", $freetextval);
		$freetext->value = str_replace(" and ", " AND ", $freetextval);
		$queryString->appendChild($freetext);
		//S01: simple search tool end
		
		//S02: category tool start
		$category = $xml->createAttribute("category");
		$category->value = ("" == $absCat) ? "" : $absCat;
		$queryString->appendChild($category);
		$subcategory = $xml->createAttribute("subcategory");
		$subcategory->value = ("" == $absSubCat) ? "" : $absSubCat;
		$queryString->appendChild($subcategory);
		$subsubcategory = $xml->createAttribute("subsubcategory");
		$subsubcategory->value = ("" == $absSubSubCat) ? "" : $absSubSubCat;
		$queryString->appendChild($subsubcategory);
		//S02: category tool end
		
		//S04: eligibility criteria search tool start
		$eligibility = $xml->createAttribute("eligibilityCriteria");
		$eligibilityval = str_replace(" or ", " OR ", $absEligibility);
		$eligibilityval = str_replace(" not ", " NOT ", $eligibilityval);
		$eligibility->value = str_replace(" and ", " AND ", $eligibilityval);
		$queryString->appendChild($eligibility);
		//S04: eligibility criteria search tool end
		
		//S09: service title search tool (advanced search) start
		$title = $xml->createAttribute("title");
		$titleval = str_replace(" or ", " OR ", $absTitle);
		$titleval = str_replace(" not ", " NOT ", $titleval);
		$title->value = str_replace(" and ", " AND ", $titleval);
		$queryString->appendChild($title);
		//S09: service title search tool (advanced search) end
		
		//L01: location / proximity filter tool start
		$location = $xml->createAttribute("location");
		$locationError = $xml->createAttribute("locationError");
		$filterDist = $xml->createAttribute("filterDist");
		$national = $xml->createAttribute("national");
		$location->value = htmlspecialchars(str_replace("+", " ", $absLocation));
        $locationError->value = (true == $useLocation) ? "" : "yes";
		$filterDist->value = "5";
		if ("" != $absDistance) {
			$filterDist->value = (1 > $absDistance) ? 1 : round($absDistance, 2);
		}
		$national->value = ("off" == $absNational OR ("off" == $absXNational AND ("on" != $absNational))) ? "off" : "on";
		$queryString->appendChild($location);
		$queryString->appendChild($locationError);
		$queryString->appendChild($filterDist);
		$queryString->appendChild($national);
		//L01: location / proximity filter tool end
		
		//F02, F03, F04, F05, F06, F07, F08, F09: filter tools start
        // Create array of codes for controlled list data
        $lists = Array("fullCatsList", "referralList", "accessChannelsList", "langList");
        // Load controlled list data to construct lists of filters
	    // Create a node in the original doc to hold list data
	    $vocabData = $xml->createElement("controlledListData");
        // Load the vocabulary into a new document
        foreach ($lists as $title) {
            $vocab = new DOMDocument;
			//print "title=".$title."<Br>";
			//print htmlspecialchars($_SESSION[$title]);
            $vocab->loadXML($_SESSION[$title]);
            
            // Create a child node for this particular list
            $listData = $xml->createElement($title);
		    
            // add data
            $vocabTree = $vocab->documentElement;
            $listData->appendChild($xml->importNode($vocabTree, true));
            $vocabData->appendChild($listData);
        }
		$rootelement->appendChild($vocabData);

		$filters = $xml->createAttribute("filters");
		$filters->value = $absFilters;
		if (0 < strlen($filters->value)) {
			$filterList = $xml->createElement("filterList");
			foreach ($filtersArray as $filterCodename) {
				$filterName = $xml->createElement("filterName");
				$filterCode = $xml->createAttribute("filterCode");
				$filterCode->value = $filterCodename;
				if (array_key_exists($filterCodename, $fullFilterNames)) {
					$filterName->nodeValue = $fullFilterNames[$filterCodename];
				}
				$filterName->appendChild($filterCode);
				$filterList->appendChild($filterName);
			}
			$echo->appendChild($filterList);
		}
		$queryString->appendChild($filters);
		//F02, F03, F04, F05, F06, F07, F08, F09: filter tools end
		
		//R04, R05, R06: List view, table view, and Map view tools start
		$view = $xml->createAttribute("view");
		$view->value = ("" == $absView) ? "list" : $absView;
		$queryString->appendChild($view);
		//R04, R05, R06: List view, table view, and Map view tools end
		
		//R01: Results set sorting tool start
		$sortBy = $xml->createAttribute("sortBy");
		$sortBy->value = ("" == $absSortBy) ? "relevance" : $absSortBy;
		$queryString->appendChild($sortBy);
		//R01: Results set sorting tool end
		
		//R02: Results pagination tool start
		$startPoint = $xml->createAttribute("startPoint");
		$sruStartRecord = $xml->createAttribute("sruStartRecord");
		$startPoint->value = ("" == $absStartPoint) ? "1" : $absStartPoint;
        $sruStartRecord->value = ("50" <= $absStartPoint) ? $absStartPoint - 50 : "1";
		$queryString->appendChild($startPoint);
		$queryString->appendChild($sruStartRecord);
		//R02: Results pagination tool end
		
		//R03: Results set sizing tool start
		$perPage = $xml->createAttribute("perPage");
		$perPage->value = ("" == $absPerPage) ? "10" : $absPerPage;
		$queryString->appendChild($perPage);
		//R03: Results set sizing tool end
		
		$echo->appendChild($queryString);
		
		//R06: Map view tool start
		// GEOCODING THINGS
        if (true == $useLocation) {
		    // Create the nodes
		    $homebase = $xml->createElement("centrePoint");
		    $homebaseCoordsLat = $xml->createAttribute("lat");
		    $homebaseCoordsLng = $xml->createAttribute("lng");
		    $homebasePostcode = $xml->createAttribute("PostCode");
    		
		    // Add data from srw:searchRetrieveResponse/srw:echoedSearchRetrieveRequest/srw:extraResponseData 
		    $list = $xml->getElementsByTagName("extraProp");
		    foreach ($list as $element) {
			    // if (the element has the 'geo_lat' attribute then it contains the latitude
			    if ("geo_lat" == $element->getAttribute("name")) {
				    $homebaseCoordsLat->value = $element->getAttribute("value");
			    }
			    // If the element has the 'geo_lon' attribute then it contains the longitude
			    if ("geo_lon" == $element->getAttribute("name")) {
				    $homebaseCoordsLng->value = $element->getAttribute("value");
			    }
            }
    				
		    $homebasePostcode->value = ("" == $absLocation) ? "" : htmlspecialchars(htmlspecialchars(str_replace("+", " ", $absLocation)));
    		
		    // and add them to the xml
		    $homebase->appendChild($homebaseCoordsLat);
		    $homebase->appendChild($homebaseCoordsLng);
		    $homebase->appendChild($homebasePostcode);
		    $echo->appendChild($homebase);
        } 
		// End geocoding
		//R06: Map view tool end


		$rootelement->appendChild($echo);

	// Option to save results (for bug tracking)
	// $xml->save("C:\\Temp\\newphp.xml");
	// $xml->load("C:\\Temp\\newphp.xml");
	
	for ($i=0; $i<count($xslArray); $i++) {
		
		// load XSL file into a document object
		$xsl = new DOMDocument;
		$xsl->load(xslRootPath . $xslArray[$i]);
	
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
	
	// returns true if $str begins with $sub
function beginsWith( $str, $sub ) {
   return ( substr( $str, 0, strlen( $sub ) ) == $sub );
}

// return tru if $str ends with $sub
function endsWith( $str, $sub ) {
   return ( substr( $str, strlen( $str ) - strlen( $sub ) ) == $sub );
}



function replace_accents($str)
{

 	$str = htmlentities($str, ENT_COMPAT, "UTF-8");
  	$str = preg_replace('/&([a-zA-Z])(uml|acute|grave|circ|tilde|cedil|ring);/','$1',$str);
  	$from = explode(" ", "&#192; &#193; &#194; &#195; &#196; &#197; &#199; &#200; &#201; &#202; &#203; &#204; &#205; &#206; &#207; &#208; &#209; &#210; &#211; &#212; &#213; &#214; &#217; 		&#218; &#219; &#220; &#221; &#224; &#225; &#226; &#227; &#228; &#229; &#230; &#231; &#232; &#233; &#234; &#235; &#236; &#237; &#238; &#239; &#240; &#241; &#242; &#243; &#244; &#245; &#246; &#249; &#250; &#251; &#252; &#253; &#255; &#256; &#257; &#258; &#259; &#260; &#261; &#262; &#263; &#264; &#265; &#266; &#267; &#268; &#269; &#270; &#271; &#272; &#273; &#274; &#275; &#276; &#277; &#278; &#279; &#280; &#281; &#282; &#283; &#284; &#285; &#286; &#287; &#288; &#289; &#290; &#291; &#292; &#293; &#294; &#295; &#296; &#297; &#298; &#299; &#300; &#301; &#302; &#303; &#304; &#305; &#308; &#309; &#310; &#311; &#312; &#313; &#314; &#315; &#316; &#317; &#318; &#319; &#320; &#321; &#322; &#323; &#324; &#325; &#326; &#327; &#328; &#329; &#330; &#331; &#332; &#333; &#334; &#335; &#336; &#337; &#340; &#341; &#342; &#343; &#344; &#345; &#346; &#347; &#348; &#349; &#350; &#351; &#352; &#353; &#354; &#355; &#356; &#357; &#360; &#361; &#362; &#363; &#364; &#365; &#366; &#367; &#368; &#369; &#370; &#371; &#372; &#373; &#374; &#375; &#376; &#377; &#378; &#379; &#380; &#381; &#382; a( � � s, t, A( � � S, T, ă î â ş ţ Ă Î Â Ş Ţ");
  $to = explode(" ", "A A A A A A C E E E E I I I I D N O O O O O U U U U Y a a a a a a a c e e e e i i i i o n o o o o o u u u u y y A a A a A a C c C c C c C c D d D d E e E e E e E e E e G g G g G g G g G H H h I i I i I i I i I i J j K k k L l L l L l L l L l N n N n N n n N n O o O o O o R r R r R r S s S s S s S s T t T t U u U u U u U u U u U u W w Y y Y Z z Z z Z z a i a s t A I A S T a i a s t A I A S T");
  return str_replace($from, $to, html_entity_decode($str));
 
} 
	
?>
