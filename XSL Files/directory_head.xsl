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

  <xsl:import href="envirovars.xsl" />
  <xsl:output method="html" encoding="utf-8" indent="yes" />

  <xsl:template match="text()" />

<xsl:template match="/topTerms">
<!-- - - - - - - - - - -->
<!-- END REQUIRED CODE -->
<!-- - - - - - - - - - -->
  <meta name="ROBOTS" content="NOINDEX, NOFOLLOW" />  
	<link rel="stylesheet" type="text/css" href="{$stylesFolder}pkhd.css" />
  <!-- Conditional link to IE6-specific stylesheet -->
  <xsl:comment><![CDATA[[if IE 6]>
  <link rel="stylesheet" type="text/css" href="{$stylesFolder}pkhd_ie6.css" />
  <![endif]]]></xsl:comment>

  <!-- Calls the template to create variables (images folder etc) for Javascript to use -->
  <xsl:call-template name="javascriptvars" />

  <script type="text/javascript" src="{$scriptsFolder}pkhd.js"></script>
	<script type="text/javascript" src="{$scriptsFolder}directory.js"></script>
  <script type="text/javascript">
    var catCounts = new Array();
    <xsl:for-each select="term">
      catCounts["<xsl:value-of select="identifier" />"] = "<xsl:value-of select="normalize-space(occurence)"/>";
    </xsl:for-each>
  </script>
  <!-- end javascript -->
	
</xsl:template>

</xsl:stylesheet>