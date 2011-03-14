<xsl:stylesheet version="1.0"	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
								xmlns:ecdrec="http://dcsf.gov.uk/XMLSchema/Childcare"
								xmlns:fsdrec="http://dcsf.gov.uk/XMLSchema/ServiceDirectory"
								xmlns:srw="http://www.loc.gov/zing/srw/"
                xmlns:facet="http://k-int.com/facet"
								xmlns:jzkit="http://www.k-int.com/jzkit/"
								xmlns:apd="http://www.govtalk.gov.uk/people/AddressAndPersonalDetails"
								xmlns:con="http://www.govtalk.gov.uk/people/ContactTypes"
								xmlns:bs7666="http://www.govtalk.gov.uk/people/bs7666">

  <xsl:import href="resources_utilities.xsl" />
  <xsl:output method="html" encoding="utf-8" indent="yes" />

  <!-- logic to determine what has been searched for, what view to show, filters, page number etc -->

  <xsl:variable name="searchQuery" select="string(/srw:searchRetrieveResponse/echoedData/queryString/@query)" />
  <xsl:variable name="listCounts" select="/srw:searchRetrieveResponse/srw:extraResponseData/facet:lst['facet_counts'=@name]/facet:lst['facet_fields'=@name]" />
  
  <xsl:key name="filterListCode" match="/srw:searchRetrieveResponse/echoedData/filterList/filterName" use="@filterCode" />

  <!-- S01:  Code required for simple search tool start -->
  <xsl:variable name="searchFreetext">
    <xsl:call-template name="decode">
      <xsl:with-param name="encoded" select="string(/srw:searchRetrieveResponse/echoedData/queryString/@freetext)"/>
    </xsl:call-template>
  </xsl:variable>
  <!-- S01:  Code required for simple search tool end -->

  <!-- S02: Code required for category tool start -->
  <xsl:variable name="searchCat" select="string(/srw:searchRetrieveResponse/echoedData/queryString/@category)" />
  <xsl:variable name="searchSubCat" select="string(/srw:searchRetrieveResponse/echoedData/queryString/@subcategory)" />
  <xsl:variable name="searchSubSubCat" select="string(/srw:searchRetrieveResponse/echoedData/queryString/@subsubcategory)" />
  <xsl:variable name="catList" select="/srw:searchRetrieveResponse/controlledListData/fullCatsList/topTerms" />
  <xsl:variable name="subcatList" select="$catList/term[identifier=$searchCat]/termChildren" />
  <xsl:variable name="subsubcatList" select="$subcatList/term[identifier=$searchSubCat]/termChildren" />
  <!-- S02: Code required for category tool start -->

  <!-- S04:  Code required for eligibility criteria search tool start -->
  <xsl:variable name="searchEligibility">
    <xsl:call-template name="decode">
      <xsl:with-param name="encoded" select="string(/srw:searchRetrieveResponse/echoedData/queryString/@eligibilityCriteria)"/>
    </xsl:call-template>
  </xsl:variable>
  <!-- S04:  Code required for eligibility criteria search tool end -->

  <!-- S09:  Code required for record title search tool start -->
  <xsl:variable name="searchTitle">
    <xsl:call-template name="decode">
      <xsl:with-param name="encoded" select="string(/srw:searchRetrieveResponse/echoedData/queryString/@title)"/>
    </xsl:call-template>
  </xsl:variable>
  <!-- S09:  Code required for record title search tool end -->

  <!-- L01: Code required for Location filter / broadening tool start -->
  <xsl:variable name="searchLocation" select="string(/srw:searchRetrieveResponse/echoedData/queryString/@location)" />
  <xsl:variable name="locationError" select="string(/srw:searchRetrieveResponse/echoedData/queryString/@locationError)" />
  <xsl:variable name="filterDist">
    <xsl:choose>
      <xsl:when test="0 &lt; string-length(/srw:searchRetrieveResponse/echoedData/queryString/@filterDist)">
        <xsl:value-of select="number(/srw:searchRetrieveResponse/echoedData/queryString/@filterDist)" />
      </xsl:when>
      <xsl:otherwise>5</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="national" select="string(/srw:searchRetrieveResponse/echoedData/queryString/@national)" />
  <!-- L01: Code required for Location filter / broadening tool end -->


  <!-- F03: Code required for Referral criteria filter start -->
  <xsl:variable name="refList" select="/srw:searchRetrieveResponse/controlledListData/referralList/topTerms" />
  <xsl:variable name="refUsed" select="$refList/term[identifier=$listCounts/facet:lst['referral_criteria_s'=@name]/facet:int/@*]" />
  <!-- F03: Code required for Referral criteria filter end -->

  <!-- F04: Code required for Means of access filter start -->
  <xsl:variable name="accList" select="/srw:searchRetrieveResponse/controlledListData/accessChannelsList/topTerms" />
  <xsl:variable name="accUsed" select="$accList/term[identifier=$listCounts/facet:lst['mode_of_access_s'=@name]/facet:int/@*]" />
  <!-- F04: Code required for Means of access filter end -->

  <!-- F05: Code required for Language filter start -->
  <xsl:variable name="lanList" select="/srw:searchRetrieveResponse/controlledListData/langList/topTerms" />
  <xsl:variable name="lanUsed" select="/srw:searchRetrieveResponse/controlledListData/langList/topTerms" />
  <!-- F05: Code required for Language filter end -->


  <xsl:variable name="filters" select="string(/srw:searchRetrieveResponse/echoedData/queryString/@filters)" />
  <!-- F06: Code required for Wheelchair filter start -->
  <xsl:variable name="filterCountWheelchair" select="normalize-space($listCounts/facet:lst['flags'=@name]/facet:int['WheelChairAccess'=@name])" />
  <!-- F06: Code required for Wheelchair filter end -->

  <!-- F07: Code required for Special needs filter start -->
  <xsl:variable name="filterCountSpecialNeeds" select="normalize-space($listCounts/facet:lst['flags'=@name]/facet:int['SpecialNeeds'=@name])" />
  <!-- F07: Code required for Special needs filter end -->

  <!-- F08: Code required for vacancies filter start -->
  <xsl:variable name="filterCountVacancies" select="normalize-space($listCounts/facet:lst['immediate_vacancies_s'=@name]/facet:int['true'=@name])" />
  <!-- F08: Code required for vacancies filter end -->

  <!-- F09: Code required for school pickups filter start -->
  <xsl:variable name="filterCountPickup" select="normalize-space($listCounts/facet:lst['flags'=@name]/facet:int['SchoolPickup'=@name])" />
  <!-- F09: Code required for school pickups filter end -->


  <!-- R06: Code required for Map view tool start -->
  <xsl:variable name="geoLocked">
    <xsl:if test="(0 != string-length($searchLocation) and 'yes' != $locationError)">
      1
    </xsl:if>
  </xsl:variable>
  <!-- R06: Code required for Map view tool end -->

  <!-- R01: Code required for Sorting tool start -->
  <xsl:variable name="sortBy" select="string(/srw:searchRetrieveResponse/echoedData/queryString/@sortBy)" />
  <!-- R01: Code required for Sorting tool end -->

  <!-- R03, L01: Code required for Results set sizing and Location / proximity tool start-->
  <xsl:variable name="rawView" select="string(/srw:searchRetrieveResponse/echoedData/queryString/@view)" />
  <!-- R03, L01: Code required for Results set sizing and Location / proximity tool start-->

  <!-- R04, R05, R06: Code required for List, Table and Map view tools start -->
  <xsl:variable name="view">
    <xsl:choose>
      <xsl:when test="'table' = $rawView">resultsArea2</xsl:when>
      <xsl:when test="'map' = $rawView">resultsArea3</xsl:when>
      <xsl:otherwise>resultsArea1</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="startPoint">
    <xsl:choose>
      <xsl:when test="0 = /srw:searchRetrieveResponse/srw:numberOfRecords">
        0
      </xsl:when>
      <xsl:when test="/srw:searchRetrieveResponse/echoedData/queryString/@startPoint">
        <xsl:value-of select="/srw:searchRetrieveResponse/echoedData/queryString/@startPoint" />
      </xsl:when>
      <xsl:otherwise>
        1
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name ="endPoint">
    <xsl:choose>
      <xsl:when test="$totalRecords &gt; ($perPage + $startPoint -1)">
        <xsl:value-of select="$perPage + $startPoint -1" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$totalRecords" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <!-- R04, R05, R06: Code required for List, Table and Map view tools end -->

  <!-- R03: Code required for Results set sizing tool start -->
  <xsl:variable name="perPage" select="normalize-space(/srw:searchRetrieveResponse/echoedData/queryString/@perPage)" />
  <xsl:variable name="totalRecords" select="number(/srw:searchRetrieveResponse/srw:numberOfRecords)" />

  <xsl:variable name="pages">
    <xsl:choose>
      <xsl:when test="0 = /srw:searchRetrieveResponse/srw:numberOfRecords">1</xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="number(ceiling($totalRecords div $perPage))" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="sruStartRecord">
    <xsl:choose>
      <xsl:when test="0 = /srw:searchRetrieveResponse/srw:numberOfRecords">
        0
      </xsl:when>
      <xsl:when test="/srw:searchRetrieveResponse/echoedData/queryString/@sruStartRecord">
        <xsl:value-of select="/srw:searchRetrieveResponse/echoedData/queryString/@sruStartRecord" />
      </xsl:when>
      <xsl:otherwise>
        1
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="thisPage">
    <xsl:choose>
      <xsl:when test="0 = /srw:searchRetrieveResponse/srw:numberOfRecords">1</xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="number(ceiling($startPoint div $perPage))" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <!-- R03: Code required for Results set sizing tool end -->


  <!-- template utility 'function' for decoding URL entities -->
  <xsl:template name="decode">
    <xsl:param name="encoded"/>
    <xsl:variable name="hex" select="'0123456789ABCDEF'"/>
    <xsl:variable name="ascii"> !"#$%&amp;'()*+,-./0123456789:;&lt;=&gt;?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~</xsl:variable>
    <xsl:variable name="latin1">&#160;&#161;&#162;&#163;&#164;&#165;&#166;&#167;&#168;&#169;&#170;&#171;&#172;&#173;&#174;&#175;&#176;&#177;&#178;&#179;&#180;&#181;&#182;&#183;&#184;&#185;&#186;&#187;&#188;&#189;&#190;&#191;&#192;&#193;&#194;&#195;&#196;&#197;&#198;&#199;&#200;&#201;&#202;&#203;&#204;&#205;&#206;&#207;&#208;&#209;&#210;&#211;&#212;&#213;&#214;&#215;&#216;&#217;&#218;&#219;&#220;&#221;&#222;&#223;&#224;&#225;&#226;&#227;&#228;&#229;&#230;&#231;&#232;&#233;&#234;&#235;&#236;&#237;&#238;&#239;&#240;&#241;&#242;&#243;&#244;&#245;&#246;&#247;&#248;&#249;&#250;&#251;&#252;&#253;&#254;&#255;</xsl:variable>
    <xsl:choose>
      <xsl:when test="contains($encoded,'%')">
        <xsl:value-of select="substring-before($encoded,'%')"/>
        <xsl:variable name="hexpair" select="translate(substring(substring-after($encoded,'%'),1,2),'abcdef','ABCDEF')"/>
        <xsl:variable name="decimal" select="(string-length(substring-before($hex,substring($hexpair,1,1))))*16 + string-length(substring-before($hex,substring($hexpair,2,1)))"/>
        <xsl:choose>
          <xsl:when test="$decimal &lt; 127 and $decimal &gt; 31">
            <xsl:value-of select="substring($ascii,$decimal - 31,1)"/>
          </xsl:when>
          <xsl:when test="$decimal &gt; 159">
            <xsl:value-of select="substring($latin1,$decimal - 159,1)"/>
          </xsl:when>
          <xsl:otherwise>?</xsl:otherwise>
        </xsl:choose>
        <xsl:call-template name="decode">
          <xsl:with-param name="encoded" select="substring(substring-after($encoded,'%'),3)"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$encoded"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- template utility 'function' for encoding HTML entities -->
  <xsl:template name="encode">
    <xsl:param name="uncoded"/>
    <xsl:variable name="raw">&lt;&gt;£'&quot;</xsl:variable>
    <xsl:variable name="coded">&#188;&#189;&#163;&#167;&#162;</xsl:variable>
    <xsl:value-of select="translate($uncoded, $raw, $coded)"/>
  </xsl:template>

  <!-- template 'function' for making list of pages -->
  <!-- R02: Code required for Results Pagination tool start -->
  <xsl:template name="pageMaker">

    <xsl:if test="5 &lt; $thisPage">
      <a>
        <xsl:attribute name="href">
          <xsl:call-template name="queryStringer">
            <xsl:with-param name="newStartPoint" select="1" />
          </xsl:call-template>
        </xsl:attribute>1
      </a>&#160;<xsl:if test="6 &lt; $thisPage">...&#160;</xsl:if>
    </xsl:if>

    <xsl:call-template name="pageLister">
      <xsl:with-param name="startPage">
        <xsl:choose>
          <xsl:when test="0 &lt; $thisPage - 4">
            <xsl:value-of select="$thisPage - 4"/>
          </xsl:when>
          <xsl:otherwise>1</xsl:otherwise>
        </xsl:choose>
      </xsl:with-param>
      <xsl:with-param name="endPage">
        <xsl:choose>
          <xsl:when test="5 &lt; ($pages - $thisPage)">
            <xsl:value-of select="$thisPage + 4"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$pages" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:with-param>
    </xsl:call-template>

    <xsl:if test="5 &lt; ($pages - $thisPage)">
      ... <a>
        <xsl:attribute name="href">
          <xsl:call-template name="queryStringer">
            <xsl:with-param name="newStartPoint" select="(($pages - 1) * $perPage) +1" />
          </xsl:call-template>
        </xsl:attribute>
        <xsl:value-of select="$pages" />
      </a>
    </xsl:if>
  </xsl:template>

  <!-- template 'function' for making list of pages -->
  <xsl:template name="pageLister">
    <xsl:param name="startPage" />
    <xsl:param name="endPage" />
    <xsl:param name="iteration" select="'1'" />
    <xsl:variable name="currentPageNumber" select="$startPage + $iteration - 1" />

    <xsl:if test="$currentPageNumber &gt;= $startPage">
      <xsl:choose>
        <xsl:when test="($currentPageNumber) != $thisPage">
          <a>
            <xsl:attribute name="href">
              <xsl:call-template name="queryStringer">
                <xsl:with-param name="newStartPoint" select="$startPoint + ($perPage * ($currentPageNumber - $thisPage))" />
              </xsl:call-template>
            </xsl:attribute>
            <xsl:value-of select="$currentPageNumber" />
          </a>
          <xsl:text> </xsl:text>
        </xsl:when>

        <xsl:otherwise>
          <span class="here">
            <xsl:value-of select="$currentPageNumber" />
            <xsl:text> </xsl:text>
          </span>
        </xsl:otherwise>

      </xsl:choose>
    </xsl:if>

    <xsl:if test="($currentPageNumber) &lt; $endPage">
      <xsl:call-template name="pageLister">
        <xsl:with-param name="startPage" select="$startPage"/>
        <xsl:with-param name="endPage" select="$endPage"/>
        <xsl:with-param name="iteration" select="$iteration + 1"/>
      </xsl:call-template>
    </xsl:if>

  </xsl:template>
  <!-- R02: Code required for Results Pagination tool end -->

  <!-- template 'function' for creating stuff in the readback area -->
  <!-- U01: Code required for Breadcrumb trail tool -->
  <xsl:template name="readback">
    <xsl:choose>
      <xsl:when test="(0 != string-length($searchTitle))">
        <span class="searchTerm">
          <xsl:value-of select="$searchTitle" />
        </span>
      </xsl:when>
      <xsl:when test="(0 != string-length($searchFreetext))">
        <span class="searchTerm">
          <xsl:call-template name="decode">
            <xsl:with-param name="encoded" select="$searchFreetext"/>
          </xsl:call-template>
        </span>
      </xsl:when>
      <xsl:otherwise>
        services
      </xsl:otherwise>
    </xsl:choose>
    <xsl:if test="0 != string-length($searchCat)">
      in the category <span class="searchTerm">
        <xsl:value-of select="$catList/term[identifier=$searchCat]/name" />
        <xsl:if test="0 != string-length($searchSubCat)">
          : <xsl:value-of select="$subcatList/term[identifier=$searchSubCat]/name"/>
        </xsl:if>
        <xsl:if test="0 != string-length($searchSubSubCat)">
          : <xsl:value-of select="$subsubcatList/term[identifier=$searchSubSubCat]/name"/>
        </xsl:if>
      </span>
    </xsl:if>
    <xsl:if test="(0 != string-length($searchLocation) and 'yes' != $locationError)">
      near <span class="searchTerm">
        <xsl:value-of select="$searchLocation" />
      </span>
    </xsl:if>
  </xsl:template>
  <!-- U01: Code required for Breadcrumb trail tool -->

  <!-- template 'function' for reworking query string based on input -->
  <!-- R02, R04, R05, R06: Code required for results pagination tool, list view, table view and map view tools start -->
  <xsl:template name="queryStringer">
    <xsl:param name="parameter1" />
    <xsl:param name="value1" />
    <xsl:param name="parameter2" />
    <xsl:param name="value2" />
    <xsl:param name="newStartPoint" />?<xsl:for-each select="/srw:searchRetrieveResponse/echoedData/queryString/@*[name() != 'startPoint']">
      <xsl:choose>
        <xsl:when test="$parameter1 = name()">
          <xsl:value-of select="name()" />=<xsl:value-of select="$value1" /><xsl:if test="position() != last()">&amp;</xsl:if>
        </xsl:when>
        <xsl:when test="$parameter2 = name()">
          <xsl:value-of select="name()" />=<xsl:value-of select="$value2" /><xsl:if test="position() != last()">&amp;</xsl:if>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="name()" />=<xsl:value-of select="." /><xsl:if test="position() != last()">&amp;</xsl:if>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
    <xsl:choose>
      <xsl:when test="0 &lt; string-length($newStartPoint)">
        <xsl:value-of select="concat('&amp;startPoint=', $newStartPoint)" />
      </xsl:when>
      <xsl:otherwise>&amp;startPoint=1</xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- R02, R04, R05, R06: Code required for results pagination tool, list view, table view and map view tools end -->

  <!-- template 'function' for removing category filter -->
  <!-- S02: Code required for category tool start -->
  <xsl:template name="catCutter">
    <xsl:param name="level" />
    <xsl:for-each select="/srw:searchRetrieveResponse/echoedData/queryString/@*">
      <xsl:if test="$level != name() and ('startPoint' != name())">
        <xsl:value-of select="name()" />=<xsl:value-of select="concat(., '&amp;')" />
      </xsl:if>
    </xsl:for-each>
    <xsl:value-of select="'startPoint=1'"/>

  </xsl:template>
  <!-- S02: Code required for category tool end -->

  <!-- template 'function' for removing eligibility criteria -->
  <!--S04: Code required for eligibility criteria tool start -->
  <xsl:template name="eligibilityCutter">
    <xsl:for-each select="/srw:searchRetrieveResponse/echoedData/queryString/@*">
      <xsl:if test="'eligibilityCriteria' != name() and ('startPoint' != name())">
        <xsl:value-of select="name()" />=<xsl:value-of select="concat(., '&amp;')" />
      </xsl:if>
    </xsl:for-each>
    <xsl:value-of select="'startPoint=1'"/>
  </xsl:template>
  <!--S04: Code required for eligibility criteria tool end -->

  <!-- template 'function' for removing location filter -->
  <!--L01: Code required for Location / Proximity tool start -->
  <xsl:template name="locationCutter">
    <xsl:for-each select="/srw:searchRetrieveResponse/echoedData/queryString/@*">
      <xsl:if test="('location' != name()) and ('filterDist' != name()) and ('sortBy' != name()) and ('distance' != .) and ('startPoint' != name())">
        <xsl:value-of select="name()" />=<xsl:value-of select="concat(., '&amp;')" />
      </xsl:if>
    </xsl:for-each>
    <xsl:value-of select="'startPoint=1'"/>
  </xsl:template>
  <!--L01: Code required for Location / Proximity tool end -->

  <!-- R06: Map view tool start -->
  <!-- template 'function' for creating JavaScript array for map data -->
  <xsl:template match="srw:record" mode="mapPins">
    <xsl:variable name="recordType" select="substring(normalize-space(doc/arr[@name = 'repo_url_s']/str), string-length(normalize-space(doc/arr[@name = 'repo_url_s']/str))-2)" />
    <xsl:variable name="position" select="position() div 2" />
    Locations[<xsl:value-of select="$position" />] = new Array();
    <xsl:if test="0 &lt; string-length(doc/double['lat' = @name])">
      Locations[<xsl:value-of select="$position" />][0] = "<xsl:value-of select="concat(normalize-space(doc/double['lat' = @name]), ', ', normalize-space(doc/double['lng' = @name]))" />";
      Locations[<xsl:value-of select="$position" />][1] = "<xsl:value-of select="normalize-space(doc/arr['dc.title' = @name]/str)" />";
      Locations[<xsl:value-of select="$position" />][2] = "<xsl:value-of select="normalize-space(doc/str['dd_postcode' = @name])" />";
      Locations[<xsl:value-of select="$position" />][3] = "<xsl:value-of select="concat($detailsPage, '?recordID=')" />
      <xsl:value-of select="normalize-space(doc/str['aggregator.internal.id' = @name])"/>
      <xsl:value-of select="concat('&amp;recordType=', $recordType)" />
      <xsl:if test="0 &lt; string-length(/srw:searchRetrieveResponse/echoedData/queryString/@category)">
        <xsl:value-of select="concat('&amp;category=', /srw:searchRetrieveResponse/echoedData/queryString/@category)" />
      </xsl:if>";
    </xsl:if>
  </xsl:template>
  <!-- R06: Map view tool end -->


  <!-- template 'function' for making filters to appear in sidebar-->
  <!-- F02, F06, F07, F08, F10: Code required for filter tools start -->
  <xsl:template name="filterMaker">
    <xsl:param name="filterStem" />
    <xsl:param name="filterTitle" />
    <xsl:param name="filterCode" />
    <xsl:param name="filterName" />
    <xsl:param name="filterCount" />
    <xsl:if test="false = contains($filters, $filterCode)">
      <li id="{$filterStem}Link{position()}">
        <a>
          <xsl:attribute name="Title">
            <xsl:value-of select ="concat('Filter by ' , $filterTitle, ' ', $filterName )"/>
          </xsl:attribute>
          <xsl:attribute name="href">
            <xsl:call-template name="queryStringer">
              <xsl:with-param name="parameter1" select="'filters'" />
              <xsl:with-param name="value1">
                <xsl:choose>
                  <xsl:when test="0 &lt; string-length(/srw:searchRetrieveResponse/echoedData/queryString/@filters)">
                    <xsl:value-of select="concat(/srw:searchRetrieveResponse/echoedData/queryString/@filters, ',', $filterCode)" />
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="$filterCode" />
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:attribute>
          <xsl:value-of select="$filterName" />
        </a>
        <xsl:if test="string-length($filterCount) &gt; 0">
          (
          <xsl:value-of select="$filterCount" />
          )
        </xsl:if>
      </li>
    </xsl:if>
  </xsl:template>
  <!-- F02, F06, F07, F08, F10: Code required for filter  tools end -->

  <!-- template 'function' for making hyperlinks to remove filters -->
  <!-- F02, F06, F07, F08, F10: Code required for broadening  tools start -->
  <xsl:template name="filterCutter">
    <xsl:param name="filterCode" />
    <xsl:call-template name="queryStringer">
      <xsl:with-param name="parameter1" select="'filters'" />
      <xsl:with-param name="value1">
        <xsl:for-each select="/srw:searchRetrieveResponse/echoedData/filterList/filterName">
          <xsl:if test="$filterCode != ./@filterCode">
            <xsl:value-of select="./@filterCode" />
            <xsl:if test="(position() != last()) and (following-sibling::*/@filterCode != $filterCode)">,</xsl:if>
          </xsl:if>
        </xsl:for-each>
      </xsl:with-param>
      <xsl:with-param name="newStartPoint" select="'1'" />
    </xsl:call-template>
  </xsl:template>
  <!-- F02, F06, F07, F08, F10: Code required for broadening  tools end -->


  <!-- template 'function' for creating actual result records (list mode) -->
  <!-- R04: Code required for List View tool start -->
  <xsl:template match="srw:record" mode="list">
    <xsl:variable name="recordType" select="substring(normalize-space(doc/arr[@name = 'repo_url_s']/str), string-length(normalize-space(doc/arr[@name = 'repo_url_s']/str))-2)" />
    <xsl:variable name="position" select="position() div 2" />
    <xsl:variable name="markerNum" select="(position() div 2) - ($startPoint - $sruStartRecord + 1) +1" />
    <xsl:if test="$position &gt;= ($startPoint - $sruStartRecord + 1) and $position &lt; ($startPoint - $sruStartRecord + 1 + $perPage)">
      <li class="map">
        <div class="listDiv">
          <p>
            <xsl:choose>
              <xsl:when test="0 &lt; string-length(doc/double['lat' = @name])">
                <img src="{$imagesFolder}map_{$markerNum}.gif" alt="Pin {$markerNum}" class="mapPin" />
              </xsl:when>
              <xsl:otherwise>
                <img src="{$imagesFolder}plain_{$markerNum}.gif" alt="Pin {$markerNum} (location unavailable)" class="mapPin" />
              </xsl:otherwise>
            </xsl:choose>
          </p>
          <h3>
            <a class="resultLink">
              <xsl:attribute name="href">
                <xsl:value-of select="concat($detailsPage, '?recordID=')" />
                <xsl:value-of select="normalize-space(doc/str['aggregator.internal.id' = @name])"/>
                <xsl:value-of select="concat('&amp;recordType=', $recordType)" />
                <xsl:if test="0 &lt; string-length(/srw:searchRetrieveResponse/echoedData/queryString/@category)">
                  <xsl:value-of select="concat('&amp;category=', /srw:searchRetrieveResponse/echoedData/queryString/@category)" />
                </xsl:if>
              </xsl:attribute>
              <xsl:value-of select="normalize-space(doc/arr['dc.title' = @name]/str)" />
            </a>
            <xsl:if test="'NFSDPortal' = normalize-space(doc/str['authority' = @name]) and 'FSD' = $recordType">
              &#160;<img src="{$imagesFolder}national.png" alt="Nationwide service" />
            </xsl:if>
          </h3>
          <p>
            <span class="description">
              <xsl:choose>
                <xsl:when test="110 &lt; string-length(doc/arr['dc.description' = @name]/str)">
                  <xsl:value-of select="concat(substring(normalize-space(doc/arr['dc.description' = @name]/str), 1, 97), substring-before(substring(normalize-space(doc/arr['dc.description' = @name]/str), 98, 107), ' '))" />...
                </xsl:when>
                <xsl:when test="0 &lt; string-length(doc/arr['dc.description' = @name]/str)">
                  <xsl:value-of select="normalize-space(doc/arr['dc.description' = @name]/str)" />
                </xsl:when>
                <xsl:otherwise>&#160;</xsl:otherwise>
              </xsl:choose>
            </span>
          </p>
          <p>
            Address:
            <xsl:choose>
              <xsl:when test="'false'=normalize-space(doc/bool['address.visible'=@name]) or '0'=normalize-space(doc/bool['address.visible'=@name])">
                <i>This provider has elected to have their exact physical address withheld from the listings.</i>
              </xsl:when>
              <xsl:when test="0 &lt; string-length(normalize-space(doc/str[starts-with(@name,'address')]))">
                <span class="resultsAddress">
                  <xsl:call-template name="distinct">
                    <xsl:with-param name="nodes" select="doc/str[starts-with(@name,'address')]" />
                  </xsl:call-template>
                </span>
              </xsl:when>
              <xsl:otherwise>
                <i>We do not have address details for this service</i>
              </xsl:otherwise>
            </xsl:choose>
          </p>
          <xsl:if test="0 &lt; string-length(doc/str['telephone'=@name]) and 'null' != normalize-space(doc/str['telephone'=@name])">
            <p>
              <span class="telephone">
                Tel: <xsl:value-of select="normalize-space(doc/str['telephone'=@name])" />
                <xsl:if test="0 &lt; string-length(doc/str['telephone.type'=@name])">
                  (
                  <xsl:value-of select="normalize-space(doc/str['telephone.type'=@name])" />
                  )
                </xsl:if>
              </span>
            </p>
          </xsl:if>
          <xsl:if test="0 &lt; string-length(doc/str['email'=@name]) and 'null' != normalize-space(doc/str['email'=@name])">
            <p>
              <span class="email">
                Email: <xsl:value-of select="normalize-space(doc/str['email'=@name])" /><xsl:if test="0 &lt; string-length(doc/str['email.type'=@name])">
                  (<xsl:value-of select="normalize-space(doc/str['email.type'=@name])" />)
                </xsl:if>
              </span>
            </p>
          </xsl:if>
          <p>
            <span class="ageRange">
              Age range:
              <xsl:choose>
                <xsl:when test="0 &lt; string-length(doc/int['ispp.age_min' = @name])">
                  <xsl:value-of select="concat(normalize-space(doc/int['ispp.age_min' = @name]), ' - ', normalize-space(doc/int['ispp.age_max' = @name]), ' years')" />
                </xsl:when>
                <xsl:otherwise>
                  <i>We do not have age ranges for this service</i>
                </xsl:otherwise>
              </xsl:choose>
            </span>
          </p>
          <xsl:if test="0 &lt; string-length(doc/str['geo_distance' = @name])">
            <p>
              <span class="distance">
                Distance: <xsl:choose>
                  <xsl:when test="1 &lt; round(doc/str['geo_distance' = @name])">
                    <xsl:value-of select="round(doc/str['geo_distance' = @name])" /> miles
                  </xsl:when>
                  <xsl:when test="1 = round(doc/str['geo_distance' = @name])">
                    1 mile
                  </xsl:when>
                  <xsl:otherwise>
                    &lt; 1 mile
                  </xsl:otherwise>
                </xsl:choose>
              </span>
            </p>
          </xsl:if>
          <xsl:if test="0 &lt; string-length(doc/date['modified'=@name])">
            <p>
              <span class="lastUpdate">
                Last updated: <xsl:call-template name="dateMaker">
                  <xsl:with-param name="DateTime" select="normalize-space(doc/date['modified'=@name])" />
                </xsl:call-template>
              </span>
            </p>
          </xsl:if>

          <xsl:if test="string-length(doc/str['feedback_name_s'= @name]) &gt; 0">
            <div class="laLogo">
              <xsl:if test="string-length(doc/str['icon_url_s' = @name])">
                <img class="resultsLALogo" src="{doc/str['icon_url_s' = @name]}" alt="{doc/str['feedback_name_s' = @name]}" />
              </xsl:if>
              <span class="resultsLAName">
                <xsl:value-of select="doc/str['feedback_name_s' = @name]" />
              </span>
            </div>
          </xsl:if>


          <p>
            <span class="icons">
              <xsl:choose>
                <xsl:when test="contains(string(doc/arr['flags' = @name]), 'WheelChairAccess')">
                  <img src="{$imagesFolder}wheelchair.png" alt="Wheelchair access" />
                </xsl:when>
                <xsl:otherwise>
                  <img src="{$imagesFolder}null_icon.gif" alt="" />
                </xsl:otherwise>
              </xsl:choose>
              &#160;
              <xsl:choose>
                <xsl:when test="contains(string(doc/arr['flags' = @name]), 'SpecialNeeds')">
                  <img src="{$imagesFolder}spec_needs.png" alt="Caters for Special Needs" />
                </xsl:when>
                <xsl:otherwise>
                  <img src="{$imagesFolder}null_icon.gif" alt="" />
                </xsl:otherwise>
              </xsl:choose>
              &#160;
              <xsl:choose>
                <xsl:when test="'true' = normalize-space(doc/arr['immediate_vacancies_s' = @name]/str) or '1' = normalize-space(doc/arr['immediate_vacancies_s' = @name]/str)">
                  <img src="{$imagesFolder}vac.png" alt="Current vacancies"  />
                </xsl:when>
                <xsl:otherwise>
                  <img src="{$imagesFolder}null_icon.gif" alt="" />
                </xsl:otherwise>
              </xsl:choose>
              &#160;
              <xsl:choose>
                <xsl:when test="contains(string(doc/arr['flags' = @name]), 'DietaryNeeds')">
                  <img src="{$imagesFolder}dietary.png" alt="Pickup service available" />
                </xsl:when>
                <xsl:otherwise>
                  <img src="{$imagesFolder}null_icon.gif" alt="" />
                </xsl:otherwise>
              </xsl:choose>
              &#160;
              <xsl:choose>
                <xsl:when test="contains(string(doc/arr['flags' = @name]), 'SchoolPickup')">
                  <img src="{$imagesFolder}pickup.png" alt="Pickup service available" />
                </xsl:when>
                <xsl:otherwise>
                  <img src="{$imagesFolder}null_icon.gif" alt="" />
                </xsl:otherwise>
              </xsl:choose>
              &#160;
              <xsl:choose>
                <xsl:when test="'NFSDPortal' =normalize-space(doc/arr['authority' = @name]/str)">
                  <img src="{$imagesFolder}national.png" alt="National service" />
                </xsl:when>
                <xsl:otherwise>
                  <img src="{$imagesFolder}null_icon.gif" alt="" />
                </xsl:otherwise>
              </xsl:choose>
            </span>
          </p>
        </div>
      </li>
    </xsl:if>
  </xsl:template>
  <!-- R04: Code required for List View tool end -->

  <!-- template 'function' for creating actual result records (table mode) -->
  <!-- R05: Code required for Table View tool start -->
  <xsl:template match="srw:record" mode="table">
    <xsl:variable name="recordType" select="substring(normalize-space(doc/arr[@name = 'repo_url_s']/str), string-length(normalize-space(doc/arr[@name = 'repo_url_s']/str))-2)" />
    <xsl:variable name="position" select="position() div 2" />
    <xsl:variable name="markerNum" select="(position() div 2) - ($startPoint - $sruStartRecord + 1) +1" />
    <xsl:if test="$position &gt;= ($startPoint - $sruStartRecord + 1) and $position &lt; ($startPoint - $sruStartRecord + 1 + $perPage)">
      <tr>
        <td class="cell_description" scope="row">
          <p class="mapPin">
            <xsl:choose>
              <xsl:when test="0 &lt; string-length(doc/double['lat' = @name])">
                <img src="{$imagesFolder}map_{$markerNum}.gif" alt="Pin {$markerNum}" class="mapPin" />
              </xsl:when>
              <xsl:otherwise>
                <img src="{$imagesFolder}plain_{$markerNum}.gif" alt="Pin {$markerNum} (location unavailable)" class="mapPin" />
              </xsl:otherwise>
            </xsl:choose>
          </p>
          <h3>
            <a class="resultLink">
              <xsl:attribute name="href">
                <xsl:value-of select="concat($detailsPage, '?recordID=')" />
                <xsl:value-of select="normalize-space(doc/str['aggregator.internal.id' = @name])"/>
                <xsl:value-of select="concat('&amp;recordType=', $recordType)" />
                <xsl:if test="0 &lt; string-length(/srw:searchRetrieveResponse/echoedData/queryString/@category)">
                  <xsl:value-of select="concat('&amp;category=', /srw:searchRetrieveResponse/echoedData/queryString/@category)" />
                </xsl:if>
              </xsl:attribute>
              <xsl:value-of select="normalize-space(doc/arr['dc.title' = @name]/str)" />
            </a>
          </h3>
          <p>
            <span class="description">
              <xsl:choose>
                <xsl:when test="110 &lt; string-length(doc/arr['dc.description' = @name]/str)">
                  <xsl:value-of select="concat(substring(normalize-space(doc/arr['dc.description' = @name]/str), 1, 97), substring-before(substring(normalize-space(doc/arr['dc.description' = @name]/str), 98, 107), ' '))" />...
                </xsl:when>
                <xsl:when test="0 &lt; string-length(doc/arr['dc.description' = @name]/str)">
                  <xsl:value-of select="normalize-space(doc/arr['dc.description' = @name]/str)" />
                </xsl:when>
                <xsl:otherwise>&#160;</xsl:otherwise>
              </xsl:choose>
            </span>
          </p>
          <p>
            Address: <xsl:choose>
              <xsl:when test="'false'=normalize-space(doc/bool['address.visible'=@name]) or '0'=normalize-space(doc/bool['address.visible'=@name])">
                <i>This provider has elected to have their exact physical address withheld from the listings.</i>
              </xsl:when>
              <xsl:when test="0 &lt; string-length(doc/str[starts-with(@name,'address')])">
                <span class="resultsAddress">
                  <xsl:call-template name="distinct">
                    <xsl:with-param name="nodes" select="doc/str[starts-with(@name,'address')]" />
                  </xsl:call-template>
                </span>
              </xsl:when>
              <xsl:otherwise>
                <i>We do not have address details for this service</i>
              </xsl:otherwise>
            </xsl:choose>
          </p>
          <xsl:if test="0 &lt; string-length(doc/str['telephone'=@name]) and 'null' != normalize-space(doc/str['telephone'=@name])">
            <p>
              <span class="telephone">
                Tel: <xsl:value-of select="normalize-space(doc/str['telephone'=@name])" />
                <xsl:if test="0 &lt; string-length(doc/str['telephone.type'=@name])">
                  (<xsl:value-of select="normalize-space(doc/str['telephone.type'=@name])" />)
                </xsl:if>
              </span>
            </p>
          </xsl:if>
          <xsl:if test="0 &lt; string-length(doc/str['email'=@name]) and 'null' != normalize-space(doc/str['email'=@name])">
            <p>
              <span class="email">
                Email: <xsl:value-of select="normalize-space(doc/str['email'=@name])" />
                <xsl:if test="0 &lt; string-length(doc/str['email.type'=@name])">
                  (<xsl:value-of select="normalize-space(doc/str['email.type'=@name])" />)
                </xsl:if>
              </span>
            </p>
          </xsl:if>
        </td>
        <xsl:if test="$geoLocked = 1">
          <td class="cell_distance">
            <xsl:if test="0 &lt; string-length(doc/str['geo_distance' = @name])">
              <xsl:choose>
                <xsl:when test="1 &lt; round(doc/str['geo_distance' = @name])">
                  <xsl:value-of select="round(doc/str['geo_distance' = @name])" /> miles
                </xsl:when>
                <xsl:when test="1 = round(doc/str['geo_distance' = @name])">
                  1 mile
                </xsl:when>
                <xsl:otherwise>&lt; 1 mile</xsl:otherwise>
              </xsl:choose>
            </xsl:if>
          </td>
        </xsl:if>
        <td class="cell_ages">
          <xsl:choose>
            <xsl:when test="0 &lt; string-length(doc/int['ispp.age_min' = @name])">
              <xsl:value-of select="concat(normalize-space(doc/int['ispp.age_min' = @name]), ' - ', normalize-space(doc/int['ispp.age_max' = @name]), ' years')" />
            </xsl:when>
            <xsl:otherwise>
              <i>We do not have age ranges for this service</i>
            </xsl:otherwise>
          </xsl:choose>
        </td>
        <td class="cell_national">
          <xsl:choose>
            <xsl:when test="'NFSDPortal' = normalize-space(doc/str['authority' = @name]) and 'FSD' = $recordType">
              <img src="{$imagesFolder}national.png" alt="Nationwide service" />
            </xsl:when>
            <xsl:otherwise>-</xsl:otherwise>
          </xsl:choose>
        </td>
        <td class="cell_facilities">
          <p>
            <span class="icons">
              <xsl:choose>
                <xsl:when test="contains(string(doc/arr['flags' = @name]), 'WheelChairAccess')">
                  <img src="{$imagesFolder}wheelchair.png" alt="Wheelchair access" />
                </xsl:when>
                <xsl:otherwise>
                  <img src="{$imagesFolder}null_icon.gif" alt="" />
                </xsl:otherwise>
              </xsl:choose>
              <xsl:choose>
                <xsl:when test="contains(string(doc/arr['flags' = @name]), 'SpecialNeeds')">
                  <img src="{$imagesFolder}spec_needs.png" alt="Caters for Special Needs" />
                </xsl:when>
                <xsl:otherwise>
                  <img src="{$imagesFolder}null_icon.gif" alt="" />
                </xsl:otherwise>
              </xsl:choose>
            </span>
          </p>
        </td>
        <td class="cell_others">
          <p>
            <span class="icons">
              <xsl:choose>
                <xsl:when test="'true' = normalize-space(doc/arr['immediate_vacancies_s' = @name]/str) or '1' = normalize-space(doc/arr['immediate_vacancies_s' = @name]/str)">
                  <img src="{$imagesFolder}vac.png" alt="Current vacancies"  />
                </xsl:when>
                <xsl:otherwise>
                  <img src="{$imagesFolder}null_icon.gif" alt="" />
                </xsl:otherwise>
              </xsl:choose>
              <xsl:choose>
                <xsl:when test="contains(string(doc/arr['flags' = @name]), 'SchoolPickup')">
                  <img src="{$imagesFolder}pickup.png" alt="Pickup service available" />
                </xsl:when>
                <xsl:otherwise>
                  <img src="{$imagesFolder}null_icon.gif" alt="" />
                </xsl:otherwise>
              </xsl:choose>
            </span>
          </p>
        </td>
      </tr>
    </xsl:if>
  </xsl:template>
  <!-- R05: Code required for Table View tool end -->

  <!-- template 'function' for creating short result listing (maplist mode) -->
  <!-- R06: Code required for Map View tool start -->
  <xsl:template match="srw:record" mode="maplist">
    <xsl:variable name="recordType" select="substring(normalize-space(doc/arr[@name = 'repo_url_s']/str), string-length(normalize-space(doc/arr[@name = 'repo_url_s']/str))-2)" />
    <xsl:variable name="position" select="position() div 2" />
    <xsl:variable name="markerNum" select="(position() div 2) - ($startPoint - $sruStartRecord + 1) +1" />
    <xsl:if test="$position &gt;= ($startPoint - $sruStartRecord + 1) and $position &lt; ($startPoint - $sruStartRecord + 1 + $perPage)">
      <div class="mapListDiv">
        <xsl:if test="0 &lt; string-length(doc/double['lat' = @name])">
          <xsl:attribute name="onmouseover">
            <xsl:value-of select="concat('javascript: changeMarker(markerArray[', $position, '], true);')" />
          </xsl:attribute>
          <xsl:attribute name="onmouseout">
            <xsl:value-of select="concat('javascript: changeMarker(markerArray[', $position, ']);')" />
          </xsl:attribute>
        </xsl:if>
        <p>
          <xsl:choose>
            <xsl:when test="0 &lt; string-length(doc/double['lat' = @name])">
              <img src="{$imagesFolder}map_{$markerNum}.gif" alt="Pin {$markerNum}" class="mapPin" />
            </xsl:when>
            <xsl:otherwise>
              <img src="{$imagesFolder}plain_{$markerNum}.gif" alt="Pin {$markerNum} (not shown on map)" class="mapPin" />
            </xsl:otherwise>
          </xsl:choose>
        </p>
        <p class="inline">
          <h3>
            <a class="resultLink">
              <xsl:attribute name="href">
                <xsl:value-of select="concat($detailsPage, '?recordID=')" />
                <xsl:value-of select="normalize-space(doc/str['aggregator.internal.id' = @name])"/>
                <xsl:value-of select="concat('&amp;recordType=', $recordType)" />
                <xsl:if test="0 &lt; string-length(/srw:searchRetrieveResponse/echoedData/queryString/@category)">
                  <xsl:value-of select="concat('&amp;category=', /srw:searchRetrieveResponse/echoedData/queryString/@category)" />
                </xsl:if>
              </xsl:attribute>
              <xsl:value-of select="normalize-space(doc/arr['dc.title' = @name]/str)" />
            </a>
          </h3>
          <span class="description">
            <xsl:choose>
              <xsl:when test="0 &lt; string-length(normalize-space(doc/arr['dc.description' = @name]/str))">
                <xsl:value-of select="normalize-space(doc/arr['dc.description' = @name]/str)" />
              </xsl:when>
              <xsl:otherwise>
                <br />
              </xsl:otherwise>
            </xsl:choose>
          </span>
        </p>
      </div>
    </xsl:if>
  </xsl:template>
  <!-- R06: Code required for Map View tool end -->


  <xsl:template match="text()" />
  <xsl:template match="text()" mode="fullAddress" />
  <xsl:template match="text()" mode="mapPins" />
  <xsl:template match="text()" mode="postcodeOnly" />
  <xsl:template match="text()" mode="list" />
  <xsl:template match="text()" mode="table" />
  <xsl:template match="text()" mode="maplist" />

</xsl:stylesheet>
