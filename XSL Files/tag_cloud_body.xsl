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

  <xsl:variable name="maxSize">
    <xsl:for-each select="/topTerms/term/occurence">
      <xsl:sort data-type="number" select="@logCount" order="descending" />
      <xsl:if test="1=position()">
        <xsl:value-of select="@logCount"/>
      </xsl:if>
    </xsl:for-each>
  </xsl:variable>
  <xsl:variable name="minSize">
    <xsl:for-each select="/topTerms/term/occurence">
      <xsl:sort data-type="number" select="@logCount" />
      <xsl:if test="1=position()">
        <xsl:value-of select="@logCount"/>
      </xsl:if>
    </xsl:for-each>
  </xsl:variable>

  <xsl:template match="text()" />

<xsl:template match="/topTerms">
<!-- - - - - - - - - - -->
<!-- END REQUIRED CODE -->
<!-- - - - - - - - - - -->

      <div id="outerContainer">
        <div id="innerContainer">

          <div id="mainContent" class="wide">

            <!-- Standard header section -->
            <div id="findItTitle">
              <div id="findIt">
                <div id="findIt2">
                  <a href="{$homepage}" accesskey="1">
                    <img src="{$imagesFolder}banner.jpg" alt="Homepage" />
                  </a>
                </div>
              </div>
              <div id="linksBar">
                <ul id="pageLinks">
                  <li id="top1">
                    <span class="here">Directory</span>
                  </li>
                  <li id="top2">
                    <a href="{$indexPage}">Subject Index</a>
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

            <!-- Main directory section -->
            <div id="tabDirectory">

              <!-- Top header, could optionally contain some more guidance or information -->
              <div id="tabDirectoryHeader" class="headerPane">
                <p class="infoText">Click to see services in each category</p>
              </div>

              <!-- Lower section, containing actual directory listings -->
              <div id="directoryList" class="lowerPane">

                <div id="tag_cloud">
                  <div id="tag_cloud2">
                    <xsl:for-each select="term">
                      <xsl:sort select="name" />
                      <!-- The $size variable calculates the relative size for each link -->
                      <xsl:variable name="size" select="75 + round(100 * (occurence/@logCount - $minSize) div ($maxSize - $minSize))" />
                      <!-- inline style added to resize the links -->
                      <span style="font-size: {$size}%">
                        <a class="cloudTerm" href="{$locationPage}?category={identifier}">
                          <xsl:value-of select="normalize-space(name)"/>
                        </a>
                      </span>&#160;
                    </xsl:for-each>
                  </div>
                </div>

                <!-- Clearing div to ensure the background extends around the (floated) columns -->
                <div class="clear">&#160;</div>

              </div><!-- end of lower section div -->

            </div><!-- end of tabDirectory div -->

          </div><!-- end of mainContent div -->

        </div>
      </div>
      
      <!-- The 'screen' to stop users clicking on anything other than the dialogue box -->
      <div id="location_screen"></div>
      <!-- Dialogue box which prompts users for a location once a category is selected -->
      <div id="location_dialog" class="noShow">
        <div id="searchPlace">
          <p id="selectionReadout" class="infoText">
            <!-- TODO - change this to give results count, not subcat count -->
            The <span id="selectedCatName" class="searchTerm">chosen</span> category contains <span id="catResultCount">numerous</span> records.
          </p>
          <p class="infoText">You might like to narrow down your results by choosing a location</p>
          <br />
          <form id="locationForm" name="locationForm" action="{$resultsPage}" method="GET">
            <input id="category" type="hidden" name="category" value="" />
            <p>
              <label>Location: </label>
            </p>
            <input id="locationInput" type="text" name="location" />&#160;
            <input id="narrowButton" type="submit" value="Narrow results" />
            <p>e.g. postcode, town, area..</p>
          </form>
        </div>

        <div id="searchAllButton">
          <a id="showAllButton" href="{$resultsPage}">
            <img src="{$imagesFolder}show_all.gif" alt="Show all results" />
          </a>
        </div>
        <div id="cancelLocation">
          <a href="{$directoryPage}">Cancel</a>
        </div>
      </div>

</xsl:template>

</xsl:stylesheet>