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

  <xsl:variable name="catList" select="/srw:searchRetrieveResponse/controlledListData/fullCatsList/topTerms" />
  <xsl:variable name="refList" select="/srw:searchRetrieveResponse/controlledListData/referralList/topTerms" />
  <xsl:variable name="accList" select="/srw:searchRetrieveResponse/controlledListData/accessChannelsList/topTerms" />
  <xsl:variable name="lanList" select="/srw:searchRetrieveResponse/controlledListData/langList/topTerms" />

  <xsl:variable name="listCounts" select="/srw:searchRetrieveResponse/srw:extraResponseData/facet:lst['facet_counts'=@name]/facet:lst['facet_fields'=@name]" />
  <xsl:variable name="catCounts" select="$listCounts/facet:lst['dc.subject'=@name]" />
  <xsl:variable name="refCounts" select="$listCounts/facet:lst['referral_criteria_s'=@name]" />
  <xsl:variable name="accCounts" select="$listCounts/facet:lst['mode_of_access_s'=@name]" />
  <xsl:variable name="lanCounts" select="$listCounts/facet:lst['language_spoken_s'=@name]" />
  
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
							<li id="top1">
								<a href="{$directoryPage}">Directory</a>
							</li>
							<li id="top2">
								<a href="{$indexPage}">Subject Index</a>
							</li>
						</ul>
					</div>
				</div>
				<!-- End title div -->

				<div id="advanced">

					<div id="advancedHeader" class="headerPane">
						<h1>
							<i>find-it</i> Search
						</h1>
						<br />
						<p class="infoText">
							You can use this page to search for services.<br />
							You do not have to fill in all of the boxes,<br />
							but the more you do fill in, the more specific your results will be.<br />
							When entering a location you can enter a town, an area, a postcode (either whole or part)<br />
              or latitude and longitude (use decimal latitude and longitude separated by a comma, example 52.966,-1.016<br />
							to search within the specified number of miles (the default is 5 miles).
						</p>
						<div id="formErrorHelp">
							<p>
								Please fill in <i>at least one</i> of the items marked with an asterisk (*)
							</p>
						</div>
					</div>

					<div id="advancedList" class="lowerPane">



						<form id="advSearchForm" name="advSearchForm" action="{$advsearchPage}">
							<fieldset>

								<div id="formHeader">
									<legend>Find services that..</legend>
								</div>
								
								<!-- S09:  Code required for service search tool start -->
                  <div class="advSearchDiv">
					  <label for="searchTerms">contains these words</label>:
                      <input type="text" id="searchTerms" name="title" maxlength="150" accesskey="3">
                      <xsl:attribute name="value">
                        <xsl:value-of select="/srw:searchRetrieveResponse/echoedData/queryString/@title"/>
                      </xsl:attribute>
                    </input>
                  </div>
								
                  <!-- S09:  Code required for service search tool end -->

                  <!-- S02:  Code required for category browse tool start -->
                  <div class="advSearchDiv">
                    <span class="description">
                      are in this <label for="categoryList">category: *</label>
                    </span>
                    <!-- create a select list of (top-level) categories -->
                    <select name="category" id="categoryList">
                      <!-- a 'null' option, which transmits no value, so users can 'undo' selecting a category -->
                      <option id="nocatOption" value="">Please select a category</option>
                      <xsl:for-each select="$catList/term">
                        <!-- sort the list alphabetically -->
                        <xsl:sort select="name" />
                        <option value="{identifier}">
                          <xsl:if test="/srw:searchRetrieveResponse/echoedData/queryString/@category = identifier">
                            <xsl:attribute name="selected" />
                          </xsl:if>
                          <xsl:value-of select="name" />
                        </option>
                      </xsl:for-each>
                    </select>&#160;
                    <!-- input button to select subcategory -->
                    <input type="submit" id="selectSubcat" name="target" value="Select Subcategory" />
                    <!-- subcategory div - holds all subcategory select lists -->
                    <div id="advSearchSubcat" class="advSearchDiv">
                      <xsl:if test="0 = count(/srw:searchRetrieveResponse/echoedData/queryString/@*)"><xsl:attribute name="style">display: none;</xsl:attribute></xsl:if>
                      <span class="description">
                        and this <label for="subcategory">subcategory:</label>
                      </span>
                      <select id="subcat-zero" name="subcategory" class="subcatList">
                        <xsl:if test="/srw:searchRetrieveResponse/echoedData/queryString/@category != ''">
                          <xsl:attribute name="style">display: none;</xsl:attribute>
                          <xsl:attribute name="disabled">true</xsl:attribute>
                        </xsl:if>
                        <option value="" class="noSubcatOption">(none)</option>
                      </select>
                      <!--for each top-level category, create a select list of (2nd-level) subcategories-->
                      <xsl:for-each select="$catList/term">
                        <!-- add the category code to the id of the subcategory list-->
                        <div id="subcat-{identifier}">
                          <xsl:if test="/srw:searchRetrieveResponse/echoedData/queryString/@category != identifier">
                            <xsl:attribute name="style">display: none;</xsl:attribute>
                          </xsl:if>
                          <select name="subcategory" class="subcatList">
                            <xsl:if test="0 = count(/srw:searchRetrieveResponse/echoedData/queryString/@*) or /srw:searchRetrieveResponse/echoedData/queryString/@category != identifier">
                              <xsl:attribute name="disabled">true</xsl:attribute>
                            </xsl:if>
                            <!--each list has a 'null' option, which transmits no value, so users can 'undo' selecting a subcategory-->
                            <option value="" class="noSubcatOption">(none)</option>
                            <!--create an option in the list for each subcategory (child term of the category)-->
                            <xsl:for-each select="termChildren/term">
                              <option value="{identifier}">
                                <xsl:value-of select="concat(name, ' (', normalize-space(occurence), ')')"/>
                              </option>
                            </xsl:for-each>
                          </select>
                        </div>
                      </xsl:for-each>
                    </div>
                  </div>
                  <!-- S02:  Code required for category browse tool end -->

                  <!-- L01: Code required for Location filter / broadening tool start -->
                  <div class="advSearchDiv">
					  that are 
					  <label for="location">
						close to 
						<span class="note">(enter a town, area, postcode or co-ordinates) </span>
					  </label>
					  <input type="text" id="location" name="location" maxlength="100">
						  <xsl:attribute name="value">
							  <xsl:value-of select="/srw:searchRetrieveResponse/echoedData/queryString/@location"/>
						  </xsl:attribute>
					  </input>&#160;
					  (<label for="filterDist">
					  Maximum distance in miles
					  </label>)
					  <input type="text" id="filterDist" name="filterDist" class="number" maxlength="6">
						  <xsl:attribute name="value">
							  <xsl:value-of select="/srw:searchRetrieveResponse/echoedData/queryString/@filterDist"/>
						  </xsl:attribute>
					  </input> 
                    <a class="helpIcon" href="#">
                      <img src="{$imagesFolder}i.gif" alt="Help. You can enter a town, an area or a postcode (either whole or part) to search within the specified number of miles (the default is 5 miles)." />
                      <span id="helpPopup1" class="helpPopup">
                        <span>
                          You can enter a town, an area or a postcode (either whole or part) to search within the specified number of miles (the default is 5 miles).<br />
                        </span>
                      </span>
                    </a>
                  </div>

                  <div id="nationwide" class="advSearchDiv">
					  
					  <label for="national">include nationwide services</label>?
					  <input class="national" id="national"  type="checkbox" name="national">
						  <xsl:choose>
							  <xsl:when test="'off'=/srw:searchRetrieveResponse/echoedData/queryString/@xnational and 0 = string-length(/srw:searchRetrieveResponse/echoedData/queryString/@national)">
								  <xsl:attribute name="unchecked" />
							  </xsl:when>
							  <xsl:otherwise>
								  <xsl:attribute name="checked" />
							  </xsl:otherwise>
						  </xsl:choose>
					  </input>
					  
                  </div>
                  <!-- L01: Code required for Location filter / broadening tool end -->

                  <p>
                    <a name="advancedOpts">&#160;</a>
                  </p>
                  <p class="description">
                    <a class="showHideLink" id="moreOptionsLink" href="#advancedOpts">
                      <img id="moreOptsArrow" src="{$imagesFolder}circle-trans-down.gif" alt="More options" />&#160;<span>More Options</span>
                    </a>
                  </p>

                  <div id="moreOptions1">

                    <!-- S08:  Code required for disability/special needs specification tool start -->
                    <div id="provision" class="advSearchDiv">
						which have:
						<ul class="alignedList lineup"
						id="provisionList">
							<li>
								<label for="wheelchairAccess">
									<span class="screenreader-only">have </span>
									wheelchair access *
								</label>
							<input type="checkbox" id="wheelchairAccess" name="wheelchairAccess">
								<xsl:if test="'on'=/srw:searchRetrieveResponse/echoedData/queryString/@wheelchairAccess">
									<xsl:attribute name="checked" />
								</xsl:if>
							</input>&#160;                        
						</li>
                        <li>
						  <label for="specialNeeds">
						    <span class="screenreader-only">supports </span>
								special	needs
							</label>
                          <input type="checkbox" id="specialNeeds" name="specialNeeds">
                            <xsl:if test="'on'=/srw:searchRetrieveResponse/echoedData/queryString/@specialNeeds">
                              <xsl:attribute name="checked" />
                            </xsl:if>
                          </input>&#160;
                        </li>
                      </ul>
                    </div>
                    <!-- S08:  Code required for disability/special needs specification tool end -->

                    <!-- S03:  Code required for age range selection tool start -->
                    <div class="advSearchDiv">
						<label for="ageRanges">are suitable for age range</label>:
                      <select id="ageRanges" name="filters">
                        <option value="" selected="selected">Select an age range</option>
                        <option value="yrs0-1">0 - 1 year</option>
                        <option value="yrs1-4">1 - 4 year</option>
                        <option value="yrs5-10">5 - 10 year</option>
                        <option value="yrs10-18">10 - 18 year</option>
                        <option value="yrs18-25">18 - 25 year</option>
                      </select>
                    </div>
                    <!-- S03:  Code required for age range selection tool end -->

                    <!-- S04:  Code required for eligibility criteria selection tool start -->
                    <div class="advSearchDiv">
                      <span class="description">
                        specify the following <label for="eligibilityCriteria">criteria for eligibility: *</label>
                      </span>
                      <input type="text" id="eligibilityCriteria" name="eligibilityCriteria">
                        <xsl:attribute name="value">
                          <xsl:value-of select="/srw:searchRetrieveResponse/echoedData/queryString/@eligibilityCriteria"/>
                        </xsl:attribute>
                      </input>
                    </div>
                    <!-- S04:  Code required for eligibility criteria selection tool end -->
                    
                    <!-- S05:  Code required for referral criteria selection tool start -->
                    <div class="advSearchDiv">
                      <span class="description">
                        specify the following <label for="referralCriteria">criteria for referral: *</label>
                      </span>
                      <select id="referralCriteria" name="referralCriteria">
                        <option value="" selected="selected">Please select</option>
                        <xsl:for-each select="$refList/term[identifier=$refCounts/facet:int/@*]">
                          <xsl:sort select="name" />
                          <option value="ref{identifier}">
                            <xsl:if test="/srw:searchRetrieveResponse/echoedData/queryString/@referralCriteria = identifier">
                              <xsl:attribute name="selected" />
                            </xsl:if>
                            <xsl:value-of select="concat(name, ' (', normalize-space($refCounts/facet:int[@name=current()/identifier]), ')')" />
                          </option>
                        </xsl:for-each>
                      </select>
                    </div>
                    <!-- S05:  Code required for referral criteria selection tool end -->
                    
                    <!-- S06:  Code required for access channel selection tool start -->
                    <div class="advSearchDiv">
                      <span class="description">
                        are <label for="accessChannel">accessed via: *</label>
                      </span>
                      <select id="accessChannel" name="accessChannel">
                        <option value="" selected="selected">Please select</option>
                        <xsl:for-each select="$accList/term[identifier=$accCounts/facet:int/@*]">
                          <xsl:sort select="name" />
                          <option value="acc{identifier}">
                            <xsl:if test="/srw:searchRetrieveResponse/echoedData/queryString/@accessChannel = identifier">
                              <xsl:attribute name="selected" />
                            </xsl:if>
                            <xsl:value-of select="concat(name, ' (', normalize-space($accCounts/facet:int[@name=current()/identifier]), ')')" />
                          </option>
                        </xsl:for-each>
                      </select>
                    </div>
                    <!-- S06:  Code required for access channel selection tool end -->
                    
                    <!-- S07:  Code required for language selection tool start -->
                    <div class="advSearchDiv">
                      <span class="description">
                        can <label for="language">speak the following language: *</label>
                      </span>
                      <select id="language" name="language">
                        <option value="" selected="selected">Please select</option>
                        <xsl:for-each select="$lanList/term[identifier=$lanCounts/facet:int/@*]">
                          <xsl:sort select="name" />
                          <option value="lan{identifier}">
                            <xsl:if test="/srw:searchRetrieveResponse/echoedData/queryString/@language = identifier">
                              <xsl:attribute name="selected" />
                            </xsl:if>
                            <xsl:value-of select="concat(name, ' (', normalize-space($lanCounts/facet:int[@name=current()/identifier]), ')')" />
                          </option>
                        </xsl:for-each>
                      </select>
                    </div>
                    <!-- S07:  Code required for language selection tool end -->

                  </div> <!-- end More Options section -->

                  <div id="searchCluster">
                    <input type="submit" id="advSearchButton" name="target" value="Search" Title="Perform Advanced Search" />
                  </div>

                  <div class="clear">&#160;</div>

							</fieldset>
						</form>

					</div>

            </div>

          </div>
	
	</div>
	</div>
		

</xsl:template>

</xsl:stylesheet>