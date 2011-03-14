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

  <xsl:import href="resources_details.xsl" />
  <xsl:output method="html" encoding="utf-8" indent="no" />

<!--  Switch to show the map or not - if this is set to anything other than 'yes', the entire map section will be skipped 
      Note - this is a per-page override for the same setting in the 'resources-details.xsl' file, and can be deleted if you wish-->
<xsl:variable name="showMap" select="'yes'" />

<xsl:template match="/ecdrec:ProviderDescription/ecdrec:ProviderDetails">
<!-- - - - - - - - - - -->
<!-- END REQUIRED CODE -->
<!-- - - - - - - - - - -->
  <meta name="ROBOTS" content="NOINDEX, NOFOLLOW" />
	<link rel="stylesheet" type="text/css" href="{$stylesFolder}pkhd.css" />
  <!-- Conditional link to IE6-specific stylesheet -->
  <xsl:comment><![CDATA[[if IE 6]>
  <link rel="stylesheet" type="text/css" href="{$stylesFolder}pkhd_ie6.css" />
  <![endif]]]></xsl:comment>
  
	<!-- If the 'print' option is set, this calls the stylesheet to format the page appropriately -->
	<xsl:if test="'print' = $print">
  <link rel="stylesheet" type="text/css" href="{$stylesFolder}pkhd_print.css" />
	</xsl:if>

  <!-- javascript - used to enable the tabs functionality, and for the map -->
  <xsl:call-template name="javascriptvars" />
	<script type="text/javascript" src="{$scriptsFolder}pkhd.js"></script>
	<script type="text/javascript" src="{$scriptsFolder}details.js"></script>
	<!-- map-specific -->
	<xsl:if test="'yes' = $showMap and (0 &lt; string-length(../echoedData/centrePoint/@lat)) and (0 &lt; string-length(../echoedData/centrePoint/@lng))">
    <!-- Load appropriate map provider code -->
    <script type="text/javascript" src="{$mapAPI}"></script>
    <!-- Load map script -->
    <script type="text/javascript" src="{$scriptsFolder}map_basics.js"></script>
    <!-- Set map pin for the location -->
    <script type="text/javascript">
      <xsl:if test="'print' != $print">
        <!-- Display the map tab briefly (gets round a bug which messes the map up if it's created in a div which is not displayed) -->
        addLoadEvent( function() { showItem('moreDetails8'); } );
      </xsl:if>

      var Locations = new Array();

      Locations[0] = new Array();
      Locations[0][0] = "<xsl:value-of select="concat(../echoedData/centrePoint/@lat, ', ', ../echoedData/centrePoint/@lng)" />";
		  Locations[0][1] = "<xsl:call-template name="encode"><xsl:with-param name="uncoded" select="../ecdrec:DC.Title" /></xsl:call-template>";
		  Locations[0][2] = "<xsl:choose>
      <xsl:when test="'true' = ecdrec:ConsentVisibleAddress or '1' = ecdrec:ConsentVisibleAddress">
		<xsl:apply-templates select="ecdrec:SettingDetails/ecdrec:PostalAddress" mode="fullAddress" />
	  </xsl:when>
      <xsl:when test="0 &lt; string-length(ecdrec:SettingDetails/ecdrec:PostalAddress/ecdrec:PostcodeOutcode)">
		  <xsl:apply-templates select="ecdrec:SettingDetails/ecdrec:PostalAddress" mode="postcode" />
	  </xsl:when>
      <xsl:otherwise>
		  <i>This provider has elected to have their exact physical address withheld from the listings</i>
	  </xsl:otherwise>
      </xsl:choose>";

      <!-- Queues up functions to create the map, create the pins and reset the center & zoom level to show all pins -->
      addLoadEvent( function() { appendMap('mapDiv', 'noMapText'); } );
      addLoadEvent( function() { makeMap("mapDiv", '<xsl:value-of select="string($mapType)" />', Locations[0][0], 15); } );
      addLoadEvent( function() { mapstraction.addMarker(makeMarker(Locations[0][0], "<xsl:value-of select="concat($imagesFolder, 'map_1.gif')" />", "<xsl:value-of select="concat($imagesFolder, 'map_1.gif')" />", "<xsl:call-template name="encode"><xsl:with-param name="uncoded" select="../ecdrec:DC.Title" /></xsl:call-template>", "<b>"+Locations[0][1]+"</b><br />"+Locations[0][2])); } );
		
    </script>
	</xsl:if> <!-- End of map-specific Javascript -->
  
  <!-- R09:  Code required for tab tool start -->
  <xsl:if test="'print' != $print">
    <script type="text/javascript">
		  addLoadEvent( function() { showItem('moreDetails<xsl:value-of select="$view" />') } );
    </script>
  </xsl:if>
  <!-- R09:  Code required for tab tool end -->
    
  <xsl:if test=" 3 &lt; count(../ecdrec:DC.Subject)">
    <script type="text/javascript">
      addLoadEvent( function() { compressItem('categories', <xsl:value-of select="count(../ecdrec:DC.Subject)" />) } );
    </script>
  </xsl:if>

  <!-- end javascript -->
	

</xsl:template>

</xsl:stylesheet>