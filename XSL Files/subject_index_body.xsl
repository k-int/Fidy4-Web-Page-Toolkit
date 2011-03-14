<xsl:stylesheet version="1.0"	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
								xmlns:ecdrec="http://dcsf.gov.uk/XMLSchema/Childcare"
								xmlns:fsdrec="http://dcsf.gov.uk/XMLSchema/ServiceDirectory"
								xmlns:srw="http://www.loc.gov/zing/srw/"
								xmlns:jzkit="http://www.k-int.com/jzkit/"
								xmlns:apd="http://www.govtalk.gov.uk/people/AddressAndPersonalDetails"
								xmlns:con="http://www.govtalk.gov.uk/people/ContactTypes" 
								xmlns:bs7666="http://www.govtalk.gov.uk/people/bs7666">

<xsl:import href="resources_utilities.xsl" />

<xsl:output method="html" doctype-public="-//W3C//DTD HTML 4.01//EN" doctype-system="http://www.w3.org/TR/html4/strict.dtd" encoding="utf-8" indent="yes" />

<xsl:key name="identifier" match="term" use="identifier" />
<xsl:key name="term" match="term" use="'all'" />

<!-- Number of columns to display (default optimised for 3) -->
<xsl:variable name="columns" select="'3'" /><!-- suggested range 1 - 6 -->
  
<xsl:variable name="lcletters">abcdefghijklmnopqrstuvwxyz</xsl:variable>
<xsl:variable name="ucletters">ABCDEFGHIJKLMNOPQRSTUVWXYZ</xsl:variable>

<xsl:variable name="items" select="//term[translate(/topTerms/echoedData/queryString/@letter,$lcletters,$ucletters) = substring(name,1,1)]" />

<!-- Template to generate columns of terms (number of columns determined by the $columns variable above) -->
<xsl:template name="columnMaker" >
  <xsl:param name="i" />
  <xsl:variable name="perColumn" select="ceiling(count($items) div $columns)" />
  <xsl:if test="$i &lt; $columns +1">
    <div class="indexColumn" style="width: {(91 div $columns)}%;"><!-- inline style added to resize column width -->
      <xsl:for-each select="$items">
        <xsl:sort select="name" />
        <xsl:if test="position() &gt; ($perColumn * ($i - 1)) and position() &lt; ($perColumn * $i) +1 and 0 &lt; string-length(./../../identifier)">
          <p>
            <a>
              <xsl:attribute name="href">
                <xsl:choose>
                  <xsl:when test="0 &lt; string-length(./../../../../name)">
                    <xsl:value-of select="concat($resultsPage, '?category=', ./../../../../identifier, '&amp;subcategory=', ../../identifier, '&amp;subsubcategory=', identifier)"/>
                  </xsl:when>
                  <xsl:when test="0 &lt; string-length(./../../name)">
                    <xsl:value-of select="concat($resultsPage, '?category=', ./../../identifier, '&amp;subcategory=', identifier)"/>
                  </xsl:when>
                </xsl:choose>
              </xsl:attribute>
              <xsl:attribute name="title">
                <xsl:choose>
                  <xsl:when test="0 &lt; string-length(./../../../../name)">
                    <xsl:value-of select="concat(./../../../../name, ' &gt; ', ../../name, ' &gt; ', name)"/>
                  </xsl:when>
                  <xsl:when test="0 &lt; string-length(./../../name)">
                    <xsl:value-of select="concat(./../../name, ' &gt; ', name)"/>
                  </xsl:when>
                </xsl:choose>
              </xsl:attribute>
              <xsl:value-of select="name" />              
            </a>
            <xsl:if test="string-length(occurence) &gt; 0">
              <xsl:text> (</xsl:text>
              <xsl:value-of select="occurence"/>
              <xsl:text>)</xsl:text>
            </xsl:if>
          </p>
        </xsl:if>
      </xsl:for-each>
    </div>
    <xsl:call-template name="columnMaker">
      <xsl:with-param name="i" select="$i + 1" />
    </xsl:call-template>
  </xsl:if>
</xsl:template>

  
<!-- template 'function' for making letters list -->
<xsl:template name="letters">
  <xsl:param name="i" />
  <xsl:if test="$i &lt; 27">
    <xsl:choose><xsl:when test="substring($lcletters, $i, 1) = /topTerms/echoedData/queryString/@letter">
        <span class="indexLetter here">
          <xsl:value-of select="translate(substring($lcletters, $i, 1),$lcletters,$ucletters)" />
        </span>
        <xsl:text> </xsl:text>
    </xsl:when><xsl:otherwise>
        <a class="indexLetter" href="?ltr={substring($lcletters, $i, 1)}">
          <xsl:value-of select="translate(substring($lcletters, $i, 1),$lcletters,$ucletters)" />
        </a>
        <xsl:text> </xsl:text>
    </xsl:otherwise></xsl:choose>
  <xsl:call-template name="letters">
    <xsl:with-param name="i" select="$i+1" />
  </xsl:call-template>
  </xsl:if>
</xsl:template>
  
<xsl:template match="text()" />

<xsl:template match="/">


      <div id="outerContainer">
        <div id="innerContainer">

          <div id="mainContent" class="wide">

            <div id="findItTitle">
              <div id="findIt">
                <div id="findIt2">
                  <a href="{$homepage}" accesskey="1">
                    <img src="{$imagesFolder}banner.jpg" alt="Homepage" />
                  </a>
                </div>
              </div>
              <div id="linksBar">
                <ul>
                  <li id="top1">
                    <a href="{$directoryPage}">Directory</a>
                  </li>
                  <li id="top2">
                    <span class="here">Subject Index</span>
                  </li>
                </ul>
                <div id="simpleSearchDiv">
                  <form name="simpleSearchForm" action="{$resultsPage}" method="GET">
                    <label>Search for:</label>
                    <img id="poweredByIcon"  src="{$imagesFolder}powered_by_logo.gif" alt="Powered by ..." />
                    <input type="text" id="simpleSearchInput" name="freetext" value="" />
                    <input id="searchButton" type="image" src="{$imagesFolder}null_icon.gif" alt="Search" />
                  </form>
                  <a id="advSearchLink" href="{$advsearchPage}">Advanced Search</a>
                  <p id="poweredBy">
                    Powered by <br />...
                  </p>
                </div>
              </div>
            </div>

            <div id="index">
              
              <div id="indexHeader" class="headerPane">
                <h1>
                  <i>find-it</i> index
                </h1>
                <br />
                <p>Click to see services in each category:</p>
                <span>
                  <xsl:call-template name="letters">
                    <xsl:with-param name="i" select="1" />
                  </xsl:call-template>
                </span>
              </div>

              <div id="indexList" class="lowerPane">

                <xsl:choose>
                  <xsl:when test="0 != count($items)">
                    <!-- Calls the template to generate columns of links -->
                    <xsl:call-template name="columnMaker">
                      <xsl:with-param name="i" select="'1'" />
                    </xsl:call-template>
                  </xsl:when>
                  <xsl:otherwise>
                    <!-- if there are no terms, displays a message to say so -->
                    <div>
                      <p>We have no results beginning with '<xsl:value-of select="translate(topTerms/echoedData/queryString/@letter,$lcletters,$ucletters)" />'</p>
                    </div>
                  </xsl:otherwise>
                </xsl:choose>
                <div class="clear"></div>
              </div>
            </div>
          </div>
        </div>
      </div>

</xsl:template>

</xsl:stylesheet>