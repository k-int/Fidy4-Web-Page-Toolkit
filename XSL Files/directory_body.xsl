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

  <xsl:variable name="catList" select="/srw:searchRetrieveResponse/controlledListData/topTerms" />
  <!-- Variable for number of categories to show per column - only required if generating columns dynamically (see below) -->
  <xsl:variable name="perColumn" select="'7'" />
  <!-- suggested range 4 - 10 -->

  <!-- If used, this template will automatically generate columns of categories -->
  <xsl:template name="columnMaker">
    <xsl:param name="i" />
    <xsl:if test="$i &lt; ceiling(count(controlledListData/topTerms/term) div $perColumn) +1">
      <div class="directoryColumn" style="width: {(91 div ceiling(count(controlledListData/topTerms/term) div $perColumn))}%;">
        <!-- inline style added to resize column width -->
        <xsl:for-each select="facet:int[@name=$catList/term/identifier]">
          <xsl:if test="position() &gt; ($perColumn * ($i - 1)) and position() &lt; ($perColumn * $i) +1">
            <xsl:apply-templates select="$catList/term"/>
            <!-- this applies the 'catMaker' template -->
          </xsl:if>
        </xsl:for-each>
      </div>
      <xsl:call-template name="columnMaker">
        <xsl:with-param name="i" select="$i + 1" />
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <!-- This section generates the top-level categories, consisting of the category name and a number of examples (see the next section) -->
  <xsl:template name="catMaker" match="term">
    <xsl:variable name="linkPage">
      <xsl:choose>
        <xsl:when test="50 &lt; normalize-space(occurence)">
          <xsl:value-of select="$locationPage"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$resultsPage"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <div class="topCat">
      <div class="topCat2">
        <a class="browseTerm" href="{$linkPage}?category={identifier}">
          <xsl:value-of select="name"/>
        </a>
        <xsl:if test="string-length(occurence) &gt; 0">
          <xsl:text> (</xsl:text>
          <xsl:value-of select="occurence"/>
          <xsl:text>)</xsl:text>
        </xsl:if>
        <span class="browseExample">
          e.g. <xsl:apply-templates select="termChildren" />
        </span>

        <!-- this applies the 'exampleMaker' template -->
      </div>
    </div>
  </xsl:template>

  <!-- Here you can select three (or more) examples to appear under the main headings.  The number after 'position() = ' selects the relevant term from the vocabulary.  -->
  <!-- You can add as many examples as you like, but the position() must equate to a node that exists (ie you can't specify a number greater than the number of subcategories in the category -->
  <!-- You should also ensure that the final line has the highest number, as this prevents an extra comma being written out -->
  <xsl:template name="exampleMaker" match="termChildren">
    <xsl:for-each select="term">
      <xsl:if test="position() = 6">
        <!-- suggested range 1 - 10 -->
        <xsl:value-of select="concat(name, ', ')" />
      </xsl:if>
      <xsl:if test="position() = 1">
        <!-- suggested range 1 - 10 -->
        <xsl:value-of select="concat(name, ', ')" />
      </xsl:if>
      <xsl:if test="position() = 9">
        <!-- suggested range 3 - 10 -->
        <xsl:value-of select="name" />
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

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

            <!-- Lower seciton, containing actual directory listings -->
            <div id="directoryList" class="lowerPane">

              <!-- Use this section to automatically generate columns, with a set number of items in each -->
              <!-- This is currently unused, as the manual version (below) allows a longer column in the middle, giving a more balanced appearance -->
              <!--
                  <xsl:call-template name="columnMaker">
                    <xsl:with-param name="i" select="'1'" />
                  </xsl:call-template>
                  -->
              <!-- end of auto-column section -->

              <!-- Use this section if you want 3 columns, with the centre one the largest -->
              <!-- Delete this section if you are using the auto-column section above -->
              <!-- First column, 6 items -->
              <div class="directoryColumn">
                <xsl:for-each select="term">
                  <xsl:sort select="name" />
                  <xsl:if test="position() &lt; 7">
                    <xsl:apply-templates select="."/>
                    <!-- this applies the 'catMaker' template -->
                  </xsl:if>
                </xsl:for-each>
              </div>
              <!-- Second column, 7 items -->
              <div class="directoryColumn">
                <xsl:for-each select="term">
                  <xsl:sort select="name" />
                  <xsl:if test="position() &gt; 6 and position() &lt; 14">
                    <xsl:apply-templates select="."/>
                    <!-- this applies the 'catMaker' template -->
                  </xsl:if>
                </xsl:for-each>
              </div>
              <!-- Third column, 6 items -->
              <div class="directoryColumn">
                <xsl:for-each select="term">
                  <xsl:sort select="name" />
                  <xsl:if test="position() &gt; 13">
                    <xsl:apply-templates select="."/>
                    <!-- this applies the 'catMaker' template -->
                  </xsl:if>
                </xsl:for-each>
              </div>
              <!-- end of 3-column section -->

              <!-- Clearing div to ensure the background extends around the (floated) columns -->
              <div class="clear">&#160;</div>

            </div>
            <!-- end of lower section div -->

          </div>
          <!-- end of tabDirectory div -->

        </div>
        <!-- end of mainContent div -->

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