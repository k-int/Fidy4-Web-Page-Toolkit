<?php

    // URL of PKHD Aggregator server
    define("root", "https://<aggregator_instance_in_here>");
	
	// API key for accessing PKHD Aggregator server
	define("apikey", "");

    // Option to use a proxy server - if set to 'true', ensure the IP and port are completed also
    define("useProxy", false);
    define("proxyIP", "0.0.0.0");
    define("proxyPort", 000);
    
    // Root directory where XSL files are located
	define("xslRootPath", "templates_xsl/");
	
	// Location of cURL certificates file and controlled list data files (make sure you have read/write access!!!)
    define("APP_DATA_PATH", "C:\\inetpub\\wwwroot\\ToolkitPHP\\templates_php\\");
	
	// Custom page to show users when an error occurs
	define("four0fourPage", xslRootPath . "custom404.html");

    // Define the id number of each controlled list (this allows a url to be built to retrieve the list)
    define("langList", 10);               // Language list (ISO 639-1)
    define("accreditList", 1);           // Accredidation list (Accreditation-1.0)
    define("facilityList", 4);          // Facility Terms list 	(Facility 1.0)
    define("ppaList", 6);               // Provision of Positive Activities 	(PPAYP-1.0)
    define("qualityList", 7);           // Quality Assurance List 	(QualityAssurance-1.0)
    define("referralList", 8);          // ReferralCriteria Terms List 	(ReferralCriteria 1.0)
    define("rolesList", 9);             // Role list 	(Role 1.0)
    define("spLevelsList", 2);           // Spatial Levels list 	(Spatial Levels 1.0)
    define("accessChannelsList", 5);    // Local Government Channels-Terms list 	(LGCHL-1.01)
    define("topCatsList", 11);           // PKH Mapped Vocabulary Version Ph3FINALV2 	(ISPP-001a-M)

    define("host", $_SERVER['HTTP_HOST']);

    function application_read($listname) {
		$filename = APP_DATA_PATH.$listname.".xml";
        // if data file exists, load application variables
        if (file_exists($filename)) {
            // read data file
            $file = fopen($filename, "r");
            if ($file) {
                $data = fread($file, filesize($filename));
                fclose($file);
            }
			return $data;
        }
		else {
			return false;
		}
    }

    function application_write($listname, $data) {
		$filename = APP_DATA_PATH.$listname.".xml";
        $file = fopen($filename, "w");
        if ($file)
        {
            fwrite($file, $data);
            fclose($file);
        }
    }

    function redirect_error() {
        $uri = rtrim(dirname($_SERVER['PHP_SELF']), '/\\');
        header("Location: http://".host."$uri/".four0fourPage);
        // echo( "<br /><br />If you're seeing this, you would have normally been redirected to an error page..." ); 
		exit;
    }

    function loadList($listName) {
        return readXMLFile(root."/terminology/vocabs/".constant($listName)."/topterms");
    }

    function loadAllCats() {
        $allCategories = new DOMDocument;
        $allCategories->loadXML($_SESSION['topCatsList']);
        
        // Make a clone of the doc to avoid changing the node list WHILE iterating through it
        $clone = new DOMDocument;
        $clone->loadXML($_SESSION['topCatsList']);
        $level1IDs = $clone->getElementsByTagName("internalId");
        
        foreach ($level1IDs as $level1ID) {
            $subcatPath = root."/terminology/term/" . $level1ID->nodeValue . "/children";
            
            $vocab = new DOMDocument;
            $vocab->loadXML(readXMLFile($subcatPath));
            // Identify the node in the original doc to hold data
            $xpath = new DOMXPath($allCategories);
            $termParent = $xpath->query("/topTerms/term[internalId = " . $level1ID->nodeValue . "]");
            
            // add data
            $vocabTree = $vocab->documentElement;
            $termParent->item(0)->appendChild($allCategories->importNode($vocabTree, true));

            // Now get the 2nd-level category IDs
            $level2IDs = $vocab->getElementsByTagName("internalId");

            foreach ($level2IDs as $level2ID) {
                set_time_limit(20);
                $sub2catPath = root."/terminology/term/" . $level2ID->nodeValue . "/children";
                $vocab2 = new DOMDocument;

                // Check if there are any 3rd-level categories
                $sub2catXML = readXMLFile($sub2catPath);
                if ("" != $sub2catXML) {
                    $vocab2->loadXML($sub2catXML);
                    // Identify the node in the original doc to hold data
                    $xpath2 = new DOMXPath($allCategories);
                    $term2Parent = $xpath2->query("/topTerms/term[internalId = " . $level1ID->nodeValue . "]/termChildren/term[internalId = " . $level2ID->nodeValue . "]");

                    // add data
                    $vocab2Tree = $vocab2->documentElement;
                    $term2Parent->item(0)->appendChild($allCategories->importNode($vocab2Tree, true));
                }
            }    
        }
        
        return $allCategories->saveXML();
    }

    function readXMLFile($url) {
		
        $ch = curl_init($url);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
		#curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, FALSE);
		curl_setopt($ch, CURLOPT_CAINFO, APP_DATA_PATH."ca-bundle.crt");
        if (true === useProxy) {
            curl_setopt($ch, CURLOPT_PROXY, proxyIP);
            curl_setopt($ch, CURLOPT_PROXYPORT, proxyPort);
        }
        $xmlstring = curl_exec($ch);
	if(!$xmlstring)
	{
		$xmlstring = file_get_contents($url);
	}
	else
	{
		if (curl_errno($ch)) {
			print curl_error($ch);
		} else {
			curl_close($ch);
		}
	}
        $rawVocab = utf8_encode($xmlstring);
        $trimmed = "";
        if (0 < strlen($rawVocab)) {
            $dupPos = strpos(substr($rawVocab, 5), "<?xml version=\"1.0\" encoding=\"UTF-8\"?>");
            $trimmed = (0 < $dupPos) ? substr($rawVocab, 0, $dupPos+5) : $rawVocab;
        }

	

        return $trimmed;
    }

    session_start();

	if (!isset($_SESSION['listsLoaded'])) {
		if (false === application_read("referralList")) {
			application_write("referralList", loadList("referralList"));
			$_SESSION['referralList'] = application_read("referralList");
		}
		if (false === application_read("accessChannelsList")) {
			application_write("accessChannelsList", loadList("accessChannelsList"));
			$_SESSION['accessChannelsList'] = application_read("accessChannelsList");
		}
		if (false === application_read("langList")) {
			application_write("langList", loadList("langList"));
			$_SESSION['langList'] = application_read("langList");
		}
		if (false === application_read("topCatsList")) {
			application_write("topCatsList", loadList("topCatsList"));
			$_SESSION['topCatsList'] = application_read("topCatsList");
		}
		if (false === application_read("fullCatsList")) {
			application_write("fullCatsList", loadAllCats());
			$_SESSION['fullCatsList'] = application_read("fullCatsList");
		}
		$_SESSION['listsLoaded'] = true;
	}
	
    if (!isset($_SESSION['referralList'])) {
        $_SESSION['referralList'] = application_read("referralList");
    }
    
    if (!isset($_SESSION['accessChannelsList'])) {
        $_SESSION['accessChannelsList'] = application_read("accessChannelsList");
    }
    
    if (!isset($_SESSION['langList'])) {
        $_SESSION['langList'] = application_read("langList");
    }

    if (!isset($_SESSION['topCatsList'])) {
        $_SESSION['topCatsList'] = application_read("topCatsList");
    }
    
    if (!isset($_SESSION['fullCatsList'])) {
        $_SESSION['fullCatsList'] = application_read("fullCatsList");
    }

    
?>