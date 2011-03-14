<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
<!-- REQUIRED CODE - LEAVE THIS INTACT WHEN MODIFYING TEMPLATES  -->
<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

<xsl:stylesheet version="1.0"	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
								xmlns:ecdrec="http://dcsf.gov.uk/XMLSchema/Childcare"
								xmlns:fsdrec="http://dcsf.gov.uk/XMLSchema/ServiceDirectory"
								xmlns:srw="http://www.loc.gov/zing/srw/"
                xmlns:facet="http://k-int.com/facet"
                xmlns:disam="http://k-int.com/disambiguation"
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

    <!-- Two page-wide container divs, to allow CSS effect such as drop-shadows around the main content -->
    <div id="outerContainer">
      <div id="innerContainer">

        <!-- Actual content div - all content appears in here by default -->
        <div id="mainContent" class="wide">

          <!-- Standard title div - contains links to directory and subject index, and holds the quick, simple search -->
          <div id="findItTitle">
            <!-- This also has extra divs to help CSS tricks like rounded corners -->
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
                  <a href="{$indexPage}">Subject Index</a>
                </li>
                <!-- <li id="top3"><a href="faq1.html">Search by Questions</a></li> -->
              </ul>
              <div></div>
              <div id="simpleSearchDiv">
                <!-- S01: Simple search tool start -->
                <form name="simpleSearchForm" action="{$resultsPage}" method="GET">
                  <label>Search for:</label>
                  <img id="poweredByIcon"  src="{$imagesFolder}powered_by_logo.gif" alt="Powered by ..." />
                  <input type="text" id="simpleSearchInput" name="freetext" value="" />
                  <input id="searchButton" type="image" src="{$imagesFolder}null_icon.gif" alt="Search" Title="Search"/>
                </form>
                <a id="advSearchLink" href="{$advsearchPage}">Advanced Search</a>
                <p id="poweredBy">
                  Powered by <br />...
                </p>
                <!-- SO1: Simple search tool end -->
              </div>
            </div>
          </div>
          <!-- End title div -->

          <!-- U01: Breadcrumb trail tool -->
          <div id="breadcrumb">
            <p>
              You searched for <xsl:call-template name="readback" />
            </p>
            <div class="clear"></div>
          </div>
          <!-- U01: Breadcrumb trail tool -->

          <!-- Navigation div at top of results, also contains control for choosing results per page-->
          <div id="resultsNav" class="clear">

            <div id="perPageSpacer">&#160;</div>
            <!-- R03: Results set sizing tool start -->
            <div id="perPageControl">
              Results per page:<br />
              <form id="perPage" name="perPage" action="" method="GET">
                <input type="hidden" name="freetext" value="{$searchFreetext}" />
                <input type="hidden" name="title" value="{$searchTitle}" />
                <input type="hidden" name="category" value="{$searchCat}" />
                <input type="hidden" name="subcategory" value="{$searchSubCat}" />
                <input type="hidden" name="subsubcategory" value="{$searchSubSubCat}" />
                <input type="hidden" name="eligibilityCriteria" value="{$searchEligibility}" />
                <input type="hidden" name="location" value="{$searchLocation}" />
                <p>
                  <select name="perPage">
                    <option value="10">
                      <xsl:if test="'10' = $perPage">
                        <xsl:attribute name="selected">
                          <xsl:value-of select="'selected'" />
                        </xsl:attribute>
                      </xsl:if>10
                    </option>
                    <option value="20">
                      <xsl:if test="'20' = $perPage">
                        <xsl:attribute name="selected">
                          <xsl:value-of select="'selected'" />
                        </xsl:attribute>
                      </xsl:if>20
                    </option>
                    <option value="50">
                      <xsl:if test="'50' = $perPage">
                        <xsl:attribute name="selected">
                          <xsl:value-of select="'selected'" />
                        </xsl:attribute>
                      </xsl:if>50
                    </option>
                  </select>
                  <input type="hidden" name="startPoint" value="1" />
                  <input type="hidden" name="filterDist" value="{$filterDist}" />
                  <input type="hidden" name="filters" value="{$filters}" />
                  <input type="hidden" name="national" value="{echoedData/queryString/@national}" />
                  <input type="hidden" name="view" value="{$rawView}" />
                  <input type="hidden" name="sortBy" value="{$sortBy}" />
                  <input type="submit" value="Show" Title="Show Items Per Page" />
                </p>
              </form>
            </div>
            <!-- R03: Results set sizing tool end -->

            <!-- R02: Results set pagination tool start -->
            <div id="resultsCount">
              <p>
                Displaying results <xsl:value-of select="$startPoint" /> to <xsl:value-of select="$endPoint" /> of <xsl:value-of select="$totalRecords" />,
                ordered by <b>
                  <xsl:value-of select="$sortBy" />
                </b>
              </p>
            </div>

            <xsl:choose>
              <xsl:when test ="$pages > 1">

                <div id="pageCount">
                  <xsl:choose>
                    <xsl:when test="1=$thisPage">
                      <span class="previous nonLink">
                        <xsl:text>&#160; </xsl:text>
                      </span>
                    </xsl:when>
                    <xsl:otherwise>
                      <a class="previous">
                        <xsl:attribute name="href">
                          <xsl:call-template name="queryStringer">
                            <xsl:with-param name="newStartPoint" select="$startPoint - $perPage" />
                          </xsl:call-template>
                        </xsl:attribute>Previous
                      </a>
                      <xsl:text>&#160; </xsl:text>
                    </xsl:otherwise>
                  </xsl:choose>

                  <span class="pageNumbers">
                    <xsl:call-template name="pageMaker" />
                  </span>

                  <xsl:choose>
                    <xsl:when test="$pages=$thisPage">
                      <span class="next nonLink">
                        <xsl:text>&#160;</xsl:text>
                      </span>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:text>&#160; </xsl:text>
                      <a class="next">
                        <xsl:attribute name="href">
                          <xsl:call-template name="queryStringer">
                            <xsl:with-param name="newStartPoint" select="$startPoint + $perPage" />
                          </xsl:call-template>
                        </xsl:attribute>Next
                      </a>
                    </xsl:otherwise>
                  </xsl:choose>


                </div>
              </xsl:when>
            </xsl:choose>

            <!-- R02: Results set pagination tool end -->

            <div class="clear"></div>

          </div>
          <!-- End top navigation div -->


          <!-- F01, F02, F03, F04, F05, F06, L01: Filter tools list start -->
          <div id="filterPanel">

            <!--  F01, F02, F03, F04, F05, F06: Any of the active filter tools displayed in their broadening context start 
			        the exact list of possible broadening tools will be dependant upon which filter tools are implemented -->
            <div id="currentFilters">
              <xsl:choose>
                <xsl:when test="/srw:searchRetrieveResponse/echoedData/filterList != not(*) or 1=$geoLocked or 0 &lt; string-length($searchCat) or 0 &lt; string-length($searchEligibility)">
                  <p>
                    Active filters<br />(click to remove):
                  </p>

                  <ul>
                    <xsl:if test="/srw:searchRetrieveResponse/echoedData/filterList != not(*)">
                      <xsl:for-each select="/srw:searchRetrieveResponse/echoedData/filterList/filterName">
                        <xsl:variable name="filterCode"  select="substring(normalize-space(@filterCode), 4)" />
                        <xsl:variable name="filterName">
                          <xsl:choose>
                            <xsl:when test="'ref'=substring(normalize-space(@filterCode), 1, 3)">
                              <xsl:value-of select="$refList/term[identifier=$filterCode]/name" />
                            </xsl:when>
                            <xsl:when test="'acc'=substring(normalize-space(@filterCode), 1, 3)">
                              <xsl:value-of select="$accList/term[identifier=$filterCode]/name" />
                            </xsl:when>
                            <xsl:when test="'lan'=substring(normalize-space(@filterCode), 1, 3)">
                              <xsl:value-of select="$lanList/term[identifier=$filterCode]/name" />
                            </xsl:when>
                            <xsl:otherwise>
                              <xsl:value-of select="." />
                            </xsl:otherwise>
                          </xsl:choose>
                        </xsl:variable>
                        <li>
                          <a>
                            <xsl:attribute name="Title">
                              <xsl:value-of select="concat('Remove Filter for: ',$filterName )"/>
                            </xsl:attribute>
                            <xsl:attribute name="href">
                              <xsl:value-of select="$resultsPage"/>
                              <xsl:call-template name="filterCutter">
                                <xsl:with-param name="filterCode" select="@filterCode" />
                              </xsl:call-template>
                            </xsl:attribute>
                            <img src="{$imagesFolder}cross.gif" class="filterCross" border="0" alt="Click to remove this filter" title="Click to remove this filter" />
                            <xsl:value-of select="$filterName" />
                          </a>
                        </li>
                      </xsl:for-each>
                    </xsl:if>

                    <!-- S02: category tool.  Displayed in its broadening context start -->
                    <xsl:choose>
                      <xsl:when test="0 &lt; string-length($searchSubSubCat)">
                        <li>
                          <a>
                            <xsl:attribute name="Title">
                              <xsl:value-of select="concat('Remove Filter for: ',$subsubcatList/term[identifier=$searchSubSubCat]/name )"/>
                            </xsl:attribute>
                            <xsl:attribute name="href">
                              <xsl:value-of select="$resultsPage"/>?<xsl:call-template name="catCutter">
                                <xsl:with-param name="level" select="'subsubcategory'" />
                              </xsl:call-template>
                            </xsl:attribute>
                            <img src="{$imagesFolder}cross.gif" class="filterCross" border="0" alt="Click to remove this filter" title="Click to remove this filter" />
                            Sub-sub-category (<xsl:value-of select="$subsubcatList/term[identifier=$searchSubSubCat]/name" />)
                          </a>
                        </li>
                      </xsl:when>
                      <xsl:when test="0 &lt; string-length($searchSubCat)">
                        <li>
                          <a>
                            <xsl:attribute name="Title">
                              <xsl:value-of select="concat('Remove Filter for: ',$subcatList/term[identifier=$searchSubCat]/name )"/>
                            </xsl:attribute>
                            <xsl:attribute name="href">
                              <xsl:value-of select="$resultsPage"/>?<xsl:call-template name="catCutter">
                                <xsl:with-param name="level" select="'subcategory'" />
                              </xsl:call-template>
                            </xsl:attribute>
                            <img src="{$imagesFolder}cross.gif" class="filterCross" border="0" alt="Click to remove this filter" title="Click to remove this filter" />
                            Sub-category (<xsl:value-of select="$subcatList/term[identifier=$searchSubCat]/name" />)
                          </a>
                        </li>
                      </xsl:when>
                      <xsl:when test="0 &lt; string-length($searchCat)">
                        <li>
                          <a>
                            <xsl:attribute name="Title">
                              <xsl:value-of select="concat('Remove Filter for: ',$catList/term[identifier=$searchCat]/name )"/>
                            </xsl:attribute>
                            <xsl:attribute name="href">
                              <xsl:value-of select="$resultsPage"/>?<xsl:call-template name="catCutter">
                                <xsl:with-param name="level" select="'category'" />
                              </xsl:call-template>
                            </xsl:attribute>
                            <img src="{$imagesFolder}cross.gif" class="filterCross" border="0" alt="Click to remove this filter" title="Click to remove this filter" />
                            Category (<xsl:value-of select="$catList/term[identifier=$searchCat]/name" />)
                          </a>
                        </li>
                      </xsl:when>
                    </xsl:choose>
                    <!-- S02: category tool.  Displayed in its broadening context end -->

                    <!-- S04: eligibility criteria tool.  Displayed in its broadening context start -->
                    <xsl:if test="0 &lt; string-length($searchEligibility)">
                      <li>
                        <a>
                          <xsl:attribute name="Title">
                            <xsl:value-of select="concat('Remove Filter for: ',$searchEligibility )"/>
                          </xsl:attribute>
                          <xsl:attribute name="href">
                            <xsl:value-of select="$resultsPage"/>?<xsl:call-template name="eligibilityCutter" />
                          </xsl:attribute>
                          <img src="{$imagesFolder}cross.gif" class="filterCross" border="0" alt="Click to remove this filter" title="Click to remove this filter" />
                          Eligibility Criteria
                        </a> - &quot;<i>
                          <xsl:value-of select="$searchEligibility" />
                        </i>&quot;
                      </li>
                    </xsl:if>
                    <!-- S04: eligibility criteria tool.  Displayed in its broadening context end -->

                    <!-- L01: Location / proximity tool.  Displayed in its broadening context start -->
                    <xsl:if test="1=$geoLocked">
                      <li>
                        <a>
                          <xsl:attribute name="Title">
                            <xsl:value-of select="'Remove location Filter:'"/>
                          </xsl:attribute>
                          <xsl:attribute name="href">
                            <xsl:value-of select="$resultsPage"/>?<xsl:call-template name="locationCutter" />
                          </xsl:attribute>
                          <img src="{$imagesFolder}cross.gif" class="filterCross" border="0" alt="Click to remove this filter" title="Click to remove this filter" />
                          Location
                        </a>
                      </li>
                    </xsl:if>
                    <!-- L01: Location / proximity tool.  Displayed in its broadening context end -->
                  </ul>

                </xsl:when>
                <xsl:otherwise>
                  <p>No filters selected</p>
                </xsl:otherwise>
              </xsl:choose>

            </div>
            <!--  F01, F02, F03, F04, F05, F06: Any of the active filter tools displayed in their broadening context end -->

            <!-- L01: Location / proximity filter tool start -->
            <div id="filterLocation" Title="Filters">


              <xsl:if test="'yes' = $locationError">
                <div id="locationError">
                  <p>
                    The location <i>
                      <xsl:value-of select="$searchLocation" />
                    </i> was not recognised (possibly it is too large an area).  Please try another location.
                  </p>
                </div>
              </xsl:if>
              <form id="filterLocationForm" name="filterLocationForm" action="" method="GET">
                <fieldset>
                  <legend>
                    <b>Narrow by location</b>
                  </legend>
                  <input type="hidden" name="freetext" value="{$searchFreetext}" />
                  <input type="hidden" name="title" value="{$searchTitle}" />
                  <input type="hidden" name="category" value="{$searchCat}" />
                  <input type="hidden" name="subcategory" value="{$searchSubCat}" />
                  <input type="hidden" name="subsubcategory" value="{$searchSubSubCat}" />
                  <input type="hidden" name="eligibilityCriteria" value="{$searchEligibility}" />
                  <xsl:choose>
                    <xsl:when test="$geoLocked = 1">
                      <br />
                      <label for="location">
                        that are close to location
                      </label>
                      <input class="postcode" type="text" name="location" maxlength="100" value="{$searchLocation}" title ="(enter a town, an area or postcode)"/>
                      <br />
                      <br />
                      (
                      <label for="filterDist">
                        Maximum distance in
                        miles
                      </label>
                      )
                      <input class="number" type="text" id="filterDist"  name="filterDist" maxlength="6" value="{$filterDist}" />
                      &#160;
                      <input id="filterLocationSubmit" type="image" src="{$imagesFolder}null_icon.gif" alt="Go" Title="Go"/>
                      <br />
                    </xsl:when>
                    <xsl:otherwise>
                      <br />
                      <label for="location" class="screenreaderonly">
                        Location
                        <span>
                          <input class="place" type="text" name="location" maxlength="100" value="" />
                          <input id="filterLocationSubmit" type="image" src="{$imagesFolder}null_icon.gif" alt="Go" title="Go"/>
                        </span>
                        <p>
                          <span id="filterLocationHint">e.g. postcode, town, area..</span>
                        </p>
                      </label>
                    </xsl:otherwise>
                  </xsl:choose>
                  <input type="hidden" name="filters" value="{$filters}" />
                  <input type="hidden" name="perPage" value="{$perPage}" />
                  <input type="hidden" name="sortBy" value="{$sortBy}" />
                  <input type="hidden" name="startPoint" value="1" />
                  <input type="hidden" name="xnational" value="off" />
                  <br />
                  <span id="filterLocationNationwide">
                    <label for="national">
                      <b>Include Nationwide services</b>
                    </label>

                    <input class="national" type="checkbox" name="national" value="on">
                      <xsl:if test="'on' = $national">
                        <xsl:attribute name="checked">checked</xsl:attribute>
                      </xsl:if>
                    </input>

                  </span>
                  <input type="hidden" name="view" value="{$rawView}" />
                  <br/>
                </fieldset>
              </form>

              <!-- L01: Location / proximity filter tool end -->

              <br />

              <!-- F01, F02, F03, F04, F05, F06: Filter tools list start -->

              <fieldset>

                <legend>
                  <b>Narrow by Categories</b>
                </legend>

                <!-- F01: Category filter start -->
                <div id="filterCats" class="filterGroup" >
                  <b>
                    <xsl:choose>
                      <xsl:when test="0 &lt; string-length($searchCat) and 0 &lt; string-length($searchSubCat)">Sub-sub-categories</xsl:when>
                      <xsl:when test="0 &lt; string-length($searchCat)">Subcategories</xsl:when>
                      <xsl:otherwise>Categories</xsl:otherwise>
                    </xsl:choose>
                  </b>:<br />
                  <xsl:choose>
                    <xsl:when test="0 &lt; count($subsubcatList/term[identifier=$listCounts/facet:lst['dc.subject'=@name]/facet:int/@*]) and 0 &lt; string-length($searchCat) and 0 &lt; string-length($searchSubCat) and 0 = string-length($searchSubSubCat)">
                      <ul>
                        <xsl:for-each select="$subsubcatList/term[identifier=$listCounts/facet:lst['dc.subject'=@name]/facet:int/@*]">
                          <xsl:sort select="name" />
                          <li id="catLink{position()}">
                            <a>
                              <xsl:attribute name="Title">
                                <xsl:value-of select ="concat('Filter By Category ', normalize-space(name))"/>
                              </xsl:attribute >
                              <xsl:attribute name="href">
                                <xsl:call-template name="queryStringer">
                                  <xsl:with-param name="parameter1" select="'subsubcategory'" />
                                  <xsl:with-param name="value1" select="identifier" />
                                </xsl:call-template>
                              </xsl:attribute>
                              <xsl:value-of select="normalize-space(name)" />
                            </a> (<xsl:value-of select="normalize-space($listCounts/facet:lst['dc.subject'=@name]/facet:int[@name=current()/identifier])" />)
                          </li>
                        </xsl:for-each>
                      </ul>
                    </xsl:when>
                    <xsl:when test="0 &lt; sum($listCounts/facet:lst['dc.subject'=@name]/facet:int) and 0 &lt; string-length($searchCat) and 0 = string-length($searchSubCat)">
                      <ul>
                        <xsl:for-each select="$subcatList/term[identifier=$listCounts/facet:lst['dc.subject'=@name]/facet:int/@*]">
                          <xsl:sort select="name" />
                          <li id="catLink{position()}">
                            <a>
                              <xsl:attribute name="Title">
                                <xsl:value-of select ="concat('Filter By Category ', normalize-space(name))"/>
                              </xsl:attribute >
                              <xsl:attribute name="href">
                                <xsl:call-template name="queryStringer">
                                  <xsl:with-param name="parameter1" select="'subcategory'" />
                                  <xsl:with-param name="value1" select="identifier" />
                                </xsl:call-template>
                              </xsl:attribute>
                              <xsl:value-of select="normalize-space(name)" />
                            </a> (<xsl:value-of select="normalize-space($listCounts/facet:lst['dc.subject'=@name]/facet:int[@name=current()/identifier])" />)
                          </li>
                        </xsl:for-each>
                      </ul>
                    </xsl:when>
                    <xsl:when test="0 &lt; sum($listCounts/facet:lst['dc.subject'=@name]/facet:int) and 0 = string-length($searchSubCat)">
                      <ul>
                        <xsl:for-each select="$catList/term[identifier=$listCounts/facet:lst['dc.subject'=@name]/facet:int/@*]">
                          <xsl:sort select="name" />
                          <li id="catLink{position()}">
                            <a>
                              <xsl:attribute name="Title">
                                <xsl:value-of select ="concat('Filter By Category ', normalize-space(name))"/>
                              </xsl:attribute >
                              <xsl:attribute name="href">
                                <xsl:call-template name="queryStringer">
                                  <xsl:with-param name="parameter1" select="'category'" />
                                  <xsl:with-param name="value1" select="identifier" />
                                </xsl:call-template>
                              </xsl:attribute>
                              <xsl:value-of select="normalize-space(name)" />
                            </a> (<xsl:value-of select="normalize-space($listCounts/facet:lst['dc.subject'=@name]/facet:int[@name=current()/identifier])" />)
                          </li>
                        </xsl:for-each>
                      </ul>
                    </xsl:when>
                    <xsl:otherwise>No further filters</xsl:otherwise>
                  </xsl:choose>
                </div>
              </fieldset>
              <!-- F01: Category filter end -->

              <div id="filterFacs" class="filterGroup">
                <fieldset>
                  <legend>
                    <b>Narrow by Facilities</b>
                  </legend>
                  <br/>
                  <xsl:choose>
                    <xsl:when test="(false = contains(/srw:searchRetrieveResponse/echoedData/queryString/@filters, 'wAcc') and 0 &lt; /srw:searchRetrieveResponse/srw:extraResponseData/facet:lst['facet_counts'=@name]/facet:lst['facet_fields'=@name]/facet:lst['flags'=@name]/facet:int['WheelChairAccess'=@name]) or 
                                  (false = contains(/srw:searchRetrieveResponse/echoedData/queryString/@filters, 'sNeeds') and 0 &lt; /srw:searchRetrieveResponse/srw:extraResponseData/facet:lst['facet_counts'=@name]/facet:lst['facet_fields'=@name]/facet:lst['flags'=@name]/facet:int['SpecialNeeds'=@name]) or
                                  (false = contains(/srw:searchRetrieveResponse/echoedData/queryString/@filters, 'vacs') and 0 &lt; /srw:searchRetrieveResponse/srw:extraResponseData/facet:lst['facet_counts'=@name]/facet:lst['facet_fields'=@name]/facet:lst['immediate_vacancies_s'=@name]/facet:int) or
                                  (false = contains(/srw:searchRetrieveResponse/echoedData/queryString/@filters, 'pickup') and 0 &lt; /srw:searchRetrieveResponse/srw:extraResponseData/facet:lst['facet_counts'=@name]/facet:lst['facet_fields'=@name]/facet:lst['flags'=@name]/facet:int['SchoolPickup'=@name])">
                      <ul>
                        <!-- F06: Wheelchair access filter start -->
                        <xsl:if test="0 &lt; $filterCountWheelchair">
                          <xsl:call-template name="filterMaker">
                            <xsl:with-param name="filterStem" select="'facilities'" />
                            <xsl:with-param name="filterTitle" select="'facilities'" />
                            <xsl:with-param name="filterCode" select="'wAcc'" />
                            <xsl:with-param name="filterName" select="'Wheelchair Access' " />
                            <xsl:with-param name="filterCount" select="$filterCountWheelchair" />
                          </xsl:call-template>
                        </xsl:if>
                        <!-- F06: Wheelchair access filter end -->

                        <!-- F07: Special needs filter start -->
                        <xsl:if test="0 &lt; $filterCountSpecialNeeds">
                          <xsl:call-template name="filterMaker">
                            <xsl:with-param name="filterStem" select="'facilities'" />
                            <xsl:with-param name="filterTitle" select="'facilities'" />
                            <xsl:with-param name="filterCode" select="'sNeeds'" />
                            <xsl:with-param name="filterName" select="'Caters for Special Needs'" />
                            <xsl:with-param name="filterCount" select="$filterCountSpecialNeeds" />
                          </xsl:call-template>
                        </xsl:if>
                        <!-- F07: Special needs filter end -->

                        <!-- F08: current vacancies filter start -->
                        <xsl:if test="0 &lt; $filterCountVacancies">
                          <xsl:call-template name="filterMaker">
                            <xsl:with-param name="filterStem" select="'facilities'" />
                            <xsl:with-param name="filterTitle" select="'facilities'" />
                            <xsl:with-param name="filterCode" select="'vacs'" />
                            <xsl:with-param name="filterName" select="'Current Vacancies'" />
                            <xsl:with-param name="filterCount" select="$filterCountVacancies" />
                          </xsl:call-template>
                        </xsl:if>
                        <!-- F08: current vacancies filter end -->

                        <!-- F09: has school pickup filter start -->
                        <xsl:if test="0 &lt; $filterCountPickup">
                          <xsl:call-template name="filterMaker">
                            <xsl:with-param name="filterStem" select="'facilities'" />
                            <xsl:with-param name="filterTitle" select="'facilities'" />
                            <xsl:with-param name="filterCode" select="'pickup'" />
                            <xsl:with-param name="filterName" select="'School Pickups'" />
                            <xsl:with-param name="filterCount" select="$filterCountPickup" />
                          </xsl:call-template>
                        </xsl:if>
                        <!-- F09: has school pickup filter end -->
                      </ul>
                    </xsl:when>
                    <xsl:otherwise>No further filters</xsl:otherwise>
                  </xsl:choose>
                  <br/>
                </fieldset>
              </div>

              <!-- F02: Age range filter start -->
              <div id="filterAges" class="filterGroup">
                <fieldset >
                  <legend>
                    <b>Narrow by Age ranges</b>
                  </legend>
                  <br/>
                  <xsl:choose>
                    <xsl:when test="false = contains(/srw:searchRetrieveResponse/echoedData/queryString/@filters, 'yrs')">
                      <ul>
                        <xsl:call-template name="filterMaker">
                          <xsl:with-param name="filterStem" select="'age'" />
                          <xsl:with-param name="filterTitle" select="'age'" />
                          <xsl:with-param name="filterCode" select="'yrs0-1'" />
                          <xsl:with-param name="filterName" select="'0-1 year'" />
                        </xsl:call-template>
                        <xsl:call-template name="filterMaker">
                          <xsl:with-param name="filterStem" select="'age'" />
                          <xsl:with-param name="filterTitle" select="'age'" />
                          <xsl:with-param name="filterCode" select="'yrs1-4'" />
                          <xsl:with-param name="filterName" select="'1-4 years'" />
                        </xsl:call-template>
                        <xsl:call-template name="filterMaker">
                          <xsl:with-param name="filterStem" select="'age'" />
                          <xsl:with-param name="filterTitle" select="'age'" />
                          <xsl:with-param name="filterCode" select="'yrs5-10'" />
                          <xsl:with-param name="filterName" select="'5-10 years'" />
                        </xsl:call-template>
                        <xsl:call-template name="filterMaker">
                          <xsl:with-param name="filterStem" select="'age'" />
                          <xsl:with-param name="filterTitle" select="'age'" />
                          <xsl:with-param name="filterCode" select="'yrs10-18'" />
                          <xsl:with-param name="filterName" select="'10-18 years'" />
                        </xsl:call-template>
                        <xsl:call-template name="filterMaker">
                          <xsl:with-param name="filterStem" select="'age'" />
                          <xsl:with-param name="filterTitle" select="'age'" />
                          <xsl:with-param name="filterCode" select="'yrs18-25'" />
                          <xsl:with-param name="filterName" select="'18-25 years'" />
                        </xsl:call-template>
                        <xsl:call-template name="filterMaker">
                          <xsl:with-param name="filterStem" select="'age'" />
                          <xsl:with-param name="filterTitle" select="'age'" />
                          <xsl:with-param name="filterCode" select="'yrs25'" />
                          <xsl:with-param name="filterName" select="'25+ years'" />
                        </xsl:call-template>
                      </ul>
                    </xsl:when>
                    <xsl:otherwise>No further filters</xsl:otherwise>
                  </xsl:choose>
                  <br/>
                </fieldset>
              </div>
              <!-- F02: Age range filter end -->

              <!-- F03: Referral criteria filter start -->
              <div id="filterRefs" class="filterGroup">
                <fieldset>
                  <legend>
                    <b>
                      Narrow by Referral<br />criteria
                    </b>
                  </legend>
                  <br/>
                  <xsl:choose>
                    <xsl:when test="0 = count($refList/term[identifier=$listCounts/facet:lst['referral_criteria_s'=@name]/facet:int/@*][false = contains($filters, concat('ref', identifier))])">No further filters</xsl:when>
                    <xsl:when test="0 &lt; sum($listCounts/facet:lst['referral_criteria_s'=@name]/facet:int)">
                      <ul>
                        <xsl:for-each select="$refList/term[identifier=$listCounts/facet:lst['referral_criteria_s'=@name]/facet:int/@*][false=contains($filters, concat('ref', identifier))]">
                          <xsl:sort select="name"/>
                          <xsl:call-template name="filterMaker">
                            <xsl:with-param name="filterStem" select="'ref'" />
                            <xsl:with-param name="filterTitle" select="'Referral'" />
                            <xsl:with-param name="filterCode" select="concat('ref', identifier)" />
                            <xsl:with-param name="filterName" select="name" />
                            <xsl:with-param name="filterCount" select="normalize-space($listCounts/facet:lst['referral_criteria_s'=@name]/facet:int[@name=current()/identifier])" />
                          </xsl:call-template>
                        </xsl:for-each>
                      </ul>
                    </xsl:when>
                    <xsl:otherwise>No further filters</xsl:otherwise>
                  </xsl:choose>
                  <br/>
                  <br/>
                </fieldset>
              </div>
              <!-- F03: Referral criteria filter end -->

              <!-- F04: Means of access filter start -->
              <div id="filterAccess" class="filterGroup">
                <fieldset>
                  <legend>
                    <b>
                      Narrow by <br />Accessed Via
                    </b>
                  </legend>
                  <br/>
                  <xsl:choose>
                    <xsl:when test="0 = count($accList/term[identifier=$listCounts/facet:lst['mode_of_access_s'=@name]/facet:int/@*][false = contains($filters, concat('acc', identifier))])">No further filters</xsl:when>
                    <xsl:when test="0 &lt; sum($listCounts/facet:lst['mode_of_access_s'=@name]/facet:int)">
                      <ul>
                        <xsl:for-each select="$accList/term[identifier=$listCounts/facet:lst['mode_of_access_s'=@name]/facet:int/@*]">
                          <xsl:sort select="name"/>
                          <xsl:call-template name="filterMaker">
                            <xsl:with-param name="filterStem" select="'acc'" />
                            <xsl:with-param name="filterTitle" select="'Means'" />
                            <xsl:with-param name="filterCode" select="concat('acc', identifier)" />
                            <xsl:with-param name="filterName" select="name" />
                            <xsl:with-param name="filterCount" select="normalize-space($listCounts/facet:lst['mode_of_access_s'=@name]/facet:int[@name=current()/identifier])" />
                          </xsl:call-template>
                        </xsl:for-each>
                      </ul>
                    </xsl:when>
                    <xsl:otherwise>No further filters</xsl:otherwise>
                  </xsl:choose>
                  <br/>
                  <br/>
                </fieldset>
              </div>
              <!-- F04: Means of access filter end -->

              <!-- F05: Languages filter start -->
              <div id="filterLang" class="filterGroup">
                <fieldset>
                  <legend>
                    <b>
                      Narrow by Languages<br/>spoken
                    </b>
                  </legend>
                  <br/>
                  <xsl:choose>
                    <xsl:when test="0 = count($lanList/term[identifier=$listCounts/facet:lst['language_spoken_s'=@name]/facet:int/@*][false = contains($filters, concat('lan', identifier))])">No further filters</xsl:when>
                    <xsl:when test="0 &lt; sum($listCounts/facet:lst['language_spoken_s'=@name]/facet:int)">
                      <ul>
                        <xsl:for-each select="$lanList/term[identifier=$listCounts/facet:lst['language_spoken_s'=@name]/facet:int/@*][false=contains($filters, concat('lan', identifier))]">
                          <xsl:sort select="name"/>
                          <xsl:call-template name="filterMaker">
                            <xsl:with-param name="filterStem" select="'lan'" />
                            <xsl:with-param name="filterTitle" select="'Languages'" />
                            <xsl:with-param name="filterCode" select="concat('lan', identifier)" />
                            <xsl:with-param name="filterName" select="name" />
                            <xsl:with-param name="filterCount" select="normalize-space($listCounts/facet:lst['language_spoken_s'=@name]/facet:int[@name=current()/identifier])" />
                          </xsl:call-template>
                        </xsl:for-each>
                      </ul>
                    </xsl:when>
                    <xsl:otherwise>No further filters</xsl:otherwise>
                  </xsl:choose>
                  <br/>
                  <br/>
                </fieldset>
              </div>
              <!-- F05: Languages filter end -->

              <div class="clear">&#160;</div>

            </div>
            <!-- F01, F02, F03, F04, F05, F06: Filter tools list end -->

            <div class="clear">&#160;</div>

          </div>
          <!-- F01, F02, F03, F04, F05, F06, L01: Filter tools list end -->


          <!-- Main results panel, containing all information -->
          <div id="resultsPanel">

            <!-- D01: Disambiguation tool start -->
            <!-- Test if we have english places returned -->                        
            <xsl:if test="0 &lt; count(srw:extraResponseData/disam:alternatives/disam:alternative[contains(@title, 'England,')])">
              <div id="locationDisambiguation">
                <p>
                  We found multiple matches for <i>
                    <xsl:value-of select="$searchLocation" />
                  </i>. Did you mean:<br />
                </p>
                <ul>
                  <xsl:for-each select="srw:extraResponseData/disam:alternatives/disam:alternative[contains(@title, 'England,')]">
                    <li id="disambiguationLink{position()}">
                      <a>
                        <xsl:attribute name="href">
                          <xsl:call-template name="queryStringer">
                            <xsl:with-param name="parameter1" select="'location'" />
                            <xsl:with-param name="value1" select="@title" />
                          </xsl:call-template>
                        </xsl:attribute>
                        <xsl:value-of select="normalize-space(@title)" />
                      </a>
                    </li>
                  </xsl:for-each>
                </ul>
                <p id="currentResults">
                  <i>
                  <xsl:choose>
                    <xsl:when test="contains(srw:extraResponseData/disam:alternatives/disam:alternative/@title, 'England,')">
                      (the results below are matches for 
                        <xsl:value-of select="normalize-space(srw:extraResponseData/disam:alternatives/disam:alternative/@title)" />
                        )
                      </xsl:when>
                    <xsl:otherwise>
                      (please select a location above to view your results)
                      
                    </xsl:otherwise>
                    
                  </xsl:choose>
                  </i>
                </p>
              </div>
            </xsl:if>
            <xsl:if test=" 3 &lt; count(srw:extraResponseData/disam:alternatives/disam:alternative[contains(@title, 'England,')])">
              <script type="text/javascript">
                addLoadEvent( function() { compressItem('disambiguation', <xsl:value-of select="count(srw:extraResponseData/disam:alternatives/disam:alternative[contains(@title, 'England,')])" />) } );
              </script>
            </xsl:if>

            <!-- D01: Disambiguation tool end -->


            <!-- Top tabs - deleting one of these will remove access to that view of the results (but will not remove the results themselves) -->
            <div id="resultsTabs">

              <!-- R04: List view tool (tab head) start -->
              <span id="tab1" class="tabLink">
                <xsl:choose>
                  <xsl:when test="'resultsArea1' = $view">
                    <span class="thisTabLeft">&#160;</span>
                    <span class="thisTabMid">
                      <a>
                        <xsl:attribute name="href">
                          <xsl:call-template name="queryStringer">
                            <xsl:with-param name="parameter1" select="'view'" />
                            <xsl:with-param name="value1" select="'list'" />
                            <xsl:with-param name="newStartPoint" select="$startPoint" />
                          </xsl:call-template>
                        </xsl:attribute>List View
                      </a>
                    </span>
                    <span class="thisTabRight">&#160;</span>
                  </xsl:when>
                  <xsl:otherwise>
                    <span class="tabLeft">&#160;</span>
                    <span class="tabMid">
                      <a>
                        <xsl:attribute name="href">
                          <xsl:call-template name="queryStringer">
                            <xsl:with-param name="parameter1" select="'view'" />
                            <xsl:with-param name="value1" select="'list'" />
                            <xsl:with-param name="newStartPoint" select="$startPoint" />
                          </xsl:call-template>
                        </xsl:attribute>List View
                      </a>
                    </span>
                    <span class="tabRight">&#160;</span>
                  </xsl:otherwise>
                </xsl:choose>
              </span>
              <!-- RO4: List view tool (tab head) end -->

              <!-- R05: Table view tool (tab head) start -->
              <span id="tab2" class="tabLink">
                <xsl:choose>
                  <xsl:when test="'resultsArea2' = $view">
                    <span class="thisTabLeft">&#160;</span>
                    <span class="thisTabMid">
                      <a>
                        <xsl:attribute name="href">
                          <xsl:call-template name="queryStringer">
                            <xsl:with-param name="parameter1" select="'view'" />
                            <xsl:with-param name="value1" select="'table'" />
                            <xsl:with-param name="newStartPoint" select="$startPoint" />
                          </xsl:call-template>
                        </xsl:attribute>Table View
                      </a>
                    </span>
                    <span class="thisTabRight">&#160;</span>
                  </xsl:when>
                  <xsl:otherwise>
                    <span class="tabLeft">&#160;</span>
                    <span class="tabMid">
                      <a>
                        <xsl:attribute name="href">
                          <xsl:call-template name="queryStringer">
                            <xsl:with-param name="parameter1" select="'view'" />
                            <xsl:with-param name="value1" select="'table'" />
                            <xsl:with-param name="newStartPoint" select="$startPoint" />
                          </xsl:call-template>
                        </xsl:attribute>Table View
                      </a>
                    </span>
                    <span class="tabRight">&#160;</span>
                  </xsl:otherwise>
                </xsl:choose>
              </span>
              <!-- RO5: Table view tool (tab head) end -->

              <!-- R06: Map view tool (tab head) start -->
              <xsl:if test="$geoLocked=1 and $showMap = 'yes'">
                <span id="tab3" class="tabLink">
                  <xsl:choose>
                    <xsl:when test="'resultsArea3' = $view">
                      <span class="thisTabLeft">&#160;</span>
                      <span class="thisTabMid">
                        <a>
                          <xsl:attribute name="href">
                            <xsl:call-template name="queryStringer">
                              <xsl:with-param name="parameter1" select="'view'" />
                              <xsl:with-param name="value1" select="'map'" />
                              <xsl:with-param name="newStartPoint" select="$startPoint" />
                            </xsl:call-template>
                          </xsl:attribute>Map View
                        </a>
                      </span>
                      <span class="thisTabRight">&#160;</span>
                    </xsl:when>
                    <xsl:otherwise>
                      <span class="tabLeft">&#160;</span>
                      <span class="tabMid">
                        <a>
                          <xsl:attribute name="href">
                            <xsl:call-template name="queryStringer">
                              <xsl:with-param name="parameter1" select="'view'" />
                              <xsl:with-param name="value1" select="'map'" />
                              <xsl:with-param name="newStartPoint" select="$startPoint" />
                            </xsl:call-template>
                          </xsl:attribute>Map View
                        </a>
                      </span>
                      <span class="tabRight">&#160;</span>
                    </xsl:otherwise>
                  </xsl:choose>
                </span>
              </xsl:if>
              <!-- R06: Map view tool (tab head) end -->

            </div>
            <!-- End of tabs -->

            <!-- R04: List view tool (results content) start -->
            <div id="resultsArea1">
              <xsl:attribute name="style">
                <xsl:if test="'resultsArea1' != $view">display: none</xsl:if>
              </xsl:attribute>

              <div class="resultsBody">

                <xsl:choose>
                  <xsl:when test="0 &lt; $totalRecords">
                    <!-- R01: Results sorting tool start -->
                    <div id="sorting">
                      <p>
                        Order by:
                        <xsl:choose>
                          <xsl:when test="$sortBy != 'relevance'">
                            <a class="sortLink">
                              <xsl:attribute name="href">
                                <xsl:call-template name="queryStringer">
                                  <xsl:with-param name="parameter1" select="'sortBy'" />
                                  <xsl:with-param name="value1" select="'relevance'" />
                                  <xsl:with-param name="parameter2" select="'view'" />
                                  <xsl:with-param name="value2" select="'list'" />
                                </xsl:call-template>
                              </xsl:attribute>relevance
                            </a> -
                          </xsl:when>
                          <xsl:otherwise>
                            <span class="currentSort">
                              relevance <img src="{$imagesFolder}tri.gif" alt="Ordered by relevance" title="Ordered by relevance" />
                            </span> -
                          </xsl:otherwise>
                        </xsl:choose>
                        <xsl:choose>
                          <xsl:when test="$sortBy != 'name'">
                            <a class="sortLink">
                              <xsl:attribute name="href">
                                <xsl:call-template name="queryStringer">
                                  <xsl:with-param name="parameter1" select="'sortBy'" />
                                  <xsl:with-param name="value1" select="'name'" />
                                  <xsl:with-param name="parameter2" select="'view'" />
                                  <xsl:with-param name="value2" select="'list'" />
                                </xsl:call-template>
                              </xsl:attribute>name
                            </a> -
                          </xsl:when>
                          <xsl:otherwise>
                            <span class="currentSort">
                              name <img src="{$imagesFolder}tri.gif" alt="Ordered from A to Z" title="Ordered from A to Z" />
                            </span> -
                          </xsl:otherwise>
                        </xsl:choose>
                        <xsl:choose>
                          <xsl:when test="($sortBy = 'distance') and ($geoLocked = 1)">
                            <span class="currentSort">
                              distance <img src="{$imagesFolder}tri.gif" alt="Ordered from nearest to farthest" title="Ordered from nearest to farthest" />
                            </span> -
                          </xsl:when>
                          <xsl:when test="($sortBy != 'distance') and ($geoLocked = 1)">
                            <a class="sortLink">
                              <xsl:attribute name="href">
                                <xsl:call-template name="queryStringer">
                                  <xsl:with-param name="parameter1" select="'sortBy'" />
                                  <xsl:with-param name="value1" select="'distance'" />
                                  <xsl:with-param name="parameter2" select="'view'" />
                                  <xsl:with-param name="value2" select="'list'" />
                                </xsl:call-template>
                              </xsl:attribute>distance
                            </a> -
                          </xsl:when>
                          <xsl:otherwise>
                          </xsl:otherwise>
                        </xsl:choose>
                        <xsl:choose>
                          <xsl:when test="$sortBy = 'last updated'">
                            <span class="currentSort">
                              last updated <img src="{$imagesFolder}tri.gif" alt="Ordered from most to least recent" title="Ordered from most to least recent" />
                            </span>
                          </xsl:when>
                          <xsl:otherwise>
                            <a class="sortLink">
                              <xsl:attribute name="href">
                                <xsl:call-template name="queryStringer">
                                  <xsl:with-param name="parameter1" select="'sortBy'" />
                                  <xsl:with-param name="value1" select="'last+updated'" />
                                  <xsl:with-param name="parameter2" select="'view'" />
                                  <xsl:with-param name="value2" select="'list'" />
                                </xsl:call-template>
                              </xsl:attribute>last updated
                            </a>
                          </xsl:otherwise>
                        </xsl:choose>
                      </p>
                    </div>
                    <!-- R01: Results sorting tool end -->


                    <!-- U02: Key to icons tool start -->
                    <div id="key" class="clearRight">
                      <!-- Again, extra divs for CSS effects -->
                      <div id="keyTitle">
                        <div id="keyTitle2">
                          <h2>Key:</h2>
                        </div>
                      </div>

                      <div id="keyContents">
                        <p class="icons">
                          <img src="{$imagesFolder}national.png" alt="Nationwide service" title="Nationwide service" /> Nationwide services
                        </p>
                        <p class="icons">
                          <img src="{$imagesFolder}wheelchair.png" alt="Wheelchair access" title="Wheelchair access"/> Wheelchair access
                        </p>
                        <p class="icons">
                          <img src="{$imagesFolder}spec_needs.png" alt="Caters for Special Needs" title="Caters for Special Needs" /> Caters for Special Needs
                        </p>
                        <p class="icons">
                          <img src="{$imagesFolder}dietary.png" alt="Special Dietary provision" title="Special Dietary provision" /> Special Dietary provision
                        </p>
                        <p class="icons">
                          <img src="{$imagesFolder}vac.png" alt="Current vacancies"  title="Current vacancies" /> Current vacancies
                        </p>
                        <p class="icons">
                          <img src="{$imagesFolder}pickup.png" alt="Pickup service available" title="Pickup service available" /> Pickup service available
                        </p>
                      </div>

                    </div>
                    <!-- U02: Key to icons tool end -->

                    <div id="resultsListDiv">
                      <ol class="resultsList">
                        <xsl:apply-templates mode="list"/>
                      </ol>
                    </div>
                  </xsl:when>
                  <xsl:otherwise>
                    <h3 class="no_results">No results</h3>
                  </xsl:otherwise>
                </xsl:choose>

                <div class="clear"></div>

              </div>

            </div>
            <!-- R04: List view tool (results content) end -->

            <!-- R05: Table view tool (results content) start -->
            <div id="resultsArea2">
              <xsl:attribute name="style">
                <xsl:if test="'resultsArea2' != $view">display: none</xsl:if>
              </xsl:attribute>

              <div class="resultsBody">
                <xsl:choose>
                  <xsl:when test="0 &lt; $totalRecords">
                    <table class="resultsTable" summary="Results of search. Results {$startPoint} to {$endPoint} of {$totalRecords} ordered by {$sortBy}">

                      <thead>
                        <tr>
                          <!-- R01: Results sorting tool start -->
                          <xsl:choose>
                            <xsl:when test="$sortBy = 'name'">
                              <th class="cell_description currentSort">
                                Name <img src="{$imagesFolder}tri.gif" alt="Ordered from A to Z" title="Ordered from A to Z" />
                              </th>
                            </xsl:when>
                            <xsl:otherwise>
                              <th class="cell_description">
                                <a class="sortLink">
                                  <xsl:attribute name="href">
                                    <xsl:call-template name="queryStringer">
                                      <xsl:with-param name="parameter1" select="'sortBy'" />
                                      <xsl:with-param name="value1" select="'name'" />
                                      <xsl:with-param name="parameter2" select="'view'" />
                                      <xsl:with-param name="value2" select="'table'" />
                                    </xsl:call-template>
                                  </xsl:attribute>Name
                                </a>
                              </th>
                            </xsl:otherwise>
                          </xsl:choose>
                          <xsl:if test="$geoLocked = 1">
                            <xsl:choose>
                              <xsl:when test="($sortBy = 'distance')">
                                <th class="cell_distance currentSort">
                                  Distance <img src="{$imagesFolder}tri.gif" alt="Ordered from nearest to farthest" title="Ordered from nearest to farthest" />
                                </th>
                              </xsl:when>
                              <xsl:when test="($sortBy != 'distance')">
                                <th class="cell_distance">
                                  <a class="sortLink">
                                    <xsl:attribute name="href">
                                      <xsl:call-template name="queryStringer">
                                        <xsl:with-param name="parameter1" select="'view'" />
                                        <xsl:with-param name="value1" select="'table'" />
                                        <xsl:with-param name="parameter2" select="'sortBy'" />
                                        <xsl:with-param name="value2" select="'distance'" />
                                      </xsl:call-template>
                                    </xsl:attribute>Distance
                                  </a>
                                </th>
                              </xsl:when>
                              <xsl:otherwise>
                                <th class="cell_distance">Distance</th>
                              </xsl:otherwise>
                            </xsl:choose>
                          </xsl:if>
                          <!-- R01: Results sorting tool end -->
                          <th class="cell_ages" abbr="Age Range">Age Range</th>
                          <th class="cell_national" abbr="Nationwide">Nationwide</th>
                          <th class="cell_facilities" abbr="Facilities">Facilities</th>
                          <th class="cell_others" abbr="Other">Other</th>
                        </tr>
                      </thead>
                      <tbody>
                        <xsl:apply-templates mode="table"/>
                      </tbody>
                    </table>
                  </xsl:when>

                  <xsl:otherwise>
                    <h3 class="no_results">No results</h3>
                  </xsl:otherwise>
                </xsl:choose>

                <div class="clear"></div>

              </div>

            </div>
            <!-- R05: Table view tool (results content)  end -->

            <!-- R06: Map view tool (results content)  start -->
            <xsl:if test="$geoLocked=1 and $showMap = 'yes'">
              <div id="resultsArea3">
                <xsl:attribute name="style">
                  <xsl:if test="'resultsArea3' != $view">display: none</xsl:if>
                </xsl:attribute>

                <div class="resultsBody">

                  <xsl:choose>
                    <xsl:when test="0 &lt; $totalRecords">
                      <h3 id="noMapText">You need JavaScript enabled to view the map</h3>

                      <div id="mapListings">
                        <div class="mapListDiv" onmouseover="javascript: changeMarker(markerArray[0], true);" onmouseout="javascript: changeMarker(markerArray[0]);">
                          <p>
                            <img src="{$imagesFolder}map_home.gif" alt="Your Location" title="Your Location" class="mapPin" />
                          </p>
                          <p class="inline">
                            <h3>
                              Your Location
                            </h3>
                            <br />
                          </p>
                        </div>
                        <xsl:apply-templates mode="maplist" />
                      </div>
                    </xsl:when>

                    <xsl:otherwise>
                      <h3 class="no_results">No results</h3>
                    </xsl:otherwise>
                  </xsl:choose>

                  <div class="clear"></div>

                </div>

              </div>
            </xsl:if>
            <!-- R06: Map view tool (results content) end -->

          </div>
          <!-- End overall results panel div -->


          <div id="resultsNavBottom" class="navBottom clear">

            <!-- R02: Results set pagination tool start -->
            <div id="resultsCountBottom">
              <p>
                Displaying results <xsl:value-of select="$startPoint" /> to <xsl:value-of select="$endPoint" />
                of <xsl:value-of select="$totalRecords" />,
                ordered by <b>
                  <xsl:value-of select="$sortBy" />
                </b>
              </p>
            </div>

            <xsl:choose>
              <xsl:when test ="$pages > 1">
                <div id="pageCountBottom">
                  <xsl:choose>
                    <xsl:when test="1=$thisPage">
                      <span class="previous nonLink">
                        <xsl:text>&#160;</xsl:text>
                      </span>
                    </xsl:when>
                    <xsl:otherwise>
                      <a class="previous">
                        <xsl:attribute name="href">
                          <xsl:call-template name="queryStringer">
                            <xsl:with-param name="newStartPoint" select="$startPoint - $perPage" />
                          </xsl:call-template>
                        </xsl:attribute>Previous
                      </a>
                      <xsl:text>&#160; </xsl:text>
                    </xsl:otherwise>
                  </xsl:choose>
                  <span class="pageNumbers">
                    <xsl:call-template name="pageMaker" />
                  </span>
                  <xsl:choose>
                    <xsl:when test="$pages=$thisPage">
                      <span class="next nonLink">
                        <xsl:text>&#160; </xsl:text>
                      </span>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:text>&#160; </xsl:text>
                      <a class="next">
                        <xsl:attribute name="href">
                          <xsl:call-template name="queryStringer">
                            <xsl:with-param name="newStartPoint" select="$startPoint + $perPage" />
                          </xsl:call-template>
                        </xsl:attribute>Next
                      </a>
                    </xsl:otherwise>
                  </xsl:choose>
                </div>
              </xsl:when>
            </xsl:choose>
          </div>


          <!-- R02: Results set pagination tool end -->
          <!-- End bottom navigation div -->

        </div>
        <!-- End main content div -->

      </div>
    </div>
    <!-- End container divs -->


  </xsl:template>

</xsl:stylesheet>