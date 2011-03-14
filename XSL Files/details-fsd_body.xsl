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
  <xsl:output method="html" encoding="utf-8" indent="yes" />

  <!--  Switch to show the map or not - if this is set to anything other than 'yes', the entire map section will be skipped 
      Note - this is a per-page override for the same setting in the 'resources-fsd.xsl' file, and can be deleted if you wish-->
  <xsl:variable name="showMap" select="'yes'" />

  <xsl:template match="/fsdrec:ServiceDescription">
    <!-- - - - - - - - - - -->
    <!-- END REQUIRED CODE -->
    <!-- - - - - - - - - - -->


    <div id="outerContainer">
      <div id="innerContainer">

        <div id="mainContent" class="wide">

          <div id="findItTitle">
            <!-- the main title bar -->
            <div id="findIt">
              <div id="findIt2">
                <a href="{$homepage}" accesskey="1">
                  <img src="{$imagesFolder}banner.jpg" alt="Homepage" />
                </a>
              </div>
            </div>
            <!-- bar with links, including the quick Search box -->
            <div id="linksBar">
              <ul>
                <li id="top1">
                  <a href="{$directoryPage}">Directory</a>
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

          <!-- R07:  Code required for detail view tool start -->
          <!-- The main profile pane, holding all information specific to the service -->
          <div id="profilePane">

            <!-- the print link opens a new window, with all tabs displayed on one page.  It still requires Javascript to create the map -->
            <div class="printLink">
              <a href="{$detailsPage}?{/fsdrec:ServiceDescription/echoedData/queryString}&amp;displayType=print" target="_blank">Printer-friendly page</a><br />
              (opens new window)
            </div>

            <!-- The name of the service -->
            <div id="providerName">
              <h2>
                <xsl:value-of select="fsdrec:DC.Title" />
                <xsl:if test="'NFSDPortal' = normalize-space(echoedData/authority)">
                  &#160;<img src="{$imagesFolder}national.png" alt="Nationwide service" />
                </xsl:if>
              </h2>
            </div>

            <!-- links to each of the categories and subcategories in which this record appears -->
            <div id="broaderCats">
              <p id="broaderCatsTitle">In categories:</p>
              <xsl:for-each select="fsdrec:DC.Subject">
                <p id="categoriesLink{position()}" class="parentCat">
                  <xsl:call-template name="catLister">
                    <xsl:with-param name="id" select="@Id" />
                    <xsl:with-param name="conceptId" select="@ConceptId" />
                  </xsl:call-template>
                </p>
              </xsl:for-each>
            </div>

            <!-- section containing description, website link and last-update date -->
            <div id="topHeadings" class="detailsGroup">

              <!-- Display the description of the service -->
              <p>
                <xsl:value-of select="fsdrec:Description/fsdrec:DC.Description" />
              </p>

              <!-- Create a link to the service's website (if available) -->
              <xsl:apply-templates select="fsdrec:ContactDetails/fsdrec:WebsiteAddress" />

              <!-- Display the date the record was last update (if present), added by LC 04/10: if no modified date display the created date -->
              <xsl:choose>
                <xsl:when test="string-length(fsdrec:DC.Date.Modified) &gt; 0">
                  <p>
                    <span class="profileLabel">Information last updated:</span>&#160;<xsl:call-template name="dateMaker">
                      <xsl:with-param name="DateTime" select="fsdrec:DC.Date.Modified" />
                    </xsl:call-template>
                  </p>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:if test="string-length(fsdrec:DC.Date.Created) &gt; 0">
                    <p>
                      <span class="profileLabel">Information last updated:</span>&#160;<xsl:call-template name="dateMaker">
                        <xsl:with-param name="DateTime" select="fsdrec:DC.Date.Created" />
                      </xsl:call-template>
                    </p>
                  </xsl:if>
                </xsl:otherwise>
              </xsl:choose>
            </div>

            <!-- section containing the first set of contact details -->
            <div id="locationDetails" class="detailsGroup">
              <h5>
                <span class="sectionHead">Site Details</span>
              </h5>
              <xsl:choose>
                <xsl:when test="fsdrec:ContactDetails/*">
                  <!--Output main address, if present -->
                  <xsl:if test="0 &lt; string-length(fsdrec:ContactDetails/fsdrec:Address)">
                    <p>
                      <span class="profileLabel">Address: </span>
                      <span class="address">
                        <xsl:apply-templates select="fsdrec:ContactDetails/fsdrec:Address" mode="fullAddress" />
                      </span>
                    </p>
                  </xsl:if>

                  <!--Output main telephone number, if present-->
                  <xsl:apply-templates select="fsdrec:ContactDetails/fsdrec:ContactNumber['fax' != @Type]" />

                  <!--Output main fax number, if present-->
                  <xsl:apply-templates select="fsdrec:ContactDetails/fsdrec:ContactNumber['fax' = @Type]" />

                  <!--Output main email address, if present-->
                  <xsl:apply-templates select="fsdrec:ContactDetails/fsdrec:EmailAddress" />
                </xsl:when>
                <xsl:otherwise>
                  <p>No details available</p>
                </xsl:otherwise>
              </xsl:choose>
            </div>

            <!-- The overall span of ages catered for by the service (NOTE - this does not imply that all ages in this range are accepted) -->
            <xsl:if test="0 &lt; string-length(fsdrec:SuitableAgeRange/fsdrec:From)">
              <div id="agesDetails" class="detailsGroup">
                <h5>
                  <span class="sectionHead">Age Groups</span>
                </h5>
                <p>
                  <span class="profileLabel">Ages catered for (overall): </span>
                  <xsl:for-each select="fsdrec:SuitableAgeRange/fsdrec:From/fsdrec:Years">
                    <xsl:sort data-type="number" select="." />
                    <xsl:if test="1 = position()">
                      <xsl:value-of select="concat(., ' years, ', ../fsdrec:Months, ' months')" />
                    </xsl:if>
                  </xsl:for-each>&#160;-&#160;<xsl:for-each select="fsdrec:SuitableAgeRange/fsdrec:To/fsdrec:Years">
                    <xsl:sort data-type="number" select="." order="descending" />
                    <xsl:if test="1 = position()">
                      <xsl:value-of select="concat(., ' years, ', ../fsdrec:Months, ' months')" />
                    </xsl:if>
                  </xsl:for-each>
                </p>
              </div>
            </xsl:if>

            <!-- Add attribution details -->
            <!-- section containing the first set of contact details -->
            <xsl:if test="string-length(/fsdrec:ServiceDescription/attributionData/attributionDataList/srw:searchRetrieveResponse/srw:records/srw:record/doc/str['feedback_name_s'= @name]) &gt; 0">
              <div id="locationDetails" class="detailsGroup">
                <h5>
                  <span class="sectionHead">
                    Information Supplied Through
                  </span>
                </h5>
                <table style="border: none;">
                  <tr>
                    <td>
                      <p>
                        <span class="profileLabel">Information provider: </span>
                        <span class="resultsLAName">
                          <xsl:value-of select="/fsdrec:ServiceDescription/attributionData/attributionDataList/srw:searchRetrieveResponse/srw:records/srw:record/doc/str['feedback_name_s'= @name]" />
                        </span>
                        <xsl:if test="string-length(/fsdrec:ServiceDescription/attributionData/attributionDataList/srw:searchRetrieveResponse/srw:records/srw:record/doc/str['feedback_email_s'= @name])">
                          <br />
                          <span class="profileNoLabel">To enquire further, contact: </span>
                          <xsl:value-of select="/fsdrec:ServiceDescription/attributionData/attributionDataList/srw:searchRetrieveResponse/srw:records/srw:record/doc/str['feedback_email_s'= @name]" />
                        </xsl:if>
                        <!-- Create a link to the service's website (if available) -->
                        <xsl:if test="string-length(/fsdrec:ServiceDescription/attributionData/attributionDataList/srw:searchRetrieveResponse/srw:records/srw:record/doc/str['feedback_url_s'= @name])">
                          <br />
                          <span class="profileNoLabel">
                            <xsl:variable name="website">
                              <xsl:if test="starts-with(/fsdrec:ServiceDescription/attributionData/attributionDataList/srw:searchRetrieveResponse/srw:records/srw:record/doc/str['feedback_url_s'= @name], 'http://') != 'true'">http://</xsl:if>
                              <xsl:value-of select="/fsdrec:ServiceDescription/attributionData/attributionDataList/srw:searchRetrieveResponse/srw:records/srw:record/doc/str['feedback_url_s'= @name]" />
                            </xsl:variable>
                            <a href="{$website}" target="_blank">View the information provider website</a> (opens in new window)
                          </span>
                        </xsl:if>
                      </p>
                    </td>
                    <td>
                      <xsl:if test="string-length(/fsdrec:ServiceDescription/attributionData/attributionDataList/srw:searchRetrieveResponse/srw:records/srw:record/doc/str['icon_url_s'= @name])">
                        <img class="detailLALogo" src="{/fsdrec:ServiceDescription/attributionData/attributionDataList/srw:searchRetrieveResponse/srw:records/srw:record/doc/str['icon_url_s'= @name]}" alt="{doc/str['feedback_name_s' = @name]}" />
                      </xsl:if>
                    </td>
                  </tr>
                </table>
              </div>
            </xsl:if>

            <!-- icon representation of special provisions (used by U02: Key to icons tool) -->
            <div id="iconDetails" class="detailsGroup">
              <p>
                <span class="icons">
                  <xsl:if test="'true' = $wheelchair or '1' = $wheelchair">
                    <img src="{$imagesFolder}wheelchair.png" alt="Wheelchair access" title="Wheelchair access"/>
                  </xsl:if>
                  <xsl:if test="'true' = $specneeds or '1' = $specneeds">
                    <img src="{$imagesFolder}spec_needs.png" alt="Caters for Special Needs" title="Caters for Special Needs"/>
                  </xsl:if>
                  <xsl:if test="'true' = $cultural or '1' = $cultural">
                    <img src="{$imagesFolder}cultural.png" alt="Cultural provision" title="Cultural provision"/>
                  </xsl:if>
                  <xsl:if test="'true' = $dietary or '1' = $dietary">
                    <img src="{$imagesFolder}dietary.png" alt="Special Dietary provision" title="Special Dietary provision"/>
                  </xsl:if>
                </span>
              </p>
            </div>


            <!-- R09:  Code required for tab tool start -->
            <!-- Bottom section containing the tabs and corresponding tabbed areas -->
            <div id="moreDetailsPane" class="detailsGroup">

              <!-- Tabs list. Delete a div (with class="tab") to prevent that tab from appearing. -->
              <div id="detailsTabs">

                <div id="tab1" class="tab">
                  <xsl:if test="$view=1">
                    <xsl:attribute name="class">tab current</xsl:attribute>
                  </xsl:if>
                  <a href="?recordID={/fsdrec:ServiceDescription/echoedData/queryString/@recordID}&amp;recordType=FSD&amp;view=1">Opening times</a>
                </div>

                <div id="tab2" class="tab">
                  <xsl:if test="$view=2">
                    <xsl:attribute name="class">tab current</xsl:attribute>
                  </xsl:if>
                  <a href="?recordID={/fsdrec:ServiceDescription/echoedData/queryString/@recordID}&amp;recordType=FSD&amp;view=2">Special provision</a>
                </div>

                <div id="tab3" class="tab">
                  <xsl:if test="$view=3">
                    <xsl:attribute name="class">tab current</xsl:attribute>
                  </xsl:if>
                  <a href="?recordID={/fsdrec:ServiceDescription/echoedData/queryString/@recordID}&amp;recordType=FSD&amp;view=3">Costs</a>
                </div>

                <div id="tab4" class="tab">
                  <xsl:if test="$view=4">
                    <xsl:attribute name="class">tab current</xsl:attribute>
                  </xsl:if>
                  <a href="?recordID={/fsdrec:ServiceDescription/echoedData/queryString/@recordID}&amp;recordType=FSD&amp;view=4">Other details</a>
                </div>

                <div id="tab5" class="tab">
                  <xsl:if test="$view=5">
                    <xsl:attribute name="class">tab current</xsl:attribute>
                  </xsl:if>
                  <a href="?recordID={/fsdrec:ServiceDescription/echoedData/queryString/@recordID}&amp;recordType=FSD&amp;view=5">Contacts</a>
                </div>

                <xsl:if test="'yes' = $showMap and (0 &lt; string-length(/fsdrec:ServiceDescription/echoedData/centrePoint/@lat)) and (0 &lt; string-length(/fsdrec:ServiceDescription/echoedData/centrePoint/@lng))">
                  <div id="tab6" class="tab">
                    <xsl:if test="$view=6">
                      <xsl:attribute name="class">tab current</xsl:attribute>
                    </xsl:if>
                    <a href="?recordID={/fsdrec:ServiceDescription/echoedData/queryString/@recordID}&amp;recordType=FSD&amp;view=6">Map</a>
                  </div>
                </xsl:if>

              </div>


              <!-- List of tabbed areas.  To make these inaccessible in normal view, delete the corresponding tab above.
						To prevent them from appearing at all (in normal or Print view) delete the div here AND the tab above -->

              <!-- Opening hours tab -->
              <div id="moreDetails1">
                <xsl:attribute name="style">
                  <xsl:if test="'1' != $view">display: none</xsl:if>
                </xsl:attribute>
                <div id="openingDetails" class="tabMain">
                  <h5>
                    <span class="sectionHead">Details of opening times</span>
                  </h5>
                  <xsl:choose>
                    <xsl:when test="0 &lt; string-length(fsdrec:Availability)">

                      <!-- List of broad opening periods of the service (usually spanning several weeks) -->
                      <xsl:if test="0 &lt; string-length(fsdrec:Availability/fsdrec:StartDateTime)">
                        <p>
                          <span class="profileLabel">Broad opening periods:</span>
                        </p>
                        <xsl:for-each select="fsdrec:Availability/fsdrec:StartDateTime">
                          <p>
                            <xsl:call-template name="dateMaker">
                              <xsl:with-param name="DateTime" select="." />
                            </xsl:call-template>
                            <xsl:if test="0 &lt; string-length(../fsdrec:EndDateTime)">
                              - <xsl:call-template name="dateMaker">
                                <xsl:with-param name="DateTime" select="../fsdrec:EndDateTime" />
                              </xsl:call-template>
                            </xsl:if>
                          </p>
                        </xsl:for-each>
                      </xsl:if>

                      <!-- More specific lists and details of the service's opening times -->
                      <p>
                        <span class="profileLabel">Opening times:</span>
                      </p>
                      <xsl:if test="fsdrec:Availability/fsdrec:Period">
                        <table id="openingDetails">
                          <tr>
                            <th class="">Day</th>
                            <th class="">Open</th>
                            <th class="">Close</th>
                          </tr>
                          <xsl:for-each select="fsdrec:Availability/fsdrec:Period">
                            <tr>
                              <td class="">
                                <xsl:value-of select="@Day" />
                              </td>
                              <td class="">
                                <xsl:call-template name="timeMaker">
                                  <xsl:with-param name="time" select="fsdrec:StartTime" />
                                </xsl:call-template>
                              </td>
                              <td class="">
                                <xsl:call-template name="timeMaker">
                                  <xsl:with-param name="time" select="fsdrec:EndTime" />
                                </xsl:call-template>
                              </td>
                            </tr>
                          </xsl:for-each>
                        </table>
                      </xsl:if>
                      <xsl:for-each select="fsdrec:Availability/fsdrec:Details">
                        <p>
                          <span class="profileLabel">Notes on availability: </span>
                          <xsl:value-of select="." />
                        </p>
                      </xsl:for-each>

                    </xsl:when>
                    <xsl:otherwise>
                      <p>No details available.</p>
                    </xsl:otherwise>
                  </xsl:choose>

                </div>
              </div>

              <!-- Special provision Details tab -->
              <div id="moreDetails2">
                <xsl:attribute name="style">
                  <xsl:if test="'2' != $view">display: none</xsl:if>
                </xsl:attribute>
                <div id="provisionDetails" class="tabMain">
                  <h5>
                    <span class="sectionHead">Special Provision</span>
                  </h5>
                  <xsl:choose>
                    <xsl:when test="0 &lt; string-length(fsdrec:SpecialProvisions/fsdrec:WheelchairAccess)
                                      or 0 &lt; string-length(fsdrec:SpecialProvisions/fsdrec:CulturalProvision)
                                      or 0 &lt; string-length(fsdrec:SpecialProvisions/fsdrec:SpecialDiet)
                                      or 0 &lt; string-length(fsdrec:SpecialProvisions/fsdrec:SpecialNeeds)
                                      or 0 &lt; string-length(fsdrec:SpecialProvisions/fsdrec:Details) 
                                      or 0 &lt; string-length(fsdrec:DisabledAccess)">

                      <!-- Details of any Wheelchair access -->
                      <xsl:if test="0 &lt; string-length(fsdrec:SpecialProvisions/fsdrec:WheelchairAccess)">
                        <p>
                          <span class="profileLabel">Wheelchair access: </span>
                          <xsl:value-of select="fsdrec:SpecialProvisions/fsdrec:WheelchairAccess" />
                        </p>
                      </xsl:if>

                      <!-- Full details about cultural provision by the service -->
                      <xsl:if test="0 &lt; string-length(fsdrec:SpecialProvisions/fsdrec:CulturalProvision)">
                        <p>
                          <span class="profileLabel">Cultural provision: </span>
                          <xsl:value-of select="fsdrec:SpecialProvisions/fsdrec:CulturalProvision" />
                        </p>
                      </xsl:if>

                      <!-- Details of any dietary provision in the provider record-->
                      <xsl:if test="0 &lt; string-length(fsdrec:SpecialProvisions/fsdrec:SpecialDiet)">
                        <p>
                          <span class="profileLabel">Dietary provision: </span>
                          <xsl:value-of select="fsdrec:SpecialProvisions/fsdrec:SpecialDiet" />
                        </p>
                      </xsl:if>

                      <!-- Full details of any Special Needs provision listed in the provider record-->
                      <xsl:choose>
                        <xsl:when test="fsdrec:SpecialProvisions/fsdrec:SpecialNeeds/@HasProvision = '1' or fsdrec:SpecialProvisions/fsdrec:SpecialNeeds/@HasProvision = 'true'">
                          <xsl:if test="string-length(fsdrec:SpecialProvisions/fsdrec:SpecialNeeds/fsdrec:Experience &gt; 0)
                                       or string-length(fsdrec:SpecialProvisions/fsdrec:SpecialNeeds/fsdrec:Confidence &gt; 0)
                                       or string-length(fsdrec:SpecialProvisions/fsdrec:SpecialNeeds/fsdrec:Details &gt; 0)">
                            <p>
                              <span class="profileLabel">Some special needs catered for: </span>
                            </p>
                            <xsl:if test="0 &lt; string-length(fsdrec:SpecialProvisions/fsdrec:SpecialNeeds/fsdrec:Experience)">
                              <p>
                                Experience:
                                <xsl:value-of select="fsdrec:SpecialProvisions/fsdrec:SpecialNeeds/fsdrec:Experience" />
                                <xsl:text> </xsl:text>
                              </p>
                            </xsl:if>
                            <xsl:if test="0 &lt; string-length(fsdrec:SpecialProvisions/fsdrec:SpecialNeeds/fsdrec:Confidence)">
                              <p>
                                <span>Confidence: </span>
                                <xsl:value-of select="fsdrec:SpecialProvisions/fsdrec:SpecialNeeds/fsdrec:Confidence" />
                                <xsl:text> </xsl:text>
                              </p>
                            </xsl:if>
                            <xsl:if test="0 &lt; string-length(fsdrec:SpecialProvisions/fsdrec:SpecialNeeds/fsdrec:Details)">
                              <p>
                                <xsl:value-of select="fsdrec:SpecialProvisions/fsdrec:SpecialNeeds/fsdrec:Details" />
                              </p>
                            </xsl:if>
                          </xsl:if>
                        </xsl:when>
                        <xsl:otherwise>
                          <p>
                            No record of special needs provision
                          </p>
                        </xsl:otherwise>
                      </xsl:choose>
                      
                      <!-- More info on Disabled access to the provider -->
                      <xsl:if test="0 &lt; string-length(fsdrec:DisabledAccess)">
                        <p>
                          <span class="profileLabel">Disabled access: </span>
                          <xsl:value-of select="fsdrec:DisabledAccess" />
                        </p>
                      </xsl:if>

                      <!-- Full details of any additional provision listed in the provider record-->
                      <xsl:if test="0 &lt; string-length(fsdrec:SpecialProvisions/fsdrec:Details)">
                        <p>
                          <span class="profileLabel">Additional details: </span>
                          <xsl:value-of select="fsdrec:SpecialProvisions/fsdrec:Details" />
                        </p>
                      </xsl:if>

                    </xsl:when>
                    <xsl:otherwise>
                      <p>No details available.</p>
                    </xsl:otherwise>
                  </xsl:choose>

                </div>
              </div>

              <!-- Cost Details tab -->
              <div id="moreDetails3">
                <xsl:attribute name="style">
                  <xsl:if test="'3' != $view">display: none</xsl:if>
                </xsl:attribute>
                <div id="costDetails" class="tabMain">
                  <h5>
                    <span class="sectionHead">Costs</span>
                  </h5>

                  <!-- Indicates if the provider has stipulated they should be contacted for full cost details -->
                  <xsl:choose>
                    <xsl:when test="0 &lt; string-length(fsdrec:CostDetails/fsdrec:Costs) or 0 &lt; string-length(fsdrec:CostDetails/fsdrec:OtherCosts) or 'true' = fsdrec:CostDetails/fsdrec:ContactForCosts or '1' = fsdrec:CostDetails/fsdrec:ContactForCosts">
                      <xsl:if test="'true' = fsdrec:CostDetails/fsdrec:ContactForCosts or '1' = fsdrec:CostDetails/fsdrec:ContactForCosts">
                        <p>Please contact thise provider for full cost details.</p>
                      </xsl:if>

                      <!-- Details of any costs in the provider record -->
                      <xsl:if test="0 &lt; string-length(fsdrec:CostDetails/fsdrec:Costs)">
                        <p>
                          <span class="profileLabel">Main costs: </span>
                          <xsl:value-of select="fsdrec:CostDetails/fsdrec:Costs" />
                        </p>
                      </xsl:if>

                      <!-- Additional information about costs in the provider record -->
                      <xsl:if test="0 &lt; string-length(fsdrec:CostDetails/fsdrec:OtherCosts)">
                        <p>
                          <span class="profileLabel">Additional information: </span>
                          <xsl:value-of select="fsdrec:CostDetails/fsdrec:OtherCosts" />
                        </p>
                      </xsl:if>

                    </xsl:when>
                    <xsl:otherwise>
                      <p>No details available.</p>
                    </xsl:otherwise>
                  </xsl:choose>

                </div>
              </div>

              <!-- Other Details tab -->
              <div id="moreDetails4">
                <xsl:attribute name="style">
                  <xsl:if test="'4' != $view">display: none</xsl:if>
                </xsl:attribute>
                <div id="otherDetails" class="tabMain">
                  <h5>
                    <span class="sectionHead">Other Details</span>
                  </h5>

                  <!-- Display the quality assurance items -->
                  <xsl:if test="count(fsdrec:QualityAssurance/fsdrec:QualityLevel) &gt; 0">
                    <p>
                      <span class="profileLabel">Quality assurance: </span>
                      <xsl:for-each select="fsdrec:QualityAssurance/fsdrec:QualityLevel">
                        <xsl:value-of select="fsdrec:QualityStatus" />
                        <xsl:if test="string-length(fsdrec:QualityStatusChangeDate) &gt; 0">
                          <xsl:text> </xsl:text>
                          <xsl:call-template name="dateMaker">
                            <xsl:with-param name="DateTime" select="fsdrec:QualityStatusChangeDate" />
                          </xsl:call-template>
                        </xsl:if>
                        <xsl:if test="string-length(fsdrec:Details) &gt; 0">
                          <xsl:text> </xsl:text>
                          <xsl:value-of select="fsdrec:Details"/>
                        </xsl:if>
                        <xsl:if test="position() != count(../fsdrec:QualityLevel)">
                          <xsl:text>, </xsl:text>
                        </xsl:if>
                      </xsl:for-each>
                    </p>
                  </xsl:if>
                  
                  

                  <!-- Displays info about the facilities of the service, if present -->
                  <xsl:if test="0 &lt; string-length(fsdrec:Facility)">
                    <p>
                      <span class="profileLabel">Extra facilities: </span>
                      <xsl:value-of select="fsdrec:Facility" />
                    </p>
                  </xsl:if>

                  <!-- Displays info about any quality awards the service has won, if present -->
                  <xsl:if test="0 &lt; string-length(fsdrec:Accreditation)">
                    <p>
                      <span class="profileLabel">Quality awards: </span>
                      <xsl:value-of select="fsdrec:Accreditation" />
                    </p>
                  </xsl:if>

                  <!-- Displays additional languages spoken at the service, if present -->
                  <xsl:if test="0 &lt; string-length(fsdrec:LanguageSpoken)">
                    <p>
                      <span class="profileLabel">Languages spoken: </span>
                      <xsl:for-each select="fsdrec:LanguageSpoken">
                        <xsl:value-of select="." />
                        <xsl:if test="position() != last()">, </xsl:if>
                      </xsl:for-each>
                    </p>
                  </xsl:if>

                  <!-- Displays info about how the service is accessed (e.g. internet, phone etc) -->
                  <xsl:if test="0 &lt; string-length(fsdrec:AccessChannel)">
                    <p>
                      <span class="profileLabel">Accessed via: </span>
                      <xsl:for-each select="fsdrec:AccessChannel">
                        <xsl:value-of select="." />
                        <xsl:if test="position() != last()">, </xsl:if>
                      </xsl:for-each>
                    </p>
                  </xsl:if>

                  <!-- Displays info about who may be eligible for the service -->
                  <xsl:if test="0 &lt; string-length(fsdrec:EligibilityCriteria)">
                    <p>
                      <span class="profileLabel">Eligibility: </span>
                      <xsl:value-of select="fsdrec:EligibilityCriteria" />
                    </p>
                  </xsl:if>

                  <!-- Displays info about whether referral is required (for example, some are by GP referral only) -->
                  <xsl:if test="0 &lt; string-length(fsdrec:ReferralCriteria)">
                    <p>
                      <span class="profileLabel">Referral: </span>
                      <xsl:for-each select="fsdrec:ReferralCriteria/fsdrec:Criteria">
                        <xsl:value-of select="." />
                        <xsl:if test="position() != last()">, </xsl:if>
                      </xsl:for-each>
                    </p>
                  </xsl:if>

                  <!-- Details of any waiting list for the service -->
                  <xsl:if test="0 &lt; string-length(fsdrec:WaitingList)">
                    <p>
                      <span class="profileLabel">Waiting list: </span>
                      <xsl:value-of select="fsdrec:WaitingList" />
                    </p>
                  </xsl:if>

                  <!-- Displays info about whether the service may accept leisure cards -->
                  <xsl:if test="0 &lt; string-length(fsdrec:LeisureCardInformation)">
                    <p>
                      <span class="profileLabel">Leisure card information: </span>
                      <xsl:value-of select="fsdrec:LeisureCardInformation" />
                    </p>
                  </xsl:if>

                  <!-- Travel information for the service (may be local or national travel) -->
                  <xsl:if test="0 &lt; string-length(fsdrec:TravelInformation)">
                    <p>
                      <span class="profileLabel">Travel information: </span>
                      <xsl:value-of select="fsdrec:TravelInformation" />
                    </p>
                  </xsl:if>

                  <!-- Displays any other details about the service, if present -->
                  <xsl:if test="0 &lt; string-length(fsdrec:Notes)">
                    <p>
                      <span class="profileLabel">Other details: </span>
                      <xsl:value-of select="fsdrec:Notes" />
                    </p>
                  </xsl:if>

                </div>
              </div>

              <!-- Contact Details tab -->
              <div id="moreDetails5">
                <xsl:attribute name="style">
                  <xsl:if test="'5' != $view">display: none</xsl:if>
                </xsl:attribute>
                <div id="otherContactDetails" class="tabMain">
                  <h5>
                    <span class="sectionHead">Additional Contact Details</span>
                  </h5>

                  <xsl:choose>
                    <xsl:when test="fsdrec:Contact = (*)">
                      <xsl:for-each select="fsdrec:Contact">

                        <!-- Display the name of the contact, if present -->
                        <p>
                          <span class="profileLabel">Name: </span>
                          <xsl:value-of select="fsdrec:Name" />
                        </p>

                        <!-- Display the postal address(es) of the contact, if present, and if the provider has not withheld them -->
                        <p>
                          <span class="profileLabel">Address: </span>
                          <span class="address">
                            <xsl:apply-templates select="fsdrec:ContactDetails/fsdrec:Address" mode="fullAddress"/>
                          </span>
                        </p>

                        <!-- Display the telephone number(s) of the contact, if present -->
                        <xsl:for-each select="fsdrec:ContactDetails/fsdrec:ContactNumber[@TelPreferred = 'yes' and 0 &lt; string-length(apd:TelNationalNumber)]">
                          <xsl:apply-templates select="." />
                        </xsl:for-each>

                        <!-- Display the telephone number(s) of the contact, if present -->
                        <xsl:for-each select="fsdrec:ContactDetails/fsdrec:ContactNumber[@TelPreferred != 'yes' and 0 &lt; string-length(apd:TelNationalNumber)]">
                          <xsl:apply-templates select="." />
                        </xsl:for-each>

                        <!-- Display the email address(es) of the contact, if present -->
                        <xsl:for-each select="fsdrec:ContactDetails/fsdrec:EmailAddress[@EmailPreferred = 'yes' and 0 &lt; string-length(apd:EmailAddress)]">
                          <p>
                            <span class="profileLabel">Email: </span>
                            <xsl:value-of select="apd:EmailAddress" />
                            <xsl:if test="@EmailUsage">
                              (<xsl:value-of select="@EmailUsage" />)
                            </xsl:if>
                          </p>
                        </xsl:for-each>
                        <xsl:for-each select="fsdrec:ContactDetails/fsdrec:EmailAddress[@EmailPreferred != 'yes' and 0 &lt; string-length(apd:EmailAddress)]">
                          <p>
                            <span class="profileLabel">Email: </span>
                            <xsl:value-of select="apd:EmailAddress" />
                            <xsl:if test="@EmailUsage">
                              (<xsl:value-of select="@EmailUsage" />)
                            </xsl:if>
                          </p>
                        </xsl:for-each>

                        <!-- Display website address(es) of the contact, if present -->
                        <xsl:for-each select="fsdrec:ContactDetails/fsdrec:WebsiteAddress">
                          <xsl:if test="0 &lt; string-length(.)">
                            <xsl:apply-templates select="." />
                          </xsl:if>
                        </xsl:for-each>

                      </xsl:for-each>
                    </xsl:when>
                    <xsl:otherwise>
                      <p>No additional contacts.</p>
                    </xsl:otherwise>
                  </xsl:choose>

                </div>
              </div>

              <!-- Map tab - only displayed if the showMap option is 'yes' and if there is a latitude/longitude position for the record-->
              <xsl:if test="('yes' = $showMap) and (0 &lt; string-length(/fsdrec:ServiceDescription/echoedData/centrePoint/@lat)) and (0 &lt; string-length(/fsdrec:ServiceDescription/echoedData/centrePoint/@lng))">
                <div id="moreDetails6">
                  <xsl:attribute name="style">
                    <xsl:if test="'6' != $view">display: none</xsl:if>
                  </xsl:attribute>
                  <div id="mapDetails" class="tabMain">
                    <h3 id="noMapText">You need JavaScript enabled to view this map</h3>
                  </div>
                </div>
              </xsl:if>

            </div>
            <!-- end moreDetailsPane -->
            <!-- R09:  Code required for tab tool end -->

          </div>
          <!-- end profilePane -->
          <!-- R07:  Code required for detail view tool end -->

          <!-- F11:  Code required for serendipity tool start -->
          <xsl:if test="0 &lt; string-length(echoedData/srw:records/srw:record)">
            <!-- Additional information box -->
            <div class="seeAlso sidebar">
              <div class="seeAlsoTitle">
                <div class="seeAlsoTitle2">
                  <h2>You may also be interested in</h2>
                </div>
              </div>
              <div class="seeAlsoContents clear">
                <ul>
                  <xsl:for-each select="echoedData/srw:records/srw:record">
                    <li>
                      <xsl:call-template name="seeAlso">
                        <xsl:with-param name="data" select="doc" />
                      </xsl:call-template>
                    </li>
                  </xsl:for-each>
                </ul>
              </div>
            </div>
          </xsl:if>
          <!-- F11:  Code required for serendipity tool end -->

          <!-- U02:  Code required for key to icons tool start -->
          <div id="key" class="sidebar">
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
                <img src="{$imagesFolder}cultural.png" alt="Cultural provision" title="Cultural provision" /> Cultural provision
              </p>
              <p class="icons">
                <img src="{$imagesFolder}dietary.png" alt="Special Dietary provision" title="Special Dietary provision" /> Special Dietary provision
              </p>
            </div>
          </div>
          <!-- U02:  Code required for key to icons tool end -->

          <div class="clear">&#160;</div>

        </div>

      </div>
    </div>


  </xsl:template>

</xsl:stylesheet>