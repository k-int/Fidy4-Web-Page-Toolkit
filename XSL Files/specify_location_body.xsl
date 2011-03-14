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

  <xsl:template match="/topTerms/term[identifier=/topTerms/echoedData/queryString/@category]">
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
            <div id="locationDialog">
              
              <!-- Top header, could optionally contain some more guidance or information -->
              <div id="locationDialogHeader" class="headerPane">
                <p id="selectionReadout" class="infoText">
                  The <span class="searchTerm">
                    <xsl:value-of select="name"/>
                  </span> category contains <xsl:value-of select="occurence" /> results
                </p>
                <p class="infoText">You might like to narrow down your results by choosing a location</p>
              </div>

              <!-- Lower section, containing actual directory listings -->
              <div id="locationDialogMain" class="lowerPane">

                <div id="searchPlace">
                  <form id="locationForm" name="locationForm" action="{$resultsPage}" method="GET">
                    <input id="category" type="hidden" name="category" value="{/topTerms/echoedData/queryString/@category}" />
                    <p>
                      <label>Location: </label>
                    </p>
                    <input id="locationInput" type="text" name="location" />&#160;
                    <input id="narrowButton" type="submit" value="Narrow results" />
                    <p>e.g. postcode, town, area..</p>
                  </form>
                </div>

                <div id="searchAllButton">
                  <a id="showAllButton" href="{$resultsPage}?category={/topTerms/echoedData/queryString/@category}">
                    <img src="{$imagesFolder}show_all.gif" alt="Show all results" />
                  </a>
                </div>

                <div id="cancelLocation">
                  <a href="{$directoryPage}">Cancel</a>
                </div>

                <!-- Clearing div to ensure the background extends around the content -->
                <div class="clear=">&#160;</div>

              </div><!-- End lower section -->

            </div><!-- end of locationDialog div -->

          </div><!-- end of mainContent div -->

        </div>
      </div>


</xsl:template>

</xsl:stylesheet>