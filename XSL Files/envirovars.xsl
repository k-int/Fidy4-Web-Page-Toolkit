<xsl:stylesheet version="1.0"	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:output method="html" doctype-public="-//W3C//DTD HTML 4.01//EN" doctype-system="http://www.w3.org/TR/html4/strict.dtd" encoding="utf-8" indent="yes" />

<xsl:variable name="envirovars_path" select="'envirovars.xml'" />
  
<!-- define some variables so they have global scope -->
  <xsl:variable name="homepage" select="document($envirovars_path)/environmentVariables/pages/homepage" />
  <xsl:variable name="directoryPage" select="document($envirovars_path)/environmentVariables/pages/directoryPage" />
  <xsl:variable name="indexPage" select="document($envirovars_path)/environmentVariables/pages/indexPage" />
  <xsl:variable name="advsearchPage" select="document($envirovars_path)/environmentVariables/pages/advsearchPage" />
  <xsl:variable name="resultsPage" select="document($envirovars_path)/environmentVariables/pages/resultsPage" />
  <xsl:variable name="locationPage" select="document($envirovars_path)/environmentVariables/pages/locationPage" />
  <xsl:variable name="detailsPage" select="document($envirovars_path)/environmentVariables/pages/detailsPage" />

  <xsl:variable name="resourcesFolder" select="document($envirovars_path)/environmentVariables/folders/resourcesFolder" />
  <xsl:variable name="imagesFolder" select="document($envirovars_path)/environmentVariables/folders/imagesFolder" />
  <xsl:variable name="stylesFolder" select="document($envirovars_path)/environmentVariables/folders/stylesFolder" />
  <xsl:variable name="scriptsFolder" select="document($envirovars_path)/environmentVariables/folders/scriptsFolder" />

  <xsl:variable name="mapType" select="document($envirovars_path)/environmentVariables/maps/mapType" />
  <xsl:variable name="mapAPI" select="document($envirovars_path)/environmentVariables/maps/API[$mapType = @type]" />

  <xsl:template name="javascriptvars">
    <script type="text/javascript">
      var imagesFolder = "<xsl:value-of select="$imagesFolder" />";
      var scriptsFolder = "<xsl:value-of select="$scriptsFolder" />";
      var resultsPage = "<xsl:value-of select="$resultsPage" />";
    </script>
  </xsl:template>
  
</xsl:stylesheet>