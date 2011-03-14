<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
<!-- REQUIRED CODE - LEAVE THIS INTACT WHEN MODIFYING TEMPLATES  -->
<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

<xsl:stylesheet version="1.0"	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
								xmlns:ecdrec="http://dcsf.gov.uk/XMLSchema/Childcare"
								xmlns:fsdrec="http://dcsf.gov.uk/XMLSchema/ServiceDirectory"
								xmlns:srw="http://www.loc.gov/zing/srw/"
                xmlns:facet="http://k-int.com/facet"
								xmlns:jzkit="http://www.k-int.com/jzkit/"
								xmlns:apd="http://www.govtalk.gov.uk/people/AddressAndPersonalDetails"
								xmlns:con="http://www.govtalk.gov.uk/people/ContactTypes"
								xmlns:bs7666="http://www.govtalk.gov.uk/people/bs7666">

  <xsl:import href="resources_results.xsl" />
  <xsl:output method="html" encoding="utf-8" indent="yes" />

  <!-- switch to show the map or not - if this is set to anything other than 'yes', the entire map section will be skipped -->
<xsl:variable name="showMap" select="'yes'" />

<xsl:template match="/srw:searchRetrieveResponse">
<!-- - - - - - - - - - -->
<!-- END REQUIRED CODE -->
<!-- - - - - - - - - - -->
  <meta name="ROBOTS" content="NOINDEX, NOFOLLOW" />
  <!-- Link to main PKHD stylesheet -->
  <link rel="stylesheet" type="text/css" href="{$stylesFolder}pkhd.css" />
  <!-- Conditional link to IE6-specific stylesheet -->
  <xsl:comment><![CDATA[[if IE 6]>
  <link rel="stylesheet" type="text/css" href="{$stylesFolder}pkhd_ie6.css" />
  <![endif]]]></xsl:comment>


  <!-- Calls the template to create variables (images folder etc) for Javascript to use -->
  <xsl:call-template name="javascriptvars" />

  <!-- Links to the main javascript files, which allow the tabs etc to function -->
  <!-- NOTE - these files do not involve the maps at all; that is next -->
  <script type="text/javascript" src="{$scriptsFolder}pkhd.js"></script>
  <script type="text/javascript" src="{$scriptsFolder}results.js"></script>

  <!-- R04: Map view tool start -->
  <!-- Test if the search includes a location (signified by geoLocked being set to 1) and the map is allowed to be shown -->
  <xsl:if test="$geoLocked=1 and $showMap = 'yes' and 0 &lt; $totalRecords">
    <!-- Load appropriate map provider code -->
    <script type="text/javascript" src="{$mapAPI}"></script>
    <!-- Load map script -->
    <script type="text/javascript" src="{$scriptsFolder}map_basics.js"></script>
    <!-- Set the home location to the location entered, and create map pins for all results with valid addresses -->
    <script type="text/javascript">
      <!-- Display the map tab briefly (gets round a bug which messes the map up if it's created in a div which is not displayed) -->
			addLoadEvent( function() { showItem('resultsArea3'); } );
      
      var Locations = new Array();
      Locations[0] = new Array();
      Locations[0][0] = "<xsl:value-of select="echoedData/centrePoint/@lat" />,<xsl:text> </xsl:text><xsl:value-of select="echoedData/centrePoint/@lng" />";
      Locations[0][1] = "Your Location";
      Locations[0][2] = "<xsl:value-of select="echoedData/centrePoint/@PostCode" />";

      <!-- Calls the template to create map pins for valid addresses -->
      <xsl:apply-templates mode="mapPins" />

      <!-- Queues up functions to create the map, create the pins and reset the center & zoom level to show all pins -->
      addLoadEvent( function() { appendMap('mapDiv', 'noMapText'); } );
      addLoadEvent( function() { makeMap('mapDiv', '<xsl:value-of select="string($mapType)" />', null, 7); } );
      addLoadEvent( function() { makeLocations(Locations, '<xsl:value-of select="normalize-space($startPoint)" />', '<xsl:value-of select="normalize-space($sruStartRecord)" />', '<xsl:value-of select="$perPage" />', '<xsl:value-of select="string($mapType)" />', <xsl:value-of select="echoedData/queryString/@filterDist" />); } );
      addLoadEvent( function() { minMaxPoints(); } );
    </script>
	</xsl:if> <!-- End of map-specific Javascript -->
	<!-- R04: Map view tool end -->

  <!-- Adds a function to show the required tab (list view, table view or map view) to the onLoad queue -->
  <script type="text/javascript">
			addLoadEvent( function() { showItem('<xsl:value-of select="$view" />'); } );
      <xsl:choose>
		<xsl:when test="0 &lt; string-length($searchSubSubCat)">
		</xsl:when>
        <xsl:when test="0 &lt; string-length($searchSubCat)">
        <xsl:if test="6 &lt; count($subsubcatList/term[identifier=$listCounts/facet:lst['dc.subject'=@name]/facet:int/@*])">
			    addLoadEvent( function() { compressItem('cat', <xsl:value-of select="count($subsubcatList/term[identifier=$listCounts/facet:lst['dc.subject'=@name]/facet:int/@*])" />) } );
        </xsl:if>
        </xsl:when>
        <xsl:when test="0 &lt; string-length($searchCat)">
        <xsl:if test="6 &lt; count($subcatList/term[identifier=$listCounts/facet:lst['dc.subject'=@name]/facet:int/@*])">
			    addLoadEvent( function() { compressItem('cat', <xsl:value-of select="count($subcatList/term[identifier=$listCounts/facet:lst['dc.subject'=@name]/facet:int/@*])" />) } );
        </xsl:if>
        </xsl:when>
        <xsl:when test="6 &lt; count($catList/term[identifier=$listCounts/facet:lst['dc.subject'=@name]/facet:int/@*])">
			    addLoadEvent( function() { compressItem('cat', <xsl:value-of select="count($catList/term[identifier=$listCounts/facet:lst['dc.subject'=@name]/facet:int/@*])" />) } );
        </xsl:when>
      </xsl:choose>
      <xsl:if test="6 &lt; count($refList/term[identifier=$listCounts/facet:lst['referral_criteria_s'=@name]/facet:int/@*][false = contains($filters, concat('ref', identifier))])">
			  addLoadEvent( function() { compressItem('ref', <xsl:value-of select="count($refList/term[identifier=$listCounts/facet:lst['referral_criteria_s'=@name]/facet:int/@*][false = contains($filters, concat('ref', identifier))])" />) } );
      </xsl:if>
      <xsl:if test="6 &lt; count($accList/term[identifier=$listCounts/facet:lst['mode_of_access_s'=@name]/facet:int/@*][false = contains($filters, concat('acc', identifier))])">
			  addLoadEvent( function() { compressItem('acc', <xsl:value-of select="count($accList/term[identifier=$listCounts/facet:lst['mode_of_access_s'=@name]/facet:int/@*][false = contains($filters, concat('acc', identifier))])" />) } );
      </xsl:if>
      <xsl:if test="6 &lt; count($lanList/term[identifier=$listCounts/facet:lst['language_spoken_s'=@name]/facet:int/@*][false = contains($filters, concat('lan', identifier))])">
			  addLoadEvent( function() { compressItem('lan', <xsl:value-of select="count($lanList/term[identifier=$listCounts/facet:lst['language_spoken_s'=@name]/facet:int/@*][false = contains($filters, concat('lan', identifier))])" />) } );
      </xsl:if>
  </script>

</xsl:template>

</xsl:stylesheet>