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

<xsl:template match="/">
<!-- - - - - - - - - - -->
<!-- END REQUIRED CODE -->
<!-- - - - - - - - - - -->
  
      <div id="outerContainer">
        <div id="innerContainer">

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
						    <li id="top1"><a href="{$directoryPage}">Directory</a></li>
						    <li id="top2"><a href="{$indexPage}">Subject Index</a></li>
					    </ul>
            </div>
          </div> <!-- End title div -->

            <div id="search">

              <div id="searchHeader" class="headerPane">
                <h1>
                  <i>find-it</i> Search
                </h1>
              </div>


              <div id="searchList" class="lowerPane">

                <form id="searchForm" name="simpleSearchForm" action="{$resultsPage}" method="GET">

                  <!-- S01:  Code required for freetext search tool start -->
                  <div class="simpleSearchDiv">
                    <p><label for="freetext">Search for:</label></p>
                    <img id="poweredByIcon"  src="{$imagesFolder}powered_by_logo.gif" alt="Powered by ..." />
                    <input type="text" id="freetext" name="freetext" tabindex="10" maxlength="150" accesskey="3" title="Enter free text search"/>
                    <input id="searchButton" type="image" src="{$imagesFolder}null_icon.gif" alt="Search" title="Go"/>
                    <p id="poweredBy">Powered by <br />...</p>
                    <p><a id="advSearchLink" href="{$advsearchPage}">Advanced Search</a></p>
                  </div>

                  <div id="formErrorHelp">
                    <p></p>
                  </div>
                  <!-- S01:  Code required for freetext search tool end -->

                  <div class="clear">&#160;</div>

                </form>

              </div>

            </div>

          </div>
	
	</div>
	</div>
	
</xsl:template>

</xsl:stylesheet>