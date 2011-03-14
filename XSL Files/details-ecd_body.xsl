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
      Note - this is a per-page override for the same setting in the 'resources-ecd.xsl' file, and can be deleted if you wish-->
  <xsl:variable name="showMap" select="'yes'" />

  <xsl:template match="/ecdrec:ProviderDescription/ecdrec:ProviderDetails">
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
              <a href="{$detailsPage}?{/ecdrec:ProviderDescription/echoedData/queryString}&amp;displayType=print" target="_blank">Printer-friendly page</a><br />
              (opens new window)
            </div>

            <!-- The name of the service -->
            <div id="providerName">
              <h2>
                <xsl:value-of select="../ecdrec:DC.Title" />
              </h2>
            </div>

            <!-- links to each of the categories and subcategories in which this record appears -->
            <div id="broaderCats">
              <p id="broaderCatsTitle">In categories:</p>
              <xsl:for-each select="../ecdrec:DC.Subject">
                <p id="categoriesLink{position()}" class="parentCat">
                  <xsl:call-template name="catLister">
                    <xsl:with-param name="id" select="@Id" />
                    <xsl:with-param name="conceptId" select="@ConceptId" />
                  </xsl:call-template>
                </p>
              </xsl:for-each>
            </div>

            <!-- section containing the first set of contact details -->
            <div id="locationDetails" class="detailsGroup">
              <h5>
                <span class="sectionHead">Site Details</span>
              </h5>

              <!-- Display the date the record was last update (if present), added by LC 04/10: if no modified date display the created date -->
              <xsl:choose>
                <xsl:when test="string-length(../ecdrec:DC.Date.Modified) &gt; 0">
                  <p>
                    <span class="profileLabel">Information last updated:</span>&#160;<xsl:call-template name="dateMaker">
                      <xsl:with-param name="DateTime" select="../ecdrec:DC.Date.Modified" />
                    </xsl:call-template>
                  </p>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:if test="string-length(../ecdrec:DC.Date.Created) &gt; 0">
                    <p>
                      <span class="profileLabel">Information last updated:</span>&#160;<xsl:call-template name="dateMaker">
                        <xsl:with-param name="DateTime" select="../ecdrec:DC.Date.Created" />
                      </xsl:call-template>
                    </p>
                  </xsl:if>
                </xsl:otherwise>
              </xsl:choose>

              <xsl:choose>
                <xsl:when test="ecdrec:SettingDetails/*">
                  <!--Output name of main contact, if present-->
                  <p>
                    <span class="profileLabel">Contact person: </span>
                    <xsl:if test="0 &lt; string-length(ecdrec:SettingDetails/ecdrec:ContactName)">
                      <xsl:value-of select="ecdrec:SettingDetails/ecdrec:ContactName" />
                    </xsl:if>
                  </p>

                  <!--Output main address, if present, or a message that the address is witheld-->
                  <p>
                    <span class="profileLabel">Address: </span>
                    <xsl:choose>
                      <xsl:when test="'true' = ecdrec:ConsentVisibleAddress or '1' = ecdrec:ConsentVisibleAddress">
                        <span class="address">
                          <xsl:apply-templates select="ecdrec:SettingDetails/ecdrec:PostalAddress" mode="fullAddress" />
                        </span>
                      </xsl:when>
                      <xsl:otherwise>
                        <i>This provider has elected to have their exact physical address withheld from the listings.</i>
                      </xsl:otherwise>
                    </xsl:choose>
                  </p>

                  <!--Output main telephone number, if present-->
                  <xsl:apply-templates select="ecdrec:SettingDetails/ecdrec:TelephoneNumber" />

                  <!--Output main fax number, if present-->
                  <xsl:apply-templates select="ecdrec:SettingDetails/ecdrec:FaxNumber" />

                  <!--Output main email address, if present-->
                  <xsl:apply-templates select="ecdrec:SettingDetails/ecdrec:EmailAddress" />

                  <!-- Create a link to the service's website (if available) -->
                  <xsl:apply-templates select="ecdrec:SettingDetails/ecdrec:WebsiteAddress" />

                </xsl:when>
                <xsl:otherwise>
                  <p>No details available</p>
                </xsl:otherwise>
              </xsl:choose>

              <!-- Display the description of the service -->
              <div class="detailsGroup">
                <p>
                  <xsl:value-of select="../ecdrec:Description/ecdrec:DC.Description" />
                </p>
              </div>

              <!-- Displays info about the facilities of the service, if present -->
              <p>
                <span class="profileLabel">Type of childcare: </span>
                <xsl:value-of select="ecdrec:ChildcareType"/>
              </p>

              <p>
                <span class="profileLabel">Extra facilities: </span>
                <xsl:value-of select="ecdrec:Facilities" />
              </p>
            </div>

            <!-- The overall span of ages catered for by the service (NOTE - this does not imply that all ages in this range are accepted) -->
            <xsl:if test="0 &lt; string-length(ecdrec:ChildcareAges/ecdrec:ChildcareAge/ecdrec:AgeFrom)">
              <div id="agesDetails" class="detailsGroup">
                <h5>
                  <span class="sectionHead">Age Groups</span>
                </h5>
                <p>
                  <span class="profileLabel">Ages catered for (overall): </span>
                  <xsl:for-each select="ecdrec:ChildcareAges/ecdrec:ChildcareAge/ecdrec:AgeFrom">
                    <xsl:sort data-type="number" select="." />
                    <xsl:if test="1 = position()">
                      <xsl:value-of select="." />
                    </xsl:if>
                  </xsl:for-each>&#160;-&#160;<xsl:for-each select="ecdrec:ChildcareAges/ecdrec:ChildcareAge/ecdrec:AgeTo">
                    <xsl:sort data-type="number" select="." order="descending" />
                    <xsl:if test="1 = position()">
                      <xsl:value-of select="." />
                    </xsl:if>
                  </xsl:for-each>
                </p>
              </div>
            </xsl:if>


            <!-- Add attribution details -->
            <!-- section containing the first set of contact details -->
            <xsl:if test="string-length(/ecdrec:ProviderDescription/attributionData/attributionDataList/srw:searchRetrieveResponse/srw:records/srw:record/doc/str['feedback_name_s'= @name]) &gt; 0">
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
                          <xsl:value-of select="/ecdrec:ProviderDescription/attributionData/attributionDataList/srw:searchRetrieveResponse/srw:records/srw:record/doc/str['feedback_name_s'= @name]" />
                        </span>
                        <xsl:if test="string-length(/ecdrec:ProviderDescription/attributionData/attributionDataList/srw:searchRetrieveResponse/srw:records/srw:record/doc/str['feedback_email_s'= @name])">
                          <br />
                          <span class="profileNoLabel">To enquire further, contact: </span>
                          <xsl:value-of select="/ecdrec:ProviderDescription/attributionData/attributionDataList/srw:searchRetrieveResponse/srw:records/srw:record/doc/str['feedback_email_s'= @name]" />
                        </xsl:if>
                        <!-- Create a link to the service's website (if available) -->
                        <xsl:if test="string-length(/ecdrec:ProviderDescription/attributionData/attributionDataList/srw:searchRetrieveResponse/srw:records/srw:record/doc/str['feedback_url_s'= @name])">
                          <br />
                          <span class="profileNoLabel">
                            <xsl:variable name="website">
                              <xsl:if test="starts-with(/ecdrec:ProviderDescription/attributionData/attributionDataList/srw:searchRetrieveResponse/srw:records/srw:record/doc/str['feedback_url_s'= @name], 'http://') != 'true'">http://</xsl:if>
                              <xsl:value-of select="/ecdrec:ProviderDescription/attributionData/attributionDataList/srw:searchRetrieveResponse/srw:records/srw:record/doc/str['feedback_url_s'= @name]" />
                            </xsl:variable>
                            <a href="{$website}" target="_blank">View the information provider website</a> (opens in new window)
                          </span>
                        </xsl:if>
                      </p>
                    </td>
                    <td>
                      <xsl:if test="string-length(/ecdrec:ProviderDescription/attributionData/attributionDataList/srw:searchRetrieveResponse/srw:records/srw:record/doc/str['icon_url_s'= @name])">
                        <img class="detailLALogo" src="{../attributionData/attributionDataList/srw:searchRetrieveResponse/srw:records/srw:record/doc/str['icon_url_s'= @name]}" alt="{doc/str['feedback_name_s' = @name]}" />
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
                  <xsl:if test="'true' = $vacancies or '1' = $vacancies">
                    <img src="{$imagesFolder}vac.png" alt="Current vacancies" title="Current vacancies"/>
                  </xsl:if>
                  <xsl:if test="'true' = $pickup or '1' = $pickup">
                    <img src="{$imagesFolder}pickup.png" alt="Pickup service available" title="Pickup service available"/>
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
                  <a href="?recordID={/ecdrec:ProviderDescription/echoedData/queryString/@recordID}&amp;recordType=ECD&amp;view=1">Places</a>
                </div>

                <div id="tab2" class="tab">
                  <xsl:if test="$view=2">
                    <xsl:attribute name="class">tab current</xsl:attribute>
                  </xsl:if>
                  <a href="?recordID={/ecdrec:ProviderDescription/echoedData/queryString/@recordID}&amp;recordType=ECD&amp;view=2">Opening times</a>
                </div>

                <div id="tab3" class="tab">
                  <xsl:if test="$view=3">
                    <xsl:attribute name="class">tab current</xsl:attribute>
                  </xsl:if>
                  <a href="?recordID={/ecdrec:ProviderDescription/echoedData/queryString/@recordID}&amp;recordType=ECD&amp;view=3">Special provision</a>
                </div>

                <div id="tab4" class="tab">
                  <xsl:if test="$view=4">
                    <xsl:attribute name="class">tab current</xsl:attribute>
                  </xsl:if>
                  <a href="?recordID={/ecdrec:ProviderDescription/echoedData/queryString/@recordID}&amp;recordType=ECD&amp;view=4">Costs</a>
                </div>

                <div id="tab5" class="tab">
                  <xsl:if test="$view=5">
                    <xsl:attribute name="class">tab current</xsl:attribute>
                  </xsl:if>
                  <a href="?recordID={/ecdrec:ProviderDescription/echoedData/queryString/@recordID}&amp;recordType=ECD&amp;view=5">Pickup</a>
                </div>

                <div id="tab6" class="tab">
                  <xsl:if test="$view=6">
                    <xsl:attribute name="class">tab current</xsl:attribute>
                  </xsl:if>
                  <a href="?recordID={/ecdrec:ProviderDescription/echoedData/queryString/@recordID}&amp;recordType=ECD&amp;view=6">Ofsted registration</a>
                </div>

                <div id="tab7" class="tab">
                  <xsl:if test="$view=7">
                    <xsl:attribute name="class">tab current</xsl:attribute>
                  </xsl:if>
                  <a href="?recordID={/ecdrec:ProviderDescription/echoedData/queryString/@recordID}&amp;recordType=ECD&amp;view=7">Other details</a>
                </div>

                <xsl:if test="'yes' = $showMap and (0 &lt; string-length(/ecdrec:ProviderDescription/echoedData/centrePoint/@lat)) and (0 &lt; string-length(/ecdrec:ProviderDescription/echoedData/centrePoint/@lng))">
                  <div id="tab8" class="tab">
                    <xsl:if test="$view=8">
                      <xsl:attribute name="class">tab current</xsl:attribute>
                    </xsl:if>
                    <a href="?recordID={/ecdrec:ProviderDescription/echoedData/queryString/@recordID}&amp;recordType=ECD&amp;view=8">Map</a>
                  </div>
                </xsl:if>

              </div>


              <!-- List of tabbed areas.  To make these inaccessible in normal view, delete the corresponding tab above.
						To prevent them from appearing at all (in normal or Print view) delete the div here AND the tab above -->

              <!-- Details of places tab -->
              <div id="moreDetails1">
                <xsl:attribute name="style">
                  <xsl:if test="'1' != $view">display: none</xsl:if>
                </xsl:attribute>
                <div id="placesDetails" class="tabMain">
                  <h5>
                    <span class="sectionHead">Places and availability</span>
                  </h5>

                  <!-- Immediate vacancies -->
                  <xsl:if test="string-length($vacancies) &gt; 0 and ($vacancies = '1' or $vacancies = 'true')" >
                    <p>
                      This provider has vacancies at the moment.
                    </p>
                  </xsl:if>

                  <xsl:choose>
                    <xsl:when test="string-length(ecdrec:FutureVacancyDetails/ecdrec:TotalVacancies) &gt; 0">
                      <xsl:if test="ecdrec:FutureVacancyDetails/ecdrec:TotalVacancies = 1" >
                        <p>This provider has 1 vacancy.</p>
                      </xsl:if>
                      <xsl:if test="ecdrec:FutureVacancyDetails/ecdrec:TotalVacancies != 1">
                        <p>
                          This provider has <xsl:value-of select="ecdrec:FutureVacancyDetails/ecdrec:TotalVacancies" /> vacancies.
                        </p>
                      </xsl:if>
                    </xsl:when>
                    <xsl:otherwise>
                      <p>This provider may have vacancies.</p>
                    </xsl:otherwise>
                  </xsl:choose>

                  <xsl:if test="ecdrec:FutureVacancyDetails/ecdrec:ContactForVacancies = '1' or ecdrec:FutureVacancyDetails/ecdrec:ContactForVacancies = 'true'">
                    <p>Please contact the provider for further details.</p>
                  </xsl:if>

                  <xsl:if test="string-length(ecdrec:FutureVacancyDetails/ecdrec:VacancyInformation) &gt; 0">
                    <p>
                      <xsl:value-of select="ecdrec:FutureVacancyDetails/ecdrec:VacancyInformation" />
                    </p>
                  </xsl:if>
                </div>
              </div>

              <!-- Opening hours tab -->
              <div id="moreDetails2">
                <xsl:attribute name="style">
                  <xsl:if test="'2' != $view">display: none</xsl:if>
                </xsl:attribute>
                <div id="openingDetails" class="tabMain">
                  <h5>
                    <span class="sectionHead">Details of opening times</span>
                  </h5>
                  <xsl:choose>
                    <xsl:when test="0 &lt; string-length(ecdrec:ChildcarePeriods/ecdrec:ChildcarePeriod) or ecdrec:ChildcareTimes = (*) or ecdrec:TimesofFundedPlaces.Times = (*)">

                      <!-- More specific lists and details of the service's opening times -->
                      <xsl:if test="ecdrec:ChildcareTimes = (*)">
                        <p>
                          <span class="profileLabel">Opening hours:</span>
                        </p>

                        <!-- Display times -->
                        <xsl:for-each select="ecdrec:ChildcareTimes/ecdrec:Times">
                          <xsl:if test="string-length(.) &gt; 0">
                            <p>
                              <xsl:value-of select="." />
                            </p>
                          </xsl:if>
                        </xsl:for-each>

                        <!-- Display other hours -->
                        <xsl:for-each select="ecdrec:ChildcareTimes/ecdrec:OtherHours">
                          <xsl:if test="string-length(.) &gt; 0">
                            <p>
                              Other hours: <xsl:value-of select="." />
                            </p>
                          </xsl:if>
                        </xsl:for-each>

                        <!-- Display notes on childcare availability -->
                        <xsl:for-each select="ecdrec:ChildcareTimes/ecdrec:Availability">
                          <xsl:if test="string-length(.) &gt; 0">
                            <p>
                              <span class="profileLabel">Notes on childcare availability: </span>
                              <xsl:value-of select="." />
                            </p>
                          </xsl:if>
                        </xsl:for-each>
                      </xsl:if>

                      <!-- Display times where funded places are available -->
                      <xsl:for-each select="ecdrec:TimesOfFundedPlaces/ecdrec:Times">
                        <xsl:if test="string-length(.) &gt; 0">
                          <p>
                            <span class="profileLabel">Times where funded places are available: </span>
                            <xsl:value-of select="." />
                          </p>
                        </xsl:if>
                      </xsl:for-each>

                      <!-- Display notes on times funded -->
                      <xsl:for-each select="ecdrec:TimesOfFundedPlaces/ecdrec:Availability">
                        <xsl:if test="string-length(.) &gt; 0">
                          <p>
                            <span class="profileLabel">Notes on times of funded places: </span>
                            <xsl:value-of select="." />
                          </p>
                        </xsl:if>
                      </xsl:for-each>

                      <!-- List of broad opening periods of the service (usually spanning several weeks) -->
                      <xsl:if test="0 &lt; string-length(ecdrec:ChildcarePeriods/ecdrec:ChildcarePeriod)">
                        <p>
                          <span class="profileLabel">Broad opening periods: </span>
                        </p>
                        <xsl:for-each select="ecdrec:ChildcarePeriods/ecdrec:ChildcarePeriod">
                          <p>
                            <xsl:value-of select="." />
                          </p>
                        </xsl:for-each>
                      </xsl:if>
                    </xsl:when>

                    <!-- Display no details available -->
                    <xsl:otherwise>
                      <p>No details available.</p>
                    </xsl:otherwise>
                  </xsl:choose>
                </div>
              </div>

              <!-- Special provision Details tab -->
              <div id="moreDetails3">
                <xsl:attribute name="style">
                  <xsl:if test="'3' != $view">display: none</xsl:if>
                </xsl:attribute>
                <div id="provisionDetails" class="tabMain">
                  <h5>
                    <span class="sectionHead">Special provision</span>
                  </h5>

                  <!-- Full details about cultural provision by the service -->
                  <xsl:if test="0 &lt; string-length(ecdrec:SpecialProvisions/ecdrec:CulturalProvision)">
                    <p>
                      <span class="profileLabel">Cultural provision: </span>
                      <xsl:value-of select="ecdrec:SpecialProvisions/ecdrec:CulturalProvision" />
                    </p>
                  </xsl:if>

                  <!-- Details of any dietary provision in the provider record -->
                  <xsl:if test="ecdrec:SpecialProvisions/ecdrec:SpecialDiet/@HasProvision = '1' or ecdrec:SpecialProvisions/ecdrec:SpecialDiet/@HasProvision = 'true'">
                    <p>
                      <xsl:choose>
                        <xsl:when test="string-length(ecdrec:SpecialProvisions/ecdrec:SpecialDiet) &gt; 0">
                          <span class="profileLabel">Able to provide for special diets: </span>
                          <xsl:value-of select="ecdrec:SpecialProvisions/ecdrec:SpecialDiet" />
                        </xsl:when>
                        <xsl:otherwise>
                          Able to provide for special diets
                        </xsl:otherwise>
                      </xsl:choose>
                    </p>
                  </xsl:if>

                  <!-- Details of any Wheelchair access -->
                  <xsl:choose>
                    <xsl:when test="ecdrec:SpecialProvisions/ecdrec:WheelchairAccess/@HasProvision = '1' or ecdrec:SpecialProvisions/ecdrec:WheelchairAccess/@HasProvision = 'true'">
                      <p>
                        <xsl:choose>
                          <xsl:when test="string-length(ecdrec:SpecialProvisions/ecdrec:WheelchairAccess) &gt; 0">
                            <span class="profileLabel">Wheelchair access available: </span>
                            <xsl:value-of select="ecdrec:SpecialProvisions/ecdrec:WheelchairAccess" />
                          </xsl:when>
                          <xsl:otherwise>
                            Wheelchair access available
                          </xsl:otherwise>
                        </xsl:choose>
                      </p>
                    </xsl:when>
                    <xsl:otherwise>
                      <p>
                        Wheelchair access not available
                      </p>
                    </xsl:otherwise>
                  </xsl:choose>

                  <!-- Full details of any Special Needs provision listed in the provider record-->
                  <xsl:choose>
                    <xsl:when test="ecdrec:SpecialProvisions/ecdrec:SpecialNeeds/@HasProvision = '1' or ecdrec:SpecialProvisions/ecdrec:SpecialNeeds/@HasProvision = 'true'">
                      <xsl:if test="string-length(ecdrec:SpecialProvisions/ecdrec:SpecialNeeds/ecdrec:Experience &gt; 0)
                                       or string-length(ecdrec:SpecialProvisions/ecdrec:SpecialNeeds/ecdrec:Confidence &gt; 0)
                                       or string-length(ecdrec:SpecialProvisions/ecdrec:SpecialNeeds/ecdrec:Details &gt; 0)">
                        <p>
                          <span class="profileLabel">Some special needs catered for: </span>
                        </p>
                        <xsl:if test="0 &lt; string-length(ecdrec:SpecialProvisions/ecdrec:SpecialNeeds/ecdrec:Experience)">
                          <p>
                            Experience:
                            <xsl:value-of select="ecdrec:SpecialProvisions/ecdrec:SpecialNeeds/ecdrec:Experience" />
                            <xsl:text> </xsl:text>
                          </p>
                        </xsl:if>
                        <xsl:if test="0 &lt; string-length(ecdrec:SpecialProvisions/ecdrec:SpecialNeeds/ecdrec:Confidence)">
                          <p>
                            <span>Confidence: </span>
                            <xsl:value-of select="ecdrec:SpecialProvisions/ecdrec:SpecialNeeds/ecdrec:Confidence" />
                            <xsl:text> </xsl:text>
                          </p>
                        </xsl:if>
                        <xsl:if test="0 &lt; string-length(ecdrec:SpecialProvisions/ecdrec:SpecialNeeds/ecdrec:Details)">
                          <p>
                            <xsl:value-of select="ecdrec:SpecialProvisions/ecdrec:SpecialNeeds/ecdrec:Details" />
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

                  <!-- Show no details if not data for special needs provided -->
                  <xsl:if test="string-length(ecdrec:SpecialProvisions/ecdrec:CulturalProvision) = 0 
                          and (string-length(ecdrec:SpecialProvisions/ecdrec:SpecialDiet/@HasProvision) = 0 or ecdrec:SpecialProvisions/ecdrec:SpecialDiet/@HasProvision = '0' or ecdrec:SpecialProvisions=/ecdrec:SpecialDiet/@HasProvision = 'false')
                          and (string-length(ecdrec:SpecialProvisions/ecdrec:WheelchairAccess/@HasProvision) = 0 or ecdrec:SpecialProvisions/ecdrec:WheelchairAccess/@HasProvision = '0' or ecdrec:SpecialProvisions/ecdrec:WheelchairAccess/@HasProvision = 'false')
                          and (string-length(ecdrec:SpecialProvisions/ecdrec:SpecialNeeds/@HasProvision) = 0 or  ecdrec:SpecialProvisions/ecdrec:SpecialNeeds/@HasProvision = '0' or ecdrec:SpecialProvisions/ecdrec:SpecialNeeds/@HasProvision = 'false')">
                    <p>No details available.</p>
                  </xsl:if>

                </div>
              </div>

              <!-- Cost Details tab -->
              <div id="moreDetails4">
                <xsl:attribute name="style">
                  <xsl:if test="'4' != $view">display: none</xsl:if>
                </xsl:attribute>
                <div id="costDetails" class="tabMain">
                  <h5>
                    <span class="sectionHead">Costs</span>
                  </h5>

                  <!-- Details of any costs in the provider record -->
                  <xsl:if test="string-length(ecdrec:CostDetails/ecdrec:Costs) &gt; 0">
                    <p>
                      <span class="profileLabel">Main costs: </span>
                      <xsl:value-of select="ecdrec:CostDetails/ecdrec:Costs" />
                    </p>
                  </xsl:if>

                  <!-- Additional information about costs in the provider record -->
                  <xsl:if test="0 &lt; string-length(ecdrec:CostDetails/ecdrec:OtherCosts)">
                    <p>
                      <xsl:value-of select="ecdrec:CostDetails/ecdrec:OtherCosts" />
                    </p>
                  </xsl:if>

                  <!-- Display please contact this provider if flag is set -->
                  <xsl:if test="ecdrec:CostDetails/ecdrec:ContactForCosts = 'true' or ecdrec:CostDetails/ecdrec:ContactForCosts = '1'">
                    <p>Please contact this provider for details of costs.</p>
                  </xsl:if>

                  <!-- Show no information message if no details provided -->
                  <xsl:if test="string-length(ecdrec:CostDetails/ecdrec:Costs) = 0 
                          and string-length(ecdrec:CostDetails/ecdrec:OtherCosts) = 0
                          and (string-length(ecdrec:CostDetails/ecdrec:ContactForCosts) = 0 or ecdrec:CostDetails/ecdrec:ContactForCosts = 'false' or ecdrec:CostDetails/ecdrec:ContactForCosts = '0')">
                    <p>No cost information is currently available for this provider.</p>
                  </xsl:if>
                </div>
              </div>

              <!-- Pickup Details tab -->
              <div id="moreDetails5">
                <xsl:attribute name="style">
                  <xsl:if test="'5' != $view">display: none</xsl:if>
                </xsl:attribute>
                <div id="pickupDetails" class="tabMain">
                  <h5>
                    <span class="sectionHead">Pickup services</span>
                  </h5>

                  <!-- If the service indicates it does pickups, details appear here -->
                  <xsl:choose>

                    <!-- Dipslay pick is available if we have data for this -->
                    <xsl:when test="ecdrec:Pickups['true' = @HasProvision] or ecdrec:Pickups['1' = @HasProvision]">
                      <p>
                        <span class="profileLabel">Pickup service provided</span>
                      </p>
                      <xsl:if test="string-length(ecdrec:Pickups/ecdrec:SchoolList) &gt; 0">
                        <p>
                          <span class="profileLabel">Schools covered: </span>
                          <xsl:value-of select="ecdrec:Pickups/ecdrec:SchoolList" />
                        </p>
                      </xsl:if>
                      <!-- Show details if we have some -->
                      <xsl:if test="string-length(ecdrec:Pickups/ecdrec:Details) &gt; 0">
                        <p>
                          <xsl:value-of select="ecdrec:Pickups/ecdrec:Details" />
                        </p>
                      </xsl:if>
                    </xsl:when>

                    <!-- Show no pick up service -->
                    <xsl:otherwise>
                      <p>No pickup service on record.</p>
                    </xsl:otherwise>
                  </xsl:choose>
                </div>
              </div>

              <!-- Ofsted registration tab -->
              <div id="moreDetails6">
                <xsl:attribute name="style">
                  <xsl:if test="'6' != $view">display: none</xsl:if>
                </xsl:attribute>
                <div id="otherContactDetails" class="tabMain">
                  <h5>
                    <span class="sectionHead">Ofsted registration details</span>
                  </h5>

                  <!-- Displays total number of places registered -->
                  <xsl:if test="string-length(ecdrec:ChildcareAges/ecdrec:ChildnumberOverallLimit) &gt; 0">
                    <p>
                      <span class="sectionHead">Total number of places registered with Ofsted: </span>
                      <xsl:value-of select="ecdrec:ChildcareAges/ecdrec:ChildnumberOverallLimit" />
                    </p>
                  </xsl:if>

                  <!-- Places available in each age range -->
                  <xsl:if test="0 &lt; string-length(ecdrec:ChildcareAges/ecdrec:ChildcareAge)">
                    <p>
                      <span class="profileLabel">Registered places</span>
                    </p>
                    <xsl:for-each select="ecdrec:ChildcareAges/ecdrec:ChildcareAge">
                      <xsl:if test="string-length(ecdrec:ChildNumberLimit) &gt; 0">
                        <p>
                          <xsl:value-of select="ecdrec:AgeFrom" />&#160;-&#160;<xsl:value-of select="ecdrec:AgeTo" />&#160;years:&#160;<xsl:value-of select="ecdrec:ChildNumberLimit" />
                        </p>
                      </xsl:if>
                    </xsl:for-each>
                  </xsl:if>

                  <!-- Number of current vacancies -->
                  <xsl:if test="0 &lt; string-length(ecdrec:FutureVacancyDetails/ecdrec:TotalVacancies)">
                    <p>
                      <span class="profileLabel">Available places: Not known</span>
                      <!--
							<xsl:value-of select="ecdrec:FutureVacancyDetails/ecdrec:TotalVacancies" />
							-->
                    </p>
                  </xsl:if>

                  <!-- If the provider has specified to be contacted about vacancies -->
                  <xsl:if test="('true' = ecdrec:FutureVacancyDetails/ecdrec:ContactForVacancies) or ('1' = ecdrec:FutureVacancyDetails/ecdrec:ContactForVacancies)">
                    <p>Please contact this provider for full details of places and availability.</p>
                  </xsl:if>




                  <!-- Indicates if the childminder caters for over eights -->
                  <xsl:if test="string-length(ecdrec:CaterForOverEights) &gt; 0">
                    <p>This provider caters for children over eight years old.</p>
                  </xsl:if>

                  <!-- Displays the registration date -->
                  <xsl:if test="string-length(ecdrec:RegistrationDetails/ecdrec:RegistrationDate) &gt; 0">
                    <p>
                      <span class="profileLabel">Registration date: </span>
                      <xsl:call-template name="dateMaker">
                        <xsl:with-param name="DateTime" select="ecdrec:RegistrationDetails/ecdrec:RegistrationDate" />
                      </xsl:call-template>
                    </p>
                  </xsl:if>

                  <!-- Displays registration conditions -->
                  <xsl:if test="count(ecdrec:RegistrationDetails/ecdrec:RegistrationConditions/ecdrec:RegistrationCondition) &gt; 0">
                    <p>
                      <span class="profileLabel">Registration conditions: </span>
                      <xsl:for-each select="ecdrec:RegistrationDetails/ecdrec:RegistrationConditions/ecdrec:RegistrationCondition">
                        <xsl:value-of select="." />
                        <xsl:if test="position() != count(../ecdrec:RegistrationCondition)">
                          <xsl:text>, </xsl:text>
                        </xsl:if>
                      </xsl:for-each>
                    </p>
                  </xsl:if>

                  <!-- Displays the registration status -->
                  <xsl:if test="string-length(ecdrec:RegistrationDetails/ecdrec:RegistrationStatus/ecdrec:RegistrationStatus) &gt; 0">
                    <p>
                      <span class="profileLabel">Registration status: </span>
                      <xsl:value-of select="ecdrec:RegistrationDetails/ecdrec:RegistrationStatus/ecdrec:RegistrationStatus" />
                    </p>
                  </xsl:if>

                  <!-- Displays the suspension detail -->
                  <xsl:if test="string-length(ecdrec:RegistrationDetails/ecdrec:RegistrationSuspensionDetail) &gt; 0">
                    <p>
                      <span class="profileLabel">Registration suspension detail: </span>
                      <xsl:value-of select="ecdrec:RegistrationDetails/ecdrec:RegistrationSuspensionDetail" />
                    </p>
                  </xsl:if>

                  <!-- Displays cancellation details -->
                  <xsl:if test="string-length(ecdrec:RegistrationDetails/ecdrec:RegistrationCancellationDetails) &gt; 0">
                    <p>
                      <span class="profileLabel">Registration cancellation details: </span>
                      <xsl:value-of select="ecdrec:RegistrationDetails/ecdrec:RegistrationCancellationDetails" />
                    </p>
                  </xsl:if>

                  <!-- Display registration status start date -->
                  <xsl:if test="string-length(ecdrec:RegistrationDetails/ecdrec:RegistrationStatus/ecdrec:RegistrationStatusStartDate) &gt; 0">
                    <p>
                      <span class="profileLabel">Registration status start date: </span>
                      <xsl:call-template name="dateMaker">
                        <xsl:with-param name="DateTime" select="ecdrec:RegistrationDetails/ecdrec:RegistrationStatus/ecdrec:RegistrationStatusStartDate" />
                      </xsl:call-template>
                    </p>
                  </xsl:if>

                  <!-- Display registration exempt -->
                  <xsl:if test="ecdrec:RegistrationExempt='1' or ecdrec:RegistrationExempt='true'">
                    <p>
                      Registration exempt
                    </p>
                  </xsl:if>

                  <!-- Display last inspection date -->
                  <p>
                    <span class="profileLabel">Last inspection: </span>
                    <xsl:if test="string-length(ecdrec:RegistrationDetails/ecdrec:LastInspection/ecdrec:InspectionDate) &gt; 0">
                      <xsl:call-template name="dateMaker">
                        <xsl:with-param name="DateTime" select="ecdrec:RegistrationDetails/ecdrec:LastInspection/ecdrec:InspectionDate" />
                      </xsl:call-template>
                    </xsl:if>
                  </p>

                  <!-- Display the inspection type -->
                  <xsl:if test="string-length(ecdrec:RegistrationDetails/ecdrec:LastInspection/ecdrec:InspectionType) &gt; 0">
                    <p>
                      <span class="profileLabel">Inspection type: </span>
                      <xsl:value-of select="ecdrec:RegistrationDetails/ecdrec:LastInspection/ecdrec:InspectionType" />
                    </p>
                  </xsl:if>

                  <!-- Display the judgement -->
                  <p>
                    <span class="profileLabel">Inspection judgment: </span>
                    <xsl:if test="ecdrec:RegistrationDetails/ecdrec:LastInspection/ecdrec:InspectionOverallJudgementDescription">
                      <xsl:value-of select="ecdrec:RegistrationDetails/ecdrec:LastInspection/ecdrec:InspectionOverallJudgementDescription" />
                    </xsl:if>
                  </p>
                </div>
              </div>

              <!-- Other Details tab -->
              <div id="moreDetails7">
                <xsl:attribute name="style">
                  <xsl:if test="'7' != $view">display: none</xsl:if>
                </xsl:attribute>
                <div id="otherDetails" class="tabMain">
                  <h5>
                    <span class="sectionHead">Other Details</span>
                  </h5>

                  <!-- Display the quality assurance items -->
                  <xsl:if test="count(ecdrec:QualityAssurance/ecdrec:QualityLevel) &gt; 0">
                    <p>
                      <span class="profileLabel">Quality assurance: </span>
                      <xsl:for-each select="ecdrec:QualityAssurance/ecdrec:QualityLevel">
                        <xsl:value-of select="ecdrec:QualityStatus" />
                        <xsl:if test="string-length(ecdrec:QualityStatusChangeDate) &gt; 0">
                          <xsl:text> </xsl:text>
                          <xsl:call-template name="dateMaker">
                            <xsl:with-param name="DateTime" select="ecdrec:QualityStatusChangeDate" />
                          </xsl:call-template>
                        </xsl:if>
                        <xsl:if test="string-length(ecdrec:Details) &gt; 0">
                          <xsl:text> </xsl:text>
                          <xsl:value-of select="ecdrec:Details"/>
                        </xsl:if>
                        <xsl:if test="position() != count(../ecdrec:QualityLevel)">
                          <xsl:text>, </xsl:text>
                        </xsl:if>
                      </xsl:for-each>
                    </p>                    
                  </xsl:if>

                  <!-- Displays info about any quality awards the service has won, if present -->
                  <xsl:if test="0 &lt; string-length(ecdrec:QualityAwards)">
                    <p>
                      <span class="profileLabel">Quality awards: </span>
                      <xsl:value-of select="ecdrec:QualityAwards" />
                    </p>
                  </xsl:if>

                  <!-- Displays info about the facilities of the service, if present -->
                  <xsl:if test="0 &lt; string-length(ecdrec:Facilities)">
                    <p>
                      <span class="profileLabel">Extra facilities: </span>
                      <xsl:value-of select="ecdrec:Facilities" />
                    </p>
                  </xsl:if>

                  <!-- Displays any other details about the service, if present -->
                  <xsl:if test="0 &lt; string-length(ecdrec:OtherInformation)">
                    <p>
                      <span class="profileLabel">Other details: </span>
                      <xsl:value-of select="ecdrec:OtherInformation" />
                    </p>
                  </xsl:if>

                  <!-- Display a lsit of tags if present -->
                  <xsl:if test="count(../ecdrec:DC.Subject) &gt; 0">
                    <p>
                      <span class="profileLabel">Tags: </span>
                      <xsl:for-each select="../ecdrec:DC.Subject">
                        <xsl:value-of select="." />
                        <xsl:if test="position() != count(../ecdrec:DC.Subject)">
                          <xsl:text>, </xsl:text>
                        </xsl:if>
                      </xsl:for-each>
                    </p>
                  </xsl:if>

                  <!-- Display keywords if present -->
                  <xsl:if test="string-length(ecdrec:Keyword) &gt; 0">
                    <p>

                      <xsl:choose>
                        <xsl:when test="count(../ecdrec:DC.Subject) &gt; 0">
                          <span class="profileLabel">Keywords: </span>
                        </xsl:when>
                        <xsl:otherwise>
                          <span class="profileLabel">Other keywords: </span>
                        </xsl:otherwise>
                      </xsl:choose>
                      <xsl:value-of select="ecdrec:Keyword"/>
                    </p>

                  </xsl:if>

                  <xsl:choose>
                    <xsl:when test="ecdrec:ContactDetails = (*)">
                      <h5>
                        <span class="sectionHead">Additional contacts</span>
                      </h5>

                      <xsl:for-each select="ecdrec:ContactDetails">

                        <!-- Display the name of the contact -->
                        <p>
                          <span class="profileLabel">Name: </span>
                          <xsl:value-of select="ecdrec:ContactName" />
                        </p>


                        <!-- Display the postal address(es) of the contact, if present, and if the provider has not withheld them -->
                        <p>
                          <span class="profileLabel">Address: </span>
                          <xsl:choose>
                            <xsl:when test="'true' = ../ecdrec:ConsentVisibleAddress or '1' = ../ecdrec:ConsentVisibleAddress">
                              <span class="address">
                                <xsl:apply-templates select="ecdrec:PostalAddress" mode="fullAddress" />
                              </span>
                            </xsl:when>
                            <xsl:otherwise>
                              <i>This provider has elected to have their exact physical address withheld from the listings.</i>
                            </xsl:otherwise>
                          </xsl:choose>
                        </p>

                        <!-- Display the telephone number(s) of the contact, if present -->
                        <xsl:for-each select="ecdrec:TelephoneNumber">
                          <xsl:choose>
                            <xsl:when test="0 &lt; string-length(.)">
                              <xsl:apply-templates select="." />
                            </xsl:when>
                            <xsl:otherwise>Telephone:</xsl:otherwise>
                            <!--No telephone number but add label-->
                          </xsl:choose>
                        </xsl:for-each>

                        <!-- Display the fax number(s) of the contact, if present -->
                        <xsl:for-each select="ecdrec:FaxNumber">
                          <xsl:if test="0 &lt; string-length(.)">
                            <xsl:apply-templates select="." />
                          </xsl:if>
                        </xsl:for-each>

                        <!-- Display the email address(es) of the contact, if present -->
                        <xsl:for-each select="ecdrec:EmailAddress">
                          <xsl:if test="0 &lt; string-length(.)">
                            <xsl:apply-templates select="." />
                          </xsl:if>
                        </xsl:for-each>

                        <!-- Display website address(es) of the contact, if present -->
                        <xsl:for-each select="ecdrec:WebsiteAddress">
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
              <xsl:if test="('yes' = $showMap) and (0 &lt; string-length(/ecdrec:ProviderDescription/echoedData/centrePoint/@lat)) and (0 &lt; string-length(/ecdrec:ProviderDescription/echoedData/centrePoint/@lng))">
                <div id="moreDetails8">
                  <xsl:attribute name="style">
                    <xsl:if test="'8' != $view">display: none</xsl:if>
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
          <xsl:if test="0 &lt; string-length(../echoedData/srw:records/srw:record)">
            <!-- Additional information box -->
            <div class="seeAlso sidebar">
              <div class="seeAlsoTitle">
                <div class="seeAlsoTitle2">
                  <h2>You may also be interested in</h2>
                </div>
              </div>
              <div class="seeAlsoContents clear">
                <ul>
                  <xsl:for-each select="../echoedData/srw:records/srw:record">
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
              <p class="icons">
                <img src="{$imagesFolder}vac.png" alt="Current vacancies" title="Current vacancies" /> Current vacancies
              </p>
              <p class="icons">
                <img src="{$imagesFolder}pickup.png" alt="Pickup service available" title="Pickup service available" /> Pickup service available
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